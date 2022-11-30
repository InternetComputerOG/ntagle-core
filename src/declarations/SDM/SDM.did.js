export const idlFactory = ({ IDL }) => {
  const DemoTagData = IDL.Record({
    'balance' : IDL.Nat64,
    'owner' : IDL.Principal,
    'locked' : IDL.Bool,
  });
  const DemoTagDataResponse = IDL.Record({
    'tag1' : DemoTagData,
    'tag2' : DemoTagData,
  });
  const ScanError = IDL.Record({ 'msg' : IDL.Text });
  const DemoTagDataResult = IDL.Variant({
    'Ok' : DemoTagDataResponse,
    'Err' : ScanError,
  });
  const CMAC = IDL.Text;
  const TagCtr = IDL.Nat32;
  const AESKey = IDL.Text;
  const DemoTagScanResponse = IDL.Record({
    'cmac' : CMAC,
    'count' : TagCtr,
    'transfer_code' : AESKey,
  });
  const DemoTagScanResult = IDL.Variant({
    'Ok' : DemoTagScanResponse,
    'Err' : ScanError,
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
  const TagEncodeResult = IDL.Record({
    'key' : AESKey,
    'transfer_code' : AESKey,
  });
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
    'demoTagData' : IDL.Func([], [DemoTagDataResult], []),
    'demoTagGenerateScan' : IDL.Func([IDL.Nat], [DemoTagScanResult], []),
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
    'lockDemoTag' : IDL.Func([TagUid], [], ['oneway']),
    'postMessage' : IDL.Func([NewMessage], [IDL.Vec(LoggedMessage)], []),
    'registerTag' : IDL.Func([TagUid], [TagEncodeResult], []),
    'scan' : IDL.Func([Scan], [ScanResult], []),
    'tagBalance' : IDL.Func([TagUid], [IDL.Nat64], []),
    'unlockDemoTag' : IDL.Func([TagUid], [], ['oneway']),
    'withdraw' : IDL.Func(
        [TagUid, IDL.Vec(IDL.Nat8), IDL.Nat64],
        [TransferResult],
        [],
      ),
  });
  return SDM;
};
export const init = ({ IDL }) => { return []; };
