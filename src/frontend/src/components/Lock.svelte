<script>
  import { onMount } from "svelte";
  import { tag, scanCredentials, auth } from "../store/auth";

  let msg = "";
  let compatible_browser = false;
  let inProgress = false;
  let lock_url = "https://gx5ru-liaaa-aaaal-abmtq-cai.ic0.app/tag?m=00000000000000x000000x0000000000000000x00000000000000000000000000000000";

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

  async function lockTag() {
    console.log("User clicked lock button");
    inProgress = true;
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