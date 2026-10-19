import * as echarts from 'echarts'

// 统一管理所有图表实例，window resize 时批量自适应
const instances = new Set()
window.addEventListener('resize', () => {
  instances.forEach((c) => c && c.resize())
})

export { echarts }

// 初始化一个图表并登记到全局，返回实例
export function initChart(el) {
  const chart = echarts.init(el)
  instances.add(chart)
  return chart
}

// 销毁单个图表
export function disposeChart(chart) {
  if (chart) {
    instances.delete(chart)
    chart.dispose()
  }
}

// 统一 resize（页面切换 / v-show 显示后调用）
export function resizeAllCharts() {
  instances.forEach((c) => c && c.resize())
}
