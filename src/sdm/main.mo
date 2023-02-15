//  ----------- Decription
//  This Motoko file contains the logic of the backend canister.

//  ----------- Imports

//  Imports from Motoko Base Library
import Array        "mo:base/Array";
import Bool         "mo:base/Bool";
import Blob         "mo:base/Blob";
import Buffer       "mo:base/Buffer";
import Hash         "mo:base/Hash";
import Int          "mo:base/Int";
import Iter         "mo:base/Iter";
import Nat          "mo:base/Nat";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";
import Option       "mo:base/Option";
import Principal    "mo:base/Principal";
import Text         "mo:base/Text";
import Time         "mo:base/Time";
import TrieMap      "mo:base/TrieMap";

//  Imports from helpers, utils, & types
import Hex          "lib/Hex";
import T            "types";
import Helpers      "helpers";

//  Imports from external interfaces


shared actor class SDM() = this {

  //  ----------- Variables
  private stable var tag_total : Nat32 = 0;
  private stable var tagIntegration_total : Nat = 0;
  let internet_identity_principal_isaac : Principal = Principal.fromText("gvi7s-tbk2k-4qba4-mw6qj-azomr-rrwex-byyqb-icyrn-eygs4-nrmm5-eae");
  var admins : [Principal] = [internet_identity_principal_isaac]; 

  //  ----------- State
  private stable var tagsEntries : [(T.TagUid, T.Tag)] = [];
  private stable var integratorsEntries : [(Principal, T.Integrator)] = [];
  private stable var integrationsEntries : [(T.TagIdentifier, T.Integration)] = [];
  private stable var validationsEntries : [(T.ValidationIdentifier, T.TagIdentifier)] = [];

  private let tags : TrieMap.TrieMap<T.TagUid, T.Tag> = TrieMap.fromEntries<T.TagUid, T.Tag>(tagsEntries.vals(), Text.equal, Text.hash);
  private let integrators : TrieMap.TrieMap<Principal, T.Integrator> = TrieMap.fromEntries<Principal, T.Integrator>(integratorsEntries.vals(), Principal.equal, Principal.hash);
  private let integrations : TrieMap.TrieMap<T.TagIdentifier, T.Integration> = TrieMap.fromEntries<T.TagIdentifier, T.Integration>(integrationsEntries.vals(), Text.equal, Text.hash);
  private let validations : TrieMap.TrieMap<T.ValidationIdentifier, T.TagIdentifier> = TrieMap.fromEntries<T.ValidationIdentifier, T.TagIdentifier>(validationsEntries.vals(), Text.equal, Text.hash);

  //  ----------- Configure external actors


  //  ----------- Public functions
  //  Integrator Registry
  public func integratorRegistry() : async [(Principal, T.Integrator)] {
    Iter.toArray(integrators.entries());
  };

  //  Encoding
  public shared({ caller }) func registerTag(uid : T.TagUid) : async T.TagEncodeResult {
    assert _isAdmin(caller);
    assert not _tag_exists(uid);

    await _registerTag(caller, uid);
  };

  public shared({ caller }) func importCMACs(
    uid : T.TagUid, 
    data : [Hex.Hex]
    ) : async T.ImportCMACResult {
      assert _isAdmin(caller);

      _addCMACs(uid, data);
  };

  public shared func testHash(s : Text) : async Hex.Hex {
    return Helpers.hashSecret(s);
  };

  public shared({ caller }) func isAdmin() : async Bool {
    _isAdmin(caller);
  };

  //  Scan
  public shared({ caller }) func scan(scan : T.Scan) : async T.ScanResult {
    assert not _isCanister(caller);
    _scan(caller, scan);
  };

  //  Access integration
  public shared({ caller }) func requestAccess(request : T.AccessRequest) : async T.AccessResult {
    assert not _isCanister(caller);
    assert _isOwner(caller, request.uid);

    await _generateAccessCode(request);
  };

  //  Integrators
  public shared({ caller }) func registerIntegrator(integrator : T.NewIntegrator) {
    assert _isCanister(caller);

    _addIntegrator(caller, integrator);
  };

  //  Validation
  public shared({ caller }) func validateAccess(request : T.ValidationRequest) : async T.ValidationResult {
    assert _isCanister(caller);
    assert _isIntegrator(caller);

    _validateAccess(caller, request);
  };

  //  Tag Info
  public shared({ caller }) func tagInfo(tagIdentifier : T.TagIdentifier) : async T.TagInfoResult {
    assert _isCanister(caller);

    _getTagInfo(caller, tagIdentifier);
  };

  //  Unlocking
  public shared({ caller }) func unlock(uid : T.TagUid) : async T.UnlockResult {
    assert not _isCanister(caller);
    assert _isOwner(caller, uid);

    await _generateTransferCode(caller, uid);
  };

  //  Adding New Integration
  public shared({ caller }) func newIntegration(request : T.NewIntegrationRequest) : async T.NewIntegrationResult {
      assert not _isCanister(caller);
      assert _isOwner(caller, request.uid);

      await _addIntegration(request);
  };

  //  ----------- Directly called private functions

  //  Encoding
  private func _registerTag(
    caller : Principal, 
    uid : T.TagUid
    ) : async T.TagEncodeResult {
      let new_transfer_code = await Helpers.generateKey();
      let new_salt = await Helpers.generateKey();

      let new_tag = {
        index = tag_total;
        ctr = 0 : Nat32;
        cmacs = [];
        owner = caller;
        hashed_transfer_code = ?Helpers.hashSecret(new_transfer_code);
        salt = new_salt;
        active_integrations = [];
        last_ownership_change = Time.now();
        creation_date = Time.now();
      };

      tags.put(uid, new_tag);
      tag_total += 1;

      let result = {
        key = await Helpers.generateKey();
        transfer_code = new_transfer_code;
      }; 

      return result;
  };

  private func _addCMACs(
    uid : T.TagUid, 
    data : [Hex.Hex]
    ) : T.ImportCMACResult {
      switch (tags.get(uid)) {
        case (?tag) {
          let new_tag : T.Tag = {
            index = tag.index;
            ctr = tag.ctr;
            cmacs = data;
            owner = tag.owner;
            hashed_transfer_code = tag.hashed_transfer_code;
            salt = tag.salt;
            active_integrations = tag.active_integrations;
            last_ownership_change = tag.last_ownership_change;
            creation_date = tag.creation_date;
          };

          tags.put(uid, new_tag);
          return #Ok;
        };

        case _ {
          return #Err;
        };
      };
  };

  private func _isAdmin (p: Principal) : Bool {
    return Helpers.contains<Principal>(admins, p, Principal.equal);
  };

  //  Scan
  private func _scan(
    caller : Principal, 
    scan : T.Scan
    ) : T.ScanResult {
      switch (tags.get(scan.uid)) {
        case (?tag) {
          var new_owner_principal = tag.owner;  //  The new value for the Principal "owner" value for this tag.
          var new_owner_bool = false;  //  The new value for the Boolean "owner" value for the response.
          var new_owner_changed = false;
          var new_transfer_code = Option.get(tag.hashed_transfer_code, "");
          var new_last_ownership_change = tag.last_ownership_change;
          var new_locked = true;

          //  Check CMAC
          if (tag.cmacs[Nat32.toNat(scan.ctr)] != scan.cmac) {
            return #Err(#InvalidCMAC);
          };

          //  Check Count
          if (tag.ctr >= scan.ctr) {
            return #Err(#ExpiredCount);
          };

          //  Check if already owner
          if (tag.owner == caller) {
            new_owner_bool := true;
          };

          //  Check Transfer Code
          if (new_transfer_code != "") {
            let new_transfer_code_hash = Helpers.hashSecret(scan.transfer_code); 

            if (new_transfer_code == new_transfer_code_hash) {

              //  Handle current owner scanning an unlocked tag
              if (tag.owner == caller) {
                new_locked := false;

              //  Handle new owner claiming ownership
              } else {
                new_owner_principal := caller;
                new_transfer_code := "";
                new_last_ownership_change := Time.now();
                new_owner_bool := true;
                new_owner_changed := true;
              };
            };
          };

          //  Updating Tag
          let new_tag : T.Tag = {
            index = tag.index;
            ctr = scan.ctr;  //  Update count to the most recent scan.
            cmacs = tag.cmacs;
            owner = new_owner_principal;  //  Update owner.
            hashed_transfer_code = ?new_transfer_code;  //  Update transfer code
            salt = tag.salt;
            active_integrations = tag.active_integrations;
            last_ownership_change = new_last_ownership_change;  //  Update last ownership change
            creation_date = tag.creation_date;
          };

          tags.put(scan.uid, new_tag);

          //  Preparing Result
          var result : T.ScanResponse = {
            owner = new_owner_bool;
            owner_changed = new_owner_changed;
            locked = new_locked;
            integrations = _getIntegrationResults(scan.uid, tag.salt, tag.active_integrations);
            scans_left = 10_000 - scan.ctr;
            years_left = Helpers.calculateYearsLeft(tag.creation_date);
          };

          return #Ok(result);
        };

        case _ {
          return #Err(#TagNotFound);
        };
      };
  };

  //  Access integration
  private func _generateAccessCode(request : T.AccessRequest) : async T.AccessResult {
      let new_access_code = await Helpers.generateKey();

      switch (tags.get(request.uid)) {
        case (?tag) {
          let tag_identifier = Helpers.getTagIdentifier(request.uid, request.canister, tag.salt);

          //  Add Validation
          let new_validation_identifier = Helpers.getValidationIdentifier(tag_identifier, request.canister);
          validations.put(new_validation_identifier, tag_identifier);

          switch (integrations.get(tag_identifier)) {
            case (?integration) {
              //  Update Integration
              let new_integration = {
                canister = integration.canister;
                uid = integration.uid;
                hashed_access_code = Helpers.hashSecret(new_access_code);  //  Add new access code
                user = integration.user;
                last_access_key_change = Time.now();  //  Update to now
              };

              integrations.put(tag_identifier, new_integration);

              //  Return result
              let result = {
                validation = new_validation_identifier;
                access_code = new_access_code;
              };

              return #Ok(result);
            };

            case _ {
              return #Err(#IntegrationNotFound);
            };
          };
        };

        case _ {
          return #Err(#SaltNotFound);
        };
      };
  };

  //  Integrators
  private func _addIntegrator(
    caller : Principal, 
    integrator : T.NewIntegrator
    ) {
      let new_integrator = {
        name = integrator.name;
        image = integrator.image;
        description = integrator.description;
        url = integrator.url;
        tags = [];
      };

      integrators.put(caller, new_integrator);
  };

  //  Validation
  private func _validateAccess(
    caller : Principal, 
    request : T.ValidationRequest
    ) : T.ValidationResult {

      switch (validations.get(request.validation)) {
        case (?tag_identifier) {
          
          // Delete validation entry, they can only ever be use once
          validations.delete(request.validation);

          switch (integrations.get(tag_identifier)) {
            case (?integration) {
              
              //  Confirm not expired
              let time_since = Time.now() - integration.last_access_key_change;
              let ten_minutes = 1_000_000_000 * 60 * 10;
              if (time_since > ten_minutes) {
                return #Err(#Expired);
              };

              //  Confirm access code validity
              let new_hashed_access_code = Helpers.hashSecret(request.access_code);
              if (new_hashed_access_code != integration.hashed_access_code) {
                return #Err(#Invalid);
              };

              //  Confirm caller is authorized
              if (integration.canister != caller) {
                return #Err(#NotAuthorized);
              };

              //  Get Tag
              switch (tags.get(integration.uid)) {
                case (?tag) {
                  let new_previous_user = integration.user;
                  let new_last_access_key_change = integration.last_access_key_change;

                  //  Update Integration
                  let new_integration = {
                    canister = integration.canister;
                    uid = integration.uid;
                    hashed_access_code = integration.hashed_access_code;
                    user = ?request.user;  //  Update to include current user.
                    last_access_key_change = integration.last_access_key_change;
                  };

                  integrations.put(tag_identifier, new_integration);

                  //  Prepare Result
                  let result = {
                    tag = tag_identifier;
                    current_user = request.user;
                    previous_user = new_previous_user;
                    last_ownership_change = tag.last_ownership_change;
                    last_access_key_change = new_last_access_key_change;
                  };

                  return #Ok(result);
                };

                case _ {
                  return #Err(#TagNotFound);
                };
              };
            };

            case _ {
              return #Err(#IntegrationNotFound);
            };
          };
        };

        case _ {
          return #Err(#ValidationNotFound);
        };
      };
  };

  //  Tag Info
  private func _getTagInfo(
    caller : Principal, 
    tagIdentifier : T.TagIdentifier
    ) : T.TagInfoResult {
      switch (integrations.get(tagIdentifier)) {
        case (?integration) {

          //  Confirm canister is authorized
          if (caller != integration.canister) {
            return #Err(#NotAuthorized);
          };
          
          //  Get Tag
          switch (tags.get(integration.uid)) {
            case (?tag) {
              
              //  Prepare Result
              let result = {
                current_user = integration.user;
                last_ownership_change = tag.last_ownership_change;
                last_access_key_change = integration.last_access_key_change;
              };

              return #Ok(result);
            };

            case _ {
              return #Err(#TagNotFound);
            };
          };
        };

        case _ {
          return #Err(#IntegrationNotFound);
        };
      };
  };
  
  //  Unlocking
  private func _generateTransferCode(
    caller : Principal, 
    uid : T.TagUid
    ) : async T.UnlockResult {
    
      switch (tags.get(uid)) {
        case (?tag) {
          let new_transfer_code = await Helpers.generateKey();

          let new_tag = {
            index = tag.index;
            ctr = tag.ctr;
            cmacs = tag.cmacs;
            owner = tag.owner;
            hashed_transfer_code = ?Helpers.hashSecret(new_transfer_code);
            salt = tag.salt;
            active_integrations = tag.active_integrations;
            last_ownership_change = tag.last_ownership_change;
            creation_date = tag.creation_date;
          };

          tags.put(uid, new_tag);

          let result = {
            transfer_code = new_transfer_code;
          }; 

          return #Ok(result);
        };

        case _ {
          #Err(#TagNotFound);
        };
      };
  };

  //  Adding New Integration
  private func _addIntegration(request : T.NewIntegrationRequest) : async T.NewIntegrationResult {
      if (not _isCanister(request.canister)) {
        return #Err(#NotCanisterPrincipal);
      };

      switch (integrators.get(request.canister)) {
        case (?integrator) {

          switch (tags.get(request.uid)) {
            case (?tag) {
              let tag_identifier = Helpers.getTagIdentifier(request.uid, request.canister, tag.salt);

              switch (integrations.get(tag_identifier)) {
                case (?integration) {
                  return #Err(#IntegrationAlreadyExists);
                };

                case _ {

                  //  Update Tag
                  let new_tag = {
                    index = tag.index;
                    ctr = tag.ctr;
                    cmacs = tag.cmacs;
                    owner = tag.owner;
                    hashed_transfer_code = tag.hashed_transfer_code;
                    salt = tag.salt;
                    active_integrations = Array.append(tag.active_integrations, [tag_identifier]);  //  Add new tag identifier
                    last_ownership_change = tag.last_ownership_change;
                    creation_date = tag.creation_date;
                  };

                  tags.put(request.uid, new_tag);

                  //  Update Integrator
                  let new_integrator = {
                    name = integrator.name;
                    image = integrator.image;
                    description = integrator.description;
                    url = integrator.url;
                    tags = Array.append(integrator.tags, [tag_identifier]);  //  Add new tag identifier
                  };

                  integrators.put(request.canister, new_integrator);

                  //  Add Integration
                  let new_access_code = await Helpers.generateKey();
                  let new_integration = {
                    canister = request.canister;
                    uid = request.uid;
                    hashed_access_code = Helpers.hashSecret(new_access_code);
                    user = null;
                    last_access_key_change = Time.now();
                  };

                  integrations.put(tag_identifier, new_integration);

                  //  Add Validation
                  let new_validation_identifier = Helpers.getValidationIdentifier(tag_identifier, request.canister);
                  validations.put(new_validation_identifier, tag_identifier);


                  //  Prepare Result
                  let result = {
                    name = integrator.name;
                    canister = request.canister;
                    image = integrator.image;
                    description = integrator.description;
                    url = integrator.url;
                    validation = new_validation_identifier;
                    access_code = new_access_code;
                  };

                  return #Ok(result);
                };
              };
            };

            case _ {
              return #Err(#TagNotFound);
            };
          };
        };

        case _ {
          return #Err(#IntegratorNotFound);
        };
      };
  };

  //  Get Integration Results
  private func _getIntegrationResults(
    uid : T.TagUid, 
    salt : T.AESKey, 
    tagIdentifiers : [T.TagIdentifier]
    ) : [T.IntegrationResult] {
      let result = Buffer.Buffer<T.IntegrationResult>(integrators.size());
      for ((canister, integrator) in integrators.entries()) {
        let tag_identifier = Helpers.getTagIdentifier(uid, canister, salt);
        var new_integrated = false;

        switch (Array.find(tagIdentifiers, func (t : Text) : Bool {t == tag_identifier})) {
          case (?value) {
            new_integrated := true;
          };

          case _ {};
        };

        let integration_result = {
          integrated = new_integrated;
          name = integrator.name;
          image = integrator.image;
          description = integrator.description;
          canister = canister;
          url = integrator.url;
        };

        result.add(integration_result);
      };

      return Buffer.toArray(result);
  };

  //  ----------- Boolean helper functions
  private func _tag_exists(uid : T.TagUid) : Bool {
    return Option.isSome(tags.get(uid));
  };

  private func _isCanister(caller : Principal) : Bool {
    return Helpers.isCanisterPrincipal(caller);
  };

  private func _isOwner(
    caller : Principal, 
    uid : T.TagUid
    ) : Bool {

      switch (tags.get(uid)) {
        case (?tag) {
          return tag.owner == caller;
        };

        case _ {
          return false;
        };
      };
  };

  private func _isIntegrator(caller : Principal) : Bool {
    return Option.isSome(integrators.get(caller));
  };



  //  ----------- System functions
  system func preupgrade() {
    tagsEntries := Iter.toArray(tags.entries());
    integratorsEntries := Iter.toArray(integrators.entries());
    integrationsEntries := Iter.toArray(integrations.entries());
    validationsEntries := Iter.toArray(validations.entries());
  };

  system func postupgrade() {
    tagsEntries := [];
    integratorsEntries := [];
    integrationsEntries := [];
    validationsEntries := [];
  };
};