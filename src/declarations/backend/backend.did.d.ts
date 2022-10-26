import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type Hex = string;
export interface SDM {
  'decrypt' : ActorMethod<[TagParam], Array<number>>,
  'encrypt' : ActorMethod<[TagParam], Array<number>>,
  'getRegistry' : ActorMethod<[], Array<[TagUid, Principal]>>,
  'reflect' : ActorMethod<[TagParam], TagParam>,
  'registerTag' : ActorMethod<[TagUid], [Hex, Hex]>,
  'show_key' : ActorMethod<[], Array<number>>,
  'text_to_array' : ActorMethod<[TagParam], Array<number>>,
  'whoami' : ActorMethod<[], Principal>,
}
export interface TagParam {
  'ctr' : Array<number>,
  'uid' : Array<number>,
  'cmac' : Array<number>,
}
export type TagUid = bigint;
export interface _SERVICE extends SDM {}
