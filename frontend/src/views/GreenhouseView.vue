<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { echarts, initChart, disposeChart } from '../utils/useChart'
import { showModal } from '../store'
import { grapeVarieties as mockGrape } from '../utils/mockData'
import { getGrapeList } from '../api'

const varieties = ref([...mockGrape])

const kpiCards = [
  { type: 'greenhouseCount', icon: '🏠', iconClass: 'icon-blue', title: '大棚数量', value: '232' },
  { type: 'farmerCount', icon: '👨‍🌾', iconClass: 'icon-purple', title: '服务农户数', value: '29' },
  { type: 'plantArea', icon: '🌱', iconClass: 'icon-blue', title: '葡萄总实际面积', value: '6789 亩' },
  { type: 'totalMu', icon: '📐', iconClass: 'icon-red', title: '葡萄总饱和面积', value: '8000 亩' },
  { type: 'totalYield', icon: '🍇', iconClass: 'icon-blue', title: '品种总数', value: '10' }
]

const ghTableRows = [
  { name: '巨峰', sat: 950, actual: 885, rate: 12.3, note: '主栽品种，基数大' },
  { name: '阳光玫瑰', sat: 1000, actual: 912, rate: 4.7, note: '扩种放缓，回归理性' },
  { name: '夏黑', sat: 850, actual: 768, rate: 8.1, note: '早熟优势明显' },
  { name: '红提', sat: 900, actual: 826, rate: 2.3, note: '传统品种，小幅增长' },
  { name: '无核白', sat: 800, actual: 715, rate: 5.4, note: '主流稳定品种' },
  { name: '金手指', sat: 650, actual: 423, rate: -6.8, note: '小众，意愿下降' },
  { name: '美人指', sat: 600, actual: 386, rate: -9.2, note: '管理成本高，持续下滑' },
  { name: '甜蜜蓝宝石', sat: 750, actual: 572, rate: 1.5, note: '热度消退，近停滞' },
  { name: '玫瑰香', sat: 700, actual: 594, rate: 7.6, note: '需求回升，增速稳健' },
  { name: '青提', sat: 800, actual: 708, rate: 3.9, note: '基础量大，平稳增长' }
]

const ghAreaMuEl = ref(null)
const ghProductDistEl = ref(null)
const ghStructureEl = ref(null)
const ghMapEl = ref(null)
const ghTotalYieldEl = ref(null)

let ghAreaMuChart, ghProductDistChart, ghStructureChart, ghMapChart, ghTotalYieldChart

function showKpi(card) {
  showModal(card.title, `当前${card.title}：${card.value}`)
}

function showTableDetail(row) {
  showModal(`${row.name}数据详情`, `饱和数据：${row.sat}亩<br>实际数据：${row.actual}亩<br>增长率：${row.rate >= 0 ? '↑' : '↓'}${Math.abs(row.rate)}%<br>备注：${row.note}`)
}

