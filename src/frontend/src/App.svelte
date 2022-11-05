<script>
  import Auth from "./components/Auth.svelte";
  import { auth, adminStatus, tag } from "./store/auth";
  import { library } from '@fortawesome/fontawesome-svg-core';
  import { faCopy } from '@fortawesome/free-solid-svg-icons';
  import { Router, Route, Link } from "svelte-navigator";
  import CanisterIds from "./components/CanisterIds.svelte";
  import Chat from "./components/Chat.svelte";
  import CMAC from "./components/CMAC.svelte";
  import Encode from "./components/Encode.svelte";
  import Home from "./components/Home.svelte";
  import Links from "./components/Links.svelte";
  import Tag from "./components/Tag.svelte";
  import Unlock from "./components/Unlock.svelte";

  // Add fontawesome Copy icon
  const icons = [faCopy];
  library.add(icons);
</script>

<Router>
  <main>

    <Link to="/">
      <div class="container">
        <img src="images/ntagle-logo.png" alt="ntagle logo" />
      </div>
    </Link>

    <Route path="/">
      <Home />
    </Route>

    <Route path="tag">
      <Auth />
      {#if $tag.valid}
        <!-- {#if $tag.locked && $tag.owner}
          <Unlock />
        {/if} -->
        <Tag />
        {#if $tag.owner}
          <Chat />
        {/if}
      {/if}
      {#if $auth.loggedIn && $adminStatus}
        <CMAC />
        <Encode />
        <Links />
        <CanisterIds />
      {/if}
    </Route>
  
  </main>
</Router>

<style>

  :global(body) {
    font-family: "Open Sans", sans-serif;
  }

  :global(button) {
    font-family: Exo, sans-serif;
  }

  img {
    object-fit: contain;
    width: 100%;
    height: 80px;
    display: inline-block;
    margin-bottom: 64px;
    margin-top: 24px;
  }

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
