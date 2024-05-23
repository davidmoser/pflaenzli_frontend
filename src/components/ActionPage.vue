<template>
  <div class="actions-container">
    <h1>Control Actions</h1>
    <ActionButton label="Start Pump" url="pump/start" />
    <ActionButton label="Stop Pump" url="pump/stop" />
    <ActionButton label="Reset Pump" url="pump/reset" />
    <ActionButton label="Trigger Measurement" url="sensor/trigger" />
  </div>
</template>

<script>
import ActionButton from './ActionButton.vue';

export default {
  components: {
    ActionButton
  }
};
</script>

<style scoped>
.actions-container {
  display: flex;
  flex-direction: column;
  align-items: start;
  padding: 5px;
}
</style>
