<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { initChart, disposeChart } from '../utils/useChart'
import { showModal } from '../store'
import { farmingRecords as mockRecords } from '../utils/mockData'
import { getFarmingList, addFarming } from '../api'

const records = ref([...mockRecords])

const pieEl = ref(null)
const trendEl = ref(null)
const completionEl = ref(null)

let farmingPieChart, farmingTrendChart, farmingCompletionChart

const weekDays = ['日', '一', '二', '三', '四', '五', '六']
const calendarDays = ref([])
const eventDates = [23, 24, 25, 27]

const todos = [
  { text: '5月30日 全园病虫害防治', date: '截止时间：2025-05-30' },
  { text: '6月02日 葡萄疏果作业', date: '截止时间：2025-06-02' },
  { text: '6月05日 施用膨果肥', date: '截止时间：2025-06-05' }
]

const types = ['施肥', '打药', '除草', '疏果', '采摘', '修剪', '其他']
const lands = ['1号地', '2号地', '3号地', '1号大棚', '2号大棚']

// 新增记录表单
const showAdd = ref(false)
const farmingDate = ref('')
const farmingType = ref('施肥')
const farmingContent = ref('')
const farmingPerson = ref('admin')
const farmingLand = ref('1号地')

function viewDetail(r) {
  showModal('农事详情', `<strong>日期：</strong>${r.date}<br/><strong>类型：</strong>${r.type}<br/><strong>内容：</strong>${r.content}<br/><strong>负责人：</strong>${r.person}<br/><strong>地块：</strong>${r.land}`)
}

function initCalendar() {
  const now = new Date()
  const year = now.getFullYear()
  const month = now.getMonth()
  const today = now.getDate()
  const firstDay = new Date(year, month, 1).getDay()
  const daysInMonth = new Date(year, month + 1, 0).getDate()

  const days = []
  for (let i = 0; i < firstDay; i++) days.push({ day: '', isToday: false, hasEvent: false })
  for (let i = 1; i <= daysInMonth; i++) {
    days.push({ day: i, isToday: i === today, hasEvent: eventDates.includes(i) })
  }
  calendarDays.value = days
}

