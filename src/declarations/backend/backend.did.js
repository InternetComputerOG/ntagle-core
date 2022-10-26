export const idlFactory = ({ IDL }) => {
  const TagParam = IDL.Record({
    'ctr' : IDL.Vec(IDL.Nat8),
    'uid' : IDL.Vec(IDL.Nat8),
    'cmac' : IDL.Vec(IDL.Nat8),
  });
  const TagUid = IDL.Nat64;
  const Hex = IDL.Text;
  const SDM = IDL.Service({
    'decrypt' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'encrypt' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TagUid, IDL.Principal))],
        ['query'],
      ),
    'reflect' : IDL.Func([TagParam], [TagParam], ['query']),
    'registerTag' : IDL.Func([TagUid], [Hex, Hex], []),
    'show_key' : IDL.Func([], [IDL.Vec(IDL.Nat8)], ['query']),
    'text_to_array' : IDL.Func([TagParam], [IDL.Vec(IDL.Nat8)], ['query']),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return SDM;
};
export const init = ({ IDL }) => { return []; };
