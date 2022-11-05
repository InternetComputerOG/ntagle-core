<script>
  import { onMount } from "svelte";
  import { auth, scanCredentials, createActor, tag } from "../store/auth";
  import { FontAwesomeIcon } from 'fontawesome-svelte';
  import QRCode from "./QRJS.svelte";

  let template_url = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/tag?m=00000000000000x000000x0000000000000000x00000000000000000000000000000000";
  let errorMsg = "";
  let errorMsgTag1 = "";
  let errorMsgTag2 = "";

  let tag1Uid = "046C2152E11190";
  let tag1Status = true;
  let tag1OwnerPrincipal = "Something went wrong...";
  let tag1Balance = "Something went wrong...";
  let tag1Url = "";
  let tag1Count = 0;

  let tag2Uid = "044A2152E11190";
  let tag2Status = true;
  let tag2OwnerPrincipal = "Something went wrong...";
  let tag2Balance = "Something went wrong...";
  let tag2Url = "";
  let tag2Count = 0;

  let pendingTagData = true;

  let tag1Scanning = false;
  let tag1Scanned = false;
  let didCopyTag1Url = false;

  let tag2Scanning = false;
  let tag2Scanned = false;
  let didCopyTag2Url = false;

  onMount(async () => {
    refreshTagData();
  });

  async function writeTemplate() {
    try {
      const ndef = new NDEFReader();
      await ndef.write({
        records: [{ recordType: "url", data: template_url }]
      });
    } catch (error) {
      console.log(error);
    }
  };

  async function refreshTagData() {
    console.log("Refreshing Demo Tag Data.");
    pendingTagData = true;
    tag1Scanned = false;
    tag2Scanned = false;

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

    let result = await $auth.actor.demoTagData();
    console.log(result);

    if(result.hasOwnProperty("Ok")) {
      tag1Status = result.Ok.tag1.locked;
      tag1OwnerPrincipal = result.Ok.tag1.owner;
      tag1Balance = (Number(result.Ok.tag1.balance) / 100000000).toFixed(2);

      tag2Status = result.Ok.tag2.locked;
      tag2OwnerPrincipal = result.Ok.tag2.owner;
      tag2Balance = (Number(result.Ok.tag2.balance) / 100000000).toFixed(2);
    } else {
      errorMsg = result.Err.msg;
    };

    pendingTagData = false;
  };

  async function tagScan(tag) {
    tag1Scanned = false;
    tag2Scanned = false;

    if (tag == 1) {
      tag1Scanning = true;
      let result = await $auth.actor.demoTagGenerateScan(tag);

      if(result.hasOwnProperty("Ok")) {
        tag1Count = result.Ok.count + 1;
        let count = ("000000" + (Number(result.Ok.count) + 1).toString(16)).slice(-6);
        tag1Url = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/tag?m=" + tag1Uid + "x" + count + "x" + result.Ok.cmac + "x" + result.Ok.transfer_code;
      } else {
        errorMsgTag1 = result.Err.msg;
      };

      tag1Scanning = false;
      tag1Scanned = true;
    } else {
      tag2Scanning = true;
      let result = await $auth.actor.demoTagGenerateScan(tag);

      if(result.hasOwnProperty("Ok")) {
        tag2Count = result.Ok.count + 1;
        let count = ("000000" + (Number(result.Ok.count) + 1).toString(16)).slice(-6);
        tag2Url = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/tag?m=" + tag2Uid + "x" + count + "x" + result.Ok.cmac + "x" + result.Ok.transfer_code;
      } else {
        errorMsgTag2 = result.Err.msg;
      };

      tag2Scanning = false;
      tag2Scanned = true;
    };
  };

  function copyTag1Url(text) {
    if(window.isSecureContext) {
      didCopyTag1Url = true;
      navigator.clipboard.writeText(text);
    }
    setTimeout(() => {
      didCopyTag1Url = false;
    }, 3000)
  };

  function copyTag2Url(text) {
    if(window.isSecureContext) {
      didCopyTag2Url = true;
      navigator.clipboard.writeText(text);
    }
    setTimeout(() => {
      didCopyTag2Url = false;
    }, 3000)
  };

