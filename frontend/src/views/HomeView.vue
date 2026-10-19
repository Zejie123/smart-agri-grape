<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { echarts, initChart, disposeChart } from '../utils/useChart'
import { showModal, showToast } from '../store'
import { grapeVarieties as mockGrape, weatherData, priceData } from '../utils/mockData'
import { getGrapeList, getLatestAlarm, getEnvLatest } from '../api'
import farmImg from '../assets/farm.png'

const grapeVarieties = ref([...mockGrape])
const alertList = ref([])

const envItems = ref([
  { type: 'temp', label: '温度：', value: '30℃', bg: 'bg-yellow', avg: '30℃' },
  { type: 'humidity', label: '湿度：', value: '56%', bg: 'bg-purple', avg: '55%' },
  { type: 'pm25', label: 'PM2.5：', value: '80', bg: 'bg-yellow', avg: '80' },
  { type: 'pm10', label: 'PM10：', value: '120', bg: 'bg-yellow', avg: '120' },
  { type: 'soilPh', label: '土壤PH：', value: '6.5', bg: 'bg-blue', avg: '6.4' },
  { type: 'ec', label: '电导率：', value: '60', bg: 'bg-blue', avg: '58' },
  { type: 'windDir', label: '风向：', value: '东南', bg: 'bg-blue', avg: '东南' },
  { type: 'windSpeed', label: '风速：', value: '1.5m/s', bg: 'bg-blue', avg: '1.5m/s' }
])

const growItems = [
  { name: '巨峰葡萄', pct: 75 },
  { name: '阳光玫瑰', pct: 68 },
  { name: '夏黑葡萄', pct: 82 }
]

// 图表 DOM
const staffChartEl = ref(null)
const mapChartEl = ref(null)
const mapSubChartEl = ref(null)
const landChartEl = ref(null)
const cropTypeChartEl = ref(null)
const cropYieldChartEl = ref(null)
const soilChartEl = ref(null)
const priceChartEl = ref(null)

// 图表实例（普通变量，避免 Vue 深响应代理 echarts 实例）
let staffChart, mapChart, mapSubChart, landChart, cropTypeChart, cropYieldChart, soilChart, priceChart
let refreshTimer = null

function initStaffChart() {
  staffChart = initChart(staffChartEl.value)
  staffChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 10, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: [0, 4, 12, 16, 31], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', max: 100, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    series: [{
      data: [0, 30, 60, 40, 100], type: 'line', smooth: true,
      areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(0,212,255,0.5)' }, { offset: 1, color: 'rgba(0,212,255,0.1)' }]) },
      lineStyle: { color: '#00d4ff' }, itemStyle: { color: '#00d4ff' }
    }]
  })
  staffChart.on('click', (p) => showModal('人员出勤详情', `日期：${p.name}<br>出勤率：${p.value}%<br>出勤人数：${Math.round(p.value)}人`))
}

function initMapCharts() {
  mapChart = initChart(mapChartEl.value)
  mapChart.setOption({ backgroundColor: 'transparent', graphic: [{ type: 'rect', left: 0, top: 0, shape: { width: '100%', height: '100%' }, style: { fill: 'rgba(0, 50, 100, 0.5)' } }] })
  mapChart.on('click', () => showModal('农场地图详情', '四川示范农场实时监控：<br>葡萄总饱和面积：8000亩<br>葡萄实际种植面积：6789亩<br>当前状态：正常'))

  mapSubChart = initChart(mapSubChartEl.value)
  mapSubChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 10, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['1', '6', '9', '12', '18', '21', '24'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', max: 100, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['温度', '湿度'], textStyle: { color: '#fff' }, top: 0, left: 'center' },
    series: [
      { id: 'mapTemp', name: '温度', type: 'line', data: [30, 40, 60, 30, 35, 40, 35], lineStyle: { color: '#ffd700' }, itemStyle: { color: '#ffd700' } },
      { id: 'mapHumidity', name: '湿度', type: 'line', data: [40, 30, 50, 60, 55, 40, 45], lineStyle: { color: '#00d4ff' }, itemStyle: { color: '#00d4ff' } }
    ]
  })
  mapSubChart.on('click', (p) => showModal(`${p.seriesName}详情`, `时间：${p.name}时<br>${p.seriesName}：${p.value}`))
}

