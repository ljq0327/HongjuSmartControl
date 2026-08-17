# 鸿居智控后端演示服务

这是当前 App 样板配套的后端服务，支持两种存储模式：

- 内存模式：不配置 MySQL 时自动启用，适合快速演示。
- MySQL 模式：配置数据库后启用，保存用户、设备、状态、日志、场景和温湿度历史。

## 启动

```powershell
node backend/server.js
```

如果系统没有全局 Node.js，可以使用 DevEco Studio 自带的 Node：

```powershell
& "D:\Program Files\DevEco Studio\tools\node\node.exe" backend/server.js
```

也可以直接运行脚本：

```powershell
.\backend\start-server.ps1
```

## 启用 MySQL

1. 安装依赖：

```powershell
cd backend
npm install
```

2. 创建数据库和表：

```powershell
mysql -u root -p < schema.sql
```

3. 复制配置文件：

```powershell
Copy-Item .env.example .env
```

然后修改 `.env` 里的 MySQL 账号、密码和数据库名。

如果没有配置 `.env` 或没有安装 `mysql2`，后端会自动使用内存模式，不影响演示。

## 演示地址

- 虚拟卧室网页：http://127.0.0.1:3027/bedroom?username=linjiaqi
- 登录接口：`POST /api/login`
- 全部状态：`GET /api/status`
- 操作日志：`GET /api/logs`
- 灯光控制：`POST /api/light`
- 门禁控制：`POST /api/door`
- 空调控制：`POST /api/air`
- AI 管家生成方案：`POST /api/ai/housekeeper`
- AI 管家执行方案：`POST /api/ai/execute`

## AI 管家接入

在 `backend/.env` 中增加：

```env
AI_API_KEY=你的大模型API密钥
AI_BASE_URL=https://api.openai.com/v1/chat/completions
AI_MODEL=gpt-4.1-mini
```

说明：

- `AI_API_KEY` 只放后端，不要放在 OpenHarmony APP 里。
- APP 只调用你自己的后端接口 `/api/ai/housekeeper` 和 `/api/ai/execute`。
- 如果没有配置 `AI_API_KEY`，后端会自动回退到本地规则方案，方便演示。

演示账号：

- 用户名：`linjiaqi`
- 密码：`123456`

App 后续接入后，可以通过后端保存设备状态、接收控制命令、同步虚拟网页并返回最新状态。

接口返回里的 `storage` 字段表示当前存储模式：

- `memory`：内存模式
- `mysql`：MySQL 持久化模式

## 数据库表

- `users`：用户账号
- `rooms`：房间列表
- `devices`：设备列表和当前状态
- `device_states`：设备状态历史
- `operation_logs`：操作日志
- `scene_modes`：场景模式
- `sensor_records`：温湿度历史数据
- `door_camera_videos`：入户门猫眼视频记录

`door_camera_videos` 建议只存视频路径和封面路径，视频文件放在 `backend/uploads/` 下，例如：

```sql
INSERT INTO door_camera_videos (
  user_id, device_id, video_url, cover_url, captured_at, duration_sec, camera_status, notes
) VALUES (
  1, 'entrance_door', '/uploads/doorcam/demo.mp4', '/uploads/doorcam/demo-cover.jpg',
  NOW(), 12, 'normal', '门口有人按铃，可先查看猫眼画面再决定是否解锁'
);
```

查看最新一条猫眼记录的接口：

```text
GET /api/door/camera/latest?username=linjiaqi&deviceId=entrance_door
```

## 接口示例

```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:3027/api/status"

Invoke-RestMethod -Uri "http://127.0.0.1:3027/api/light" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"deviceId":"bedroom_light","power":true}'

Invoke-RestMethod -Uri "http://127.0.0.1:3027/api/door" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"deviceId":"bedroom_door","locked":false}'

Invoke-RestMethod -Uri "http://127.0.0.1:3027/api/air" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"deviceId":"bedroom_air","power":true,"temperature":25,"mode":"制冷"}'
```

## 注意

当前 App 里的接口地址是 `http://127.0.0.1:3027`，适合 DevEco Preview 预览时使用。

如果运行到模拟器或真机，`127.0.0.1` 可能指向设备自身，不是你的电脑。此时需要把 `Index.ets` 里的 `apiBaseUrl` 改成电脑局域网 IP，例如：

```ts
@State apiBaseUrl: string = 'http://192.168.1.10:3027';
```
## 后端启动建议

如果你只是双击或短暂执行 `node server.js`，窗口关闭后服务也会一起退出。

更稳的启动方式：

```powershell
cd E:\hongmeng\backend
node server.js
```

保持这个终端窗口不要关闭。

如果想一键单独打开一个常驻窗口，可以运行：

```powershell
E:\hongmeng\backend\start-server-window.ps1
```

启动成功后，再在浏览器里访问：

```text
http://127.0.0.1:3027/api/status?username=linjiaqi
```

如果这两个地址都打不开，说明后端当前没有真正运行，而不是 APP 登录逻辑有问题。
