<script>
  import { AccountIdentifier } from "@dfinity/nns";
  import { onMount } from "svelte";
  import { FontAwesomeIcon } from 'fontawesome-svelte';
  import { auth, tag, scanCredentials } from "../store/auth";

  let walletBalance;
  let withdrawalAddress;
  let withdrawalAmount;


  let pendingWithdrawal = false;
  let pendingBalanceRefresh = true;
  let didCopyDepositAddress = false;
  let hideWithdrawForm = true;

  let withdrawalResult = "";

  onMount(async () => {
    if($auth.loggedIn) {
      getBalance();
    };
  });

  async function getBalance() {
    pendingBalanceRefresh = true;
    let newBalance = await $auth.actor.tagBalance($scanCredentials.uid);
    walletBalance = (Number(newBalance) / 100000000).toFixed(2);
    pendingBalanceRefresh = false;
  }

  async function withdrawICP(uid, address, amount) {
    pendingWithdrawal = true;
    let result;

    if (amount == walletBalance) {
      result = await $auth.actor.withdraw(uid, AccountIdentifier.fromHex(address).bytes);
    } else {
      result = await $auth.actor.withdraw(uid, AccountIdentifier.fromHex(address).bytes, amount);
    };

    if(result.hasOwnProperty("Ok")) {
      withdrawalResult = "ICP transfer successfully completed in block " + result.Ok;
    } else {
      withdrawalResult = "Transfer Failed, the ICP ledger canister returned an error.";
    }
    
    hideWithdrawForm = true;
    pendingWithdrawal = false;
    
    getBalance();
  }

  function copyDepositAddress(text) {
    if(window.isSecureContext) {
      didCopyDepositAddress = true;
      navigator.clipboard.writeText(text);
    }
    setTimeout(() => {
      didCopyDepositAddress = false
    }, 3000)
  };

  function capAmount(amount) {
    if (amount > walletBalance) {
      withdrawalAmount = parseFloat((walletBalance).toFixed(4));
    };
  };
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
</div>

<div class="container">
  <h2>Tag Wallet</h2>
  <div class="wallet-address">
    {$tag.wallet}
    <span class="copy-icon" on:click={() => copyDepositAddress($tag.wallet)}>
      <FontAwesomeIcon icon="copy" />
      {#if didCopyDepositAddress}
          Copied!
      {/if}
    </span>
  </div>

  <h2>ICP Balance</h2>
  <div class="wallet-balance">
    <h3>
      {#if pendingBalanceRefresh}
        <div class="loader"></div> Refreshing...
      {:else}
        {walletBalance}
      {/if}
    </h3>
    {#if !pendingBalanceRefresh}
      <button on:click={getBalance}>↻ Refresh</button>
      <button on:click={() => hideWithdrawForm = !hideWithdrawForm} class:hide={walletBalance <= 0.0001 || !$tag.owner}>
        {#if hideWithdrawForm}
          Withdraw
        {:else}
          Hide Form
        {/if}
      </button>

      <div class:hide={hideWithdrawForm}>
        {#if pendingWithdrawal}
          <br/><div class="loader"></div> Processing Your Withdrawal...
        {:else}
          <h4>Withdrawal Address:</h4>
          <input bind:value={withdrawalAddress}>
          <h4>Withdrawal Amount:</h4>
          <input 
            type="number" 
            bind:value={withdrawalAmount}
            on:change={capAmount(withdrawalAmount)}
          >
          <button 
            on:click={withdrawalAmount = parseFloat((walletBalance).toFixed(4))} 
            class:hide={withdrawalAmount == walletBalance}
          >
            Max
          </button>
          <br />
          <button on:click={withdrawICP($scanCredentials.uid, withdrawalAddress, withdrawalAmount)}>Withdraw <strong>{parseFloat((withdrawalAmount - 0.0001).toFixed(4))}</strong> ICP</button>
        {/if}
      </div>
    {/if}

    {#if withdrawalResult != ""}
      <div class="withdrawal-result">
        {withdrawalResult}
      </div>
  {/if}
  </div>
</div>

<style>
  .container, .withdrawal-result {
    margin: 30px 0;
    border: 2px solid #fff;
    padding: 15px;
  }

  .hide {
    display: none;
  }

  .locked {
    color: rgb(237, 120, 120);
    font-weight: bold;
  }

  .unlocked {
    color: rgb(69, 203, 69);
    font-weight: bold;
  }

  .wallet-address {
    font-size: 12px;
  }

  .copy-icon {
    color: #a9a9a9;
    cursor: pointer;
  }

  .copy-icon:hover {
    color: #d4d4d4;
    cursor: copy;
  }

  input {
    padding: 12px;
    width: 80%;
    border-radius: 6px;
  }

  @media (min-width: 640px) {
    .container {
      max-width: 800px;
      margin: 0 auto;
    }
  }
</style>