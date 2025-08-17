# =============================================
# Claude Terminal - Bash 配置文件  
# =============================================

# 如果不是交互式shell，直接返回
[[ $- != *i* ]] && return

# 基本设置
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# 设置命令行编辑模式为vi（可选）
# set -o vi

# 启用颜色支持
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# 常用别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# Git 别名
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# nvm 环境配置
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # 加载 nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # 加载 nvm bash 补全

# 确保使用默认 Node.js 版本 (让 nvm 自动管理路径)
[ -s "$NVM_DIR/nvm.sh" ] && nvm use default > /dev/null 2>&1

# 加载环境变量配置文件
if [ -f ~/.env ]; then
    # 加载用户自定义环境变量
    set -a  # 自动导出所有变量
    source ~/.env
    set +a  # 关闭自动导出
    echo "✅ 已加载环境变量配置文件"
else
    echo "💡 提示：复制 .env.example 为 .env 来配置通知功能"
    echo "   命令：cp .env.example .env && nano .env"
fi

# 自定义提示符（可选）
# export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# 欢迎信息
echo "🚀 欢迎使用 Claude Terminal!"
echo "📍 Node.js: $(node --version 2>/dev/null || echo '正在初始化...')"
echo "📍 npm: $(npm --version 2>/dev/null || echo '正在初始化...')"
echo "📍 Claude Code: $(claude --version 2>/dev/null || echo '已安装')"
echo "💡 输入 'claude' 开始使用 Claude Code"
echo "💡 tmux 快捷键: Ctrl+b 然后按 ? 查看帮助"
echo "───────────────────────────────────────"