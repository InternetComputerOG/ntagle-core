<script>
  import { onMount } from "svelte";
  import { auth, scanCredentials, createActor, tag } from "../store/auth";
  import QRCode from "./QRJS.svelte";

</script>

<h1>Welcome</h1>
<!-- <button on:click={async () => await writeTemplate()}>Write Template</button> -->
<p>Home page of ntagle core.</p>

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

  h1 {
    margin-top: 60px;
  }

</style>