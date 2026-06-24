<template>
  <div class="schedule-container">
    <h1>Today's Watering Schedule</h1>

    <div class="summary">
      <div class="summary-card">
        <span class="summary-label">ET₀</span>
        <span class="summary-value">{{ schedule ? schedule.et0 + ' mm' : '—' }}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Pump actions planned</span>
        <span class="summary-value">{{ actions.length }}</span>
      </div>
    </div>

    <div class="times-card">
      <div class="times-header">
        <span class="times-title">Pump Times</span>
        <button v-if="!editing" class="icon-button" @click="editing = true" title="Edit">
          <Pencil :size="18" />
        </button>
        <button v-else class="done-button" @click="editing = false" title="Done">
          <Check :size="18" />
        </button>
      </div>

      <!-- Read-only view -->
      <template v-if="!editing">
        <p v-if="actions.length === 0" class="empty">No actions scheduled for today.</p>
        <ul v-else class="action-list">
          <li v-for="action in actions" :key="action.id" class="action-row">
            <span class="time-label">{{ action.time }}</span>
          </li>
        </ul>
      </template>

      <!-- Edit view -->
      <template v-else>
        <p v-if="actions.length === 0" class="empty">No actions scheduled for today.</p>
        <ul v-else class="action-list">
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
      </template>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import { Pencil, Trash2, Plus, Check } from 'lucide-vue-next';

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
  components: { Pencil, Trash2, Plus, Check },
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
.summary {
  display: flex;
  gap: 16px;
  margin: 8px 0 20px;
}

.summary-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 12px 16px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  background-color: var(--color-surface);
}

.summary-label {
  color: var(--color-muted);
  font-size: 0.9rem;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--color-border);
}

.summary-value {
  padding-top: 8px;
  font-size: 1.4rem;
  font-weight: 700;
}

.times-card {
  padding: 12px 16px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  background-color: var(--color-surface);
}

.times-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 32px;
  padding-bottom: 8px;
  margin-bottom: 8px;
  border-bottom: 1px solid var(--color-border);
}

.times-title {
  color: var(--color-muted);
  font-size: 0.9rem;
  font-weight: 600;
}

.empty {
  color: var(--color-muted);
  margin: 4px 0 0;
}

.action-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.action-row {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.add-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 12px;
}

.time-label {
  font-size: 1rem;
  font-variant-numeric: tabular-nums;
  padding: 4px 10px;
  background-color: var(--color-bg);
  border-radius: var(--radius);
}

button {
  cursor: pointer;
  border: none;
  border-radius: var(--radius);
  color: white;
  font-size: 1rem;
  transition: background-color 0.3s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.add-button {
  padding: 6px 16px;
  background-color: var(--color-primary);
}

.add-button:hover:not(:disabled) {
  background-color: var(--color-primary-dark);
}

.add-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.delete-button {
  padding: 6px 12px;
  background-color: var(--color-danger);
}

.delete-button:hover {
  background-color: var(--color-danger-dark);
}

.icon-button {
  padding: 6px 14px;
  background-color: var(--color-neutral);
  color: var(--color-text);
}

.icon-button:hover {
  background-color: var(--color-neutral-dark);
}

.done-button {
  padding: 6px 14px;
  background-color: var(--color-primary);
}

.done-button:hover {
  background-color: var(--color-primary-dark);
}
</style>
