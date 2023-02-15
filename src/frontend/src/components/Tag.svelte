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

<div class="tag-container">
  <h1>Tag Info</h1>
  <h2 class="tag-uid">#{$scanCredentials.uid} | 
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


<h2>Integrated Dapps</h2>
<div class="indented">
  {#each $tag.integrations as integration}
    {#if (integration.integrated)}
      <div class="container">
        <div class="img-container">
          <img src={integration.image} alt={integration.name} />
        </div>
        <h1>{integration.name}</h1>
        <h6>Canister ID: {integration.canister}</h6>
        <h4>Description</h4>
        <p>{integration.description}</p>
        <a href={integration.url} target="_blank" rel="noreferrer"><h4>Visit Website</h4></a>
        <button on:click={useIntegration(integration.canister, integration.url)}>Use Integration</button>
      </div> 
    {/if}
  {/each}
  <h1>{message}</h1>
</div>


<h2>Available Dapps</h2>
<div class="indented">
  {#each $tag.integrations as integration}
    {#if (!integration.integrated)}
      <div class="container">
        <div class="img-container">
          <img src={integration.image} alt={integration.name} />
        </div>
        <h3>{integration.name}</h3>
        <h6>Canister ID: {integration.canister}</h6>
        <h4>Description</h4>
        <p>{integration.description}</p>
        <a href={integration.url} target="_blank" rel="noreferrer"><h4>Visit Website</h4></a>
        <button on:click={addIntegration(integration.canister)}>Add Integration</button>
      </div>
    {/if}
  {/each}
</div>



<style>
  .container {
    margin: 30px 0;
    padding: 15px;
    border: 1px solid white;
    text-align: left;
    border-radius: 10px;
  }

  h1 {
    margin-bottom: 0px;
  }

  

  h2 {
    margin-top: 80px;
  }

  .tag-uid {
    margin-top: 0px;
  }

  .tag-container {
    margin: 30px 0;
    padding: 15px;
    border: 4px solid white;
    text-align: left;
    border-radius: 20px;
  }

  button {
    margin-left: 0px;
  }

  .img-container {
    padding: 20px;
    background-color: white;
    border-radius: 15px;
    display: inline-block;
  }

  img {
    object-fit: contain;
    height: 60px;
    display: inline-block;
    margin: 0px;
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