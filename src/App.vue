<script setup>
</script>

<template>
  <div id="app">
    <h1>Pflänzli</h1>
    <nav>
      <router-link to="/">Chart</router-link>
      <router-link to="/schedule">Schedule</router-link>
      <router-link to="/actions">Actions</router-link>
      <router-link to="/config">Configuration</router-link>
    </nav>
    <router-view/>
  </div>
</template>

<style scoped>
#app {
  max-width: 1200px;
  margin: 24px auto;
  padding: 24px;
  background-color: var(--color-surface);
  border-radius: 8px;
  box-shadow: var(--shadow);
}

h1 {
  color: var(--color-primary); /* A green color for the main heading */
}

nav {
  display: flex;
  background-color: var(--color-bg);
  margin-bottom: 24px;
  border-radius: var(--radius);
  border-bottom: 1px solid var(--color-border);
  overflow: hidden;
}

nav > a {
  text-decoration: none;
  color: var(--color-text); /* Consistent text color for all states */
  font-weight: bold;
  padding: 12px 18px;
  border-bottom: 3px solid transparent;
  transition: color 0.3s, background-color 0.3s, border-color 0.3s;
}

nav > a:hover {
  color: var(--color-primary);
  background-color: #ececec;
}

.router-link-active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}
</style>