</script>

<h1>Home</h1>
<!-- <button on:click={async () => await writeTemplate()}>Write Template</button> -->

<h2>Simulated Demo Tags</h2>
<p>The NTAG424 NFC tags generate a unique url every time you scan them (by bringing a smartphone within 10cm of the tag). The virtual tags below simulate these scans, so you can try the dapp without physical tags.</p>

<button on:click={refreshTagData}>↻ Refresh Tag Data</button>

{#if errorMsg.length > 0}
  <br><h5>{errorMsg}</h5>
{/if}

<div class="container">
  <h3>Virtual Tag #1</h3>
  <h4><span class="label">Tag: </span>#1244790287045008</h4>
  {#if pendingTagData}
    <div class="loader"></div> Loading tag data...
  {:else}
    <h6><span class="label">Status: </span> 
      {#if tag1Status}
        <span class="locked">LOCKED</span>
      {:else}
        <span class="unlocked">UNLOCKED</span>
      {/if}
    </h6>
    <h6><span class="label"> Owner Principal:</span>{tag1OwnerPrincipal}</h6>
    <h6><span class="label"> Balance:</span>{tag1Balance} ICP</h6>
    {#if !tag1Scanning}
      <button on:click={() => tagScan(1)}>Simulate a scan</button>
    {:else}
      <div class="loader"></div> Generating Scan URL...
    {/if}
    {#if tag1Scanned}
      {#if errorMsgTag1.length > 0}
        <br><h5>{errorMsgTag1}</h5>
      {:else}
        <h3>Virtual Scan #{tag1Count} of 500</h3>
        <div class="qr_code">
          <QRCode codeValue="{tag1Url}" squareSize=140/>
        </div>
        <h6><a href="{tag1Url}" target="_blank" rel="noopener noreferrer">{tag1Url} </a><span class="copy-icon" on:click={() => copyTag1Url(tag1Url)}>
          <FontAwesomeIcon icon="copy" />
          {#if didCopyTag1Url}
              Copied!
          {/if}
        </span></h6>
      {/if}
    {/if}
  {/if}
</div>

<div class="container">
  <h3>Virtual Tag #2</h3>
  <h4><span class="label">Tag: </span>#1207406891700624</h4>
  {#if pendingTagData}
    <div class="loader"></div> Loading tag data...
  {:else}
    <h6><span class="label">Status: </span> 
      {#if tag2Status}
        <span class="locked">LOCKED</span>
      {:else}
        <span class="unlocked">UNLOCKED</span>
      {/if}
    </h6>
    <h6><span class="label">Owner Principal: </span>{tag2OwnerPrincipal}</h6>
    <h6><span class="label">Balance: </span>{tag2Balance} ICP</h6>
    {#if !tag2Scanning}
      <button on:click={() => tagScan(2)}>Simulate a scan</button>
    {:else}
      <div class="loader"></div> Generating Scan URL...
    {/if}
    {#if tag2Scanned}
      {#if errorMsgTag2.length > 0}
        <br><h5>{errorMsgTag2}</h5>
      {:else}
        <h3>Virtual Scan #{tag2Count} of 500</h3>
        <div class="qr_code">
          <QRCode codeValue="{tag2Url}" squareSize=140/>
        </div>
        <h6><a href="{tag2Url}" target="_blank" rel="noopener noreferrer">{tag2Url} </a><span class="copy-icon" on:click={() => copyTag2Url(tag2Url)}>
          <FontAwesomeIcon icon="copy" />
          {#if didCopyTag2Url}
              Copied!
          {/if}
        </span></h6>
      {/if}
    {/if}
  {/if}
</div>

<style>
  .container {
    margin: 30px 0;
    padding: 15px;
    border: 2px solid #fff;
    background-color: rgb(27, 27, 27);
    text-align: left;
  }

  .qr_code {
    padding: 5px;
    background-color: white;
    display: inline-block;
  }

  button {
    margin-left: 0px;
  }

  .label {
    color: rgb(111, 111, 111);
  }

  .container h4, h6 {
    margin: 3px;
  }

</style>