function initBottomCharts() {
  landChart = initChart(landChartEl.value)
  landChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 10, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['2019', '2020', '2021', '2022', '2023', '2024'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', max: 9000, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['葡萄饱和面积', '葡萄实际面积'], textStyle: { color: '#fff' }, top: 0, left: 'center' },
    series: [
      { name: '葡萄饱和面积', type: 'bar', data: [6200, 6600, 7000, 7400, 7800, 8000], itemStyle: { color: '#00d4ff' } },
      { name: '葡萄实际面积', type: 'bar', data: [5100, 5480, 5920, 6210, 6560, 6789], itemStyle: { color: '#ffd700' } }
    ]
  })
  landChart.on('click', (p) => showModal(`${p.seriesName}详情`, `年份：${p.name}<br>${p.seriesName}：${p.value}亩`))

  cropTypeChart = initChart(cropTypeChartEl.value)
  cropTypeChart.on('click', (p) => showModal(`${p.name}详情`, `实际面积：${p.value}亩<br>占比：${p.percent}%`))
  cropYieldChart = initChart(cropYieldChartEl.value)
  cropYieldChart.on('click', (p) => showModal(`${p.name}详情`, `实际面积：${p.value}亩<br>排名：${p.dataIndex + 1}`))

  soilChart = initChart(soilChartEl.value)
  soilChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 10, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['1', '6', '9', '12', '18', '21', '24'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', max: 100, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['土壤温度', '土壤水分', '土壤湿度', '土壤PH值', '土壤电导率'], textStyle: { color: '#fff' }, top: 0, left: 'center' },
    series: [
      { id: 'soilTemp', name: '土壤温度', type: 'line', data: [70, 85, 75, 85, 90, 85, 80], lineStyle: { color: '#ffd700' } },
      { id: 'soilWater', name: '土壤水分', type: 'line', data: [20, 25, 30, 25, 30, 25, 20], lineStyle: { color: '#00ff9d' } },
      { id: 'soilHumidity', name: '土壤湿度', type: 'line', data: [80, 70, 60, 70, 60, 70, 60], lineStyle: { color: '#4facfe' } },
      { id: 'soilPh', name: '土壤PH值', type: 'line', data: [40, 40, 40, 50, 40, 40, 40], lineStyle: { color: '#b066ff' } },
      { id: 'soilEc', name: '土壤电导率', type: 'line', data: [60, 60, 60, 55, 60, 65, 60], lineStyle: { color: '#ff6b6b' } }
    ]
  })
  soilChart.on('click', (p) => {
    if (p.seriesName === '土壤PH值' && p.value < 50) showToast('土壤PH值异常！请及时处理')
    showModal(`${p.seriesName}详情`, `时间：${p.name}时<br>${p.seriesName}：${p.value}`)
  })
}

function initPriceChart() {
  priceChart = initChart(priceChartEl.value)
  const option = {
    backgroundColor: 'transparent',
    tooltip: { trigger: 'axis' },
    legend: { data: priceData.varieties.map((v) => v.name), textStyle: { color: '#fff' }, top: 0 },
    grid: { top: 30, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: priceData.dates, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', name: '价格(元/kg)', axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    series: priceData.varieties.map((v, i) => ({
      name: v.name, type: 'line', smooth: true, data: v.data,
      itemStyle: { color: ['#ffd700', '#ff6b6b', '#00d4ff'][i] }, lineStyle: { width: 2 }
    }))
  }
  priceChart.setOption(option)
  priceChart.on('click', (params) => showModal('价格详情', `<strong>品种：</strong>${params.seriesName}<br/><strong>日期：</strong>${params.name}<br/><strong>价格：</strong>${params.value} 元/kg`))
}

function renderGrapeCharts() {
  if (!cropTypeChart || !cropYieldChart) return
  cropTypeChart.setOption({
    backgroundColor: 'transparent',
    tooltip: { trigger: 'item' },
    series: [{
      name: '葡萄品种', type: 'pie', radius: ['35%', '70%'], center: ['50%', '52%'],
      label: { show: true, color: '#fff', formatter: '{b}\n{value}' },
      data: grapeVarieties.value.map((v, i) => ({
        value: v.actual, name: v.name,
        itemStyle: { color: ['#00d4ff', '#ffd700', '#81c784', '#ff8a65', '#4facfe', '#ff6b6b', '#b066ff', '#f48fb1', '#90ee90', '#87ceeb'][i % 10] }
      }))
    }]
  })
  const sorted = [...grapeVarieties.value].sort((a, b) => b.actual - a.actual)
  cropYieldChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 10, right: 10, bottom: 20, left: 90 },
    xAxis: { type: 'value', max: 1000, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'category', data: sorted.map((v, i) => `TOP${i + 1} ${v.name}`), axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    series: [{ type: 'bar', data: sorted.map((v) => v.actual), itemStyle: { color: new echarts.graphic.LinearGradient(1, 0, 0, 0, [{ offset: 0, color: '#00d4ff' }, { offset: 1, color: '#b066ff' }]) } }]
  })
}

function viewVariety(index) {
  const v = grapeVarieties.value[index]
  if (!v) return
  const up = v.rate >= 0
  showModal(`${v.name}详情`, `葡萄品种：${v.name}<br>饱和数据：${v.sat}亩<br>实际数据：${v.actual}亩<br>增长率：${up ? '↑' : '↓'} ${Math.abs(v.rate)}%<br>备注：${v.note || ''}`)
}

