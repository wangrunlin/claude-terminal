#!/bin/bash

# Claude Terminal 启动脚本
# 提供简单的方式来运行 Claude Terminal 容器，并自动处理数据卷挂载

# 设置默认配置
CONTAINER_NAME="claude-terminal"
IMAGE_NAME="claude-terminal"
PORT="7681"
WORKSPACE_DIR="./workspace"

# 显示使用说明
show_usage() {
    echo "Claude Terminal 启动脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port PORT        设置端口 (默认: 7681)"
    echo "  -w, --workspace DIR    设置工作空间目录 (默认: ./workspace)"
    echo "  -n, --name NAME        设置容器名称 (默认: claude-terminal)"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                     # 使用默认配置启动"
    echo "  $0 -p 8080             # 在端口 8080 启动"
    echo "  $0 -w /path/to/workspace  # 使用指定的工作空间目录"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -w|--workspace)
            WORKSPACE_DIR="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            show_usage
            exit 1
            ;;
    esac
done

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到 Docker。请先安装 Docker。"
    exit 1
fi

# 创建工作空间目录（如果不存在）
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "创建工作空间目录: $WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR"
fi

# 停止并删除现有容器（如果存在）
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "停止并删除现有容器: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1
fi

# 构建镜像（如果不存在）
if ! docker images --format 'table {{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
    echo "构建 Docker 镜像..."
    docker build -t "$IMAGE_NAME" .
    if [ $? -ne 0 ]; then
        echo "错误: 镜像构建失败"
        exit 1
    fi
fi

# 运行容器
echo "启动 Claude Terminal..."
echo "端口: $PORT"
echo "工作空间: $WORKSPACE_DIR"
echo "容器名称: $CONTAINER_NAME"
echo ""

docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT:7681" \
    -v "$(realpath "$WORKSPACE_DIR"):/workspace" \
    -e TZ=Asia/Shanghai \
    --restart unless-stopped \
    "$IMAGE_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Claude Terminal 启动成功！"
    echo "🌐 访问地址: http://localhost:$PORT"
    echo "📁 工作空间: $WORKSPACE_DIR"
    echo ""
    echo "使用以下命令查看容器状态:"
    echo "  docker logs $CONTAINER_NAME"
    echo ""
    echo "使用以下命令停止容器:"
    echo "  docker stop $CONTAINER_NAME"
else
    echo "❌ 容器启动失败"
    exit 1
fi