<script>
  import { auth, tag, scanCredentials } from "../store/auth";

</script>

<div class="container">
  <h1>Tag #{$scanCredentials.uid} | 
    {#if $tag.locked}
      <span class="locked">LOCKED</span>
    {:else}
      <span class="unlocked">UNLOCKED</span>
    {/if}
  </h1>

  {#if $tag.owner}
    <h3>You are the owner of this tag.</h3>
  {:else}
    <h3>You are not the owner of this tag.</h3>
  {/if}

  <!-- <h2>Transfer Code</h2>
  <div class="transfer-code">
    {$tag.transfer_code}
  </div> -->

  <h2>Tag Wallet</h2>
  <div class="wallet-address">
    {$tag.wallet}
  </div>
</div>

<style>
  .container {
    margin: 30px;
    padding: 30px;
    border: 2px solid #fff;
  }

  .locked {
    color: rgb(237, 120, 120);
    font-weight: bold;
  }

  .unlocked {
    color: rgb(69, 203, 69);
    font-weight: bold;
  }

  .wallet-address, .transfer-code {
    font-size: 12px;
  }
</style>