function onEnvClick(item) {
  showModal(item.label.replace('：', ''), `当前${item.label}${item.value}<br>历史平均值：${item.avg}`)
}

async function loadGrapeVarieties() {
  try {
    const r = await getGrapeList()
    if (r.code === 200 && Array.isArray(r.data) && r.data.length) {
      grapeVarieties.value = r.data.map((v) => ({ name: v.name, sat: v.satArea, actual: v.actualArea, rate: v.rate, note: v.note }))
      renderGrapeCharts()
    }
  } catch (e) { /* 后端不可用，保留本地模拟数据 */ }
}

async function loadAlarms() {
  try {
    const r = await getLatestAlarm()
    if (r.code === 200 && Array.isArray(r.data) && r.data.length) {
      alertList.value = r.data.map((a) => {
        const levelText = { 1: '紧急', 2: '警告', 3: '提示' }[a.level] || ''
        const t = (a.createTime || '').replace('T', ' ').slice(0, 16)
        return { time: t, text: `${a.alarmType}${levelText ? '·' + levelText : ''}` }
      })
    }
  } catch (e) { /* 忽略 */ }
}

async function loadEnvData() {
  try {
    const r = await getEnvLatest()
    if (r.code === 200 && r.data) {
      const d = r.data
      const byType = Object.fromEntries(envItems.value.map((i) => [i.type, i]))
      if (byType.temp && d.temp != null) byType.temp.value = `${d.temp}℃`
      if (byType.humidity && d.humidity != null) byType.humidity.value = `${d.humidity}%`
      if (byType.pm25 && d.pm25 != null) byType.pm25.value = String(d.pm25)
      if (byType.pm10 && d.pm10 != null) byType.pm10.value = String(d.pm10)
      if (byType.soilPh && d.soilPh != null) byType.soilPh.value = String(d.soilPh)
      if (byType.ec && d.ec != null) byType.ec.value = String(d.ec)
      if (byType.windDir && d.windDir != null) byType.windDir.value = d.windDir
      if (byType.windSpeed && d.windSpeed != null) byType.windSpeed.value = `${d.windSpeed}m/s`
    }
  } catch (e) { /* 后端不可用，保留本地模拟数据 */ }
}

function updateChartData() {
  const t = mapSubChart.getOption().series[0].data
  const h = mapSubChart.getOption().series[1].data
  const nt = t.map((v) => Math.max(20, Math.min(70, v + Math.floor(Math.random() * 11) - 5)))
  const nh = h.map((v) => Math.max(30, Math.min(70, v + Math.floor(Math.random() * 11) - 5)))
  mapSubChart.setOption({ series: [{ id: 'mapTemp', data: nt }, { id: 'mapHumidity', data: nh }] })

  const phData = soilChart.getOption().series[3].data
  const nph = phData.map((v) => Math.max(30, Math.min(60, v + Math.floor(Math.random() * 11) - 5)))
  soilChart.setOption({ series: [{ id: 'soilPh', data: nph }] })
}

onMounted(() => {
  initStaffChart()
  initMapCharts()
  initBottomCharts()
  initPriceChart()
  renderGrapeCharts()
  loadAlarms()
  loadGrapeVarieties()
  loadEnvData()
  refreshTimer = setInterval(() => {
    loadEnvData()
    updateChartData()
    loadAlarms()
    if (Math.random() < 0.1) showToast('土壤PH值异常！请及时处理')
  }, 5000)
})

onBeforeUnmount(() => {
  if (refreshTimer) clearInterval(refreshTimer)
  ;[staffChart, mapChart, mapSubChart, landChart, cropTypeChart, cropYieldChart, soilChart, priceChart].forEach(disposeChart)
})
</script>