function initCharts() {
  ghAreaMuChart = initChart(ghAreaMuEl.value)
  ghAreaMuChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 10, right: 10, bottom: 20, left: 70 },
    xAxis: { type: 'value', max: 2500, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'category', data: ['洪雅县', '仁寿县', '东坡区', '彭山区'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    series: [{
      type: 'bar', data: [1600, 1800, 2189, 2200],
      itemStyle: { color: (p) => ['#b388ff', '#ffff99', '#90ee90', '#0099ff'][p.dataIndex] },
      label: { show: true, position: 'right', color: '#fff', fontSize: 14 }
    }]
  })
  ghAreaMuChart.on('click', (p) => showModal(`${p.name}亩数详情`, `区域：${p.name}<br>葡萄实际面积：${p.value}亩`))

  ghProductDistChart = initChart(ghProductDistEl.value)
  ghProductDistChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 30, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['彭山区', '东坡区', '仁寿县', '洪雅县'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', max: 2200, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['增长型', '平稳型', '下滑型'], textStyle: { color: '#fff' }, top: 0, left: 'center', icon: 'roundRect' },
    series: [
      { name: '增长型', type: 'bar', stack: 'total', data: [780, 740, 680, 762], itemStyle: { color: '#81c784' } },
      { name: '平稳型', type: 'bar', stack: 'total', data: [690, 760, 780, 788], itemStyle: { color: '#4facfe' } },
      { name: '下滑型', type: 'bar', stack: 'total', data: [190, 120, 140, 359], itemStyle: { color: '#ff6b6b' } }
    ]
  })
  ghProductDistChart.on('click', (p) => showModal(`${p.seriesName}详情`, `区域：${p.name}<br>${p.seriesName}面积：${p.value}亩`))

  ghStructureChart = initChart(ghStructureEl.value)
  ghStructureChart.on('click', (p) => showModal(`${p.name}结构详情`, `实际面积：${p.value}亩<br>占比：${p.percent}%`))
  renderStructureChart()

  ghTotalYieldChart = initChart(ghTotalYieldEl.value)
  ghTotalYieldChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 30, right: 10, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['第一季度', '第二季度', '第三季度', '第四季度'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', max: 180, axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    legend: { data: ['增长型', '平稳型', '下滑型'], textStyle: { color: '#fff' }, top: 0, left: 'center' },
    series: [
      { name: '增长型', type: 'line', data: [72, 86, 95, 102], lineStyle: { color: '#81c784' }, itemStyle: { color: '#81c784' }, label: { show: true, color: '#fff' } },
      { name: '平稳型', type: 'line', data: [64, 68, 70, 73], lineStyle: { color: '#4facfe' }, itemStyle: { color: '#4facfe' }, label: { show: true, color: '#fff' } },
      { name: '下滑型', type: 'line', data: [42, 36, 31, 28], lineStyle: { color: '#ff6b6b' }, itemStyle: { color: '#ff6b6b' }, label: { show: true, color: '#fff' } }
    ]
  })
  ghTotalYieldChart.on('click', (p) => showModal(`${p.seriesName}产量趋势`, `季度：${p.name}<br>指数：${p.value}`))

  initMapChart()
}

function renderStructureChart() {
  if (!ghStructureChart) return
  ghStructureChart.setOption({
    backgroundColor: 'transparent',
    tooltip: { trigger: 'item' },
    series: [{
      name: '葡萄品种结构', type: 'pie', radius: ['30%', '68%'], center: ['50%', '50%'],
      label: { show: true, color: '#fff', formatter: '{b}\n{value}' },
      data: varieties.value.map((v, i) => ({
        name: v.name, value: v.actual,
        itemStyle: { color: ['#00d4ff', '#ffd700', '#81c784', '#ff8a65', '#4facfe', '#ff6b6b', '#b066ff', '#f48fb1', '#90ee90', '#87ceeb'][i] }
      }))
    }]
  })
}

function initMapChart() {
  ghMapChart = initChart(ghMapEl.value)
  const areaData = [
    { name: '彭山区', value: 2200, level: '一级' },
    { name: '东坡区', value: 2189, level: '一级' },
    { name: '仁寿县', value: 1800, level: '二级' },
    { name: '洪雅县', value: 1600, level: '三级' }
  ]
  const coords = {
    '彭山区': [103.85, 30.2],
    '东坡区': [103.83, 30.05],
    '仁寿县': [104.15, 30.0],
    '洪雅县': [103.35, 29.9]
  }
  fetch('https://geo.datav.aliyun.com/areas_v3/bound/510000_full.json')
    .then((response) => response.json())
    .then((geoJson) => {
      echarts.registerMap('sichuan', geoJson)
      const option = {
        backgroundColor: 'transparent',
        tooltip: {
          trigger: 'item',
          formatter: (params) => {
            const item = areaData.find((i) => i.name === params.name)
            return item ? `${item.name}<br>种植面积：${item.value}亩<br>等级：${item.level}` : params.name
          }
        },
        geo: {
          map: 'sichuan', roam: true, zoom: 7, center: [103.85, 30.1],
          label: { show: true, color: '#fff', fontSize: 11 },
          itemStyle: { areaColor: 'rgba(0,30,60,0.8)', borderColor: '#00d4ff', borderWidth: 1 },
          emphasis: { itemStyle: { areaColor: 'rgba(0,212,255,0.5)' } }
        },
        series: [
          {
            type: 'scatter', coordinateSystem: 'geo',
            data: areaData.map((item) => ({ name: item.name, value: [...coords[item.name], item.value], level: item.level })),
            symbolSize: (val) => val[2] / 35,
            itemStyle: {
              color: (params) => {
                const colors = { '一级': '#87ceeb', '二级': '#00bfff', '三级': '#008b8b' }
                return colors[params.data.level] || '#00d4ff'
              },
              borderColor: '#fff', borderWidth: 1
            }
          }
        ]
      }
      ghMapChart.setOption(option)
      ghMapChart.on('click', (params) => {
        const item = areaData.find((i) => i.name === params.name)
        if (item) showModal(`${item.name}详情`, `种植面积：${item.value}亩<br>等级：${item.level}`)
      })
    })
}

