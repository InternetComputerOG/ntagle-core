import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";

module Utilities {
    public func copy<T>(
        n   : Nat, // Position to start writing.
        dst : [var T], 
        src : [T]
    ) : Nat {
        let l = dst.size();
        if (l < n) return 0;
        for (i in src.keys()) {
            if (l <= n + i) return i;
            dst[n + i] := src[i];
        };
        src.size();
    };

    public func removeN<T>(
        n  : Nat, // Number to remove.
        xs : [T]
    ) : [T] {
        Array.tabulate<T>(
            xs.size() - n,
            func (i : Nat) : T {
                xs[i + n];
            }
        );
    };

    public func takeN<T>(
        n  : Nat, // Number to take.
        xs : [T]
    ) : [T] {
        Array.tabulate<T>(
            n,
            func (i : Nat) : T {
                xs[i];
            }
        );
    };

    public func select<T>(
        start : Nat,
        end   : Nat, // excl.
        xs    : [T]
    ) : [T] {
        Array.tabulate<T>(
            end - start : Nat,
            func (i : Nat) : T {
                xs[start + i]
            }
        );
    };

    public func nat32to8(n : Nat32) : Nat8 {
        Nat8.fromIntWrap(Nat32.toNat(n));
    };

    public func nat8to32(n : Nat8) : Nat32 {
        Nat32.fromNat(Nat8.toNat(n));
    };
};