# Claude Workspace Docker

> **企业级 Claude Code 工作空间容器化解决方案**  
> 提供完整的 Docker 化 Claude Code 环境，集成企业级 Hooks 配置、通知系统和持久化会话管理。

## 🚀 核心特性

- **🏢 企业级配置**: 基于 Claude Code 官方规范的企业管理策略配置
- **🔔 智能通知**: 集成飞书和 Telegram 通知，实时跟踪 AI 操作状态
- **🐳 容器化部署**: 开箱即用的 Docker 解决方案，支持 Dokploy、Docker Compose
- **💾 会话持久化**: 基于 tmux 的会话管理，工作永不丢失
- **🔒 安全访问**: 内置身份验证和访问控制
- **⚡ 高可用性**: 企业级稳定性和可靠性保证

## 📁 项目架构

```bash
claude-workspace-docker/
├── docker-claude-config/           # Claude Code 配置目录
│   ├── managed-settings.json       # 企业管理策略配置（最高优先级）
│   └── scripts/
│       ├── feishu-notify.ts         # 飞书通知脚本
│       └── telegram-notify.ts       # Telegram 通知脚本
├── Dockerfile                       # 主要构建文件
├── docker-compose.yml              # Docker Compose 配置
└── docs/                           # 文档目录
```

### Docker 容器内结构

```bash
/etc/claude-code/
└── managed-settings.json          # 企业管理策略（不可覆盖）

/opt/claude-scripts/
├── feishu-notify.ts               # 通知脚本（绝对路径）
└── telegram-notify.ts

/root/.claude/                     # 用户配置目录（可自定义）

/workspace/                        # 工作目录（持久化）
```

## 🔧 Claude Code Hooks 配置

本项目采用 **企业管理策略** 配置模式，确保最高优先级和配置稳定性：

### 配置优先级

1. **企业管理策略** (`/etc/claude-code/managed-settings.json`) ← **当前使用**
2. 命令行参数
3. 本地项目设置
4. 共享项目设置
5. 用户设置

### Hooks 事件配置

- **Notification**: 当 Claude Code 发送通知时触发
- **PostToolUse**: 在工具执行完成后触发
- **支持工具**: Bash, Edit, Write, MultiEdit, NotebookEdit

### 通知脚本路径设计

使用绝对路径 `/opt/claude-scripts/` 确保容器环境下的稳定性，避免环境变量依赖问题。

## 🚀 快速开始

### 方式一：Docker Compose（推荐）

```bash
# 克隆项目
git clone https://github.com/yourusername/claude-workspace-docker.git
cd claude-workspace-docker

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，添加必要的 API 密钥

# 启动服务
docker-compose up -d
```

### 方式二：Docker 直接运行

```bash
# 构建镜像
docker build -t claude-workspace .

# 运行容器
docker run -d \
  --name claude-workspace \
  -p 7681:7681 \
  -v $(pwd)/workspace:/workspace \
  claude-workspace
```

### 方式三：Dokploy 部署

1. **创建应用**: 选择 Git Repository，连接本仓库
2. **配置端口**: 设置端口为 `7681`
3. **添加域名**: 配置你的域名如 `claude.yourdomain.com`
4. **添加身份验证** (可选):

   ```bash
   # 生成密码
   docker run --rm httpd:2.4 htpasswd -nb admin yourpassword

   # 在 Dokploy 添加标签
   traefik.http.routers.app.middlewares=claude-auth@docker
   traefik.http.middlewares.claude-auth.basicauth.users=admin:$apr1$...
   ```

## 🔔 通知配置

### 飞书通知设置

1. 创建飞书自定义机器人
2. 获取 Webhook URL
3. 在 `.env` 文件中配置：

   ```env
   FEISHU_WEBHOOK_URL=https://open.feishu.cn/open-apis/bot/v2/hook/your-webhook-id
   ```

### Telegram 通知设置

1. 创建 Telegram Bot
2. 获取 Bot Token 和 Chat ID
3. 在 `.env` 文件中配置：

   ```env
   TELEGRAM_BOT_TOKEN=your_bot_token
   TELEGRAM_CHAT_ID=your_chat_id
   ```

## 💡 使用指南

### 访问工作空间

1. 打开浏览器访问 `http://localhost:7681` 或你的域名
2. 进入身份验证（如已配置）
3. 自动进入 `claude_session` tmux 会话

### Claude Code 操作

```bash
# 在终端中启动 Claude Code
claude

# 退出但保持会话
# 按 Ctrl+B，然后按 D

# 重新连接到会话
tmux attach -t claude_session
```

### Hooks 测试

项目包含测试脚本验证 Hooks 配置：

```bash
# 在容器内运行
/opt/claude-scripts/test-hooks.sh
```

## 🔍 故障排除

### 常见问题

1. **通知不工作**

   - 检查 `.env` 文件配置
   - 验证网络连接
   - 查看容器日志：`docker logs claude-workspace`

2. **Claude Code 无法启动**

   - 确认 API 密钥配置正确
   - 检查网络代理设置
   - 验证 Node.js 环境

3. **会话丢失**
   - 确认 workspace 目录正确挂载
   - 检查 tmux 配置

### 日志查看

```bash
# 查看容器日志
docker logs -f claude-workspace

# 进入容器调试
docker exec -it claude-workspace bash

# 查看 Hooks 执行日志
cat /var/log/claude-hooks.log
```

## 🔧 自定义配置

### 修改 Hooks 配置

编辑 `docker-claude-config/managed-settings.json` 文件，修改 hooks 设置：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "tsx /opt/claude-scripts/custom-script.ts",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

### 添加自定义脚本

1. 在 `docker-claude-config/scripts/` 目录添加脚本
2. 在 `managed-settings.json` 中引用
3. 重新构建容器

## 📚 技术文档

- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Claude Code Settings 配置](https://docs.anthropic.com/en/docs/claude-code/settings)
- [企业级配置最佳实践](docs/enterprise-config.md)

## 🤝 贡献指南

欢迎提交 Issues 和 Pull Requests！

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## ⭐ Star History

如果这个项目对你有帮助，请给个 Star ⭐️

---

**Claude Workspace Docker** - 让 AI 开发更高效，让团队协作更智能。
