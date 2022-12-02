import SHA2 "SHA2";
import Hash "Hash";

module SHA224 {
    // Initial hash value, H(0).
    private let H256 : [Nat32] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c,
        0x1f83d9ab, 0x5be0cd19,
    ];

    /// Returns the SHA256 checksum of the data.
    public func sum(bs : [Nat8]) : [Nat8] {
        let h = SHA2.SHA2(H256, 32);
        h.write(bs);
        h.checkSum();
    };

    public func New() : Hash.Hash { SHA2.SHA2(H256, 32); };
};