<template>
  <div class="main-content">
    <div class="left-col">
      <div class="module video-module">
        <div class="module-title"><span class="dot"></span>1号地-1号监控摄像头</div>
        <div class="video-placeholder" @click="showModal('监控视频', '1号地实时监控画面：<br>当前状态：正常<br>设备在线：正常')"><div class="play-icon">▶</div></div>
      </div>
      <div class="module alert-module">
        <div class="module-title"><span class="dot"></span>葡萄品种种植预警（核心字段）</div>
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>葡萄品种</th><th>饱和数据(亩)</th><th>实际数据(亩)</th><th>增长率</th><th>备注</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(v, i) in grapeVarieties" :key="v.name" @click="viewVariety(i)">
                <td>{{ v.name }}</td>
                <td>{{ v.sat }}</td>
                <td>{{ v.actual }}</td>
                <td :class="v.rate >= 0 ? 'up' : 'down'">{{ v.rate >= 0 ? '↑' : '↓' }} {{ Math.abs(v.rate) }}%</td>
                <td>{{ v.note }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="module staff-module">
        <div class="module-title"><span class="dot"></span>人员结构（30日出勤率）</div>
        <div class="staff-info"><span>农场总人数：100人</span><span>男：30人 女：70人</span></div>
        <div ref="staffChartEl" class="chart-box"></div>
      </div>
    </div>

    <div class="center-col">
      <div class="module map-module">
        <div class="kpi-cards">
          <div class="kpi-card" @click="showModal('种植面积详情', '葡萄总饱和面积：8000亩<br>葡萄总实际面积：6789亩<br>整体增长：+6.1%')"><p>第二季度葡萄种植</p><h2>8000亩 <span>本季度+6.1%</span></h2></div>
          <div class="kpi-card" @click="showModal('品种结构态势', '增长型：巨峰、夏黑、玫瑰香、无核白<br>下滑型：金手指、美人指<br>平稳型：阳光玫瑰、红提、甜蜜蓝宝石、青提')"><p>第二季度产量</p><h2>135000吨</h2></div>
        </div>
        <div ref="mapChartEl" class="map-box"></div>
        <div class="farm-info-card" @click="showModal('农场详情', '四川示范农场<br>地址：四川省眉山市彭山区<br>负责人：葡香筑梦组<br>联系方式：17780129602<br>数据字段：品种/饱和/实际/增长率/备注')">
          <h3>四川示范农场</h3>
          <img :src="farmImg" alt="农场图片" />
          <p>地址：四川省眉山市</p>
          <p>负责人：葡香筑梦组</p>
          <p>联系方式：17780129602</p>
          <div class="alert-info">
            <h4>报警信息</h4>
            <ul>
              <li v-for="(a, i) in alertList" :key="i">{{ a.time }} <span class="alert-text">{{ a.text }}</span></li>
            </ul>
          </div>
        </div>
        <div ref="mapSubChartEl" class="map-sub-chart"></div>
        <div class="map-scale">50 km</div>
      </div>
      <div class="bottom-stats">
        <div class="stat-item">
          <div class="module-title"><span class="dot"></span>土地使用面积</div>
          <div ref="landChartEl" class="chart-box"></div>
        </div>
        <div class="stat-item">
          <div class="module-title"><span class="dot"></span>葡萄品类结构</div>
          <div ref="cropTypeChartEl" class="chart-box"></div>
        </div>
        <div class="stat-item">
          <div class="module-title"><span class="dot"></span>葡萄产量排行</div>
          <div ref="cropYieldChartEl" class="chart-box"></div>
        </div>
      </div>
    </div>

    <div class="right-col">
      <div class="module env-module">
        <div class="module-title"><span class="dot"></span>实时环境监测</div>
        <div class="env-grid">
          <div v-for="item in envItems" :key="item.type" class="env-item" :class="item.bg" @click="onEnvClick(item)">
            <span class="label">{{ item.label }}</span><span class="value">{{ item.value }}</span>
          </div>
        </div>
      </div>

      <div class="module weather-module">
        <div class="module-title"><span class="dot"></span>未来7天天气预报</div>
        <div class="weather-scroll">
          <div v-for="w in weatherData" :key="w.date" class="weather-item">
            <div class="weather-date">{{ w.date }}</div>
            <div class="weather-icon">{{ w.icon }}</div>
            <div class="weather-temp">{{ w.temp }}℃</div>
            <div class="weather-desc">{{ w.desc }}</div>
          </div>
        </div>
      </div>

      <div class="module grow-module">
        <div class="module-title"><span class="dot"></span>作物生长监测</div>
        <div class="grow-item" v-for="g in growItems" :key="g.name">
          <div class="grow-label"><span>{{ g.name }}</span><span>{{ g.pct }}%</span></div>
          <div class="grow-bar"><div class="grow-value" :style="{ width: g.pct + '%' }"></div></div>
        </div>
      </div>

      <div class="module price-module">
        <div class="module-title"><span class="dot"></span>农产品价格走势</div>
        <div ref="priceChartEl" class="chart-box"></div>
      </div>

      <div class="module soil-module">
        <div class="module-title"><span class="dot"></span>土地墒情预警</div>
        <div ref="soilChartEl" class="chart-box"></div>
        <div class="legend">
          <span><i style="background:#ffd700"></i>土壤温度</span>
          <span><i style="background:#00ff9d"></i>土壤水分</span>
          <span><i style="background:#4facfe"></i>土壤湿度</span>
          <span><i style="background:#b066ff"></i>土壤PH值</span>
          <span><i style="background:#ff6b6b"></i>土壤电导率</span>
        </div>
      </div>
    </div>
  </div>
</template>
