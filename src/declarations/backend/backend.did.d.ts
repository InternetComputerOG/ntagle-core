import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AESKey = string;
export type BlockIndex = bigint;
export type CMAC = string;
export interface DemoTagData {
  'balance' : bigint,
  'owner' : Principal,
  'locked' : boolean,
}
export interface DemoTagDataResponse {
  'tag1' : DemoTagData,
  'tag2' : DemoTagData,
}
export type DemoTagDataResult = { 'Ok' : DemoTagDataResponse } |
  { 'Err' : ScanError };
export interface DemoTagScanResponse {
  'cmac' : CMAC,
  'count' : TagCtr,
  'transfer_code' : AESKey,
}
export type DemoTagScanResult = { 'Ok' : DemoTagScanResponse } |
  { 'Err' : ScanError };
export type Hex = string;
export interface Location { 'latitude' : number, 'longitude' : number }
export interface LoggedMessage {
  'uid' : TagUid,
  'balance' : bigint,
  'from' : Principal,
  'time' : bigint,
  'message' : string,
  'location' : string,
}
export interface NewMessage {
  'uid' : TagUid,
  'message' : string,
  'location' : [] | [Location],
}
export interface SDM {
  'demoTagData' : ActorMethod<[], DemoTagDataResult>,
  'demoTagGenerateScan' : ActorMethod<[bigint], DemoTagScanResult>,
  'getChatLog' : ActorMethod<[TagUid, [] | [Location]], Array<LoggedMessage>>,
  'getRegistry' : ActorMethod<[], Array<[TagUid, Principal]>>,
  'importScans' : ActorMethod<[TagUid, Array<Hex>], undefined>,
  'isAdmin' : ActorMethod<[], boolean>,
  'lockDemoTag' : ActorMethod<[TagUid], undefined>,
  'postMessage' : ActorMethod<[NewMessage], Array<LoggedMessage>>,
  'registerTag' : ActorMethod<[TagUid], TagEncodeResult>,
  'scan' : ActorMethod<[Scan], ScanResult>,
  'tagBalance' : ActorMethod<[TagUid], bigint>,
  'unlockDemoTag' : ActorMethod<[TagUid], undefined>,
  'withdraw' : ActorMethod<[TagUid, Array<number>, bigint], TransferResult>,
}
export interface Scan {
  'ctr' : TagCtr,
  'uid' : TagUid,
  'cmac' : CMAC,
  'transfer_code' : AESKey,
}
export interface ScanError { 'msg' : string }
export interface ScanResponse {
  'owner' : boolean,
  'locked' : boolean,
  'wallet' : Array<number>,
  'transfer_code' : [] | [AESKey],
}
export type ScanResult = { 'Ok' : ScanResponse } |
  { 'Err' : ScanError };
export type TagCtr = number;
export interface TagEncodeResult { 'key' : AESKey, 'transfer_code' : AESKey }
export type TagUid = bigint;
export interface Tokens { 'e8s' : bigint }
export type TransferError = {
    'TxTooOld' : { 'allowed_window_nanos' : bigint }
  } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'TxDuplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TxCreatedInFuture' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type TransferResult = { 'Ok' : BlockIndex } |
  { 'Err' : TransferError };
export interface _SERVICE extends SDM {}
