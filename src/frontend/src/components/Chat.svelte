<script>
  import { paginate, DarkPaginationNav } from 'svelte-paginate';
  import { AccountIdentifier } from "@dfinity/nns";
  import { onMount } from "svelte";
  import { FontAwesomeIcon } from 'fontawesome-svelte';
  import { auth, tag, scanCredentials } from "../store/auth";

  let msg = "Let us use your location to calculate distances from others in the chat, your exact location will remain anonymous.";
  let userMsg = "";
  let havePosition = false;
  let incompatibleBrowser = false;
  let latitude = 0;
  let longitude = 0;
  let chatLog = [
    {
      from: "",
      uid: "",
      time: 100,
      balance: 0,
      message: "default text"
    }, 
    {
      from: "",
      uid: "",
      time: 100,
      balance: 0,
      message: "default text"
    }
  ];
  let currentPage = 1; // first page
  let pageSize = 1;
  let pendingSendMsg = false;
  //$: paginatedChat = paginate({ chatLog, pageSize, currentPage });

  onMount(async () => {
    getPosition();
  });

  function getPosition() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(setPositions, showError);
    } else {
      msg = "Geolocation is not supported by this browser, so we cannot estimate distances.";
      incompatibleBrowser = true;
    };
  };

  function setPositions(position) {
    havePosition = true;
    latitude = position.coords.latitude;
    longitude = position.coords.longitude;
  };

  function showError(error) {
    switch(error.code) {
      case error.PERMISSION_DENIED:
        msg = "User denied the request for Geolocation."
        break;
      case error.POSITION_UNAVAILABLE:
        msg = "Location information is unavailable."
        break;
      case error.TIMEOUT:
        msg = "The request to get user location timed out."
        break;
      case error.UNKNOWN_ERROR:
        msg = "An unknown error occurred."
        break;
    };
  };

  async function postMessage(messageText, currentLatitude, currentLongitude) {
    pendingSendMsg = true;

    if (Boolean(currentLatitude) || Boolean(currentLongitude)) { ////SWAP THIS AROUND USING !
      let new_message = {
        uid: $scanCredentials.uid,
        location: [{
          latitude: currentLatitude,
          longitude: currentLongitude
        }],
        message: messageText
      };

      console.log(new_message);

      chatLog = await $auth.actor.postMessage(new_message);

      console.log(chatLog);
    } else {
      let new_message = {
        uid: $scanCredentials.uid,
        location: [],
        message: messageText
      };

      console.log(new_message);

      chatLog = await $auth.actor.postMessage(new_message);

      console.log(chatLog);
    };

    pendingSendMsg = false;
  };

</script>



{#if $tag.owner}
  {#if !havePosition}
    <p>{msg}</p>
    <button on:click={getPosition} disabled={incompatibleBrowser}>Get location</button>
  {/if}

  <h3>Disclaimer:</h3>
  <p>Please play nice and do not post personal/sensitive information.</p>

  <textarea bind:value={userMsg}></textarea>
  <button on:click={postMessage(userMsg, latitude, longitude)} disabled={pendingSendMsg}>
    {#if pendingSendMsg}
      <div class="loader"></div> Sending Message...
    {:else}
      Send
    {/if}
  </button>

  <ul class="chats">
    {#each chatLog as chatMessage}
      <li class="chatMessage">
        <h6>Principal: {chatMessage.from}</h6>
        <h3>Tag: {chatMessage.uid} | {parseInt((Number(chatMessage.balance) / 100000000).toFixed(4)).toFixed(2)} ICP</h3>
        <h5><strong>{new Date(Number(chatMessage.time) / 1000000)}</strong> | Distance: {chatMessage.location}</h5>
        -----------------
        <p>{chatMessage.message}</p>
      </li>
    {/each}
  </ul>
  
  <!-- <DarkPaginationNav
    totalItems="{chatLog.length}"
    pageSize="{pageSize}"
    currentPage="{currentPage}"
    limit=null
    showStepOptions="{false}"
  /> -->
{/if}

<style>
  .chatMessage {
    border-left: 2px solid #fff;
    margin: 30px 0;
    padding: 15px;
    width: 80%;
    max-width: 500px;
  }
</style>