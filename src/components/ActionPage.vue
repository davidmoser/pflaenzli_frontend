<template>
  <div class="actions-container">
    <h1>Control Actions</h1>
    <button class="action-button" @click="startPump">Start Pump</button>
    <button class="action-button" @click="stopPump">Stop Pump</button>
    <button class="action-button" @click="resetPump">Reset Pump</button>
    <button class="action-button" @click="triggerMeasurement">Trigger Measurement</button>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  methods: {
    startPump() {
      axios.put('http://localhost:8000/api/pump/start');
    },
    stopPump() {
      axios.put('http://localhost:8000/api/pump/stop');
    },
    resetPump() {
      axios.put('http://localhost:8000/api/pump/reset');
    },
    triggerMeasurement() {
      axios.put('http://localhost:8000/api/sensor/trigger');
    }
  }
}
</script>

<style scoped>
.actions-container {
  display: flex;
  flex-direction: column;
  align-items: start;
  padding: 5px;
}

.action-button {
  width: 200px; /* Ensures all buttons have the same width */
  padding: 10px 20px;
  margin: 10px 0; /* Vertical spacing between buttons */
  font-size: 16px;
  cursor: pointer;
  background-color: #4CAF50; /* Green background */
  color: white; /* White text */
  border: none;
  border-radius: 5px;
  transition: background-color 0.3s;
}

.action-button:hover {
  background-color: #367c39; /* Darker shade of green on hover */
}
</style>