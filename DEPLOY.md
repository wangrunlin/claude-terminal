# Dokploy 部署指南

本文档详细介绍如何在 Dokploy 上部署 Claude Workspace Docker 项目。

## 部署前准备

### 1. 确认 Dokploy 环境

- 确保 Dokploy 已正确安装并运行
- 确认你有管理员权限

### 2. 准备代码仓库

```bash
# 将代码推送到 Git 仓库（GitHub/GitLab/Gitea 等）
git add .
git commit -m "准备 Dokploy 部署"
git push origin main
```

## 部署方法

### 方法一：Git 仓库部署（推荐）

1. **登录 Dokploy 控制台**

   - 访问你的 Dokploy 服务地址
   - 使用管理员账号登录

2. **创建新项目**

   - 点击 "Create Project"
   - 填写项目名称：`claude-terminal`

3. **添加 Compose 应用**

   - 在项目中点击 "Add Application"
   - 选择 "Compose" 类型
   - 填写应用名称：`claude-terminal`

4. **配置 Git 仓库**

   - **Repository URL**: 你的 Git 仓库地址
   - **Branch**: `main` 或你的主分支
   - **Build Path**: `/` (根目录)

5. **配置环境变量**

   ```bash
   PORT=7681
   TIMEZONE=Asia/Shanghai
   NODE_ENV=production
   WORKSPACE_PATH=/etc/dokploy/data/claude-terminal/workspace
   ```

6. **部署应用**
   - 点击 "Deploy" 按钮
   - 等待构建和部署完成

### 方法二：手动 Compose 配置

1. **创建 Compose 应用**

   - 选择 "Compose" 应用类型

2. **直接粘贴 Compose 配置**

   - 将 `docker-compose.yml` 内容粘贴到配置框
   - 设置环境变量

3. **部署应用**

## 数据存储位置

### Dokploy 数据目录结构

```bash
/etc/dokploy/
├── projects/
│   └── claude-terminal/
│       └── claude-terminal/
│           ├── source/                    # 源代码
│           ├── docker-compose.yml         # Compose 配置
│           └── .env                       # 环境变量
└── data/
    └── claude-terminal/
        └── workspace/                     # 持久化的工作空间
```

### 访问数据目录

```bash
# SSH 到 Dokploy 宿主机
ssh user@your-dokploy-server

# 查看项目目录
ls -la /etc/dokploy/projects/

# 查看持久化数据
ls -la /etc/dokploy/data/claude-terminal/workspace/
```

## 环境变量配置

| 变量名           | 默认值                                      | 说明             |
| ---------------- | ------------------------------------------- | ---------------- |
| `PORT`           | 7681                                        | Web 终端端口     |
| `TIMEZONE`       | Asia/Shanghai                               | 时区设置         |
| `NODE_ENV`       | production                                  | Node.js 环境     |
| `WORKSPACE_PATH` | /etc/dokploy/data/claude-terminal/workspace | 工作空间存储路径 |

## 网络配置

### 端口映射

- 默认端口：`7681`
- Dokploy 会自动处理反向代理和域名配置

### 自定义域名

1. 在 Dokploy 中配置域名
2. 确保 DNS 解析指向 Dokploy 服务器
3. Dokploy 会自动生成 SSL 证书

## 数据备份与恢复

### 备份数据

```bash
# 在 Dokploy 宿主机上执行
sudo tar -czf claude-terminal-backup-$(date +%Y%m%d).tar.gz \
  /etc/dokploy/data/claude-terminal/workspace/
```

### 恢复数据

```bash
# 停止应用
# 在 Dokploy 界面停止 claude-terminal 应用

# 恢复数据
sudo tar -xzf claude-terminal-backup-YYYYMMDD.tar.gz -C /

# 重启应用
# 在 Dokploy 界面重启应用
```

## 故障排除

### 常见问题

#### 1. 构建失败

- 检查 Dockerfile 语法
- 确认基础镜像可以正常拉取
- 查看构建日志

#### 2. 容器无法启动

- 检查端口冲突
- 确认环境变量配置正确
- 查看容器日志

#### 3. 数据无法持久化

- 确认 volume 挂载配置正确
- 检查目录权限
- 确认 Dokploy 数据目录存在

### 查看日志

```bash
# 在 Dokploy 界面查看应用日志
# 或在宿主机上执行
docker logs claude-terminal
```

### 健康检查

应用包含健康检查配置，会定期检查服务状态：

- **检查间隔**: 30 秒
- **超时时间**: 10 秒
- **重试次数**: 3 次
- **启动等待**: 60 秒

## 更新部署

### 自动更新（Git 仓库）

1. 推送代码到仓库
2. 在 Dokploy 中触发重新部署

### 手动更新

1. 修改 Compose 配置
2. 点击 "Redeploy" 按钮

## 监控和维护

### 资源监控

- 在 Dokploy 界面查看 CPU、内存使用情况
- 设置告警规则

### 定期维护

- 定期备份数据
- 监控磁盘空间
- 更新依赖和安全补丁

## 安全建议

1. **网络安全**

   - 使用 HTTPS 访问
   - 配置防火墙规则
   - 限制访问 IP

2. **数据安全**

   - 定期备份重要数据
   - 设置访问权限
   - 监控异常活动

3. **系统安全**
   - 保持系统更新
   - 使用强密码
   - 启用双因素认证

---

如果遇到问题，请参考 [Dokploy 官方文档](https://docs.dokploy.com/) 或联系技术支持。
