<script>
  import { paginate, DarkPaginationNav } from 'svelte-paginate';
  import { AccountIdentifier } from "@dfinity/nns";
  import { onMount } from "svelte";
  import { FontAwesomeIcon } from 'fontawesome-svelte';
  import { auth, tag, scanCredentials } from "../store/auth";
  import { bigIntToUint8Array, toHexString } from "../utils/helpers";

  let msg = "Let us use your location to calculate your distance from others in the chat. Only the smart contract will know your exact location, your privacy will be respected.";
  let userMsg = "";
  let havePosition = false;
  let incompatibleBrowser = false;
  let latitude = 0;
  let longitude = 0;
  let chatLog = [];
  let currentPage = 1; // first page
  let pageSize = 1;
  let pendingSendMsg = false;
  let pendingLoadChats = true;
  //$: paginatedChat = paginate({ chatLog, pageSize, currentPage });

  onMount(async () => {
    // getPosition();
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

    refreshChatLog($scanCredentials.uid, latitude, longitude);
  };

  function showError(error) {
    switch(error.code) {
      case error.PERMISSION_DENIED:
        msg = "You denied the request for Geolocation. The button below will not work because you've blocked our site from requesting location. Click the lock (🔒) symbol in the address bar of your browser to enable location permission for this site. (This is not required, but without it we cannot calculate your distance from others in the chat. Only the smart contract will know your exact location, your privacy will be respected.)"
        break;
      case error.POSITION_UNAVAILABLE:
        msg = "Location information is unavailable for your device."
        break;
      case error.TIMEOUT:
        msg = "The request to get your location timed out."
        break;
      case error.UNKNOWN_ERROR:
        msg = "An unknown error occurred."
        break;
    };

    refreshChatLog($scanCredentials.uid, latitude, longitude)
  };

  async function postMessage(messageText, currentLatitude, currentLongitude) {
    pendingSendMsg = true;

    if (!Boolean(currentLatitude) || !Boolean(currentLongitude)) {
      let new_message = {
        uid: $scanCredentials.uid,
        location: [],
        message: messageText
      };

      console.log(new_message);

      chatLog = await $auth.actor.postMessage(new_message);

      console.log(chatLog);
    } else {
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
    };

    pendingSendMsg = false;
  };

  async function refreshChatLog(uid, currentLatitude, currentLongitude) {
    pendingLoadChats = true;

    if (currentLatitude == 0 || currentLongitude == 0) {
      chatLog = await $auth.actor.getChatLog(uid, []);
    } else {
      chatLog = await $auth.actor.getChatLog(uid, [{
        latitude: currentLatitude,
        longitude: currentLongitude
      }]);
    };
    
    pendingLoadChats = false;
  };

</script>

<div class="container">
  <h1>Tag Owner Chat Board</h1>
  {#if !havePosition}
    <h2>Your Location</h2>
    <p>{msg}</p>
    <button on:click={getPosition} disabled={incompatibleBrowser}>Get location</button>
  {/if}

  <h2>Compose A Message</h2>
  <h6><strong>Disclaimer:</strong> Please play nice and do not post personal/sensitive information.</h6>
  <textarea class="message-input" bind:value={userMsg} rows="8" cols="50"></textarea><br />
  <button on:click={postMessage(userMsg, latitude, longitude)} disabled={pendingSendMsg}>
    {#if pendingSendMsg}
      <div class="loader"></div> Sending Message...
    {:else}
      Send
    {/if}
  </button>

  

  {#if pendingLoadChats}
    <br /><div class="loader"></div> Loading chat history...
  {:else}
    <button on:click={refreshChatLog($scanCredentials.uid, latitude, longitude)}>↻ Refresh</button>
    <ul class="chats">
      {#each chatLog.reverse() as chatMessage}
        <li class="chatMessage">
          <h3>{(new Date(Number(chatMessage.time) / 1000000)).toLocaleString()}</h3>
          <h4><span class="chat-label">Tag:</span> {chatMessage.uid}</h4>
          <!-- {chatMessage.from}
          {console.log(chatMessage.from)} -->
          <h6><span class="chat-label">Principal:</span> {toHexString(chatMessage.from._arr).slice(0,5)}...{toHexString(chatMessage.from._arr).slice(-3)}</h6>
          <!-- <h6><span class="chat-label">Principal:</span> {chatMessage.from}</h6>{console.log(toHexString(chatMessage.from.bigIntToUint8Array()))} -->
          <h6><span class="chat-label">Balance:</span> {parseInt((Number(chatMessage.balance) / 100000000).toFixed(4)).toFixed(2)} ICP</h6>
          <h6><span class="chat-label">Distance:</span> {chatMessage.location}</h6>
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
</div>

<style>
  .container {
    margin: 30px 0;
    padding: 15px;
    text-align: left;
  }

  button {
    margin-left: 0px;
  }

  .chatMessage {
    border-left: 2px solid #fff;
    margin: 30px 0;
    padding: 15px;
    background-color: rgb(27, 27, 27);
  }

  .message-input {
    max-width: 80%;
  }

  .chats {
    list-style: none;
    text-align: left;
    padding-left: 0px;
  }

  .chat-label {
    color: rgb(111, 111, 111);
  }

  .chats li h4, h6 {
    margin: 3px;
  }
</style>