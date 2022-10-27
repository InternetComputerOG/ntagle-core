//  ----------- Decription
//  This Motoko file contains the logic of the backend canister.

//  ----------- Imports

//  Imports from Motoko Base Library
import Array        "mo:base/Array";
import Bool         "mo:base/Bool";
import Blob         "mo:base/Blob";
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
import LT           "../ledger/ledger";

shared actor class SDM() = this {
  let key = Array.freeze<Nat8>(Array.init(16, 0 : Nat8));
  let buffer = Array.freeze<Nat8>(Array.init(8, 0 : Nat8));
  let key1 = Blob.toArray(Text.encodeUtf8("0000000000000000"));
  let prefix : [Nat8] = [0x3C : Nat8, 0xC3 : Nat8, 0x00 : Nat8 , 0x01 : Nat8, 0x00 : Nat8, 0x80 : Nat8];
  
  public shared query (msg) func whoami() : async Principal {
    msg.caller;
  };

  public shared query func reflect(param : T.TagParam) : async T.TagParam {
    param;
  };

  public shared query func decrypt(param : T.TagParam) : async [Nat8] {
    let block = AES.new(key);

    switch (block) {
      case (?block) {
        block.decrypt(Array.append(Blob.toArray(param.cmac), buffer));
      };
      case _ {[0]}
    };
  };

  public shared query func text_to_array(param : T.TagParam) : async [Nat8] {
    Blob.toArray(param.cmac);
  };

  public shared query func show_key() : async [Nat8] {
    key;
  };

  public shared query func encrypt(param : T.TagParam) : async Blob {
    let block = AES.new(key);

    var digest = Array.append(Array.append(Blob.toArray(param.ctr),Blob.toArray(param.uid)), prefix);
    //digest := Array.append(digest, Array.freeze<Nat8>(Array.init(16 - digest.size(), 0 : Nat8)));

    switch (block) {
      case (?block) {
        Blob.fromArray(block.encrypt(digest));
      };
      case _ {Blob.fromArray([0]);}
    };
  };

  ///////////////////////////////////////////////////////////////

  private stable var tag_total : Nat = 0;
  let internet_identity_principal_isaac : Principal = Principal.fromText("gvi7s-tbk2k-4qba4-mw6qj-azomr-rrwex-byyqb-icyrn-eygs4-nrmm5-eae");
  var admins : [Principal] = [internet_identity_principal_isaac]; 

  private stable var ownersEntries : [(T.TagUid, Principal)] = [];
  private stable var balancesEntries : [(Principal, [T.TagUid])] = [];
  private stable var tagSecretsEntries : [(T.TagUid, T.TagSecrets)] = [];
  private stable var tagWalletsEntries : [(T.TagUid, Account.AccountIdentifier)] = [];
  private stable var tagCMACsEntries : [(T.TagUid, [Hex.Hex])] = [];

  private let owners : TrieMap.TrieMap<T.TagUid, Principal> = TrieMap.fromEntries<T.TagUid, Principal>(ownersEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let balances : TrieMap.TrieMap<Principal, [T.TagUid]> = TrieMap.fromEntries<Principal, [T.TagUid]>(balancesEntries.vals(), Principal.equal, Principal.hash);
  private let tagSecrets : TrieMap.TrieMap<T.TagUid, T.TagSecrets> = TrieMap.fromEntries<T.TagUid, T.TagSecrets>(tagSecretsEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let tagWallets : TrieMap.TrieMap<T.TagUid, Account.AccountIdentifier> = TrieMap.fromEntries<T.TagUid, Account.AccountIdentifier>(tagWalletsEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let tagCMACs : TrieMap.TrieMap<T.TagUid, [Hex.Hex]> = TrieMap.fromEntries<T.TagUid, [Hex.Hex]>(tagCMACsEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });

  //  ----------- Configure external actors
  let Ledger = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : LT.Self;
  let icp_fee : Nat64 = 10_000;

  public query func getRegistry() : async [(T.TagUid, Principal)] {
    _getOwnerEntries();
  };

  public shared({ caller }) func registerTag(uid : T.TagUid) : async T.TagEncodeResult {
    assert(_isAdmin(caller));

    tag_total += 1;
    await _registerTag(caller, uid);
  };

  public shared({ caller }) func importScans(
    uid : T.TagUid, 
    data : [Hex.Hex]
    ) {
      assert(_isAdmin(caller));

      tagCMACs.put(uid, data);
  };

  public shared({ caller }) func isAdmin() : async Bool {
    if (_isAdmin(caller)) {
      return true;
    };
    return false;
  };

  public shared({ caller }) func scan( scan : T.Scan) : async T.ScanResult {
      await _scan(caller, scan);
  };

  public shared({ caller }) func tagBalance(uid : T.TagUid) : async Nat64 {
    await _tagBalance(uid);
  };

  public shared({ caller }) func withdraw(
      uid : T.TagUid, 
      account_id : [Nat8], 
      amount : ?Nat64
    ) : async LT.TransferResult {
      assert(_isOwner(uid, caller));

      await _withdraw(
        uid, 
        account_id,
        amount
      ); 
  };


////




  private func _getOwnerEntries() : [(T.TagUid, Principal)] {
    Iter.toArray(owners.entries());
  };

  private func _isAdmin (p: Principal) : Bool {
    return(Helpers.contains<Principal>(admins, p, Principal.equal))
  };

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

  private func _scan(p : Principal, scan : T.Scan) : async T.ScanResult {
      switch (tagSecrets.get(scan.uid)) {
        case (?secrets) {

          switch (tagCMACs.get(scan.uid)) {
            case (?validCmacList) {

              if (validCmacList[Nat32.toNat(scan.ctr)] == scan.cmac /* && scan.ctr > secrets.ctr */) {

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
                  msg = "CMAC not valid.";
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

  private func _tagBalance(uid : T.TagUid) : async Nat64 {

    switch (tagWallets.get(uid)) {
      case (?wallet) {
        let icpBalance = await Ledger.account_balance({
          account = Blob.toArray(wallet);
        });

        return icpBalance.e8s;
      };

      case _ {
        return 0 : Nat64;
      }
    };
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

  private func _withdraw(
    uid : T.TagUid,
    account_id : [Nat8],
    amount : ?Nat64
    ) : async LT.TransferResult {
      var icp_amount = 0 :Nat64;

      switch (amount) {
        case (?withdrawAmount) {
          icp_amount := withdrawAmount;
        };

        case _ {
          icp_amount := await _tagBalance(uid);
        };
      };

      //  Transfer that amount back to user
      await transferICP(
        uid, 
        account_id, 
        icp_amount
      );
  };

////////////

  private func _addTagToBalance(p : Principal, uid : T.TagUid) {
    switch (balances.get(p)) {
      case (?v) {
        balances.put(p, Array.append(v,[uid]));
      };
      case null {
        balances.put(p, [uid]);
      }
    }
  };

  private func _removeTagFromBalance(p : Principal, uid : T.TagUid) {
    switch (balances.get(p)) {
      case (?v) {
        balances.put(p, Array.filter<Nat64>(v, func (e : T.TagUid) : Bool { e != uid; }));
      };
      case null {
        balances.put(p, [uid]);
      }
    }
  };

  private func _tag_exists(uid : T.TagUid) : Bool {
    return Option.isSome(owners.get(uid));
  };

  //  ----------- ICP Ledger & Transaction Functions
  private func transferICP(
    uid : T.TagUid, 
    transferTo : [Nat8], 
    transferAmount : Nat64
    ) : async LT.TransferResult {
      let res =  await Ledger.transfer({
        memo: Nat64 = uid;
        from_subaccount = ?Blob.toArray(Helpers.uidToSubaccount(uid));
        to = transferTo;
        //  The amount of ICP, minus the necessary transaction fee
        amount = { e8s = transferAmount - icp_fee };
        fee = { e8s = icp_fee };
        created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
      });
  };


////////////////////////////////////
  system func preupgrade() {
    ownersEntries := Iter.toArray(owners.entries());
    balancesEntries := Iter.toArray(balances.entries());
    tagSecretsEntries := Iter.toArray(tagSecrets.entries());
    tagWalletsEntries := Iter.toArray(tagWallets.entries());
    tagCMACsEntries := Iter.toArray(tagCMACs.entries());
  };

  system func postupgrade() {
    ownersEntries := [];
    balancesEntries := [];
    tagSecretsEntries := [];
    tagWalletsEntries := [];
    tagCMACsEntries := [];
  };
};