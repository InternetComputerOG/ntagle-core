export const idlFactory = ({ IDL }) => {
  const SDM = IDL.Service({ 'whoami' : IDL.Func([], [IDL.Principal], []) });
  return SDM;
};
export const init = ({ IDL }) => { return []; };
