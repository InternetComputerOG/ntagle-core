<script>
  import Auth from "./components/Auth.svelte";
  import { auth, adminStatus, tag } from "./store/auth";
  import { Router, Route, Link } from "svelte-navigator";
  import CMAC from "./components/CMAC.svelte";
  import Admin from "./components/Admin.svelte";
  import Home from "./components/Home.svelte";
  import Tag from "./components/Tag.svelte";

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
        <Tag />
      {/if}
      
    </Route>
  {#if $adminStatus}
    <Admin />
    <!-- <CMAC /> -->
  {/if}
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
