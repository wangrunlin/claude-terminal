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