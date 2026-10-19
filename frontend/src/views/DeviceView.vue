<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue'
import { initChart, disposeChart } from '../utils/useChart'
import { store, showModal } from '../store'
import SwitchControl from '../components/SwitchControl.vue'

const deviceEnvEl = ref(null)
const deviceRunEl = ref(null)
const deviceSoilEl = ref(null)

let deviceEnvChart, deviceRunChart, deviceSoilChart
let alarmTimer = null

const deviceOverview = [
  { name: '摄像头', value: '12 台', status: '在线', on: true },
  { name: '传感器', value: '46 个', status: '正常', on: true },
  { name: '控制器', value: '18 台', status: '运行', on: true },
  { name: '阀门', value: '32 个', status: '开启', on: true }
]

const switches = reactive({
  fan: { label: '大棚通风', on: true },
  water: { label: '水肥灌溉', on: true },
  light: { label: '补光灯', on: false },
  shadow: { label: '遮阳网', on: false },
  alarm: { label: '蜂鸣告警', on: true }
})

const deviceRows = [
  ['摄像头', 'CAM-01', '在线', '92%', '-67dBm'],
  ['传感器', 'SEN-01', '正常', '86%', '-72dBm'],
  ['控制器', 'CTL-01', '运行', '95%', '-62dBm'],
  ['阀门', 'VAL-01', '开启', '88%', '-70dBm'],
  ['摄像头', 'CAM-02', '在线', '90%', '-68dBm'],
  ['传感器', 'SEN-02', '正常', '85%', '-73dBm']
]

function showDeviceDetail(name) {
  showModal(`${name}详情`, `${name}总数：${Math.floor(Math.random() * 50) + 10}台<br>在线率：98%<br>运行状态：正常`)
}

function toggleSwitch(key) {
  const s = switches[key]
  showModal(`${s.label}控制`, `${s.label}已${s.on ? '开启' : '关闭'}`)
}

function initCharts() {
  deviceEnvChart = initChart(deviceEnvEl.value)
  deviceEnvChart.setOption({
    backgroundColor: 'transparent', grid: { top: 20, right: 20, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['0', '4', '8', '12', '16', '20', '24'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['温度', '湿度', 'PM2.5'], textStyle: { color: '#fff' } },
    series: [
      { name: '温度', type: 'line', data: [30, 32, 34, 33, 31, 29, 28], itemStyle: { color: '#ffd700' }, lineStyle: { color: '#ffd700' } },
      { name: '湿度', type: 'line', data: [55, 53, 50, 48, 52, 55, 58], itemStyle: { color: '#00d4ff' }, lineStyle: { color: '#00d4ff' } },
      { name: 'PM2.5', type: 'line', data: [70, 75, 80, 78, 72, 68, 65], itemStyle: { color: '#ff6b6b' }, lineStyle: { color: '#ff6b6b' } }
    ]
  })

  deviceRunChart = initChart(deviceRunEl.value)
  deviceRunChart.setOption({
    backgroundColor: 'transparent',
    series: [{
      type: 'pie', radius: ['40%', '70%'],
      data: [
        { value: 68, name: '在线' },
        { value: 12, name: '离线' },
        { value: 20, name: '故障' }
      ],
      label: { color: '#fff' },
      itemStyle: { colors: ['#00d4ff', '#ccc', '#ff6b6b'] }
    }]
  })

  deviceSoilChart = initChart(deviceSoilEl.value)
  deviceSoilChart.setOption({
    backgroundColor: 'transparent', grid: { top: 20, right: 20, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['0', '4', '8', '12', '16', '20', '24'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['水分', '湿度', 'PH', 'EC'], textStyle: { color: '#fff' } },
    series: [
      { name: '水分', type: 'line', data: [20, 25, 30, 28, 25, 22, 20], itemStyle: { color: '#00ff9d' } },
      { name: '湿度', type: 'line', data: [60, 65, 70, 68, 65, 62, 60], itemStyle: { color: '#4facfe' } },
      { name: 'PH', type: 'line', data: [50, 48, 45, 47, 50, 52, 50], itemStyle: { color: '#b066ff' } },
      { name: 'EC', type: 'line', data: [60, 62, 65, 63, 60, 58, 60], itemStyle: { color: '#ff6b6b' } }
    ]
  })
}

onMounted(() => {
  initCharts()
  alarmTimer = setInterval(() => {
    const t = new Date().toLocaleString()
    const txt = ['温度偏高', '湿度过低', '土壤PH异常', '电导率偏高'][Math.floor(Math.random() * 4)]
    store.alarmLog.unshift({ time: t, text: txt })
    if (store.alarmLog.length > 12) store.alarmLog.pop()
  }, 8000)
})

onBeforeUnmount(() => {
  if (alarmTimer) clearInterval(alarmTimer)
  ;[deviceEnvChart, deviceRunChart, deviceSoilChart].forEach(disposeChart)
})
</script>

<template>
  <div class="device-main">
    <div class="device-left">
      <div class="device-card" style="height:30%">
        <div class="device-title"><span class="dot"></span>设备总览</div>
        <div class="device-grid">
          <div v-for="d in deviceOverview" :key="d.name" class="device-item" @click="showDeviceDetail(d.name)">
            <div class="d-name">{{ d.name }}</div>
            <div class="d-value">{{ d.value }}</div>
            <div class="d-status" :class="d.on ? 'status-on' : 'status-off'">{{ d.status }}</div>
          </div>
        </div>
      </div>
      <div class="device-card" style="height:35%">
        <div class="device-title"><span class="dot"></span>设备控制</div>
        <div style="display:flex;flex-direction:column;gap:12px;margin-top:10px;">
          <div v-for="(s, key) in switches" :key="key" style="display:flex;justify-content:space-between;align-items:center;">
            <span>{{ s.label }}</span>
            <SwitchControl v-model="s.on" @change="toggleSwitch(key)" />
          </div>
        </div>
      </div>
      <div class="device-card" style="height:35%">
        <div class="device-title"><span class="dot"></span>实时告警</div>
        <div class="alarm-log">
          <div v-for="(a, i) in store.alarmLog" :key="i" class="alarm-item"><span class="time">{{ a.time }}</span><span class="text">{{ a.text }}</span></div>
        </div>
      </div>
    </div>
    <div class="device-center">
      <div class="device-card" style="height:50%">
        <div class="device-title"><span class="dot"></span>环境趋势（24小时）</div>
        <div ref="deviceEnvEl" class="device-chart"></div>
      </div>
      <div class="device-card" style="height:50%">
        <div class="device-title"><span class="dot"></span>设备运行统计</div>
        <div ref="deviceRunEl" class="device-chart"></div>
      </div>
    </div>
    <div class="device-right">
      <div class="device-card" style="height:50%">
        <div class="device-title"><span class="dot"></span>设备列表</div>
        <div class="device-table">
          <table>
            <thead><tr><th>设备名称</th><th>编号</th><th>状态</th><th>电量</th><th>信号</th></tr></thead>
            <tbody>
              <tr v-for="(r, i) in deviceRows" :key="i">
                <td>{{ r[0] }}</td><td>{{ r[1] }}</td><td><span style="color:#00ff9d">{{ r[2] }}</span></td><td>{{ r[3] }}</td><td>{{ r[4] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="device-card" style="height:50%">
        <div class="device-title"><span class="dot"></span>土壤墒情趋势</div>
        <div ref="deviceSoilEl" class="device-chart"></div>
      </div>
    </div>
  </div>
</template>
