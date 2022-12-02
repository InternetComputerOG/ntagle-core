import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Bool         "mo:base/Bool";
import Hash         "mo:base/Hash";
import Int          "mo:base/Int";
import Float        "mo:base/Float";
import Nat          "mo:base/Nat";
import Nat8         "mo:base/Nat8";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";
import Principal    "mo:base/Principal";
import Text         "mo:base/Text";
import Time         "mo:base/Time";
import Random       "mo:base/Random";

import Hex          "lib/Hex";
import Utilities    "lib/Utilities";
import SHA256       "lib/SHA256";
import T            "types";

module {

  public func contains<T>(xs : [T], y : T, equal : (T, T) -> Bool) : Bool {
    for (x in xs.vals()) {
      if (equal(x, y)) return true;
    }; false;
  };

  public func generateKey() : async Hex.Hex {
    let seed = await Random.blob();
    Hex.encode(drop<Nat8>(Blob.toArray(seed), 16));
  };

  public func hashSecret(secret : Hex.Hex) : Hex.Hex {
    return Hex.encode(SHA256.sum(Blob.toArray(Text.encodeUtf8(secret))));
  };

  public func getTagIdentifier(uid : T.TagUid, canister : Principal, salt : T.AESKey) : Hex.Hex {
    let h = Text.hash(uid # Principal.toText(canister) # salt);
    return Hex.encode(nat32ToBytes(h));
  };

  public func getValidationIdentifier(tagIdentifier : T.TagIdentifier, canister : Principal) : Hex.Hex {
    let h = Text.hash(tagIdentifier # Principal.toText(canister));
    return Hex.encode(nat32ToBytes(h));
  };

  public func isCanisterPrincipal(p : Principal) : Bool {
    let principal_text = Principal.toText(p);
    let correct_length = Text.size(principal_text) == 27;
    let correct_last_characters = Text.endsWith(principal_text, #text "-cai");

    if (Bool.logand(correct_length, correct_last_characters)) {
      return true;
    };
    return false;
  };

  public func calculateYearsLeft(start : Int) : Nat {
    let time_since = Time.now() - start;
    let one_year = 1_000_000_000 * 60 * 525_600;
    let years_since = Int.div(time_since, one_year);
    return Int.abs(50 - years_since);
  };

  public func arrayLength<T>(a : [T]) : Nat {
      var n = 0;
      for (k in a.keys()) {
          n := k;
      };
      return n + 1;
  };

  func nat32ToBytes(n: Nat32) : [Nat8] {
    func byte(n: Nat32) : Nat8 {
      Nat8.fromNat(Nat32.toNat(n & 0xff))
    };
    [byte(n >> 24), byte(n >> 16), byte(n >> 8), byte(n)]
  };

  // Drops the first 'n' elements of an array, returns the remainder of that array.
  public func drop<T>(
  xs : [T], 
  n : Nat
  ) : [T] {
    let xS = xs.size();
    if (xS <= n) return [];
    let s = xS - n : Nat;
    Array.tabulate<T>(s, func (i : Nat) : T { xs[n + i]; });
  };
}