import { writable } from "svelte/store";
import { idlFactory } from "../../../declarations/relay/relay.did.js";
import { Actor, HttpAgent } from "@dfinity/agent";

/**
 * Creates an actor for the Backend canister
 *
 * @param {{agentOptions: import("@dfinity/agent").HttpAgentOptions, actorOptions: import("@dfinity/agent").ActorConfig}} options
 * @returns {import("@dfinity/agent").ActorSubclass<import("../../../declarations/backend/backend.did")._SERVICE>}
 */
export function createActor(options) {
  const hostOptions = {
    host:
      process.env.DFX_NETWORK === "ic"
        ? `https://${process.env.RELAY_CANISTER_ID}.ic0.app`
        : "http://localhost:8000",
  };
  if (!options) {
    options = {
      agentOptions: hostOptions,
    };
  } else if (!options.agentOptions) {
    options.agentOptions = hostOptions;
  } else {
    options.agentOptions.host = hostOptions.host;
  }

  const agent = new HttpAgent({ ...options.agentOptions });

  // Fetch root key for certificate validation during development
  if (process.env.NODE_ENV !== "production") {
    agent.fetchRootKey().catch((err) => {
      console.warn(
        "Unable to fetch root key. Check to ensure that your local replica is running"
      );
      console.error(err);
    });
  }

  // Creates an actor with using the candid interface and the HttpAgent
  return Actor.createActor(idlFactory, {
    agent,
    canisterId: process.env.RELAY_CANISTER_ID,
    ...options?.actorOptions,
  });
}

export const auth = writable({
  loggedIn: false,
  actor: createActor()
});

export const adminStatus = writable(false);

export const scanCredentials = writable({
  uid: 0,
  ctr: 0,
  cmac: "",
  transfer_code: ""
});

export const tag = writable({
  valid: false,
  owner: false,
  locked: true,
  transfer_code: null,
  wallet: null
});