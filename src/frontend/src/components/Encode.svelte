<script>
  import { auth } from "../store/auth";

  let uid;
  let key;
  let transferCode;
  let CMACs = "paste here";

  async function register(uid) {
    let result = await $auth.actor.registerTag(uid);
    key = result.key;
    transferCode = result.transfer_code;
  };

  async function upload(CMACs) {
    data = CMACs.split(",");
    await $auth.actor.importScans(uid, data);
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
<span>https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/?m=00000000000000x000000x0000000000000000x{transferCode}</span>

<h3>Step 3: upload CMACs</h3>
<textarea bind:value={CMACs}></textarea>
<button on:click={upload(CMACs)}>Upload</button>