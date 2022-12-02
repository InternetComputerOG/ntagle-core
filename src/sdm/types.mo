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
  
  //  ----------- State
  //  Tag
  public type Tag = {
    index : TagIndex;
    ctr : TagCtr;
    cmacs : [Hex.Hex];
    owner : Principal;
    hashed_transfer_code : ?Hex.Hex;
    salt : AESKey;
    active_integrations : [TagIdentifier];
    last_ownership_change : Time.Time;
    creation_date : Time.Time;
  };

  //  Integrators
  public type Integrator = {
    name : Text;
    image : Text;
    description : Text;
    url : Text;
    tags : [TagIdentifier];
  };

  //  Integrations 
  public type Integration = {
    canister : Principal;
    uid : TagUid;
    hashed_access_code : Hex.Hex;
    user : ?Principal;
    last_access_key_change : Time.Time;
  };

  
  //  Redefinitions
  public type TagIndex = Nat32;
  public type TagCtr = Nat32;

  //  56-byte array as Hex String
  public type TagUid = Hex.Hex;

  //  32-byte array as Hex string.
  public type TagIdentifier = Hex.Hex;

  //  32-byte array as Hex string.
  public type ValidationIdentifier = Hex.Hex;

  //  32-byte array as Hex string.
  public type AESKey = Hex.Hex;

  //  16-byte array as Hex string.
  public type CMAC = Hex.Hex;

  //  ----------- Functions
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
    owner_changed : Bool;  //  If the user became the new owner after this scan.
    locked : Bool;
    integrations : [IntegrationResult];
    scans_left : Nat32;
    years_left : Nat;
  };

  public type ScanError = {
    #TagNotFound;  //  Tag UID not found.
    #InvalidCMAC;
    #ExpiredCount;  //  The scan count was lower than the last valid scan logged by the canister.
  };

  //  Encoding
  public type TagEncodeResult = {
    key: AESKey;
    transfer_code: AESKey;
  };

  public type ImportCMACResult = {
    #Ok;
    #Err;
  };

  //  Access
  public type AccessRequest = {
    uid : TagUid;
    canister : Principal;
  };

  public type AccessResult = {
    #Ok : AccessResponse;
    #Err : AccessError;
  };

  public type AccessResponse = {
    validation : ValidationIdentifier;
    access_code : AESKey;
  };

  public type AccessError = {
    #SaltNotFound;  //  Salt not found.
    #IntegrationNotFound;  //  Tag Identifier not found in Integration list.
  };

  //  Integrators
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
    validation : ValidationIdentifier;
  };

  public type ValidationResult = {
    #Ok : ValidationResponse;
    #Err : ValidationError;
  };

  public type ValidationResponse = {
    tag : TagIdentifier;
    current_user : Principal;
    previous_user : ?Principal;  //  It will only be null if this is a new tag integration.
    last_ownership_change : Time.Time;  //  Last time the tag changed owners.
    last_access_key_change : Time.Time;
  };

  public type ValidationError = {
    #ValidationNotFound;
    #IntegrationNotFound;
    #NotAuthorized;  //  Caller canister not authorized. 
    #TagNotFound;
    #Invalid;  //  The Access Code was not valid.
    #Expired; //  The Access Code was more than 10 minutes old.
  };

  //  Tag Info
  public type TagInfoResult = {
    #Ok : TagInfoResponse;
    #Err : TagInfoError;
  };

  public type TagInfoResponse = {
    current_user : ?Principal;
    last_ownership_change : Time.Time;
    last_access_key_change : Time.Time;
  };

  public type TagInfoError = {
    #IntegrationNotFound;
    #NotAuthorized;  //  Caller canister not authorized. 
    #TagNotFound;  //  Tag Identifier not found in Integration list. 
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
    #TagNotFound;  //  Tag UID not found. 
  };

  //  Integration
  public type IntegrationResult = {
    integrated : Bool;
    name : Text;
    image : Text;
    description : Text;
    canister : Principal;
    url : Text;
  };

  public type NewIntegrationRequest = {
    uid : TagUid;
    canister : Principal;
  };

  public type NewIntegrationResult = {
    #Ok : NewIntegrationResponse;
    #Err : NewIntegrationError;
  };

  public type NewIntegrationResponse = {
    name : Text;
    image : Text;
    description : Text;
    canister : Principal;
    url : Text;
    validation : ValidationIdentifier;
    access_code : AESKey;
  };

  public type NewIntegrationError = {
    #NotCanisterPrincipal;
    #IntegratorNotFound;
    #IntegrationAlreadyExists;
    #TagNotFound;  //  Tag Identifier not found. 
  };
}