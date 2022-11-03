<script>
  import { onMount } from "svelte";
  import { tag } from "../store/auth";
  
  let msg = "";
  let compatible_browser = false;
  let inProgress = false;
  let unlock_url = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/?m=00000000000000x000000x0000000000000000x" + $tag.transfer_code;

  onMount(async () => {
    if(!("NDEFReader" in window)) {
      msg = "Web NFC is not available. Use Chrome on Android to unlock.";
    } else {
      compatible_browser = true;
    };
  });

  async function unlockTag() {
    console.log("User clicked unlock button");
    msg = "Please tap the tag to your phone";
    inProgress = true;

    try {
      const ndef = new NDEFReader();
      await ndef.write({
        records: [{ recordType: "url", data: unlock_url }]
      });
      msg = "Tag Successfully Unlocked.";

      setTimeout(() => {
        tag.update(() => ({
          valid: $tag.valid,
          owner: $tag.owner,
          locked: false,
          transfer_code: $tag.valid,
          wallet: $tag.valid,
        }));
      }, 3000);
    } catch (error) {
      console.log(error);
      inProgress = false;
    }
  };

</script>

<div class="message">
  {msg}
</div>
{#if compatible_browser}
  {#if !inProgress}
    <button on:click={async () => await unlockTag()}>🔓 Unlock</button>
  {:else}
    <div class="loader"></div> Unlocking...
  {/if}
{/if}