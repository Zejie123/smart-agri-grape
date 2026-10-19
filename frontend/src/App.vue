<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { store, showModal } from './store'
import { clearAlarmApi } from './api'
import { resizeAllCharts } from './utils/useChart'
import ModalDialog from './components/ModalDialog.vue'
import HomeView from './views/HomeView.vue'
import GreenhouseView from './views/GreenhouseView.vue'
import DeviceView from './views/DeviceView.vue'
import WaterView from './views/WaterView.vue'
import FarmingView from './views/FarmingView.vue'
import SettingView from './views/SettingView.vue'

const tabs = [
  { key: 'home', label: '首页' },
  { key: 'greenhouse', label: '智慧大棚' },
  { key: 'device', label: '设备监控' },
  { key: 'water', label: '水肥一体化' },
  { key: 'farming', label: '农事记录' },
  { key: 'setting', label: '系统设置' }
]

const currentTime = ref('')
const searchInput = ref('')
let timeTimer = null

function switchPage(key, label) {
  store.currentPage = key
  // 图表在 display:none 下无法测量尺寸，切换显示后延时 resize
  setTimeout(resizeAllCharts, 50)
  if (key === 'home') showModal('页面跳转', `即将跳转到【${label}】页面`)
}

function updateTime() {
  const now = new Date()
  currentTime.value = now.toLocaleString('zh-CN', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', second: '2-digit'
  })
}

function doSearch() {
  const v = searchInput.value.trim()
  if (!v) return showModal('搜索', '请输入关键词')
  showModal('搜索结果', `正在搜索：${v}<br>匹配到【设备/图表/地块】相关内容`)
}

function toggleFull() {
  if (!document.fullscreenElement) document.documentElement.requestFullscreen()
  else document.exitFullscreen()
}

function refreshAll() {
  location.reload()
}

async function clearAlarm() {
  try {
    await clearAlarmApi()
    store.alarmLog.length = 0
    showModal('操作成功', '已清空告警记录')
  } catch (e) {
    // 后端不可用时仅清空本地
    store.alarmLog.length = 0
    showModal('操作成功', '已清空实时告警')
  }
}

function exportData() {
  showModal('导出成功', '数据已导出为 Excel 表格！')
}

function printScreen() {
  window.print()
}

onMounted(() => {
  updateTime()
  timeTimer = setInterval(updateTime, 1000)
})

onBeforeUnmount(() => {
  if (timeTimer) clearInterval(timeTimer)
})
</script>

<template>
  <div class="big-screen-container">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <input v-model="searchInput" class="search-input" placeholder="搜索设备/图表/地块/品种..." />
      <button class="search-btn" @click="doSearch">搜索</button>
    </div>

    <!-- 预警面板 -->
    <div class="warn-panel">
      <div class="warn-title">⚠️ 智能预警阈值</div>
      <div class="warn-item"><span>温度上限</span><span>35℃</span></div>
      <div class="warn-item"><span>湿度下限</span><span>40%</span></div>
      <div class="warn-item"><span>土壤PH下限</span><span>5.5</span></div>
      <div class="warn-item"><span>电导率上限</span><span>80</span></div>
    </div>

    <!-- 快捷工具 -->
    <div class="quick-tool">
      <div class="tool-btn" @click="toggleFull" title="全屏">⛶</div>
      <div class="tool-btn" @click="refreshAll" title="刷新">♻️</div>
      <div class="tool-btn" @click="clearAlarm" title="清空告警">🧹</div>
      <div class="tool-btn" @click="exportData" title="导出数据">📤</div>
      <div class="tool-btn" @click="printScreen" title="打印">🖨️</div>
    </div>

    <!-- 顶栏 -->
    <div class="header">
      <div class="header-left">
        <h1>智慧农业系统</h1>
        <div class="nav-tabs">
          <span
            v-for="t in tabs"
            :key="t.key"
            class="tab"
            :class="{ active: store.currentPage === t.key }"
            @click="switchPage(t.key, t.label)"
          >{{ t.label }}</span>
        </div>
      </div>
      <div class="header-right">
        <span class="time">{{ currentTime }}</span>
        <span class="weather">四川：今天 17℃~29℃</span>
        <span class="user-icon">👤 admin</span>
      </div>
    </div>

    <!-- 页面（v-show 通过 .active class 控制显隐，保持所有图表挂载） -->
    <div class="page" :class="{ active: store.currentPage === 'home' }"><HomeView /></div>
    <div class="page" :class="{ active: store.currentPage === 'greenhouse' }"><GreenhouseView /></div>
    <div class="page" :class="{ active: store.currentPage === 'device' }"><DeviceView /></div>
    <div class="page" :class="{ active: store.currentPage === 'water' }"><WaterView /></div>
    <div class="page" :class="{ active: store.currentPage === 'farming' }"><FarmingView /></div>
    <div class="page" :class="{ active: store.currentPage === 'setting' }"><SettingView /></div>

    <!-- 全局弹窗 -->
    <ModalDialog />

    <!-- 告警 toast -->
    <div class="alert-toast" :style="{ display: store.toast.visible ? 'block' : 'none' }">
      ⚠️ {{ store.toast.message }}
    </div>
  </div>
</template>
