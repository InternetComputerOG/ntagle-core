import Bool         "mo:base/Bool";
import Blob         "mo:base/Blob";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";

import Hex          "lib/Hex";

module {

  public type TagUid = Nat64;
  public type TagCtr = Nat32;

  // 32-byte array.
  public type AESKey = Hex.Hex;

  // 16-byte array.
  public type CMAC = Hex.Hex;

  public type TagParam = {
    uid : Blob;
    ctr : Blob;
    cmac : Blob;
  };

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
}