<template>
  <div class="schedule-container">
    <h2>Today's Watering Schedule</h2>
    <p v-if="actions.length === 0" class="empty">No actions scheduled for today.</p>
    <ul class="action-list">
      <li v-for="action in actions" :key="action.id" class="action-row">
        <input type="time" v-model="action.time" @change="updateAction(action)">
        <button class="delete-button" @click="deleteAction(action)" title="Delete">&#10007;</button>
      </li>
    </ul>
    <div class="add-row">
      <input type="time" v-model="newTime">
      <button class="add-button" @click="addAction" :disabled="!newTime">Add action</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

// The API uses "HH:MM:SS"; <input type="time"> uses "HH:MM".
function toInput(time) {
  return time ? time.slice(0, 5) : '';
}

function toApi(time) {
  return time && time.length === 5 ? `${time}:00` : time;
}

export default {
  data() {
    return {
      actions: [],
      newTime: '',
    };
  },
  mounted() {
    this.fetchActions();
  },
  methods: {
    fetchActions() {
      axios.get('schedule').then(response => {
        this.actions = response.data.map(a => ({...a, time: toInput(a.time)}));
      });
    },
    addAction() {
      if (!this.newTime) return;
      axios.post('schedule', {time: toApi(this.newTime)}).then(() => {
        this.newTime = '';
        this.fetchActions();
      });
    },
    updateAction(action) {
      axios.put(`schedule/${action.id}`, {time: toApi(action.time)}).then(() => {
        this.fetchActions();
      });
    },
    deleteAction(action) {
      axios.delete(`schedule/${action.id}`).then(() => {
        this.fetchActions();
      });
    },
  },
};
</script>

<style scoped>
.schedule-container {
  margin: 20px 0;
}

h2 {
  color: #333;
}

.empty {
  color: #777;
}

.action-list {
  list-style: none;
  padding: 0;
}

.action-row,
.add-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 8px 0;
}

input[type="time"] {
  padding: 6px;
  font-size: 16px;
}

.add-button {
  padding: 6px 16px;
  font-size: 16px;
  cursor: pointer;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 5px;
}

.add-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.delete-button {
  padding: 4px 10px;
  font-size: 16px;
  cursor: pointer;
  background-color: #f44336;
  color: white;
  border: none;
  border-radius: 5px;
}
</style>
