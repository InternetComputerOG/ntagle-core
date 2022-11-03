export const idlFactory = ({ IDL }) => {
  const TagParam = IDL.Record({
    'ctr' : IDL.Vec(IDL.Nat8),
    'uid' : IDL.Vec(IDL.Nat8),
    'cmac' : IDL.Vec(IDL.Nat8),
  });
  const TagUid = IDL.Nat64;
  const Location = IDL.Record({
    'latitude' : IDL.Float64,
    'longitude' : IDL.Float64,
  });
  const LoggedMessage = IDL.Record({
    'uid' : TagUid,
    'balance' : IDL.Nat64,
    'from' : IDL.Principal,
    'time' : IDL.Nat64,
    'message' : IDL.Text,
    'location' : IDL.Text,
  });
  const Hex = IDL.Text;
  const NewMessage = IDL.Record({
    'uid' : TagUid,
    'message' : IDL.Text,
    'location' : IDL.Opt(Location),
  });
  const AESKey = IDL.Text;
  const TagEncodeResult = IDL.Record({
    'key' : AESKey,
    'transfer_code' : AESKey,
  });
  const TagCtr = IDL.Nat32;
  const CMAC = IDL.Text;
  const Scan = IDL.Record({
    'ctr' : TagCtr,
    'uid' : TagUid,
    'cmac' : CMAC,
    'transfer_code' : AESKey,
  });
  const ScanResponse = IDL.Record({
    'owner' : IDL.Bool,
    'locked' : IDL.Bool,
    'wallet' : IDL.Vec(IDL.Nat8),
    'transfer_code' : IDL.Opt(AESKey),
  });
  const ScanError = IDL.Record({ 'msg' : IDL.Text });
  const ScanResult = IDL.Variant({ 'Ok' : ScanResponse, 'Err' : ScanError });
  const BlockIndex = IDL.Nat64;
  const Tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const TransferError = IDL.Variant({
    'TxTooOld' : IDL.Record({ 'allowed_window_nanos' : IDL.Nat64 }),
    'BadFee' : IDL.Record({ 'expected_fee' : Tokens }),
    'TxDuplicate' : IDL.Record({ 'duplicate_of' : BlockIndex }),
    'TxCreatedInFuture' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Tokens }),
  });
  const TransferResult = IDL.Variant({
    'Ok' : BlockIndex,
    'Err' : TransferError,
  });
  const SDM = IDL.Service({
    'decrypt' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'encrypt' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'getChatLog' : IDL.Func(
        [TagUid, IDL.Opt(Location)],
        [IDL.Vec(LoggedMessage)],
        [],
      ),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TagUid, IDL.Principal))],
        ['query'],
      ),
    'importScans' : IDL.Func([TagUid, IDL.Vec(Hex)], [], ['oneway']),
    'isAdmin' : IDL.Func([], [IDL.Bool], []),
    'postMessage' : IDL.Func([NewMessage], [IDL.Vec(LoggedMessage)], []),
    'reflect' : IDL.Func([TagParam], [TagParam], ['query']),
    'registerTag' : IDL.Func([TagUid], [TagEncodeResult], []),
    'scan' : IDL.Func([Scan], [ScanResult], []),
    'show_key' : IDL.Func([], [IDL.Vec(IDL.Nat8)], ['query']),
    'tagBalance' : IDL.Func([TagUid], [IDL.Nat64], []),
    'text_to_array' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
    'withdraw' : IDL.Func(
        [TagUid, IDL.Vec(IDL.Nat8), IDL.Nat64],
        [TransferResult],
        [],
      ),
  });
  return SDM;
};
export const init = ({ IDL }) => { return []; };