async function loadVarieties() {
  try {
    const r = await getGrapeList()
    if (r.code === 200 && Array.isArray(r.data) && r.data.length) {
      varieties.value = r.data.map((v) => ({ name: v.name, sat: v.satArea, actual: v.actualArea, rate: v.rate, note: v.note }))
      renderStructureChart()
    }
  } catch (e) { /* 保留本地模拟数据 */ }
}

onMounted(() => {
  initCharts()
  loadVarieties()
})

onBeforeUnmount(() => {
  ;[ghAreaMuChart, ghProductDistChart, ghStructureChart, ghMapChart, ghTotalYieldChart].forEach(disposeChart)
})
</script>

<template>
  <div class="gh-top-kpi">
    <div v-for="card in kpiCards" :key="card.type" class="gh-kpi-card" @click="showKpi(card)">
      <div class="gh-kpi-icon" :class="card.iconClass">{{ card.icon }}</div>
      <div><div class="gh-kpi-title">{{ card.title }}</div><div class="gh-kpi-value">{{ card.value }}</div></div>
    </div>
  </div>
  <div class="gh-main">
    <div class="gh-left-col">
      <div class="gh-chart-module"><div class="gh-chart-title"><span class="dot"></span>区域亩数</div><div ref="ghAreaMuEl" class="gh-chart-box"></div></div>
      <div class="gh-chart-module"><div class="gh-chart-title"><span class="dot"></span>增长/平稳/下滑分布</div><div ref="ghProductDistEl" class="gh-chart-box"></div></div>
      <div class="gh-chart-module"><div class="gh-chart-title"><span class="dot"></span>葡萄品种结构</div><div ref="ghStructureEl" class="gh-chart-box"></div></div>
    </div>
    <div class="gh-center-col">
      <div class="gh-chart-module" style="position: relative;">
        <div class="gh-chart-title"><span class="dot"></span>区域地图（葡萄种植分级）</div>
        <div ref="ghMapEl" class="gh-chart-box"></div>
        <div class="gh-map-legend">
          <div class="gh-legend-item"><i style="background:#87ceeb"></i>一级（高种植量）</div>
          <div class="gh-legend-item"><i style="background:#00bfff"></i>二级（中种植量）</div>
          <div class="gh-legend-item"><i style="background:#008b8b"></i>三级（低种植量）</div>
        </div>
      </div>
    </div>
    <div class="gh-right-col">
      <div class="gh-chart-module"><div class="gh-chart-title"><span class="dot"></span>总产量</div><div ref="ghTotalYieldEl" class="gh-chart-box"></div></div>
      <div class="gh-table-module">
        <div class="gh-table-title">数据截止日期：05/1（字段：品种/饱和/实际/增长率/备注）</div>
        <div class="gh-chart-title"><span class="dot"></span>葡萄周期数据统计</div>
        <div class="gh-table-container">
          <table>
            <thead><tr><th>葡萄品种</th><th>饱和数据(亩)</th><th>实际数据(亩)</th><th>增长率</th><th>备注</th></tr></thead>
            <tbody>
              <tr v-for="row in ghTableRows" :key="row.name" @click="showTableDetail(row)">
                <td>{{ row.name }}</td>
                <td>{{ row.sat }}</td>
                <td>{{ row.actual }}</td>
                <td :class="row.rate >= 0 ? 'up' : 'down'">{{ row.rate >= 0 ? '↑' : '↓' }}{{ Math.abs(row.rate) }}%</td>
                <td>{{ row.note }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
