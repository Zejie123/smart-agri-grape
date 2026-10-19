<script setup>
import { store, closeModal } from '../store'
</script>

<template>
  <div
    class="modal"
    :style="{ display: store.modal.visible ? 'flex' : 'none' }"
    @click.self="closeModal"
  >
    <div class="modal-content">
      <span class="modal-close" @click="closeModal">&times;</span>
      <div class="modal-title">{{ store.modal.title }}</div>
      <!-- 详情内容为受控 HTML（与原静态页一致的富文本） -->
      <div class="modal-body" v-html="store.modal.content"></div>
    </div>
  </div>
</template>
x'x'x'x