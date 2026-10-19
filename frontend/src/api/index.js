import axios from 'axios'

// 前端统一走相对路径 /api：
//  - 开发环境：由 vite.config.js 的 server.proxy 转发到后端 8080
//  - 生产环境：由 nginx 反向代理转发到后端 8080
const request = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 后端统一返回 { code, msg, data }（Result<T>），这里解包：
//  - code === 200 时直接返回整个 result
//  - 其它情况抛出错误，交由调用方 catch 后回退本地数据
request.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res && typeof res === 'object' && 'code' in res) {
      if (res.code === 200) return res
      return Promise.reject(new Error(res.msg || '请求失败'))
    }
    return res
  },
  (error) => Promise.reject(error)
)

// ===== 葡萄品种 =====
export function getGrapeList() {
  return request.get('/dashboard/grape/list')
}

// ===== 农事记录 =====
export function getFarmingList() {
  return request.get('/dashboard/farming/list')
}

export function addFarming(record) {
  return request.post('/dashboard/farming/add', record)
}

// ===== 系统配置（告警阈值） =====
export function getConfigList() {
  return request.get('/dashboard/config/list')
}

export function saveConfig(configList) {
  return request.post('/dashboard/config/save', configList)
}

// ===== 告警 =====
export function getLatestAlarm() {
  return request.get('/dashboard/alarm/latest')
}

export function clearAlarmApi() {
  return request.post('/dashboard/alarm/clear')
}

// ===== 系统（用户/日志/环境） =====
export function getUserList() {
  return request.get('/system/user/list')
}

export function getLogList() {
  return request.get('/system/log/list')
}

export function getEnvLatest() {
  return request.get('/system/env/latest')
}

export default request
