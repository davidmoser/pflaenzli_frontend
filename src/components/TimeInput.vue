<template>
  <!-- 24-hour time text field. Native <input type="time"> renders AM/PM on phones
       whose locale is 12h (and that can't be overridden from the page), so we render
       HH:MM ourselves. Accepts "HH:MM" or "HH:MM:SS"; emits "HH:MM". -->
  <input
    type="text"
    inputmode="numeric"
    placeholder="HH:MM"
    maxlength="5"
    :value="display"
    @focus="focusValue = display"
    @input="onInput"
    @blur="onBlur"
  >
</template>

<script>
const VALID = /^([01]\d|2[0-3]):[0-5]\d$/;

export default {
  name: 'TimeInput',
  props: {
    modelValue: {type: String, default: ''},
  },
  emits: ['update:modelValue', 'change'],
  data() {
    return {display: '', focusValue: ''};
  },
  watch: {
    modelValue: {immediate: true, handler(val) {
      this.display = this.normalize(val);
    }},
  },
  methods: {
    // Accept "HH:MM" or "HH:MM:SS" (the API returns seconds); show "HH:MM".
    normalize(val) {
      const m = val ? String(val).match(/^(\d{1,2}):(\d{2})/) : null;
      return m ? `${m[1].padStart(2, '0')}:${m[2]}` : '';
    },
    onInput(e) {
      // Digits only; auto-insert the colon after the hour so typing "1430" -> "14:30".
      const digits = e.target.value.replace(/\D/g, '').slice(0, 4);
      const out = digits.length > 2 ? `${digits.slice(0, 2)}:${digits.slice(2)}` : digits;
      this.display = out;
      e.target.value = out;
      if (VALID.test(out)) this.$emit('update:modelValue', out);
    },
    onBlur() {
      if (VALID.test(this.display)) {
        this.$emit('update:modelValue', this.display);
        if (this.display !== this.focusValue) this.$emit('change');
      } else {
        // Incomplete/invalid entry: revert to the last valid value.
        this.display = this.normalize(this.modelValue);
      }
    },
  },
};
</script>
