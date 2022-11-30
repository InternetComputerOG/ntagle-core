<script>
  import { AccountIdentifier } from "@dfinity/nns";
  import { onMount } from "svelte";
  import { auth, tag, scanCredentials } from "../store/auth";
  import Unlock from "./Unlock.svelte";
  import Lock from "./Lock.svelte";

  let walletBalance = 0;
  let withdrawalAddress;
  let withdrawalAmount = 0;

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
    console.log("Refreshing tag balance.");
    let newBalance = await $auth.actor.tagBalance($scanCredentials.uid);
    walletBalance = parseFloat((Number(newBalance) / 100000000).toFixed(4));
    console.log("New Balance: " + {walletBalance});
    withdrawalAmount = walletBalance;
    pendingBalanceRefresh = false;
  }

  async function withdrawICP(uid, address, amount) {
    pendingWithdrawal = true;
    let result;

    if (amount == walletBalance) {
      result = await $auth.actor.withdraw(uid, AccountIdentifier.fromHex(address).bytes, 0);
    } else {
      result = await $auth.actor.withdraw(uid, AccountIdentifier.fromHex(address).bytes, amount * 100000000);
    };

    if(result.hasOwnProperty("Ok")) {
      withdrawalResult = "ICP transfer successfully completed in block " + result.Ok;
    } else {
      withdrawalResult = "Transfer Failed, the ICP ledger canister returned an error.";
    }
    
    hideWithdrawForm = true;
    pendingWithdrawal = false;
    
    getBalance();

    setTimeout(() => {
      withdrawalResult = "";
    }, 10000)
  }

  function copyDepositAddress(text) {
    if(window.isSecureContext) {
      didCopyDepositAddress = true;
      navigator.clipboard.writeText(text);
    }
    setTimeout(() => {
      didCopyDepositAddress = false;
    }, 3000)
  };

  function capAmount(amount, amountCap) {
    if (amount > amountCap && amount > 0.0001) {
      withdrawalAmount = parseFloat((amountCap).toFixed(4));
    };
  };

  function maxAmount(amountMax) {
    withdrawalAmount = parseFloat((amountMax).toFixed(4));
  };

</script>

<svelte:window on:keyup={capAmount(withdrawalAmount, Number(walletBalance))}/>

<div class="container">
  <h1>Tag Info</h1>
  <h2>#{$scanCredentials.uid} | 
    {#if $tag.locked}
      <span class="locked">LOCKED</span>
    {:else}
      <span class="unlocked">UNLOCKED</span>
    {/if}
  </h2>

  {#if $tag.owner}
    <h3>You are the owner of this tag.</h3>
    {#if $tag.locked}
      <Unlock />
    {:else}
      <Lock />
    {/if}
  {:else}
    <h3>You are not the owner of this tag.</h3>
  {/if}
</div>

<div class="tag-wallet container">
  <h2>Tag Wallet</h2>
  <div class="wallet-address">
    <span class="wallet-address-container">{$tag.wallet}</span>
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
        {walletBalance.toFixed(2)}
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
          <input class="withdraw-address-input" bind:value={withdrawalAddress}>
          <h4>Withdrawal Amount:</h4>
          <input 
            type="number" 
            class="withdraw-amount-input"
            bind:value={withdrawalAmount}
            min=0 
            max={walletBalance}
          >
          <button 
            on:click={maxAmount(Number(walletBalance))} 
            disabled={withdrawalAmount == walletBalance}
          >
            Max
          </button>
          <br />
          {#if withdrawalAmount > 0.0001}
            <button 
              on:click={withdrawICP($scanCredentials.uid, withdrawalAddress, withdrawalAmount)}
            >
              Withdraw <strong>{parseFloat((withdrawalAmount - 0.0001).toFixed(4))}</strong> ICP
            </button>
            <h6>*includes 0.0001 ICP transaction fee</h6>
          {/if}
        {/if}
      </div>
    {/if}

    {#if withdrawalResult != ""}
      <div class="withdrawal-result container">
        {withdrawalResult}
      </div>
  {/if}
  </div>
</div>

<style>
  .container {
    margin: 30px 0;
    padding: 15px;
  }

  .tag-wallet, .withdrawal-result {
    border: 2px solid #fff;
  }

  .tag-wallet {
    background-color: rgb(27, 27, 27);
  }

  h6 {
    margin-top: 0px;
  }

  .hide {
    display: none;
  }

  .wallet-address {
    font-size: 12px;
  }

  .wallet-address-container {
    max-width: 80%;
    overflow-wrap: break-word;
  }

  .copy-icon {
    color: #a9a9a9;
    cursor: pointer;
  }

  .copy-icon:hover {
    color: #d4d4d4;
    cursor: copy;
  }

  .withdraw-address-input {
    width: 80%;
  }

  .withdraw-amount-input {
    width: 200px;
  }

  @media (min-width: 640px) {
    .container {
      max-width: 800px;
      margin: 0 auto;
    }
  }
</style>