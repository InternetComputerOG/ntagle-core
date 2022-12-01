import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Bool         "mo:base/Bool";
import Hash         "mo:base/Hash";
import Float        "mo:base/Float";
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

  public func generateKey() : async Hex.Hex {
    let seed = await Random.blob();
    Hex.encode(drop<Nat8>(Blob.toArray(seed), 16));
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