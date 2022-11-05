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
import LT           "../ledger/ledger";

shared actor class SDM() = this {

  //  ----------- Variables
  private stable var tag_total : Nat = 0;
  private stable var chat_messages : Nat = 0;
  private stable var demo_tag_1_uid : T.TagUid = 1244790287045008;
  private stable var demo_tag_2_uid : T.TagUid = 1207406891700624;
  private stable var demo_tag_1_transfer_code : Text = "F5F7B4B280C2B9DA90D73746CCC05558";
  private stable var demo_tag_2_transfer_code : Text = "1959a2a08c2e886e469d95197eb91c14";
  let internet_identity_principal_isaac : Principal = Principal.fromText("gvi7s-tbk2k-4qba4-mw6qj-azomr-rrwex-byyqb-icyrn-eygs4-nrmm5-eae");
  var admins : [Principal] = [internet_identity_principal_isaac]; 

  //  ----------- State
  private stable var ownersEntries : [(T.TagUid, Principal)] = [];
  private stable var balancesEntries : [(Principal, [T.TagUid])] = [];
  private stable var tagSecretsEntries : [(T.TagUid, T.TagSecrets)] = [];
  private stable var tagWalletsEntries : [(T.TagUid, Account.AccountIdentifier)] = [];
  private stable var tagCMACsEntries : [(T.TagUid, [Hex.Hex])] = [];
  private stable var chatsEntries : [(Nat, T.ChatMessage)] = [];

  private let owners : TrieMap.TrieMap<T.TagUid, Principal> = TrieMap.fromEntries<T.TagUid, Principal>(ownersEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let balances : TrieMap.TrieMap<Principal, [T.TagUid]> = TrieMap.fromEntries<Principal, [T.TagUid]>(balancesEntries.vals(), Principal.equal, Principal.hash);
  private let tagSecrets : TrieMap.TrieMap<T.TagUid, T.TagSecrets> = TrieMap.fromEntries<T.TagUid, T.TagSecrets>(tagSecretsEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let tagWallets : TrieMap.TrieMap<T.TagUid, Account.AccountIdentifier> = TrieMap.fromEntries<T.TagUid, Account.AccountIdentifier>(tagWalletsEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let tagCMACs : TrieMap.TrieMap<T.TagUid, [Hex.Hex]> = TrieMap.fromEntries<T.TagUid, [Hex.Hex]>(tagCMACsEntries.vals(), Nat64.equal, func (k : T.TagUid) : Hash.Hash { Hash.hash(Nat64.toNat(k)); });
  private let chats : TrieMap.TrieMap<Nat, T.ChatMessage> = TrieMap.fromEntries<Nat, T.ChatMessage>(chatsEntries.vals(), Nat.equal, Hash.hash);

  //  ----------- Configure external actors
  let Ledger = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : LT.Self;
  let icp_fee : Nat64 = 10_000;

  //  ----------- Public functions
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
      amount : Nat64
    ) : async LT.TransferResult {
      assert(_isOwner(uid, caller));

      await _withdraw(
        uid, 
        account_id,
        amount
      ); 
  };

  public shared({ caller }) func postMessage(message : T.NewMessage) : async [T.LoggedMessage] {
    assert _isOwner(message.uid, caller);

    chat_messages += 1;
    await _postMessage(caller, message);
  };

  public shared({ caller }) func getChatLog(uid : T.TagUid, location: ?T.Location) : async [T.LoggedMessage] {
    assert _isOwner(uid, caller);

    _chatLog(location);
  };

  //  Demo Tag Functions
  public func demoTagData() : async T.DemoTagDataResult {
    var tag_1_locked = _isLocked(demo_tag_1_uid, demo_tag_1_transfer_code);
    var tag_1_owner = internet_identity_principal_isaac;
    var tag_1_balance = await _tagBalance(demo_tag_1_uid);

    var tag_2_locked = _isLocked(demo_tag_2_uid, demo_tag_2_transfer_code);
    var tag_2_owner = internet_identity_principal_isaac;
    var tag_2_balance = await _tagBalance(demo_tag_2_uid);

    switch (owners.get(demo_tag_1_uid)) {
      case (?owner) {
        tag_1_owner := owner;
      };

      case _ {
        return #Err({
          msg = "Could not find Demo Tag 1 Owner.";
        }); 
      };
    };

    switch (owners.get(demo_tag_2_uid)) {
      case (?owner) {
        tag_2_owner := owner;
      };

      case _ {
        return #Err({
          msg = "Could not find Demo Tag 2 Owner.";
        }); 
      };
    };

    let tag_1_data : T.DemoTagData = {
      locked = tag_1_locked;
      owner = tag_1_owner;
      balance = tag_1_balance;
    };

    let tag_2_data : T.DemoTagData = {
      locked = tag_2_locked;
      owner = tag_2_owner;
      balance = tag_2_balance;
    };

    #Ok({
      tag1 = tag_1_data;
      tag2 = tag_2_data;
    });
  };

  public func demoTagGenerateScan(demoTag : Nat) : async T.DemoTagScanResult {
    var tag_uid = 0 : Nat64;
    var tag_count = 0 : Nat32;
    var tag_transfer_code = "0";
    var tag_cmac = "0";

    if (demoTag == 1) {
      tag_uid := demo_tag_1_uid;
      tag_transfer_code := demo_tag_1_transfer_code;
    } else if (demoTag == 2) {
      tag_uid := demo_tag_2_uid;
      tag_transfer_code := demo_tag_2_transfer_code;
    };

    switch (tagSecrets.get(tag_uid)) {
      case (?secrets) {
        tag_count := secrets.ctr;
      };
      case _ {
        return #Err({
          msg = "Could not generate tag secrets.";
        });
      };
    };

    switch (tagCMACs.get(tag_uid)) {
      case (?cmacList) {
        tag_cmac := cmacList[Nat32.toNat(tag_count) + 1];
      };
      case _ {
        return #Err({
          msg = "Could not generate valid CMAC.";
        });
      };
    };

    #Ok({
      count = tag_count;
      transfer_code = tag_transfer_code;
      cmac = tag_cmac;
    });
  };

  public shared({ caller }) func unlockDemoTag(uid : T.TagUid) {
    assert _isOwner(uid, caller);

    var correct_transfer_code = "00000000000000000000000000000000";

    switch (tagSecrets.get(uid)) {
      case (?secrets) {
        correct_transfer_code := secrets.transfer_code;
      };
      case _ {};
    };

    if (uid == demo_tag_1_uid) {
      demo_tag_1_transfer_code := correct_transfer_code;
    } else if (uid == demo_tag_2_uid) {
      demo_tag_2_transfer_code := correct_transfer_code;
    };
  };

  public shared({ caller }) func lockDemoTag(uid : T.TagUid) {
    assert _isOwner(uid, caller);

    var correct_transfer_code = "00000000000000000000000000000000";

    if (uid == demo_tag_1_uid) {
      demo_tag_1_transfer_code := correct_transfer_code;
    } else if (uid == demo_tag_2_uid) {
      demo_tag_2_transfer_code := correct_transfer_code;
    };
  };

  //  ----------- Directly called private functions
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
    amount : Nat64
    ) : async LT.TransferResult {
      var icp_amount = 0 :Nat64;

      if (amount == 0) {
        icp_amount := await _tagBalance(uid);
      } else {
        icp_amount := amount;
      };

      //  Transfer that amount back to user
      await transferICP(
        uid, 
        account_id, 
        icp_amount
      );
  };

  private func _postMessage(caller : Principal, message : T.NewMessage) : async [T.LoggedMessage] {
    let new_message : T.ChatMessage = {
      from = caller;
      uid = message.uid;
      time = Nat64.fromNat(Int.abs(Time.now()));
      balance = await _tagBalance(message.uid);
      location = message.location;
      message = message.message;
    };

    chats.put(chat_messages, new_message);

    return _chatLog(message.location);
  };

  //  ----------- Additional private functions
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

  private func _chatLog(location : ?T.Location) : [T.LoggedMessage] {
    let result = Buffer.Buffer<T.LoggedMessage>(chat_messages);

    for (message in chats.vals()) {
      result.add({
        from = message.from;
        uid = message.uid;
        time = message.time;
        balance = message.balance;
        location = Helpers.distance(location, message.location);
        message = message.message
      });
    };

    return result.toArray();    
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


  //  ----------- System functions
  system func preupgrade() {
    ownersEntries := Iter.toArray(owners.entries());
    balancesEntries := Iter.toArray(balances.entries());
    tagSecretsEntries := Iter.toArray(tagSecrets.entries());
    tagWalletsEntries := Iter.toArray(tagWallets.entries());
    tagCMACsEntries := Iter.toArray(tagCMACs.entries());
    chatsEntries := Iter.toArray(chats.entries());
  };

  system func postupgrade() {
    ownersEntries := [];
    balancesEntries := [];
    tagSecretsEntries := [];
    tagWalletsEntries := [];
    tagCMACsEntries := [];
    chatsEntries := [];
  };
};