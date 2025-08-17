# **终极指南：在 Dokploy 上部署你的私人 Web 终端 (ttyd + tmux)**

> 这篇教程将带你从零开始，在 Dokploy 上部署一个专属的、7x24 小时在线的、带密码保护的 Web 终端。它会直接进入一个名为 `claude_session` 的 `tmux` 会话，确保你的工作永不中断。

## **最终目标**

我们将创建一个安全、私密的网址（例如 `https://claude.yourdomain.com`）。打开它，输入密码后，你将立即进入一个位于云端的、持久化的 `tmux` 终端会话，随时随地可以开始你的工作。

## **准备工作 (Prerequisites)**

在开始之前，请确保你已经拥有：

1. **一个运行中的 Dokploy 实例**：并且已经完成了初始设置。
2. **一个域名**：准备一个子域名，并将其 DNS 的 A 记录指向你 Dokploy 服务器的 IP 地址。例如 `claude.yourdomain.com`。
3. **一个 GitHub 账户**：我们将使用 GitHub 仓库来存放我们的 `Dockerfile`，Dokploy 会从这里拉取代码进行构建。

---

## **Step 1: 创建你的项目代码仓库**

我们需要一个地方来存放我们应用的“蓝图”——也就是 `Dockerfile`。GitHub 是最方便的选择。

1. **在本地创建项目文件夹**：
   打开你的电脑终端，创建一个新文件夹。

   ```bash
   mkdir claude-terminal
   cd claude-terminal
   ```

2. **创建 Dockerfile**：
   在这个文件夹里，创建一个名为 `Dockerfile` 的文件（没有文件后缀），然后把下面的内容完整地复制进去：

   ```dockerfile
   # 使用一个轻量且稳定的 Debian Linux 作为基础
   FROM debian:bullseye-slim

   # 设置环境变量，避免安装过程中出现交互式弹窗
   ENV DEBIAN_FRONTEND=noninteractive

   # 更新软件包列表，并安装我们需要的核心工具
   # - ttyd: 我们的 Web 终端服务器
   # - tmux: 实现会话持久化的关键
   # - git, curl, wget, vim: 一些常用的基础工具，方便后续操作
   RUN apt-get update && apt-get install -y \
       ttyd \
       tmux \
       git \
       curl \
       wget \
       vim \
       && apt-get clean \
       && rm -rf /var/lib/apt/lists/*

   # 设置工作目录
   WORKDIR /root

   # 容器启动时要执行的命令
   # 启动 ttyd，并让它自动创建或附加到一个名为 "claude_session" 的 tmux 会话
   # -A: 如果会话存在，则附加；如果不存在，则创建
   # -s: 指定会话的名称
   CMD ["ttyd", "tmux", "new", "-A", "-s", "claude_session"]
   ```

3. **推送到 GitHub**：
   a. 在 GitHub 网站上创建一个新的**私有**（Private）仓库，例如 `claude-terminal`。
   b. 回到你的本地终端，将 `Dockerfile` 推送到这个新的 GitHub 仓库：

   ```bash
   git init
   git add Dockerfile
   git commit -m "Initial commit with Dockerfile"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/claude-terminal.git
   git push -u origin main
   ```

   _(请将 `https://github.com/YOUR_USERNAME/claude-terminal.git` 替换成你自己的仓库地址)_

**至此，我们的“建筑蓝图”已经准备好了！**

---

## **Step 2: 在 Dokploy 中创建和配置应用**

现在，我们去 Dokploy 把这个项目“盖起来”。

1. **登录 Dokploy**，进入你的项目，点击 **"Create a new Application"**。

2. **选择代码源 (Source)**：

   - 选择 **"Git Repository"**。
   - 如果这是你第一次使用，你需要授权 Dokploy 访问你的 GitHub 账户。
   - 选择你刚刚创建的 `claude-terminal` 仓库，分支选择 `main`。

3. **配置构建方式 (Build Options)**：

   - Dokploy 非常智能，它会自动检测到仓库里的 `Dockerfile`。所以 **"Build Pack"** 应该会自动选择 **"Dockerfile"**。
   - 保持默认设置即可。

4. **常规设置 (General)**：

   - 给你的应用起个名字，比如 `claude-terminal`。

5. **配置网络 (Network)**：

   - **Port**：这是最关键的一步！`ttyd` 默认在 `7681` 端口上运行。所以，请在这里填入 `7681`。
   - **Domains**：点击 **"Add Domain"**，然后输入你准备好的子域名，例如 `claude.yourdomain.com`。

6. **暂时不要部署**，我们先配置最重要的安全部分。

---

## **Step 3: 添加身份验证，保护你的终端**

我们将使用 Traefik 的 Basic Auth 中间件来添加密码保护。

1. **生成加密密码**：
   我们需要一个 `htpasswd` 格式的密码串。最快的方式是使用 Docker：

   ```bash
   docker run --rm httpd:2.4 htpasswd -nb 你的用户名 你的密码
   ```

   - 例如：`docker run --rm httpd:2.4 htpasswd -nb admin mySuperSecretPassword`
   - 你会得到一串类似 `admin:$apr1$j5d1...$8v2sD/f3hA.Pj2a.I/eN60` 的输出。**完整地复制它**。

2. **在 Dokploy 中添加标签 (Labels)**：

   - 在 `claude-terminal` 应用的设置页面，找到 **"Advanced"** 或 **"Labels"** 区域。

   - 点击 **"Add Label"**，添加以下**两个**标签：

   - **标签 1**

     - **Key**: `traefik.http.routers.app.middlewares`
     - **Value**: `claude-auth@docker`
       _(这里的 `app` 是 Dokploy 的默认路由名，通常不用改。`claude-auth` 是我们给这个认证起的自定义名字)_

   - **标签 2**

     - **Key**: `traefik.http.middlewares.claude-auth.basicauth.users`
     - **Value**: (粘贴你刚刚生成的**完整密码串**)
       _(例如: `admin:$apr1$j5d1...$8v2sD/f3hA.Pj2a.I/eN60`)_

---

## **Step 4: 部署和验证！**

所有配置都已完成，让我们启动它！

1. **点击 "Deploy"**：回到应用的主设置页面，点击部署按钮。

2. **查看日志**：你可以点开 **"Logs"** 实时查看 Dokploy 的构建和部署过程。它会拉取你的 GitHub 代码，基于 `Dockerfile` 构建镜像，然后启动容器。

3. **访问你的终端**：当日志显示应用成功启动后，在浏览器中打开你的域名 `https://claude.yourdomain.com`。

   - **第一关**：浏览器会弹出一个登录框。输入你设定的用户名和密码。
   - **成功**：验证通过后，你将看到一个全屏的、黑色的、蓄势待发的终端界面！

4. **验证持久化**：

   - 在终端里随便输入点什么，比如 `echo "Hello from my cloud terminal!"`。
   - 按下快捷键 `Ctrl + b` 然后再按 `d`，这是 `tmux` 的分离 (detach) 命令。你会看到 `[detached (from session claude_session)]` 的提示。
   - 现在，关闭浏览器标签页，甚至重启你的手机/电脑。
   - 重新打开 `https://claude.yourdomain.com`，再次登录。你会发现，你回到了刚刚的那个会话，之前输入的命令历史都还在！

**恭喜你！你已经成功为自己打造了一个全天候在线、安全可靠、且永不掉线的云端司令部！** 现在，你可以随时随地开始指挥你的 "Claude Code" 了。
