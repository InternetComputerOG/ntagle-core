<script>
  import { AuthClient } from "@dfinity/auth-client";
  import { onMount } from "svelte";
  import { adminStatus, auth, createActor, scanCredentials, tag } from "../store/auth";
  import { accountIdentifierFromBytes } from "../utils/helpers";

  /** @type {AuthClient} */
  let client;
  let url = window.location.href;

  if (url.length < 121) {
    window.location.href = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/";
  };

  let uid = parseInt(url.slice(50,64), 16);
  let ctr = parseInt(url.slice(65,71), 16);
  let cmac = url.slice(72,88);
  let transferCode = url.slice(89,121);
  let loading = false;
  console.log("url: " + url);
  console.log("uid: " + uid);
  console.log("ctr: " + ctr);
  console.log("cmac: " + cmac);
  console.log("transfer code: " + transferCode);

  let message = "Please login to validate your scan.";

  scanCredentials.update(() => ({
    uid: uid,
    ctr: ctr,
    cmac: cmac,
    transfer_code: transferCode
  }));

  onMount(async () => {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      loading = true;
      message = "Please wait...";
      handleAuth();
    }
  });

  function handleAuth() {
    auth.update(() => ({
      loggedIn: true,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      })
    }));

    // isAdmin();
    validateScan();
  };

  async function validateScan() {
    let scan_param = {
      uid: uid,
      ctr: ctr,
      cmac: cmac,
      transfer_code: transferCode
    };

    let result = await $auth.actor.scan(scan_param);
    if ( result.hasOwnProperty("Ok") ) {
      tag.update(() => ({
        valid: true,
        owner: result.Ok.owner,
        locked: result.Ok.locked,
        transfer_code: result.Ok.transfer_code,
        wallet: accountIdentifierFromBytes(result.Ok.wallet)
      }));
      message = "Scan validated!";
      setTimeout(() => {
        message = "";
      }, 5000)
    } else if ( result.hasOwnProperty("Err") ) {
      message = result.Err.msg;

      setTimeout(() => {
        window.location.href = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/";
      }, 3000)
    } else {
      message = "Something went wrong, your scan could not be validated."
    };
    loading = false;
  };

  async function isAdmin() {
    if ( await $auth.actor.isAdmin() ) {
      adminStatus.update(() => (true));
    };
  };

  function login() {
    loading = true;
    message = "Please wait...";
    client.login({
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:8000/#authorize`,
      onSuccess: handleAuth,
    });
  };

  async function logout() {
    await client.logout();

    auth.update(() => ({
      loggedIn: false,
      actor: createActor(),
      admin: false
    }));

    scanCredentials.update(() => ({
      uid: 0,
      ctr: 0,
      cmac: "",
      transfer_code: ""
    }));

    tag.update(() => ({
      valid: false,
      owner: false,
      locked: true,
      transfer_code: null,
      wallet: null
    }));

    message = "You've successfully logged out.";

    setTimeout(() => {
      window.location.href = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/";
    }, 3000)
  };
</script>

<div class="container">
  {#if !loading}
    {#if $auth.loggedIn}
      <div>
        <button on:click={logout}>Log out</button>
      </div>
    {:else}
      <button on:click={login}>Log in with Internet Identity</button>
    {/if}
  {/if}
  <h3>{#if loading}<div class="loader"></div>{/if}{" " + message}</h3>
</div>

<style>
  .container {
    margin: 30px 0 30px;
    padding: 15px;
  }
</style>
