FROM ubuntu:22.04

# 设置环境变量，避免安装过程中出现交互式弹窗
ENV DEBIAN_FRONTEND=noninteractive

# 设置语言环境支持中文
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 更新软件包列表，并安装我们需要的核心工具
# - ttyd: 我们的 Web 终端服务器
# - tmux: 实现会话持久化的关键
# - git, curl, wget, vim: 一些常用的基础工具，方便后续操作
# - fonts-noto-cjk: 中文字体支持
# - locales: 语言环境支持
RUN apt-get update && apt-get install -y \
  ttyd \
  tmux \
  git \
  curl \
  wget \
  vim \
  ca-certificates \
  fonts-noto-cjk \
  locales \
  build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 生成 UTF-8 语言环境
RUN locale-gen en_US.UTF-8

# 安装 nvm 和 Node.js
ENV NVM_DIR=/root/.nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install 22 \
  && nvm use 22 \
  && nvm alias default 22

# 安装 Claude Code
RUN . $NVM_DIR/nvm.sh && npm install -g @anthropic-ai/claude-code

# 复制配置文件
COPY .tmux.conf /root/.tmux.conf
COPY .bashrc /root/.bashrc

# 设置工作目录
WORKDIR /root

# 暴露端口（ttyd 默认使用 7681 端口）
EXPOSE 7681

# 容器启动时要执行的命令
# 启动 ttyd，绑定到所有接口，并让它自动创建或附加到一个名为 "claude_session"的 tmux 会话
# 添加 UTF-8 支持和更好的终端设置
CMD ["ttyd", "-i", "0.0.0.0", "-p", "7681", "-t", "titleFixed=Claude Terminal", "-t", "fontSize=14", "tmux", "new", "-A", "-s", "claude_session"]
