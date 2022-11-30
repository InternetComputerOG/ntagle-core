import Bool         "mo:base/Bool";
import Blob         "mo:base/Blob";
import Float        "mo:base/Float";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";
import Principal    "mo:base/Principal";
import Text         "mo:base/Text";

import Hex          "lib/Hex";

module {

  public type TagUid = Nat64;
  public type TagCtr = Nat32;

  // 32-byte array.
  public type AESKey = Hex.Hex;

  // 16-byte array.
  public type CMAC = Hex.Hex;

  public type Scan = {
    uid: TagUid;
    ctr: TagCtr;
    cmac: CMAC;
    transfer_code: AESKey;
  };

  public type ScanResponse = {
    owner: Bool;
    locked: Bool;
    transfer_code: ?AESKey;
    wallet: Blob;
  };

  public type ScanError = {
    msg : Text;
  };

  public type ScanResult = {
    #Ok : ScanResponse;
    #Err : ScanError;
  };

  public type TagEncodeResult = {
    key: AESKey;
    transfer_code: AESKey;
  };

  public type TagSecrets = {
    key : AESKey;
    ctr : TagCtr;
    transfer_code : AESKey;
  };

  public type Location = {
    latitude : Float;
    longitude : Float;
  };

  public type ChatMessage = {
    from : Principal;
    uid : TagUid;
    time : Nat64;
    balance : Nat64;
    location : ?Location;
    message : Text;
  };

  public type NewMessage = {
    uid : TagUid;
    location : ?Location;
    message : Text;
  };

  public type LoggedMessage = {
    from : Principal;
    uid : TagUid;
    time : Nat64;
    balance : Nat64;
    location : Text;
    message : Text;
  };

  public type DemoTagDataResult = {
    #Ok : DemoTagDataResponse;
    #Err : ScanError;
  };

  public type DemoTagDataResponse = {
    tag1 : DemoTagData;
    tag2 : DemoTagData;
  };

  public type DemoTagData = {
    locked : Bool;
    owner : Principal;
    balance : Nat64;
  };

  public type DemoTagScanResult = {
    #Ok : DemoTagScanResponse;
    #Err : ScanError;
  };

  public type DemoTagScanResponse = {
    count : TagCtr;
    cmac: CMAC;
    transfer_code : AESKey;
  };
}