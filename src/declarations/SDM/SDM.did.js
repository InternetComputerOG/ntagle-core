export const idlFactory = ({ IDL }) => {
  const TagUid = IDL.Text;
  const Hex = IDL.Text;
  const ImportCMACResult = IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Null });
  const TagIdentifier = IDL.Text;
  const Integrator = IDL.Record({
    'url' : IDL.Text,
    'name' : IDL.Text,
    'tags' : IDL.Vec(TagIdentifier),
    'description' : IDL.Text,
    'image' : IDL.Text,
  });
  const NewIntegrationRequest = IDL.Record({
    'uid' : TagUid,
    'canister' : IDL.Principal,
  });
  const ValidationIdentifier = IDL.Text;
  const AESKey = IDL.Text;
  const NewIntegrationResponse = IDL.Record({
    'url' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'canister' : IDL.Principal,
    'image' : IDL.Text,
    'validation' : ValidationIdentifier,
    'access_code' : AESKey,
  });
  const NewIntegrationError = IDL.Variant({
    'IntegrationAlreadyExists' : IDL.Null,
    'TagNotFound' : IDL.Null,
    'NotCanisterPrincipal' : IDL.Null,
    'IntegratorNotFound' : IDL.Null,
  });
  const NewIntegrationResult = IDL.Variant({
    'Ok' : NewIntegrationResponse,
    'Err' : NewIntegrationError,
  });
  const NewIntegrator = IDL.Record({
    'url' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'image' : IDL.Text,
  });
  const TagEncodeResult = IDL.Record({
    'key' : AESKey,
    'transfer_code' : AESKey,
  });
  const AccessRequest = IDL.Record({
    'uid' : TagUid,
    'canister' : IDL.Principal,
  });
  const AccessResponse = IDL.Record({
    'validation' : ValidationIdentifier,
    'access_code' : AESKey,
  });
  const AccessError = IDL.Variant({
    'SaltNotFound' : IDL.Null,
    'IntegrationNotFound' : IDL.Null,
  });
  const AccessResult = IDL.Variant({
    'Ok' : AccessResponse,
    'Err' : AccessError,
  });
  const TagCtr = IDL.Nat32;
  const CMAC = IDL.Text;
  const Scan = IDL.Record({
    'ctr' : TagCtr,
    'uid' : TagUid,
    'cmac' : CMAC,
    'transfer_code' : AESKey,
  });
  const IntegrationResult = IDL.Record({
    'url' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'canister' : IDL.Principal,
    'image' : IDL.Text,
    'integrated' : IDL.Bool,
  });
  const ScanResponse = IDL.Record({
    'owner_changed' : IDL.Bool,
    'integrations' : IDL.Vec(IntegrationResult),
    'owner' : IDL.Bool,
    'years_left' : IDL.Nat,
    'locked' : IDL.Bool,
    'scans_left' : IDL.Nat32,
  });
  const ScanError = IDL.Variant({
    'TagNotFound' : IDL.Null,
    'ExpiredCount' : IDL.Null,
    'InvalidCMAC' : IDL.Null,
  });
  const ScanResult = IDL.Variant({ 'Ok' : ScanResponse, 'Err' : ScanError });
  const Time = IDL.Int;
  const TagInfoResponse = IDL.Record({
    'last_access_key_change' : Time,
    'current_user' : IDL.Opt(IDL.Principal),
    'last_ownership_change' : Time,
  });
  const TagInfoError = IDL.Variant({
    'IntegrationNotFound' : IDL.Null,
    'TagNotFound' : IDL.Null,
    'NotAuthorized' : IDL.Null,
  });
  const TagInfoResult = IDL.Variant({
    'Ok' : TagInfoResponse,
    'Err' : TagInfoError,
  });
  const UnlockResponse = IDL.Record({ 'transfer_code' : AESKey });
  const UnlockError = IDL.Variant({ 'TagNotFound' : IDL.Null });
  const UnlockResult = IDL.Variant({
    'Ok' : UnlockResponse,
    'Err' : UnlockError,
  });
  const ValidationRequest = IDL.Record({
    'user' : IDL.Principal,
    'validation' : ValidationIdentifier,
    'access_code' : AESKey,
  });
  const ValidationResponse = IDL.Record({
    'tag' : TagIdentifier,
    'last_access_key_change' : Time,
    'previous_user' : IDL.Opt(IDL.Principal),
    'current_user' : IDL.Principal,
    'last_ownership_change' : Time,
  });
  const ValidationError = IDL.Variant({
    'Invalid' : IDL.Null,
    'IntegrationNotFound' : IDL.Null,
    'TagNotFound' : IDL.Null,
    'NotAuthorized' : IDL.Null,
    'ValidationNotFound' : IDL.Null,
    'Expired' : IDL.Null,
  });
  const ValidationResult = IDL.Variant({
    'Ok' : ValidationResponse,
    'Err' : ValidationError,
  });
  const SDM = IDL.Service({
    'importCMACs' : IDL.Func([TagUid, IDL.Vec(Hex)], [ImportCMACResult], []),
    'integratorRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, Integrator))],
        [],
      ),
    'isAdmin' : IDL.Func([], [IDL.Bool], []),
    'newIntegration' : IDL.Func(
        [NewIntegrationRequest],
        [NewIntegrationResult],
        [],
      ),
    'registerIntegrator' : IDL.Func([NewIntegrator], [], ['oneway']),
    'registerTag' : IDL.Func([TagUid], [TagEncodeResult], []),
    'requestAccess' : IDL.Func([AccessRequest], [AccessResult], []),
    'scan' : IDL.Func([Scan], [ScanResult], []),
    'tagInfo' : IDL.Func([TagIdentifier], [TagInfoResult], []),
    'unlock' : IDL.Func([TagUid], [UnlockResult], []),
    'validateAccess' : IDL.Func([ValidationRequest], [ValidationResult], []),
  });
  return SDM;
};
export const init = ({ IDL }) => { return []; };
