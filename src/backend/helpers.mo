import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Bool         "mo:base/Bool";
import Nat          "mo:base/Nat";
import Nat8         "mo:base/Nat8";
import Nat64        "mo:base/Nat64";
import Random       "mo:base/Random";

import Account      "lib/Account";
import Hex          "lib/Hex";
import T            "types";

module {

  public func contains<T>(xs : [T], y : T, equal : (T, T) -> Bool) : Bool {
    for (x in xs.vals()) {
      if (equal(x, y)) return true;
    }; false;
  };

  public func generate_key() : async Hex.Hex {
    let seed = await Random.blob();
    Hex.encode(drop<Nat8>(Blob.toArray(seed), 16));
  };

  public func generate_wallet(principal: Principal, uid : T.TagUid) : Account.AccountIdentifier {
    let subaccount = Blob.fromArray(Array.append(Array.freeze(Array.init<Nat8>(24, 0 : Nat8)), nat64ToBytes(uid)));
    Account.accountIdentifier(principal, subaccount);
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

  // Converts a Nat64 into an array of bytes
  func nat64ToBytes(n: Nat64) : [Nat8] {
    func byte(n: Nat64) : Nat8 {
      Nat8.fromNat(Nat64.toNat(n & 0xff))
    };
    [byte(n >> 56), byte(n >> 48), byte(n >> 40), byte(n >> 32), byte(n >> 24), byte(n >> 16), byte(n >> 8), byte(n)]
  };
}