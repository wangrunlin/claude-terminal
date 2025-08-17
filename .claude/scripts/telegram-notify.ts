#!/usr/bin/env tsx

/**
 * Telegram 通知脚本
 * 用于 Claude Code Hooks 发送通知到 Telegram
 * 
 * 环境变量：
 * TELEGRAM_BOT_TOKEN - Telegram Bot Token
 * TELEGRAM_CHAT_ID - Telegram 聊天 ID
 * 
 * 使用方式：
 * echo '{"type": "notification", "message": "测试消息"}' | tsx telegram-notify.ts
 */

import { stdin, env, exit } from 'node:process';

interface HookData {
  type: string;
  message?: string;
  tool?: string;
  result?: any;
  error?: string;
  hookType?: string;
  toolName?: string;
  [key: string]: any;
}

async function sendTelegramNotification(data: HookData): Promise<void> {
  const botToken = env.TELEGRAM_BOT_TOKEN;
  const chatId = env.TELEGRAM_CHAT_ID;
  
  if (!botToken || !chatId) {
    console.log('⚠️  TELEGRAM_BOT_TOKEN 或 TELEGRAM_CHAT_ID 未配置，跳过 Telegram 通知');
    return;
  }

  // 构建消息内容
  let messageText = `🤖 *Claude Code 通知*\n\n`;
  
  // 根据类型设置不同的图标
  const hookType = data.hookType || data.type;
  const typeIcon = hookType === 'Notification' ? '🔔' : '⚡';
  messageText += `${typeIcon} *Hook类型:* ${hookType}\n`;

  if (data.toolName || data.tool) {
    messageText += `🔧 *工具:* \`${data.toolName || data.tool}\`\n`;
  }

  if (data.message) {
    messageText += `\n📝 *消息:*\n${data.message}\n`;
  }

  if (data.error) {
    messageText += `\n❌ *错误:*\n\`${data.error}\`\n`;
  }

  // 添加时间戳
  messageText += `\n🕐 *时间:* ${new Date().toLocaleString('zh-CN')}`;

  const telegramApiUrl = `https://api.telegram.org/bot${botToken}/sendMessage`;
  
  const payload = {
    chat_id: chatId,
    text: messageText,
    parse_mode: 'Markdown',
    disable_web_page_preview: true,
  };

  try {
    const response = await fetch(telegramApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const result = await response.json();
    if (!result.ok) {
      throw new Error(`Telegram API 错误: ${result.description}`);
    }

    console.log('✅ Telegram 通知发送成功');
  } catch (error) {
    console.error('❌ Telegram 通知发送失败:', error);
    
    // 如果 Markdown 解析失败，尝试发送纯文本
    if (error instanceof Error && error.message.includes('parse')) {
      try {
        const plainPayload = {
          chat_id: chatId,
          text: messageText.replace(/[*`_]/g, ''), // 移除 Markdown 格式
          disable_web_page_preview: true,
        };

        const retryResponse = await fetch(telegramApiUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(plainPayload),
        });

        if (retryResponse.ok) {
          console.log('✅ Telegram 通知发送成功（纯文本模式）');
        }
      } catch (retryError) {
        console.error('❌ Telegram 通知重试也失败:', retryError);
      }
    }
  }
}

async function main(): Promise<void> {
  try {
    // 从 stdin 读取数据
    let input = '';
    stdin.setEncoding('utf8');
    
    for await (const chunk of stdin) {
      input += chunk;
    }

    if (!input.trim()) {
      console.log('⚠️  没有输入数据，跳过通知');
      return;
    }

    console.log('🔍 Hook 输入数据:', input.trim());
    const data: HookData = JSON.parse(input.trim());
    await sendTelegramNotification(data);
  } catch (error) {
    console.error('❌ 处理输入数据失败:', error);
    exit(1);
  }
}

// 直接执行时运行
main().catch((error) => {
  console.error('❌ 脚本执行失败:', error);
  exit(1);
});