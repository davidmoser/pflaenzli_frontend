<script setup>
</script>

<template>
  <div id="app">
    <h1>Pflänzli</h1>
    <nav>
      <router-link to="/">Chart</router-link> |
      <router-link to="/actions">Actions</router-link> |
      <router-link to="/config">Configuration</router-link>
    </nav>
    <router-view/>
  </div>
</template>

<style scoped>
#app {
  font-family: 'Arial', sans-serif;
  color: #333;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  color: #4CAF50; /* A green color for the main heading */
}

nav {
  text-decoration: none;
  background-color: #f4f4f4;
  padding: 10px;
  margin-bottom: 20px;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

nav > a {
  text-decoration: none;
  color: #333; /* Consistent text color for all states */
  font-weight: bold;
  margin-right: 10px;
  transition: color 0.3s;
}

nav > a:hover,
.router-link-active {
  color: #4CAF50;
}
</style>
