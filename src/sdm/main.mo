//  ----------- Decription
//  This Motoko file contains the logic of the backend canister.

//  ----------- Imports

//  Imports from Motoko Base Library
import Array        "mo:base/Array";
import Bool         "mo:base/Bool";
import Blob         "mo:base/Blob";
import Buffer       "mo:base/Buffer";
import Hash         "mo:base/Hash";
import Int          "mo:base/Int";
import Iter         "mo:base/Iter";
import Nat          "mo:base/Nat";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";
import Option       "mo:base/Option";
import Principal    "mo:base/Principal";
import Text         "mo:base/Text";
import Time         "mo:base/Time";
import TrieMap      "mo:base/TrieMap";

//  Imports from helpers, utils, & types
import Account      "lib/Account";
import AES          "lib/AES";
import Hex          "lib/Hex";
import T            "types";
import Helpers      "helpers";

//  Imports from external interfaces


shared actor class SDM() = this {

  //  ----------- Variables
  private stable var tag_total : Nat = 0;
  private stable var tagIntegration_total : Nat = 0;
  let internet_identity_principal_isaac : Principal = Principal.fromText("gvi7s-tbk2k-4qba4-mw6qj-azomr-rrwex-byyqb-icyrn-eygs4-nrmm5-eae");
  var admins : [Principal] = [internet_identity_principal_isaac]; 

  //  ----------- State
  private stable var tagsEntries : [(T.TagUid, T.Tag)] = [];
  private stable var integratorsEntries : [(Principal, T.Integrator)] = [];
  private stable var integrationsEntries : [(T.TagIdentifier, T.Integration)] = [];

  private let tags : TrieMap.TrieMap<T.TagUid, T.Tag> = TrieMap.fromEntries<T.TagUid, T.Tag>(tagsEntries.vals(), Text.equal, Text.hash);
  private let integrators : TrieMap.TrieMap<Principal, T.Integrator> = TrieMap.fromEntries<Principal, T.Integrator>(integratorsEntries.vals(), Principal.equal, Principal.hash);
  private let integrations : TrieMap.TrieMap<T.TagIdentifier, T.Integration> = TrieMap.fromEntries<T.TagIdentifier, T.Integration>(integrationsEntries.vals(), Text.equal, Text.hash);

  //  ----------- Configure external actors


  //  ----------- Public functions

  //  Encoding
  public shared({ caller }) func registerTag(uid : T.TagUid) : async T.TagEncodeResult {
    assert _isAdmin(caller);
    assert not _tag_exists(uid);

    tag_total += 1;
    await _registerTag(uid);
  };

  public shared({ caller }) func importCMACs(
    uid : T.TagUid, 
    data : [Hex.Hex]
    ) {
      assert(_isAdmin(caller));

      _addCMACs(uid, data);
  };

  public shared({ caller }) func isAdmin() : async Bool {
    if (_isAdmin(caller)) {
      return true;
    };
    return false;
  };

  //  Scan
  public shared({ caller }) func scan(scan : T.Scan) : async T.ScanResult {
    _scan(caller, scan);
  };

  //  Access integration
  public shared({ caller }) func requestAccess(
    uid : T.TagUid, 
    canister : Principal
    ) : async T.AESKey {
    assert _isOwner(caller, uid);

    await _generateAccessCode(uid, canister);
  };

  //  Integrators
  public shared({ caller }) func registerIntegrator(integrator : T.NewIntegrator) {
    _addIntegrator(caller, integrator);
  };

  public shared({ caller }) func validateAccess(request : T.ValidationRequest) : async T.ValidationResult {
    _validateAccess(caller, request);
  };

  public shared({ caller }) func tagInfo(tagIdentifier : T.TagIdentifier) : async T.TagInfoResult {
    _getTagInfo(caller, tagIdentifier);
  };

  //  Unlocking
  public shared({ caller }) func unlock(uid : T.TagUid) : async T.UnlockResult {
    assert _isOwner(caller, uid);

    await _generateTransferCode(uid, canister);
  };

  //  Adding New Integration
  public shared({ caller }) func newIntegration(
    uid : T.TagUid, 
    canister : Principal
    ) : async T.NewIntegrationResult {

  };

  //  ----------- Directly called private functions
  private func _registerTag(owner : Principal, uid : T.TagUid) : async T.TagEncodeResult {
    assert not _tag_exists(uid);

    let tag_secrets : T.TagSecrets = {
      key = await Helpers.generateKey();
      ctr = 0 : Nat32;
      transfer_code = await Helpers.generateKey();
    };
    let tag_wallet : Account.AccountIdentifier = Helpers.getUidWallet(Principal.fromActor(this), uid);

    _addTagToBalance(owner, uid);
    owners.put(uid, owner);        
    tagSecrets.put(uid, tag_secrets);
    tagWallets.put(uid, tag_wallet);

    let result = {
      key = tag_secrets.key;
      transfer_code = tag_secrets.transfer_code;
    };

    return result;
  };

  private func _scan(p : Principal, scan : T.Scan) : T.ScanResult {
      switch (tagSecrets.get(scan.uid)) {
        case (?secrets) {

          switch (tagCMACs.get(scan.uid)) {
            case (?validCmacList) {

              if ( Bool.logand(validCmacList[Nat32.toNat(scan.ctr)] == scan.cmac, scan.ctr > secrets.ctr)) {

                switch (tagWallets.get(scan.uid)) {
                  case (?wallet) {

                    switch (owners.get(scan.uid)) {
                      case (?owner) {
                        let isValidTransferCode = secrets.transfer_code == scan.transfer_code;

                        if (owner == p) {
                          // They are the current owner (transfer code change?)
                          let updated_secrets = {
                            key = secrets.key;
                            ctr = scan.ctr;
                            transfer_code = secrets.transfer_code;
                          };
                          tagSecrets.put(scan.uid, updated_secrets);

                          #Ok({
                            owner = true;
                            locked = Bool.lognot(isValidTransferCode);
                            transfer_code = ?secrets.transfer_code;
                            wallet = wallet;
                          });

                        } else if (isValidTransferCode) {
                          // They are new owner
                          let new_transfer_code = await Helpers.generateKey();
                          let updated_secrets = {
                            key = secrets.key;
                            ctr = scan.ctr;
                            transfer_code = new_transfer_code;
                          };
                          tagSecrets.put(scan.uid, updated_secrets);
                          _removeTagFromBalance(owner, scan.uid);
                          _addTagToBalance(p, scan.uid);
                          owners.put(scan.uid, p);

                          #Ok({
                            owner = true;
                            locked = true;
                            transfer_code = ?new_transfer_code;
                            wallet = wallet;
                          });
                          
                        } else {
                          // read only
                          let updated_secrets = {
                            key = secrets.key;
                            ctr = scan.ctr;
                            transfer_code = secrets.transfer_code;
                          };
                          tagSecrets.put(scan.uid, updated_secrets);

                          #Ok({
                            owner = false;
                            locked = true;
                            transfer_code = null;
                            wallet = wallet;
                          });
                        };
                      };

                      case _ {
                        #Err({
                          msg = "Could not find tag owner.";
                        });
                      };
                    };
                  };

                  case _ {
                    #Err({
                      msg = "Could not find tag wallet.";
                    });
                  };
                };

              } else {
                #Err({
                  msg = "CMAC not valid or already used previously.";
                });
              }
            };

            case _ {
              #Err({
                msg = "CMAC not found.";
              });
            };
          };
        };

        case _ {
          #Err({
            msg = "This tag is not recognized.";
          });
        };
      };
  };
  
  //  ----------- Additions to state functions


  //  ----------- Boolean functions
  private func _tag_exists(uid : T.TagUid) : Bool {
    return Option.isSome(owners.get(uid));
  };

  private func _isAdmin (p: Principal) : Bool {
    return(Helpers.contains<Principal>(admins, p, Principal.equal))
  };

  private func _isOwner(uid : T.TagUid, p : Principal) : Bool {

    switch (owners.get(uid)) {
      case (?v) {
        return v == p;
      };

      case _ {
        return false;
      };
    };
  };

  private func _isLocked(uid : T.TagUid, current_transfer_code : T.AESKey) : Bool {

    switch (tagSecrets.get(uid)) {
      case (?secrets) {
        if (current_transfer_code == secrets.transfer_code) {
          return false;
        } else {
          return true;
        }
      };

      case _ {
        return true;
      };
    };
  };

  //  ----------- System functions
  system func preupgrade() {
    tagsEntries := Iter.toArray(tags.entries());
    integratorsEntries := Iter.toArray(integrators.entries());
    tagIntegrationsEntries := Iter.toArray(tagIntegrations.entries());
  };

  system func postupgrade() {
    tagsEntries := [];
    integratorsEntries := [];
    tagIntegrationsEntries := [];
  };
};