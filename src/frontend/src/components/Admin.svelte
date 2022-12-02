<script>
  import { auth } from "../store/auth";

  let uid;
  let key = "nothing yet";
  let transferCode = "nothing yet";
  let CMACs = "paste here";
  let ctr = "000000";
  let cmac = "0";
  let scanResult;
  let default_integrator = {
    name: "",
    image: "",
    description: "",
    url: "",
    tags: []
  };
  let integrators = ["", default_integrator];

  async function register(rawUid) {
    console.log("Starting Register Tag...");
    let uid = rawUid;
    let result = await $auth.actor.registerTag(uid);
    console.log(result);
    key = result.key;
    transferCode = result.transfer_code;
    console.log("Completed Register Tag...");
  };

  async function upload(CMACs, rawUid) {
    console.log("Starting Upload...");
    let uid = rawUid;
    let data = CMACs.split(",");
    let result = await $auth.actor.importCMACs(uid, data);
    console.log(result);
    console.log("Completed Upload...");
  };

  async function scan(rawUid, rawCtr, cmac) {
    let uid = parseInt(rawUid, 16);
    let ctr = parseInt(rawCtr, 16);
    scanResult = await $auth.actor.scan(uid, ctr, cmac);
  };

  async function getIntegrators() {
    console.log("Getting Integrators...");
    integrators = await $auth.actor.integratorRegistry();
    console.log(integrators);
  };
</script>

<h1>Admin Dashboard</h1>

<h2>Random Stuff</h2>
<button on:click={getIntegrators}>Get Integrators</button>
<!-- {#each integrators as integrator}
  <div>
    <img src={integrator[1].image} alt={integrator[1].name} />
  </div>
  <h3>{integrator[1].name}</h3>
  <h6>{integrator[0]}</h6>
  <p>{integrator[1].description}</p>
  <a href={integrator[1].url} target="_blank" rel="noreferrer"><h4>Visit Website</h4></a>
  <h5>Tags = [{integrator[1].tags.toString()}]</h5>
{/each} -->

<h2>Encoding</h2>
<h3>Step 1: provide UID</h3>
<input bind:value={uid}>
<button on:click={register(uid)}>Register UID</button>

<h3>Step 2: Get Key & URL w/ Transfer Code</h3>
<h5>Key</h5>
{key}
<h5>URL + Transfer Code</h5>
<span>https://gx5ru-liaaa-aaaal-abmtq-cai.ic0.app/tag?m=00000000000000x000000x0000000000000000x{transferCode}</span>

<h3>Step 3: upload CMACs</h3>
<textarea bind:value={CMACs}></textarea>
<button on:click={upload(CMACs, uid)}>Upload</button>

<h3>Test A Valid Scan</h3>
<input bind:value={uid}>
<input bind:value={ctr}>
<input bind:value={cmac}>
<input bind:value={transferCode}>
<button on:click={scan(uid, ctr, cmac, transferCode)}>Test Scan</button>
{scanResult}

<style>
  img {
    object-fit: contain;
    width: 100%;
    height: 80px;
    display: inline-block;
    margin-top: 24px;
  }
</style>