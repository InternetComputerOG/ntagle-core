module {
    public type Block = {
        blockSize : () -> Nat;
        encrypt : (bs : [Nat8]) -> [Nat8];
        decrypt : (bs : [Nat8]) -> [Nat8];
    };
};