# 使用 Ubuntu 22.04，它的软件包更新，包含 ttyd
FROM ubuntu:22.04

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
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /root

# 暴露端口（ttyd 默认使用 7681 端口）
EXPOSE 7681

# 容器启动时要执行的命令
# 启动 ttyd，绑定到所有接口，并让它自动创建或附加到一个名为 "claude_session"的 tmux 会话
CMD ["ttyd", "-i", "0.0.0.0", "-p", "7681", "tmux", "new", "-A", "-s", "claude_session"]