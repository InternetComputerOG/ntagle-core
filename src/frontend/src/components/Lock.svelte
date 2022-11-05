<script>
  import { onMount } from "svelte";
  import { tag, scanCredentials, auth } from "../store/auth";
  
  let demoTag = false;
  let demoTag1Uid = 1244790287045008;
  let demoTag2Uid = 1207406891700624;

  let msg = "";
  let compatible_browser = false;
  let inProgress = false;
  let lock_url = "https://gkox5-naaaa-aaaal-abhaq-cai.ic0.app/tag?m=00000000000000x000000x0000000000000000x00000000000000000000000000000000";

  onMount(async () => {
    inProgress = false;
    isDemoTag();
    isCompatibleBrowser()
  });

  function isCompatibleBrowser() {
    if (("NDEFReader" in window) || demoTag) {
      compatible_browser = true;
    } else {
      msg = "Web NFC is not available. Use Chrome on Android to unlock this tag.";
    };
  }

  function isDemoTag() {
    if ($scanCredentials.uid == demoTag1Uid || $scanCredentials.uid == demoTag2Uid) {
      demoTag = true;
    };
  };

  async function lockTag() {
    console.log("User clicked lock button");
    inProgress = true;

    if (demoTag) {
      msg = "Please wait while we update your virtual tag.";
      await $auth.actor.lockDemoTag($scanCredentials.uid);

      msg = "Tag Successfully Locked.";

      setTimeout(() => {
        tag.update(() => ({
          valid: $tag.valid,
          owner: $tag.owner,
          locked: true,
          transfer_code: $tag.transfer_code,
          wallet: $tag.wallet,
        }));
      }, 3000);
    } else {

      msg = "Please tap the tag to your phone";

      try {
        const ndef = new NDEFReader();
        await ndef.write({
          records: [{ recordType: "url", data: lock_url }]
        });
        msg = "Tag Successfully Locked.";

        setTimeout(() => {
          tag.update(() => ({
            valid: $tag.valid,
            owner: $tag.owner,
            locked: true,
            transfer_code: $tag.transfer_code,
            wallet: $tag.wallet,
          }));
        }, 3000);
      } catch (error) {
        console.log(error);
        inProgress = false;
      }
    };
  };

</script>

<div class="message">
  {msg}
</div>
{#if compatible_browser}
  {#if !inProgress}
    <button on:click={async () => await lockTag()}>🔒 Lock Tag</button>
  {:else}
    <div class="loader"></div> Locking...
  {/if}
{/if}