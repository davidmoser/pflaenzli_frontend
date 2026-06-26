<template>
  <div class="config-container">
    <h1>Configuration</h1>
    <form class="config-form">
      <div class="form-group">
        <label for="interval">Measurement Interval (seconds):</label>
        <input id="interval" v-model.number="config.measurement_interval" type="number">
      </div>

      <div class="form-group">
        <label for="valve_duration">Valve Opening Duration (seconds):</label>
        <input id="valve_duration" v-model.number="config.valve_duration" type="number">
      </div>

      <div class="form-group">
        <label for="pump_duration">Pumping Duration (seconds):</label>
        <input id="pump_duration" v-model.number="config.pump_duration" type="number">
      </div>

      <div class="form-group checkbox-group">
        <input id="measurement_enabled" v-model="config.measurement_enabled" type="checkbox">
        <label for="measurement_enabled">Measurement Enabled</label>
      </div>

      <div class="form-group checkbox-group">
        <input id="pump_enabled" v-model="config.pump_enabled" type="checkbox">
        <label for="pump_enabled">Pump Enabled</label>
      </div>

      <h2>Irrigation Planning</h2>

      <div class="form-group">
        <label for="pump_seconds_per_mm">Pump Seconds per mm ET0:</label>
        <input id="pump_seconds_per_mm" v-model.number="config.pump_seconds_per_mm" type="number" step="any">
      </div>

      <div class="form-group">
        <label for="calc_time">Daily Plan Time:</label>
        <TimeInput id="calc_time" v-model="config.calc_time" />
      </div>

      <div class="form-group">
        <label for="window_start">Watering Window Start:</label>
        <TimeInput id="window_start" v-model="config.window_start" />
      </div>

      <div class="form-group">
        <label for="window_end">Watering Window End:</label>
        <TimeInput id="window_end" v-model="config.window_end" />
      </div>

      <div class="form-group">
        <label for="latitude">Latitude:</label>
        <input id="latitude" v-model.number="config.latitude" type="number" step="any">
      </div>

      <div class="form-group">
        <label for="longitude">Longitude:</label>
        <input id="longitude" v-model.number="config.longitude" type="number" step="any">
      </div>

      <ActionButton
        label="Save Configuration"
        :url="'configuration/1'"
        :requestData="config"
      />
    </form>
  </div>
</template>

<script>
import axios from 'axios';
import ActionButton from './ActionButton.vue';
import TimeInput from './TimeInput.vue';

export default {
  components: {
    ActionButton,
    TimeInput
  },
  data() {
    return {
      config: {
        measurement_interval: null,
        valve_duration: null,
        pump_duration: null,
        measurement_enabled: null,
        pump_enabled: null,
        pump_seconds_per_mm: null,
        calc_time: null,
        window_start: null,
        window_end: null,
        latitude: null,
        longitude: null,
      }
    }
  },
  mounted() {
    this.fetchConfig();
  },
  methods: {
    fetchConfig() {
      axios.get('configuration/1').then(response => {
        this.config = response.data;
      });
    }
  }
}
</script>

<style scoped>
.config-container {
  max-width: 500px;
}

.config-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.checkbox-group {
  flex-direction: row;
  align-items: center; /* Aligns items vertically centered */
  gap: 10px;
}

input[type="number"] {
  width: 100%;
}

label {
  color: var(--color-muted);
}
</style>
