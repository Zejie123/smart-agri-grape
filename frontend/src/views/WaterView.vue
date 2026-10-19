<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { initChart, disposeChart } from '../utils/useChart'
import { showModal } from '../store'
import { recipes } from '../utils/mockData'

const waterTrendEl = ref(null)
const waterUseEl = ref(null)

let waterTrendChart, waterUseChart
let statusTimer = null

const waterTime = ref(10)
const waterRate = ref(30)
const waterArea = ref('1号大棚A区')

const waterStatus = ref('运行中')
const waterStatusColor = ref('#00ff9d')
const waterTotal = ref('1286 分钟')
const waterUse = ref('386 kg')
const waterFlow = ref('2.6 m³/h')

const waterRecords = [
  ['05-28 10:00', '1号棚', '12分钟', '苗期配方', '完成'],
  ['05-28 14:20', '2号棚', '10分钟', '膨果配方', '完成'],
  ['05-28 16:10', '3号棚', '15分钟', '着色配方', '完成'],
  ['05-29 08:30', '1号棚', '8分钟', '均衡配方', '完成']
]

const waterFerts = [
  ['05-28 11:00', '苗期配方', '12', '1号棚', 'admin'],
  ['05-28 15:00', '膨果配方', '10', '2号棚', 'admin'],
  ['05-29 09:00', '均衡配方', '8', '3号棚', 'worker1']
]

function useRecipe(recipe) {
  showModal('配方切换', `已切换为：${recipe.name}`)
}

function startWater() {
  waterStatus.value = '运行中'
  waterStatusColor.value = '#00ff9d'
  showModal('启动灌溉', `区域：${waterArea.value}<br>时长：${waterTime.value}分钟<br>浓度：${waterRate.value}%`)
}

function stopWater() {
  waterStatus.value = '已停止'
  waterStatusColor.value = '#ff6b6b'
  showModal('停止灌溉', '灌溉已手动停止')
}

function initCharts() {
  waterTrendChart = initChart(waterTrendEl.value)
  waterTrendChart.setOption({
    backgroundColor: 'transparent', grid: { top: 20, right: 20, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['1', '5', '10', '15', '20', '25', '30'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    series: [{ name: '灌溉时长', type: 'bar', data: [20, 30, 25, 40, 35, 30, 28], itemStyle: { color: '#00d4ff' } }]
  })

  waterUseChart = initChart(waterUseEl.value)
  waterUseChart.setOption({
    backgroundColor: 'transparent',
    series: [{
      type: 'pie', radius: ['40%', '70%'],
      data: [
        { value: 40, name: '苗期肥' },
        { value: 30, name: '膨果肥' },
        { value: 20, name: '着色肥' },
        { value: 10, name: '均衡肥' }
      ],
      label: { color: '#fff' },
      itemStyle: { colors: ['#00d4ff', '#ffd700', '#ff6b6b', '#81c784'] }
    }]
  })
}

function refreshExtData() {
  waterTotal.value = `${Math.floor(Math.random() * 200) + 1200} 分钟`
  waterUse.value = `${Math.floor(Math.random() * 100) + 350} kg`
  waterFlow.value = `${(Math.random() * 2 + 2).toFixed(1)} m³/h`
}

onMounted(() => {
  initCharts()
  statusTimer = setInterval(refreshExtData, 5000)
})

onBeforeUnmount(() => {
  if (statusTimer) clearInterval(statusTimer)
  ;[waterTrendChart, waterUseChart].forEach(disposeChart)
})
</script>

<template>
  <div class="water-main">
    <div class="water-left">
      <div class="water-card" style="height:35%">
        <div class="water-title">水肥配方</div>
        <div v-for="r in recipes" :key="r.id" class="recipe-item" @click="useRecipe(r)">
          <div class="recipe-name">{{ r.name }}</div>
          <div class="recipe-desc">{{ r.desc }}</div>
        </div>
      </div>
      <div class="water-card" style="height:35%">
        <div class="water-title">灌溉控制</div>
        <div class="water-form">
          <label>灌溉时长（分钟）</label>
          <input type="number" v-model="waterTime" min="1" max="120" />
          <label>灌溉浓度（%）</label>
          <input type="number" v-model="waterRate" min="1" max="100" />
          <label>灌溉区域</label>
          <input type="text" v-model="waterArea" />
        </div>
        <button class="water-btn" @click="startWater">启动灌溉</button>
        <button class="water-btn" style="background:#ff6b6b;margin-top:6px;" @click="stopWater">停止灌溉</button>
      </div>
      <div class="water-card" style="height:30%">
        <div class="water-title">实时状态</div>
        <div style="display:flex;flex-direction:column;gap:10px;margin-top:10px;">
          <div style="display:flex;justify-content:space-between;"><span>运行状态</span><span :style="{ color: waterStatusColor }">{{ waterStatus }}</span></div>
          <div style="display:flex;justify-content:space-between;"><span>累计灌溉</span><span>{{ waterTotal }}</span></div>
          <div style="display:flex;justify-content:space-between;"><span>肥料消耗</span><span>{{ waterUse }}</span></div>
          <div style="display:flex;justify-content:space-between;"><span>当前流量</span><span>{{ waterFlow }}</span></div>
        </div>
      </div>
    </div>
    <div class="water-center">
      <div class="water-card" style="height:50%">
        <div class="water-title">灌溉趋势（近30天）</div>
        <div ref="waterTrendEl" class="water-chart"></div>
      </div>
      <div class="water-card" style="height:50%">
        <div class="water-title">肥料消耗分析</div>
        <div ref="waterUseEl" class="water-chart"></div>
      </div>
    </div>
    <div class="water-right">
      <div class="water-card" style="height:50%">
        <div class="water-title">灌溉记录</div>
        <div class="water-table">
          <table>
            <thead><tr><th>时间</th><th>区域</th><th>时长</th><th>配方</th><th>状态</th></tr></thead>
            <tbody>
              <tr v-for="(r, i) in waterRecords" :key="i">
                <td>{{ r[0] }}</td><td>{{ r[1] }}</td><td>{{ r[2] }}</td><td>{{ r[3] }}</td><td style="color:#00ff9d">{{ r[4] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="water-card" style="height:50%">
        <div class="water-title">施肥记录</div>
        <div class="water-table">
          <table>
            <thead><tr><th>时间</th><th>配方</th><th>用量(kg)</th><th>区域</th><th>操作人</th></tr></thead>
            <tbody>
              <tr v-for="(f, i) in waterFerts" :key="i">
                <td>{{ f[0] }}</td><td>{{ f[1] }}</td><td>{{ f[2] }}</td><td>{{ f[3] }}</td><td>{{ f[4] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
