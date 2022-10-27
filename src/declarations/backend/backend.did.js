export const idlFactory = ({ IDL }) => {
  const TagParam = IDL.Record({
    'ctr' : IDL.Vec(IDL.Nat8),
    'uid' : IDL.Vec(IDL.Nat8),
    'cmac' : IDL.Vec(IDL.Nat8),
  });
  const TagUid = IDL.Nat64;
  const Hex = IDL.Text;
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
  const SDM = IDL.Service({
    'decrypt' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'encrypt' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TagUid, IDL.Principal))],
        ['query'],
      ),
    'importScans' : IDL.Func([TagUid, IDL.Vec(Hex)], [], ['oneway']),
    'isAdmin' : IDL.Func([], [IDL.Bool], []),
    'reflect' : IDL.Func([TagParam], [TagParam], ['query']),
    'registerTag' : IDL.Func([TagUid], [TagEncodeResult], []),
    'scan' : IDL.Func([Scan], [ScanResult], []),
    'show_key' : IDL.Func([], [IDL.Vec(IDL.Nat8)], ['query']),
    'tagBalance' : IDL.Func([TagUid], [IDL.Nat64], []),
    'text_to_array' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return SDM;
};
export const init = ({ IDL }) => { return []; };
