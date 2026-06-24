<template>
  <div class="schedule-container">
    <h2>Today's Watering Schedule</h2>

    <div class="summary">
      <span>ET₀: {{ schedule ? schedule.et0 + ' mm' : '—' }}</span>
      <span>Pump actions planned: {{ actions.length }}</span>
    </div>

    <!-- Read-only view -->
    <template v-if="!editing">
      <p v-if="actions.length === 0" class="empty">No actions scheduled for today.</p>
      <ul class="action-list">
        <li v-for="action in actions" :key="action.id" class="action-row">
          <span class="time-label">{{ action.time }}</span>
        </li>
      </ul>
      <button class="icon-button edit-button" @click="editing = true" title="Edit">
        <Pencil :size="18" />
      </button>
    </template>

    <!-- Edit view -->
    <template v-else>
      <p v-if="actions.length === 0" class="empty">No actions scheduled for today.</p>
      <ul class="action-list">
        <li v-for="action in actions" :key="action.id" class="action-row">
          <input type="time" v-model="action.time" @change="updateAction(action)">
          <button class="delete-button" @click="deleteAction(action)" title="Delete">
            <Trash2 :size="18" />
          </button>
        </li>
      </ul>
      <div class="add-row">
        <input type="time" v-model="newTime">
        <button class="add-button" @click="addAction" :disabled="!newTime" title="Add action">
          <Plus :size="18" />
        </button>
      </div>
      <button class="done-button" @click="editing = false">Done</button>
    </template>
  </div>
</template>

<script>
import axios from 'axios';
import { Pencil, Trash2, Plus } from 'lucide-vue-next';

// The API uses "HH:MM:SS"; <input type="time"> uses "HH:MM".
function toInput(time) {
  return time ? time.slice(0, 5) : '';
}

function toApi(time) {
  return time && time.length === 5 ? `${time}:00` : time;
}

// Local "today" as YYYY-MM-DD (en-CA yields ISO date format).
function localToday() {
  return new Date().toLocaleDateString('en-CA');
}

export default {
  components: { Pencil, Trash2, Plus },
  data() {
    return {
      actions: [],
      newTime: '',
      editing: false,
      schedule: null,
    };
  },
  mounted() {
    this.fetchActions();
    this.fetchSchedule();
  },
  methods: {
    fetchActions() {
      axios.get('scheduled-pump').then(response => {
        this.actions = response.data.map(a => ({...a, time: toInput(a.time)}));
      });
    },
    fetchSchedule() {
      axios.get('schedule', {params: {schedule_date: localToday()}}).then(response => {
        this.schedule = response.data[0] || null;
      });
    },
    addAction() {
      if (!this.newTime) return;
      axios.post('scheduled-pump', {time: toApi(this.newTime)}).then(() => {
        this.newTime = '';
        this.fetchActions();
      });
    },
    updateAction(action) {
      axios.put(`scheduled-pump/${action.id}`, {time: toApi(action.time)}).then(() => {
        this.fetchActions();
      });
    },
    deleteAction(action) {
      axios.delete(`scheduled-pump/${action.id}`).then(() => {
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

.summary {
  display: flex;
  gap: 24px;
  color: #555;
  margin: 8px 0 12px;
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

.time-label {
  font-size: 16px;
  font-variant-numeric: tabular-nums;
}

input[type="time"] {
  padding: 6px;
  font-size: 16px;
}

.add-button {
  padding: 6px 16px;
  font-size: 18px;
  line-height: 1;
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

.icon-button {
  padding: 4px 12px;
  font-size: 18px;
  line-height: 1;
  cursor: pointer;
  background-color: #e0e0e0;
  border: none;
  border-radius: 5px;
}

.icon-button,
.delete-button,
.add-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.done-button {
  margin-top: 8px;
  padding: 6px 16px;
  font-size: 16px;
  cursor: pointer;
  background-color: #2196F3;
  color: white;
  border: none;
  border-radius: 5px;
}
</style>
