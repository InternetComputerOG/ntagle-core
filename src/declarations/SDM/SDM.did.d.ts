import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AESKey = string;
export type AccessError = { 'SaltNotFound' : null } |
  { 'IntegrationNotFound' : null };
export interface AccessRequest { 'uid' : TagUid, 'canister' : Principal }
export interface AccessResponse {
  'validation' : ValidationIdentifier,
  'access_code' : AESKey,
}
export type AccessResult = { 'Ok' : AccessResponse } |
  { 'Err' : AccessError };
export type CMAC = string;
export type Hex = string;
export type ImportCMACResult = { 'Ok' : null } |
  { 'Err' : null };
export interface IntegrationResult {
  'url' : string,
  'name' : string,
  'description' : string,
  'canister' : Principal,
  'image' : string,
  'integrated' : boolean,
}
export interface Integrator {
  'url' : string,
  'name' : string,
  'tags' : Array<TagIdentifier>,
  'description' : string,
  'image' : string,
}
export type NewIntegrationError = { 'IntegrationAlreadyExists' : null } |
  { 'TagNotFound' : null } |
  { 'NotCanisterPrincipal' : null } |
  { 'IntegratorNotFound' : null };
export interface NewIntegrationRequest {
  'uid' : TagUid,
  'canister' : Principal,
}
export interface NewIntegrationResponse {
  'url' : string,
  'name' : string,
  'description' : string,
  'canister' : Principal,
  'image' : string,
  'validation' : ValidationIdentifier,
  'access_code' : AESKey,
}
export type NewIntegrationResult = { 'Ok' : NewIntegrationResponse } |
  { 'Err' : NewIntegrationError };
export interface NewIntegrator {
  'url' : string,
  'name' : string,
  'description' : string,
  'image' : string,
}
export interface SDM {
  'importCMACs' : ActorMethod<[TagUid, Array<Hex>], ImportCMACResult>,
  'integratorRegistry' : ActorMethod<[], Array<[Principal, Integrator]>>,
  'isAdmin' : ActorMethod<[], boolean>,
  'newIntegration' : ActorMethod<[NewIntegrationRequest], NewIntegrationResult>,
  'registerIntegrator' : ActorMethod<[NewIntegrator], undefined>,
  'registerTag' : ActorMethod<[TagUid], TagEncodeResult>,
  'requestAccess' : ActorMethod<[AccessRequest], AccessResult>,
  'scan' : ActorMethod<[Scan], ScanResult>,
  'tagInfo' : ActorMethod<[TagIdentifier], TagInfoResult>,
  'unlock' : ActorMethod<[TagUid], UnlockResult>,
  'validateAccess' : ActorMethod<[ValidationRequest], ValidationResult>,
}
export interface Scan {
  'ctr' : TagCtr,
  'uid' : TagUid,
  'cmac' : CMAC,
  'transfer_code' : AESKey,
}
export type ScanError = { 'TagNotFound' : null } |
  { 'ExpiredCount' : null } |
  { 'InvalidCMAC' : null };
export interface ScanResponse {
  'owner_changed' : boolean,
  'integrations' : Array<IntegrationResult>,
  'owner' : boolean,
  'years_left' : bigint,
  'locked' : boolean,
  'scans_left' : number,
}
export type ScanResult = { 'Ok' : ScanResponse } |
  { 'Err' : ScanError };
export type TagCtr = number;
export interface TagEncodeResult { 'key' : AESKey, 'transfer_code' : AESKey }
export type TagIdentifier = string;
export type TagInfoError = { 'IntegrationNotFound' : null } |
  { 'TagNotFound' : null } |
  { 'NotAuthorized' : null };
export interface TagInfoResponse {
  'last_access_key_change' : Time,
  'current_user' : [] | [Principal],
  'last_ownership_change' : Time,
}
export type TagInfoResult = { 'Ok' : TagInfoResponse } |
  { 'Err' : TagInfoError };
export type TagUid = string;
export type Time = bigint;
export type UnlockError = { 'TagNotFound' : null };
export interface UnlockResponse { 'transfer_code' : AESKey }
export type UnlockResult = { 'Ok' : UnlockResponse } |
  { 'Err' : UnlockError };
export type ValidationError = { 'Invalid' : null } |
  { 'IntegrationNotFound' : null } |
  { 'TagNotFound' : null } |
  { 'NotAuthorized' : null } |
  { 'ValidationNotFound' : null } |
  { 'Expired' : null };
export type ValidationIdentifier = string;
export interface ValidationRequest {
  'user' : Principal,
  'validation' : ValidationIdentifier,
  'access_code' : AESKey,
}
export interface ValidationResponse {
  'tag' : TagIdentifier,
  'last_access_key_change' : Time,
  'previous_user' : [] | [Principal],
  'current_user' : Principal,
  'last_ownership_change' : Time,
}
export type ValidationResult = { 'Ok' : ValidationResponse } |
  { 'Err' : ValidationError };
export interface _SERVICE extends SDM {}
