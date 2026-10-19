import { reactive } from 'vue'

// 全局轻量状态（跨组件共享，替代原静态页里的全局函数/变量）
export const store = reactive({
  currentPage: 'home',
  // 详情弹窗
  modal: { visible: false, title: '', content: '' },
  // 顶部告警 toast
  toast: { visible: false, message: '' },
  // 设备页实时告警（供快捷工具「清空告警」跨组件访问）
  alarmLog: []
})

let toastTimer = null

export function showModal(title, content) {
  store.modal.title = title
  store.modal.content = content
  store.modal.visible = true
}

export function closeModal() {
  store.modal.visible = false
}

export function showToast(message) {
  store.toast.message = message
  store.toast.visible = true
  if (toastTimer) clearTimeout(toastTimer)
  toastTimer = setTimeout(() => {
    store.toast.visible = false
  }, 3000)
}
