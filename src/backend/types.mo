import Blob         "mo:base/Blob";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";

import Hex          "lib/Hex";

module {

  public type TagParam = {
    uid : Blob;
    ctr : Blob;
    cmac : Blob;
  };

  public type TagEncodeResult = {
    key: AESKey;
    transfer_code: AESKey;
  };

  public type TagUid = Nat64;

  public type TagSecrets = {
    key : AESKey;
    ctr : Nat32;
    transfer_code : AESKey;
  };

  // 32-byte array.
  public type AESKey = Hex.Hex;
}