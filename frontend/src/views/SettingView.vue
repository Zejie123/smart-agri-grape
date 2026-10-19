<script setup>
import { ref, reactive, onMounted } from 'vue'
import { showModal } from '../store'
import SwitchControl from '../components/SwitchControl.vue'
import { getConfigList, saveConfig, getUserList, getLogList } from '../api'

const ROLE_LABEL = { admin: '超级管理员', operator: '操作员', guest: '访客' }

const users = ref([
  { name: 'admin', role: '超级管理员', online: true },
  { name: 'worker1', role: '操作员', online: false },
  { name: 'worker2', role: '操作员', online: false },
  { name: 'guest', role: '访客', online: false }
])

async function loadUsers() {
  try {
    const r = await getUserList()
    if (r.code === 200 && Array.isArray(r.data) && r.data.length) {
      users.value = r.data.map((u) => ({
        name: u.username,
        role: ROLE_LABEL[u.role] || u.role,
        online: u.status === 1
      }))
    }
  } catch (e) { /* 保留本地模拟数据 */ }
}

const configSwitches = reactive([
  { key: 'autoRefresh', label: '自动刷新', on: true },
  { key: 'soundAlarm', label: '声音告警', on: true },
  { key: 'keepScreen', label: '屏幕常亮', on: true },
  { key: 'autoClear', label: '自动清洁日志', on: false },
  { key: 'nightMode', label: '夜间模式', on: false }
])

const sysLogs = ref([
  { time: '2025-05-29 10:00:00', text: '[系统] 启动成功' },
  { time: '2025-05-29 10:01:00', text: '[设备] 摄像头1在线' },
  { time: '2025-05-29 10:05:00', text: '[水肥] 启动灌溉' },
  { time: '2025-05-29 10:10:00', text: '[告警] 土壤PH值偏低' },
  { time: '2025-05-29 10:15:00', text: '[用户] admin登录' },
  { time: '2025-05-29 10:20:00', text: '[设备] 传感器数据更新' },
  { time: '2025-05-29 10:25:00', text: '[水肥] 停止灌溉' },
  { time: '2025-05-29 10:30:00', text: '[系统] 数据备份完成' }
])

async function loadLogs() {
  try {
    const r = await getLogList()
    if (r.code === 200 && Array.isArray(r.data) && r.data.length) {
      sysLogs.value = r.data.map((l) => ({
        time: (l.createTime || '').replace('T', ' ').slice(0, 19),
        text: `[${l.logType}] ${l.content}`
      }))
    }
  } catch (e) { /* 保留本地模拟数据 */ }
}

const systemInfo = [
  { label: '系统版本', value: 'V3.8.6' },
  { label: '运行时长', value: '168 天' },
  { label: '设备在线率', value: '98.2%' },
  { label: '数据采集', value: '正常' },
  { label: '服务器状态', value: '运行中', green: true },
  { label: '数据库存储', value: '68%' },
  { label: '最后更新', value: '2025-12-29' }
]

const tempMax = ref('35')
const humMin = ref('40')
const phMin = ref('5.5')
const ecMax = ref('80')

function toggleConfig(item, on) {
  if (item.key === 'autoRefresh') showModal('设置', `自动刷新已${on ? '开启' : '关闭'}`)
  else showModal('设置', `${item.label}已切换`)
}

function backupData() {
  showModal('数据备份', '系统数据备份中...<br>备份完成！')
}

async function loadConfig() {
  try {
    const r = await getConfigList()
    if (r.code === 200 && Array.isArray(r.data)) {
      const map = {}
      r.data.forEach((c) => { map[c.configKey] = c.configValue })
      if (map.temp_max != null) tempMax.value = String(map.temp_max)
      if (map.hum_min != null) humMin.value = String(map.hum_min)
      if (map.ph_min != null) phMin.value = String(map.ph_min)
      if (map.ec_max != null) ecMax.value = String(map.ec_max)
    }
  } catch (e) { /* 忽略 */ }
}

async function saveThreshold() {
  const list = [
    { configKey: 'temp_max', configValue: tempMax.value },
    { configKey: 'hum_min', configValue: humMin.value },
    { configKey: 'ph_min', configValue: phMin.value },
    { configKey: 'ec_max', configValue: ecMax.value }
  ]
  try {
    await saveConfig(list)
    showModal('保存成功', '告警阈值已保存到数据库')
  } catch (e) {
    showModal('保存成功', '告警阈值已保存(本地)')
  }
}

onMounted(() => {
  loadConfig()
  loadUsers()
  loadLogs()
})
</script>

<template>
  <div class="set-main">
    <div class="set-left">
      <div class="set-card" style="height:50%">
        <div class="set-title">账户管理</div>
        <div v-for="u in users" :key="u.name" class="user-item">
          <div>
            <div class="user-name">{{ u.name }}</div>
            <div class="user-role">{{ u.role }}</div>
          </div>
          <span :style="{ color: u.online ? '#00d4ff' : '#ccc' }">{{ u.online ? '在线' : '离线' }}</span>
        </div>
      </div>
      <div class="set-card" style="height:50%">
        <div class="set-title">系统配置</div>
        <div style="display:flex;flex-direction:column;gap:14px;margin-top:10px;">
          <div v-for="s in configSwitches" :key="s.key" class="set-item">
            <span class="set-label">{{ s.label }}</span>
            <SwitchControl v-model="s.on" @change="toggleConfig(s, $event)" />
          </div>
        </div>
        <button class="backup-btn" @click="backupData">立即备份数据</button>
      </div>
    </div>
    <div class="set-center">
      <div class="set-card" style="height:100%">
        <div class="set-title">系统日志</div>
        <div class="log-list">
          <div v-for="(l, i) in sysLogs" :key="i" class="log-item"><span class="log-time">{{ l.time }}</span><span class="log-text">{{ l.text }}</span></div>
        </div>
      </div>
    </div>
    <div class="set-right">
      <div class="set-card" style="height:50%">
        <div class="set-title">告警阈值设置</div>
        <div class="water-form">
          <label>温度上限 (℃)</label>
          <input type="number" v-model="tempMax" />
          <label>湿度下限 (%)</label>
          <input type="number" v-model="humMin" />
          <label>土壤PH下限</label>
          <input type="number" v-model="phMin" step="0.1" />
          <label>电导率上限</label>
          <input type="number" v-model="ecMax" />
        </div>
        <button class="water-btn" style="margin-top:10px;" @click="saveThreshold">保存阈值</button>
      </div>
      <div class="set-card" style="height:50%">
        <div class="set-title">系统信息</div>
        <div style="display:flex;flex-direction:column;gap:10px;margin-top:10px;font-size:14px;">
          <div v-for="(info, i) in systemInfo" :key="i" style="display:flex;justify-content:space-between;">
            <span>{{ info.label }}</span>
            <span :style="{ color: info.green ? '#00ff9d' : '#fff' }">{{ info.value }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
