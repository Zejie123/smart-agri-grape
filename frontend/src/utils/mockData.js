// 后端不可用时的本地兜底模拟数据（与原静态页保持一致）

export const grapeVarieties = [
  { name: '巨峰', sat: 950, actual: 885, rate: 12.3, note: '全国第一大主栽品种，农户种植基数大，增速平稳，调研均值880-890亩。' },
  { name: '阳光玫瑰', sat: 1000, actual: 912, rate: 4.7, note: '前期扩种快，2025年回归理性，增速放缓，主产区农户平均种植910亩左右。' },
  { name: '夏黑', sat: 850, actual: 768, rate: 8.1, note: '早熟优势明显，农户稳定种植，实际种植面积贴合饱和值，增速合理。' },
  { name: '红提', sat: 900, actual: 826, rate: 2.3, note: '传统老品种，种植趋于饱和，同比小幅增长，农户种植面积波动小。' },
  { name: '无核白', sat: 800, actual: 715, rate: 5.4, note: '新疆主产区农户主流品种，种植规模稳定，增速平缓。' },
  { name: '金手指', sat: 650, actual: 423, rate: -6.8, note: '小众特色品种，市场受众窄，农户种植意愿下降，面积同比缩减。' },
  { name: '美人指', sat: 600, actual: 386, rate: -9.2, note: '管理成本高、落果严重，农户弃种扩种少，种植面积持续下滑。' },
  { name: '甜蜜蓝宝石', sat: 750, actual: 572, rate: 1.5, note: '网红品种热度消退，仅少量农户种植，增速近乎停滞。' },
  { name: '玫瑰香', sat: 700, actual: 594, rate: 7.6, note: '香型特色品种，市场需求回升，农户小幅扩种，增速稳健。' },
  { name: '青提', sat: 800, actual: 708, rate: 3.9, note: '早熟平价品种，农户基础种植量大，同比平稳增长。' }
]

export const weatherData = [
  { date: '今天', icon: '☀️', temp: '17~29', desc: '晴' },
  { date: '明天', icon: '⛅', temp: '18~30', desc: '多云' },
  { date: '后天', icon: '🌧️', temp: '16~25', desc: '小雨' },
  { date: '周四', icon: '☁️', temp: '17~27', desc: '阴' },
  { date: '周五', icon: '☀️', temp: '19~31', desc: '晴' },
  { date: '周六', icon: '⛅', temp: '20~32', desc: '多云' },
  { date: '周日', icon: '🌤️', temp: '18~28', desc: '晴间多云' }
]

export const priceData = {
  dates: ['05-01', '05-05', '05-10', '05-15', '05-20', '05-25', '05-29'],
  varieties: [
    { name: '巨峰', data: [8.5, 8.8, 9.0, 8.7, 9.2, 9.5, 9.3] },
    { name: '阳光玫瑰', data: [25.0, 24.5, 26.0, 25.5, 27.0, 28.0, 27.5] },
    { name: '夏黑', data: [12.0, 12.5, 13.0, 12.8, 13.5, 14.0, 13.8] }
  ]
}

export const farmingRecords = [
  { date: '2025-05-25', type: '施肥', content: '施用膨果肥，钾肥20kg/亩', person: '张三', land: '1号地' },
  { date: '2025-05-24', type: '打药', content: '防治霜霉病，使用甲霜灵', person: '李四', land: '2号地' },
  { date: '2025-05-23', type: '疏果', content: '疏除小果、畸形果', person: '王五', land: '1号大棚' },
  { date: '2025-05-22', type: '除草', content: '人工除草', person: '赵六', land: '3号地' },
  { date: '2025-05-21', type: '修剪', content: '修剪副梢', person: '张三', land: '2号大棚' }
]

// 水肥配方
export const recipes = [
  { id: 1, name: '葡萄苗期配方', desc: '氮:磷:钾=2:1:1 | 适合幼苗快速生长' },
  { id: 2, name: '葡萄膨果配方', desc: '氮:磷:钾=1:2:3 | 提升果实甜度' },
  { id: 3, name: '葡萄着色配方', desc: '高磷高钾 | 促进上色、增糖、提质' },
  { id: 4, name: '通用均衡配方', desc: '氮:磷:钾=1:1:1 | 全周期适用' }
]
