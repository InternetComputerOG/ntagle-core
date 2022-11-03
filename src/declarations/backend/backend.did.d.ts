import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AESKey = string;
export type BlockIndex = bigint;
export type CMAC = string;
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
  'decrypt' : ActorMethod<[TagParam], Array<number>>,
  'encrypt' : ActorMethod<[TagParam], Array<number>>,
  'getChatLog' : ActorMethod<[TagUid, [] | [Location]], Array<LoggedMessage>>,
  'getRegistry' : ActorMethod<[], Array<[TagUid, Principal]>>,
  'importScans' : ActorMethod<[TagUid, Array<Hex>], undefined>,
  'isAdmin' : ActorMethod<[], boolean>,
  'postMessage' : ActorMethod<[NewMessage], Array<LoggedMessage>>,
  'reflect' : ActorMethod<[TagParam], TagParam>,
  'registerTag' : ActorMethod<[TagUid], TagEncodeResult>,
  'scan' : ActorMethod<[Scan], ScanResult>,
  'show_key' : ActorMethod<[], Array<number>>,
  'tagBalance' : ActorMethod<[TagUid], bigint>,
  'text_to_array' : ActorMethod<[TagParam], Array<number>>,
  'whoami' : ActorMethod<[], Principal>,
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
export interface TagParam {
  'ctr' : Array<number>,
  'uid' : Array<number>,
  'cmac' : Array<number>,
}
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
