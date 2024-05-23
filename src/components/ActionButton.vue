<template>
  <div class="button-container">
    <button class="action-button" @click="handleClick" :disabled="loading">
      <span>{{ label }}</span>
      <span v-if="loading" class="loader"></span>
    </button>
    <span v-if="success" class="status success-check">&#10003;</span>
    <span v-if="error" class="status error-cross">&#10007;</span>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: {
    label: {
      type: String,
      required: true
    },
    url: {
      type: String,
      required: true
    },
    requestData: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      loading: false,
      success: false,
      error: false
    };
  },
  methods: {
    async handleClick() {
      this.setLoading(true);
      this.setSuccess(false);
      this.setError(false);
      try {
        if (this.requestData) {
          await axios.put(this.url, this.requestData);
        } else {
          await axios.put(this.url);
        }
        this.setSuccess(true);
      } catch {
        this.setError(true);
      } finally {
        this.setLoading(false);
      }
    },
    setLoading(state) {
      this.loading = state;
    },
    setSuccess(state) {
      this.success = state;
      if (state) {
        setTimeout(() => {
          this.success = false;
        }, 5000);
      }
    },
    setError(state) {
      this.error = state;
      if (state) {
        setTimeout(() => {
          this.error = false;
        }, 5000);
      }
    }
  }
};
</script>

<style scoped>
.button-container {
  display: flex;
  align-items: center;
}

.action-button {
  width: 200px;
  padding: 10px 20px;
  margin: 10px 0;
  font-size: 16px;
  cursor: pointer;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 5px;
  transition: background-color 0.3s;
  position: relative;
}

.action-button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.loader {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  border: 2px solid #f3f3f3;
  border-top: 2px solid #4CAF50;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  animation: spin 1s linear infinite;
}

.status {
  margin-left: 10px;
  font-size: 20px;
}

.success-check {
  color: #4CAF50;
}

.error-cross {
  color: #f44336;
}

@keyframes spin {
  0% {
    transform: translateX(-50%) rotate(0deg);
  }
  100% {
    transform: translateX(-50%) rotate(360deg);
  }
}
</style>
