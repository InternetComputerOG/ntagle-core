<p align="left" >
  <img width="240"  src="./assets/logo.png">
</p>

# What is ntagle?
ntagle (a combination of the word "tag" and the concept of "entangled particles" in physics) is a decentralized application which gives developers the ability to integrate web3 assets and experiences into inexpensive, secure, and durable NFC chips which are compatible with any modern smartphone.

This is made possible using the unique properties of [The Internet Computer Protocol](https://internetcomputer.org/), [NTAG 424 DNA chips from NXP](https://www.nxp.com/products/rfid-nfc/nfc-hf/ntag-for-tags-labels/ntag-424-dna-424-dna-tagtamper-advanced-security-and-privacy-for-trusted-iot-applications:NTAG424DNA#:~:text=The%20NTAG%20424%20DNA%20is,with%20crypto%2Dsecure%20access%20permissions.), and [WebNFC](https://w3c.github.io/web-nfc/).

Learn more about this project by [reviewing our hackathon slide deck](https://docs.google.com/presentation/d/1KKktLRiNWqD3ZxWF3WZk9kEblMdr2c3gfrUekiXQa5Q/edit?usp=sharing) or [visiting our Twitter page](https://twitter.com/ntagled). You can also [watch a video](https://twitter.com/ntagled/status/1589126117524647936?s=20&t=R_T8AwXhOiF04_uieulJGQ) of how the process works with physical NFC tags.

# What's the status of this project?
The ntagle team began work in October 2022 with a $25k grant from the [DFINITY Foundation](https://dfinity.org/) which completed in February 2023. During this grant they developed a proof-of-concept, alpha tags, a demo dapp, a functional conference handout product, and a working dapp which can integrate with 3rd party projects.

In addition, the project has gone through security consultation from both DFINITY and the public ICP developers community, and come out with strong positive feedback.

**The next steps include:**
- Executing a sale to distribute tags to more people.
- Upgrading the UI, security, and integration capabilities through a major update.
- Executing a decentralization sale via the SNS.

# How to integrate:
### **WARNING:** This integration method is for testing, education, and experimentation only. It will be improved in the future with updates that are NOT BACKWARD COMPATIBLE, so *do not build anything production* using this integration method.
Here is an [integrator example](https://github.com/InternetComputerOG/ntagle-integrator) repo which can be used for reference, showing how the process below is implemented.

## Step 1: Initialize the Integration
The integrate with ntagle, you'll need to interact with our Secure Dynamic Messaging ("SDM") canister ([gq4xa-gqaaa-aaaal-abmta-cai](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=gq4xa-gqaaa-aaaal-abmta-cai)).

The first thing to do is to have your canister call the **newIntegration** function on the ntagle SDM canister:
```
registerIntegrator : shared NewIntegrator -> ();
```

Where the type **NewIntegrator** is defined as:
```
public type NewIntegrator = {
  url : Text;
  name : Text;
  description : Text;
  image : Text;
};
```

This could be done by creating an **initializeNtagle** function within your canister that can be triggered by an admin:
```
let Ntagle = actor "gq4xa-gqaaa-aaaal-abmta-cai" : NT.SDM;

let my_profile = {
  url = "https://erfdz-cyaaa-aaaal-abm6q-cai.ic0.app/";
  name = "Tradeable HW Wallet";
  description = "Binds an ICP wallet to the tag.";
  image = "https://erfdz-cyaaa-aaaal-abm6q-cai.ic0.app/favicon.svg";
};

public shared({ caller }) func initializeNtagle() {
  assert(_isAdmin(caller)); 
  Ntagle.registerIntegrator(my_profile);
};
```

## Step 2: Validating scans
When a user visits your website to use a ntagle integration, there will be a **Tag Identifier** an **Access Code** added to the URL with this format:
- https:// **[YOUR URL]** /tag?m= **[TAG IDENTIFIER]** x **[ACCESS KEY]**

The **Tag Identifier** is unique to both the tag and your canister, so it cannot be used to track a tag across multiple dapps. The **Access Code** is unique to a particulaer scan of that tag, and if it proves valid you can know that the website vistor who provided this credential (and whatever Principal they logged in with) must have physically scanned the identified tag within the past **10 minutes**, and you use that information within the logic of your canister however you desire.

To validate a scan, your canister needs to call the **validateAccess** function on the ntagle SDM canister:
```
validateAccess : shared ValidationRequest -> async ValidationResult;
```

Where these types are defined as:
```
public type ValidationRequest = {
  user : Principal;
  validation : TagIdentifier;
  access_code : AESKey;
};

public type TagIdentifier = Text;
public type AESKey = Text;

public type ValidationResult = {
  #Ok : ValidationResponse;
  #Err : ValidationError;
};

public type ValidationResponse = {
  tag : TagIdentifier;
  last_access_key_change : Time;
  previous_user : ?Principal;
  current_user : Principal;
  last_ownership_change : Time;
};
  
public type ValidationError = {
  #Invalid;
  #IntegrationNotFound;
  #TagNotFound;
  #NotAuthorized;
  #ValidationNotFound;
  #Expired;
};
```

This could be done by creating a **validateAccess** function within your own canister like this:
```
public shared({ caller }) func validateAccess(request : T.ValidationRequest) : async T.ValidationResult {
  let full_request : NT.ValidationRequest = {
    user = caller;
    validation = request.validation;
    access_code = request.access_code;
  };
    let sdm_result = await Ntagle.validateAccess(full_request);

    // An internal function that applies whatever custom logic you want based on the validation result.
     _validate(caller, sdm_result);
};
```

## Step 3: Getting physical tags
You can [DM ntagle on Twitter](https://twitter.com/ntagled) to request alpha tags for you to use in testing.

In general, projects looking to integrate with ntagle have two options:
1. They can simply announce the integration, and owners of existing ntagle tags can choose to add your integration to their tag and start using it.
2. They can [contact us](https://twitter.com/ntagled) to buy ntagle tags in bulk, and then pre-encode their integration (which could be limited to specific tag Ids) into these tags. Then directly sell their custom web3 physical objects.

Tags can be supplied in multiple form factors including full color PVC cards and 3D prints.