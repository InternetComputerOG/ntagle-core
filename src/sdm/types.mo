import Bool         "mo:base/Bool";
import Blob         "mo:base/Blob";
import Float        "mo:base/Float";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";
import Principal    "mo:base/Principal";
import Text         "mo:base/Text";
import Time         "mo:base/Time";

import Hex          "lib/Hex";

module {
  public type TagIndex = Nat32;
  public type TagCtr = Nat32;

  //  56-byte array as Hex String
  public type TagUid = Hex.Hex;

  //  32-byte array as Hex string.
  public type TagIdentifier = Hex.Hex;

  //  32-byte array as Hex string.
  public type AESKey = Hex.Hex;

  //  16-byte array as Hex string.
  public type CMAC = Hex.Hex;

  //  Scanning
  public type Scan = {
    uid : TagUid;
    ctr : TagCtr;
    cmac : CMAC;
    transfer_code : AESKey;
  };

  public type ScanResult = {
    #Ok : ScanResponse;
    #Err : ScanError;
  };

  public type ScanResponse = {
    owner : Bool;
    new_owner : Bool;
    locked : Bool;
    active_integrations : [IntegrationResult];
    available_integrations : [IntegrationResult];
    scans_left : Nat32;
    years_left : Nat8;
  };

  public type ScanError = {
    msg : Text;
  };

  //  Encoding
  public type TagEncodeResult = {
    key: AESKey;
    transfer_code: AESKey;
  };

  //  Tag
  public type Tag = {
    index : TagIndex;
    ctr : TagCtr;
    cmacs : [Hex.Hex];
    owner : Principal;
    transfer_code : AESKey;
    actove_integrations : [TagIdentifier];
    last_ownership_change : Time.Time;
    creation_date : Time.Time;
  };

  //  Integrations
  public type IntegrationResult = {
    name : Text;
    image : Text;
    description : Text;
    canister : Principal;
    url : Text;
  };
  
  public type Integration = {
    canister : Principal;
    access_code : AESKey;
    user : Principal;
    last_access_key_change : Time.Time;
  };

  public type Integrator = {
    name : Text;
    image : Text;
    description : Text;
    url : Text;
    tags : [TagIdentifier];
  };

  public type NewIntegrator = {
    name : Text;
    image : Text;
    description : Text;
    url : Text;
  };

  //  Validation
  public type ValidationRequest = {
    user : Principal;
    access_code : AESKey;
  };

  public type ValidationResult = {
    #Ok : ValidationResponse;
    #Err : ValidationError;
  };

  public type ValidationResponse = {
    tag : TagIdentifier;
    grant_access : Bool;
    previous_user : ?Principal;  //  It will only be null if this is a new tag integration.
    last_ownership_change : Time.Time;
    last_access_key_change : Time.Time;
  };

  public type ValidationError = {
    #NotAuthorized;  //  Caller not found in Integrator list. 
    #Invalid;  //  The Access Code was not found.
    #Expired; //  The Access Code was more than 10 minutes old.
  };

  //  Tag Info
  public type TagInfoResult = {
    #Ok : TagInfoResponse;
    #Err : ValidationError;
  };

  public type TagInfoResponse = {
    current_user : Principal;
    last_ownership_change : Time.Time;
    last_access_key_change : Time.Time;
  };

  public type TagInfoError = {
    #NotAuthorized;  //  Caller not found in Integrator list. 
    #NotFound;  //  Tag Identifier not found in Integration list. 
  };

  //  Unlocking
  public type UnlockResult = {
    #Ok : UnlockResponse;
    #Err : UnlockError;
  };

  public type UnlockResponse = {
    transfer_code : AESKey;
  };

  public type UnlockError = {
    #NotAuthorized;  //  Caller not owner of this tag. 
    #NotFound;  //  Tag not found. 
  };

  //  Unlocking
  public type NewIntegrationResult = {
    #Ok : NewIntegrationResponse;
    #Err : NewIntegrationError;
  };

  public type NewIntegrationResponse = IntegrationResult;

  public type NewIntegrationError = {
    #NotAuthorized;  //  Caller not owner of this tag. 
    #NotFound;  //  Tag not found. 
  };
}