<script>
  import { AccountIdentifier } from "@dfinity/nns";
  import { onMount } from "svelte";
  import { auth, tag, scanCredentials } from "../store/auth";
  import Unlock from "./Unlock.svelte";
  import Lock from "./Lock.svelte";

  let message = "";

  onMount(async () => {

  });

  async function addIntegration(new_canister) {
    console.log("Starting add integration...");
    let request = {
      uid: $scanCredentials.uid,
      canister: new_canister
    };
    let result = await $auth.actor.newIntegration(request);
    console.log(result);
    console.log("Completed add integration...");
  };

  async function useIntegration(integrated_canister, canister_url) {
    console.log("Starting use integration...");
    message = "Loading Dapp...";
    let request = {
      uid: $scanCredentials.uid,
      canister: integrated_canister
    };
    let result = await $auth.actor.requestAccess(request);
    console.log(result);
    if ( result.hasOwnProperty("Ok") ) {
      let access_url = canister_url + "tag?m=" + result.Ok.validation + "x" + result.Ok.access_code;
      console.log("Completed use integration...");
      window.open(access_url, '_blank');
    } else if ( result.hasOwnProperty("Err") ) {
      message = result.Err.msg;
    };
  };

</script>

<div class="container">
  <h1>Tag Info</h1>
  <h2>#{$scanCredentials.uid} | 
    {#if $tag.locked}
      <span class="locked">LOCKED</span>
    {:else}
      <span class="unlocked">UNLOCKED</span>
    {/if}
  </h2>

  {#if $tag.owner}
    <h3>You are the owner of this tag.</h3>
    {#if $tag.locked}
      <Unlock />
    {:else}
      <Lock />
    {/if}
  {:else}
    <h3>You are not the owner of this tag.</h3>
  {/if}
</div>

<div class="container">
  <h2>Integrated Dapps</h2>
  {#each $tag.integrations as integration}
    {#if (integration.integrated)}
      <div>
        <img src={integration.image} alt={integration.name} />
      </div>
      <h3>{integration.name}</h3>
      <h6>{integration.canister}</h6>
      <p>{integration.description}</p>
      <a href={integration.url} target="_blank" rel="noreferrer"><h4>Visit Website</h4></a>
      <button on:click={useIntegration(integration.canister, integration.url)}>Use Integration</button>
    {/if}
  {/each}
  <h1>{message}</h1>
</div>

<div class="container">
  <h2>Available Dapps</h2>
  {#each $tag.integrations as integration}
    {#if (!integration.integrated)}
      <div>
        <img src={integration.image} alt={integration.name} />
      </div>
      <h3>{integration.name}</h3>
      <h6>{integration.canister}</h6>
      <p>{integration.description}</p>
      <a href={integration.url} target="_blank" rel="noreferrer"><h4>Visit Website</h4></a>
      <button on:click={addIntegration(integration.canister)}>Add Integration</button>
    {/if}
  {/each}
</div>

<style>
  .container {
    margin: 30px 0;
    padding: 15px;
    border: 1px solid white;
  }

  h6 {
    margin-top: 0px;
  }

  @media (min-width: 640px) {
    .container {
      max-width: 800px;
      margin: 0 auto;
    }
  }
</style>