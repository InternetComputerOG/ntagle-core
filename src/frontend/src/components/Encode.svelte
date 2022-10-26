<script>
  import { auth } from "../store/auth";

  let uid;
  let key = "nothing yet";
  let transferCode = "nothing yet";
  let CMACs = "paste here";
  let ctr = "000000";
  let cmac = "0";
  let scanResult;

  async function register(rawUid) {
    let uid = parseInt(rawUid, 16);
    let result = await $auth.actor.registerTag(uid);
    key = result.key;
    transferCode = result.transfer_code;
  };

  async function upload(CMACs, rawUid) {
    let uid = parseInt(rawUid, 16);
    let data = CMACs.split(",");
    await $auth.actor.importScans(uid, data);
  };

  async function scan(rawUid, rawCtr, cmac) {
    let uid = parseInt(rawUid, 16);
    let ctr = parseInt(rawCtr, 16);
    scanResult = await $auth.actor.scan(uid, ctr, cmac);
  };
</script>

<h1>Encoding</h1>

<h3>Step 1: provide UID</h3>
<input bind:value={uid}>
<button on:click={register(uid)}>Register UID</button>

<h3>Step 2: Get Key & URL w/ Transfer Code</h3>
<h5>Key</h5>
{key}
<h5>URL + Transfer Code</h5>
<span>https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/?m=00000000000000x000000x0000000000000000x{transferCode.toUpperCase()}</span>

<h3>Step 3: upload CMACs</h3>
<textarea bind:value={CMACs}></textarea>
<button on:click={upload(CMACs, uid)}>Upload</button>

<h3>Test A Valid Scan</h3>
<input bind:value={uid}>
<input bind:value={ctr}>
<input bind:value={cmac}>
<button on:click={scan(uid, ctr, cmac)}>Test Scan</button>
{scanResult}