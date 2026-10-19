# 智慧农业平台（Smart Agri Grape）

前后端分离的智慧农业大屏系统。后端 Spring Boot + MyBatis-Plus + MySQL，前端为 Vue 3 + Vite + ECharts 大屏，通过 Nginx 反向代理实现前后端同源交互。

## 目录结构

```
smart-agri-grape/
├── start.bat                 # 一键启动后端（双击即可）
├── stop.bat                  # 一键停止后端
├── nginx.conf                # Nginx 反向代理配置（托管 dist + 转发 /api）
├── sql/schema.sql            # 数据库初始化脚本
├── frontend/                 # 前端 Vue 3 + Vite 工程
│   ├── index.html            # Vite 入口
│   ├── package.json          # 依赖（vue/echarts/axios/vite）
│   ├── vite.config.js        # @ 别名 + dev 代理 /api → 8080
│   ├── legacy/index.html     # 旧静态 HTML 备份（仅供对照）
│   └── src/
│       ├── main.js           # 入口
│       ├── App.vue           # 顶栏/Tab 切换/全局弹窗/toast/快捷工具
│       ├── api/index.js      # axios 封装 + 后端接口函数
│       ├── store.js          # 跨组件共享状态（弹窗/告警/当前页）
│       ├── styles/main.css   # 大屏暗色主题样式
│       ├── utils/            # mock 数据 + echarts 复用
│       ├── components/       # ModuleCard / SwitchControl / ModalDialog
│       └── views/            # 首页/智慧大棚/设备/水肥/农事/设置 六页
└── src/main/
    ├── java/com/agri/        # 后端源码
    │   ├── controller/       # DashboardController（接口）
    │   ├── service/          # 业务接口 + impl 实现
    │   ├── mapper/           # MyBatis-Plus Mapper
    │   ├── entity/           # 实体
    │   ├── common/Result.java
    │   └── config/CORSConfig.java
    └── resources/
        ├── application.yml   # 后端配置
        └── static/index.html # 旧静态前端（后端 jar 内置，可忽略）
```

## 快速启动

1. 确保本机已安装 **JDK 8+**、**Maven**、**Node.js**、**MySQL 5.7+**（MySQL 服务名为 `MySQL`，需在运行）。
2. 首次启动前导入数据库：`mysql -uroot -p < sql/schema.sql`（脚本会自动建库建表）。
3. 首次使用前：编辑 `start.bat`，把 `NGINX_DIR` 改成你本机 nginx 的安装目录（默认 `D:\develop\nginx-1.22.0-web\nginx-1.22.0-web`）。
4. **双击 `start.bat`**，自动：检查环境 → 构建（若 jar/dist 不存在）→ 启动后端 → 启动 nginx → 打开浏览器。
5. 浏览器访问：<http://localhost/>（nginx 托管 Vue 前端，`/api` 反向代理到后端 8080）。

停止：双击 `stop.bat`（同时停止后端和 nginx）。

## 配置说明

后端 `application.yml` 支持通过**环境变量**或**命令行参数**覆盖默认值（`${变量:默认值}`）：

| 配置项 | 环境变量 | 默认值 |
|--------|----------|--------|
| 服务端口 | `SERVER_PORT` | 8080 |
| 接口前缀 | `CONTEXT_PATH` | /api |
| 数据库地址 | `DB_HOST` | 127.0.0.1 |
| 数据库端口 | `DB_PORT` | 3306 |
| 数据库名 | `DB_NAME` | smart_agri_grape |
| 数据库用户 | `DB_USERNAME` | root |
| 数据库密码 | `DB_PASSWORD` | 5201314 |

例如临时改端口启动：

```bash
java -jar target/smart-agri-grape-0.0.1-SNAPSHOT.jar --server.port=9090
```

或设置环境变量后运行（Windows CMD）：

```bat
set SERVER_PORT=9090
set DB_PASSWORD=你的密码
start.bat
```

## 前端（Vue）开发与部署

前端统一通过相对路径 `/api` 调用后端接口，无需关心后端地址：

- **开发环境**：`vite.config.js` 里的 `server.proxy` 已把 `/api` 转发到后端 `http://127.0.0.1:8080`。
- **生产环境**：Nginx 反向代理把 `/api` 转发到后端（见 `nginx.conf`）。

### 1. 开发联调（npm run dev）

```bash
cd frontend
npm install          # 首次
npm run dev          # 启动 Vite，访问 http://localhost:5173
```

需先启动后端（`start.bat`），前端会自动经 Vite 代理调用后端接口；后端不可用时自动回退本地模拟数据，大屏仍可正常预览。

### 2. 构建产物

```bash
cd frontend
npm run build        # 产出 frontend/dist/
```

### 3. Nginx 反向代理部署

1. 构建前端：`cd frontend && npm run build`。
2. 启动后端：双击项目根目录 `start.bat`（后端监听 8080）。
3. 将 `nginx.conf` 内容应用到 Nginx（覆盖 `conf/nginx.conf` 的 server 段，并按需修改
   `root` 指向 `frontend/dist` 的绝对路径、监听端口、后端地址）。
4. 启动 Nginx，浏览器访问 <http://localhost/> —— 页面正常渲染，`/api/dashboard/*` 由 Nginx 转发到后端。

> 提示：`nginx.conf` 中 `location /` 托管前端、`location /api/` 反向代理到后端 8080，
> 实现了前后端同源，因此后端 `CORSConfig` 的跨域放行不再必需（保留亦无害）。

## 后端接口地址说明

后端接口统一挂在 context-path `/api` 下（见 `application.yml` 的 `CONTEXT_PATH`）。

## 接口列表

| 方法 | 路径 | 说明 |
|------|------|------|
| GET  | `/api/dashboard/grape/list` | 葡萄品种列表 |
| GET  | `/api/dashboard/farming/list` | 农事记录列表 |
| POST | `/api/dashboard/farming/add` | 新增农事记录 |
| GET  | `/api/dashboard/config/list` | 系统配置列表 |
| POST | `/api/dashboard/config/save` | 保存配置 |
| GET  | `/api/dashboard/alarm/latest` | 最新告警（12条） |
| POST | `/api/dashboard/alarm/clear` | 清除告警 |
