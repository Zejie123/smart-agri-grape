<script setup>
const props = defineProps({
  modelValue: { type: Boolean, default: false }
})
const emit = defineEmits(['update:modelValue', 'change'])

function toggle() {
  const next = !props.modelValue
  emit('update:modelValue', next)
  emit('change', next)
}
</script>

<template>
  <div class="device-switch" :class="{ on: modelValue }" @click="toggle"></div>
</template>