function initCharts() {
  farmingPieChart = initChart(pieEl.value)
  farmingPieChart.setOption({
    backgroundColor: 'transparent',
    tooltip: { trigger: 'item' },
    series: [{
      name: '农事类型', type: 'pie', radius: ['40%', '70%'],
      data: [
        { value: 30, name: '施肥', itemStyle: { color: '#ffd700' } },
        { value: 25, name: '打药', itemStyle: { color: '#ff6b6b' } },
        { value: 20, name: '除草', itemStyle: { color: '#00ff9d' } },
        { value: 15, name: '疏果', itemStyle: { color: '#4facfe' } },
        { value: 10, name: '其他', itemStyle: { color: '#b066ff' } }
      ],
      label: { color: '#fff' }
    }]
  })

  farmingTrendChart = initChart(trendEl.value)
  farmingTrendChart.setOption({
    backgroundColor: 'transparent',
    grid: { top: 20, right: 20, bottom: 20, left: 40 },
    xAxis: { type: 'category', data: ['05-01', '05-05', '05-10', '05-15', '05-20', '05-25', '05-29'], axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    yAxis: { type: 'value', axisLine: { lineStyle: { color: '#00d4ff' } }, axisLabel: { color: '#fff' } },
    series: [{
      name: '农事次数', type: 'line', smooth: true, data: [2, 5, 3, 8, 6, 4, 5],
      itemStyle: { color: '#00d4ff' },
      areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(0,212,255,0.5)' }, { offset: 1, color: 'rgba(0,212,255,0.1)' }] } }
    }]
  })

  farmingCompletionChart = initChart(completionEl.value)
  farmingCompletionChart.setOption({
    backgroundColor: 'transparent',
    tooltip: { trigger: 'item' },
    series: [{
      name: '农事完成率', type: 'pie', radius: ['50%', '75%'],
      data: [
        { value: 85, name: '已完成', itemStyle: { color: '#00ff9d' } },
        { value: 15, name: '未完成', itemStyle: { color: '#ff6b6b' } }
      ],
      label: { color: '#fff', formatter: '{b}: {c}%' }
    }]
  })
}

async function loadRecords() {
  try {
    const r = await getFarmingList()
    if (r.code === 200 && Array.isArray(r.data)) {
      records.value = r.data.map((x) => ({ date: x.farmingDate, type: x.type, content: x.content, person: x.person, land: x.land }))
    }
  } catch (e) { /* 保留本地模拟数据 */ }
}

function openAdd() {
  farmingDate.value = new Date().toISOString().split('T')[0]
  showAdd.value = true
}

function closeAdd() {
  showAdd.value = false
}

async function saveRecord() {
  if (!farmingDate.value || !farmingContent.value) {
    return showModal('提示', '请填写完整信息！')
  }
  const payload = {
    farmingDate: farmingDate.value,
    type: farmingType.value,
    content: farmingContent.value,
    person: farmingPerson.value,
    land: farmingLand.value
  }
  try {
    await addFarming(payload)
    await loadRecords()
    closeAdd()
    showModal('成功', '农事记录已保存！')
    farmingContent.value = ''
  } catch (e) {
    records.value.unshift({ date: farmingDate.value, type: farmingType.value, content: farmingContent.value, person: farmingPerson.value, land: farmingLand.value })
    closeAdd()
    showModal('成功', '农事记录已保存(本地)！')
    farmingContent.value = ''
  }
}

onMounted(() => {
  initCalendar()
  initCharts()
  loadRecords()
})

onBeforeUnmount(() => {
  ;[farmingPieChart, farmingTrendChart, farmingCompletionChart].forEach(disposeChart)
})
</script>

<template>
  <div class="farming-main">
    <div class="farming-left">
      <div class="farming-card">
        <div class="farming-title"><span class="dot"></span>农事日历</div>
        <div class="farming-calendar">
          <div v-for="(w, i) in weekDays" :key="'w' + i" class="calendar-header">{{ w }}</div>
          <div
            v-for="(d, i) in calendarDays"
            :key="i"
            class="calendar-day"
            :class="{ today: d.isToday, 'has-event': d.hasEvent }"
          >{{ d.day }}</div>
        </div>
      </div>
      <div class="farming-card">
        <div class="farming-title"><span class="dot"></span>农事类型统计</div>
        <div ref="pieEl" class="chart-box" style="flex:1;"></div>
      </div>
      <div class="farming-card completion-module">
        <div class="farming-title"><span class="dot"></span>农事完成率</div>
        <div ref="completionEl" class="chart-box"></div>
      </div>
    </div>
    <div class="farming-center">
      <div class="farming-card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
          <div class="farming-title"><span class="dot"></span>农事记录列表</div>
          <button class="add-btn" @click="openAdd">+ 新增记录</button>
        </div>
        <div class="farming-table">
          <table>
            <thead><tr><th>日期</th><th>类型</th><th>内容</th><th>负责人</th><th>地块</th><th>操作</th></tr></thead>
            <tbody>
              <tr v-for="(r, i) in records" :key="i">
                <td>{{ r.date }}</td>
                <td>{{ r.type }}</td>
                <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ r.content }}</td>
                <td>{{ r.person }}</td>
                <td>{{ r.land }}</td>
                <td><span style="color:#00d4ff;cursor:pointer;" @click="viewDetail(r)">查看</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div class="farming-right">
      <div class="farming-card">
        <div class="farming-title"><span class="dot"></span>农事趋势（近30天）</div>
        <div ref="trendEl" class="chart-box" style="flex:1;"></div>
      </div>
      <div class="farming-card">
        <div class="farming-title"><span class="dot"></span>待办任务</div>
        <div class="todo-list">
          <div v-for="(t, i) in todos" :key="i" class="todo-item">
            <div class="todo-text">{{ t.text }}</div>
            <div class="todo-date">{{ t.date }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 新增农事记录弹窗 -->
    <div class="modal" :style="{ display: showAdd ? 'flex' : 'none' }" @click.self="closeAdd">
      <div class="modal-content" style="width:500px;">
        <span class="modal-close" @click="closeAdd">&times;</span>
        <div class="modal-title">新增农事记录</div>
        <div class="modal-body">
          <div class="form-group"><label>日期</label><input type="date" v-model="farmingDate" /></div>
          <div class="form-group"><label>类型</label><select v-model="farmingType"><option v-for="t in types" :key="t" :value="t">{{ t }}</option></select></div>
          <div class="form-group"><label>内容</label><textarea v-model="farmingContent" placeholder="请输入农事内容..."></textarea></div>
          <div class="form-group"><label>负责人</label><input type="text" v-model="farmingPerson" /></div>
          <div class="form-group"><label>地块</label><select v-model="farmingLand"><option v-for="l in lands" :key="l" :value="l">{{ l }}</option></select></div>
          <button class="water-btn" style="width:100%;" @click="saveRecord">保存记录</button>
        </div>
      </div>
    </div>
  </div>
</template>
