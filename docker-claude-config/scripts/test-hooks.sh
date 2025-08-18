#!/bin/bash

# =============================================
# Claude Code Hooks 测试脚本
# =============================================
# 
# 用于测试飞书和 Telegram 通知脚本的功能
# 
# 使用方法：
# chmod +x test-hooks.sh
# ./test-hooks.sh
# =============================================

echo "🧪 开始测试 Claude Code Hooks 通知功能"
echo "======================================="

# 检查环境变量
echo "📋 检查环境变量配置..."

if [ -z "$FEISHU_WEBHOOK_URL" ]; then
    echo "⚠️  FEISHU_WEBHOOK_URL 未配置"
else
    echo "✅ FEISHU_WEBHOOK_URL 已配置"
fi

if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "⚠️  TELEGRAM_BOT_TOKEN 或 TELEGRAM_CHAT_ID 未配置"
else
    echo "✅ TELEGRAM_BOT_TOKEN 和 TELEGRAM_CHAT_ID 已配置"
fi

echo ""

# 检查脚本文件
echo "📁 检查脚本文件..."

FEISHU_SCRIPT="$HOME/.claude/scripts/feishu-notify.ts"
TELEGRAM_SCRIPT="$HOME/.claude/scripts/telegram-notify.ts"

if [ -f "$FEISHU_SCRIPT" ]; then
    echo "✅ 飞书通知脚本存在: $FEISHU_SCRIPT"
else
    echo "❌ 飞书通知脚本不存在: $FEISHU_SCRIPT"
fi

if [ -f "$TELEGRAM_SCRIPT" ]; then
    echo "✅ Telegram 通知脚本存在: $TELEGRAM_SCRIPT"
else
    echo "❌ Telegram 通知脚本不存在: $TELEGRAM_SCRIPT"
fi

echo ""

# 检查 tsx 命令
echo "🔧 检查运行时环境..."

if command -v tsx >/dev/null 2>&1; then
    echo "✅ tsx 命令可用"
    echo "   版本: $(tsx --version 2>/dev/null || echo '未知')"
else
    echo "❌ tsx 命令不可用，请确保 Node.js 和 tsx 已安装"
    echo "   安装命令: npm install -g tsx"
fi

if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js 可用"
    echo "   版本: $(node --version)"
else
    echo "❌ Node.js 不可用"
fi

echo ""

# 测试数据
echo "🧪 开始测试通知脚本..."

# Notification Hook 测试数据
NOTIFICATION_TEST_DATA='{
  "hookType": "Notification",
  "type": "notification",
  "message": "这是一个测试通知消息，Claude 需要用户进行下一步操作",
  "toolName": "TestTool"
}'

# PostToolUse Hook 测试数据
POSTTOOLUSE_TEST_DATA='{
  "hookType": "PostToolUse", 
  "type": "tool_completion",
  "toolName": "Bash",
  "message": "命令执行完成",
  "result": {
    "status": "success",
    "output": "操作成功完成"
  }
}'

echo ""
echo "🔔 测试 Notification Hook..."
echo "测试数据: $NOTIFICATION_TEST_DATA"
echo ""

# 测试飞书通知
if [ -f "$FEISHU_SCRIPT" ] && command -v tsx >/dev/null 2>&1; then
    echo "📧 测试飞书通知..."
    echo "$NOTIFICATION_TEST_DATA" | tsx "$FEISHU_SCRIPT"
    echo ""
fi

# 测试 Telegram 通知
if [ -f "$TELEGRAM_SCRIPT" ] && command -v tsx >/dev/null 2>&1; then
    echo "📱 测试 Telegram 通知..."
    echo "$NOTIFICATION_TEST_DATA" | tsx "$TELEGRAM_SCRIPT"
    echo ""
fi

echo "⚡ 测试 PostToolUse Hook..."
echo "测试数据: $POSTTOOLUSE_TEST_DATA"
echo ""

# 测试飞书通知
if [ -f "$FEISHU_SCRIPT" ] && command -v tsx >/dev/null 2>&1; then
    echo "📧 测试飞书通知..."
    echo "$POSTTOOLUSE_TEST_DATA" | tsx "$FEISHU_SCRIPT"
    echo ""
fi

# 测试 Telegram 通知
if [ -f "$TELEGRAM_SCRIPT" ] && command -v tsx >/dev/null 2>&1; then
    echo "📱 测试 Telegram 通知..."
    echo "$POSTTOOLUSE_TEST_DATA" | tsx "$TELEGRAM_SCRIPT"
    echo ""
fi

echo "======================================="
echo "🎉 测试完成！"
echo ""
echo "💡 如果看到 ✅ 发送成功的消息，说明通知功能正常"
echo "💡 如果看到 ⚠️ 未配置的消息，请检查环境变量设置"
echo "💡 如果看到 ❌ 发送失败的消息，请检查网络和配置"
echo ""
echo "🔍 调试信息："
echo "- 检查 ~/.env 文件是否正确配置"
echo "- 确保环境变量已加载: source ~/.bashrc"
echo "- 检查网络连接是否正常"