<script>
  import { onMount } from "svelte";
  import { tag, scanCredentials, auth } from "../store/auth";
  

  let msg = "";
  let compatible_browser = false;
  let inProgress = false;
  let unlock_url = "https://gx5ru-liaaa-aaaal-abmtq-cai.ic0.app/tag?m=00000000000000x000000x0000000000000000x";

  onMount(async () => {
    inProgress = false;
    isCompatibleBrowser()
  });

  function isCompatibleBrowser() {
    if ("NDEFReader" in window) {
      compatible_browser = true;
    } else {
      msg = "Web NFC is not available. Use Chrome on Android to unlock this tag.";
    };
  }

  async function unlockTag() {
    console.log("User clicked unlock button");
    inProgress = true;
    msg = "Please wait...";

    let result = await $auth.actor.unlock($scanCredentials.uid);
    if ( result.hasOwnProperty("Ok") ) {
      try {
        unlock_url = unlock_url + result.Ok.transfer_code;
        msg = "Please tap the tag to your phone";
        const ndef = new NDEFReader();
        let ignoreRead = true;
        ndef.onreading = (event) => {
          if (ignoreRead) {
            return; // write pending, ignore read.
          };
        };
        await ndef.write({
          records: [{ recordType: "url", data: unlock_url }]
        });
        msg = "Tag Successfully Unlocked.";

        setTimeout(() => {
          tag.update(() => ({
            valid: $tag.valid,
            owner: $tag.owner,
            owner_changed: $tag.owner_changed,
            locked: false,
            integrations: $tag.integrations,
            scans_left: $tag.scans_left,
            years_left: $tag.years_left,
          }));
        }, 3000);
      } catch (error) {
        console.log(error);
        inProgress = false;
      };
    } else if ( result.hasOwnProperty("Err") ) {
      msg = "something went wrong, could not fetch transfer code...";
    };
    inProgress = false;
  };

</script>

<div class="message">
  {msg}
</div>
{#if compatible_browser}
  {#if !inProgress}
    <button on:click={async () => await unlockTag()}>🔓 Unlock Tag</button>
  {:else}
    <div class="loader"></div> Unlocking...
  {/if}
{/if}