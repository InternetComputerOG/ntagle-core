<script>
  import { auth } from "../store/auth";
  import { hexToBytes, toHexString } from "../utils/helpers";

  let uid;
  let ctr;
  let cmac;
  let decrypt_result = 0;
  let encrypt_result = 0;
  let key_result;
  let bytes_result;

  let reflect_result = {
    uid: 0,
    ctr: 0,
    cmac: 0
  };

  async function reflect(uid, ctr, cmac) {
    console.log(uid + ", " + ctr + ", " + cmac);

    let params = {
      uid: hexToBytes(uid),
      ctr: hexToBytes(ctr),
      cmac: hexToBytes(cmac)
    };

    console.log(params);

    reflect_result = await $auth.actor.reflect(params);

    console.log(reflect_result);
  };

  async function decrypt(uid, ctr, cmac) {
    console.log(uid + ", " + ctr + ", " + cmac);

    let params = {
      uid: hexToBytes(uid),
      ctr: hexToBytes(ctr),
      cmac: hexToBytes(cmac)
    };

    console.log(params);

    decrypt_result = await $auth.actor.decrypt(params);

    console.log(decrypt_result);
  };

  async function show_key() {
    key_result = await $auth.actor.show_key();

    console.log(key_result);
  };

  async function cmac_bytes(uid, ctr, cmac) {
    console.log(uid + ", " + ctr + ", " + cmac);

    let params = {
      uid: hexToBytes(uid),
      ctr: hexToBytes(ctr),
      cmac: hexToBytes(cmac)
    };

    console.log(params);

    bytes_result = await $auth.actor.text_to_array(params);

    console.log(bytes_result);
  };

  async function encrypt(uid, ctr, cmac) {
    console.log(uid + ", " + ctr + ", " + cmac);

    let params = {
      uid: hexToBytes(uid),
      ctr: hexToBytes(ctr),
      cmac: hexToBytes(cmac)
    };

    console.log(params);

    encrypt_result = await $auth.actor.encrypt(params);

    console.log(encrypt_result);
  };

</script>

<input bind:value={uid}>
<input bind:value={ctr}>
<input bind:value={cmac}>

<button on:click={reflect(uid,ctr,cmac)}>Reflect Back</button>
<button on:click={decrypt(uid,ctr,cmac)}>Try Decrypt</button>
<button on:click={show_key()}>Show Key</button>
<button on:click={cmac_bytes(uid,ctr,cmac)}>CMAC to Bytes</button>
<button on:click={encrypt(uid,ctr,cmac)}>Try Encrypt</button>

<code>
  <br />
  reflected uid: 
  {reflect_result.uid}
  <br /> {toHexString(reflect_result.uid)}
  <br/>
  reflected count: 
  {reflect_result.ctr}
  <br /> {toHexString(reflect_result.ctr)}
  <br />
  {parseInt(toHexString(reflect_result.ctr), 16)}
  <br/>
  reflected CMAC: 
  {reflect_result.cmac}
  <br /> {toHexString(reflect_result.cmac)}
  <br />
  <br />
  decrypted CMAC: 
  {decrypt_result}
  <br /> {toHexString(decrypt_result)}
  <br />
  secret key: 
  {key_result}
  <br />
  reflected CMAC (in bytes):
  {reflect_result.cmac}
  <br />
  encrypted CMAC:
  {encrypt_result}
  <br /> {toHexString(encrypt_result)}
</code>