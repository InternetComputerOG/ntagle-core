<script>
  import Auth from "./components/Auth.svelte";
  import { auth, adminStatus, tag } from "./store/auth";
  import { library } from '@fortawesome/fontawesome-svg-core';
  import { faCopy } from '@fortawesome/free-solid-svg-icons';
  import CanisterIds from "./components/CanisterIds.svelte";
  import Chat from "./components/Chat.svelte";
  import CMAC from "./components/CMAC.svelte";
  import Encode from "./components/Encode.svelte";
  import Form from "./components/Form.svelte";
  import Links from "./components/Links.svelte";
  import Tag from "./components/Tag.svelte";
  import Unlock from "./components/Unlock.svelte";

  // Add fontawesome Copy icon
  const icons = [faCopy];
  library.add(icons);
</script>

<main>
  <!-- <a
    href="https://dfinity.org"
    target="_blank"
    rel="noopener noreferrer"
    class="logo"
  >
    <img src="images/dfinity.svg" alt="DFINITY logo" />
  </a> -->
  <h1>ntagle (Demo)</h1>
  <Auth />
  {#if $tag.valid}
    {#if $tag.locked && $tag.owner}
      <Unlock />
    {/if}
    <Tag />
    <Chat />
  {/if}
  {#if $auth.loggedIn && $adminStatus}
    <Form />
    <CMAC />
    <Encode />
    <Links />
    <CanisterIds />
  {/if}
</main>

<style>
  /* img {
    height: 22px;
  }
  .logo {
    display: inline-block;
    margin-bottom: 64px;
    margin-top: 24px;
  } */

  main {
    text-align: center;
    padding: 1em;
  }

  h1 {
    text-transform: uppercase;
    font-size: 3em;
    font-weight: 400;
    line-height: 1.09;
  }

  @media (min-width: 640px) {
    main {
      max-width: 800px;
      margin: 0 auto;
    }
    h1 {
      font-size: 4em;
    }
  }
</style>
