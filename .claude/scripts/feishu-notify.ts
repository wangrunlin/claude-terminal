#!/usr/bin/env tsx

/**
 * 飞书通知脚本
 * 用于 Claude Code Hooks 发送通知到飞书群聊
 * 
 * 环境变量：
 * FEISHU_WEBHOOK_URL - 飞书机器人 Webhook URL
 * 
 * 使用方式：
 * echo '{"type": "notification", "message": "测试消息"}' | tsx feishu-notify.ts
 */

interface HookData {
  type: string;
  message?: string;
  tool?: string;
  result?: any;
  error?: string;
  [key: string]: any;
}

interface FeishuMessage {
  msg_type: 'interactive';
  card: {
    elements: Array<{
      tag: string;
      text?: {
        content: string;
        tag: string;
      };
      fields?: Array<{
        is_short: boolean;
        text: {
          content: string;
          tag: string;
        };
      }>;
    }>;
    header: {
      title: {
        content: string;
        tag: string;
      };
      template: string;
    };
  };
}

async function sendFeishuNotification(data: HookData): Promise<void> {
  const webhookUrl = process.env.FEISHU_WEBHOOK_URL;
  
  if (!webhookUrl) {
    console.log('⚠️  FEISHU_WEBHOOK_URL 未配置，跳过飞书通知');
    return;
  }

  // 构建飞书卡片消息
  const message: FeishuMessage = {
    msg_type: 'interactive',
    card: {
      header: {
        title: {
          content: `🤖 Claude Code 通知`,
          tag: 'plain_text'
        },
        template: data.type === 'notification' ? 'orange' : 'blue'
      },
      elements: []
    }
  };

  // 添加主要消息内容
  if (data.message) {
    message.card.elements.push({
      tag: 'div',
      text: {
        content: data.message,
        tag: 'lark_md'
      }
    });
  }

  // 添加详细信息
  const fields: Array<{is_short: boolean; text: {content: string; tag: string}}> = [];
  
  if (data.type) {
    fields.push({
      is_short: true,
      text: {
        content: `**类型：**${data.type}`,
        tag: 'lark_md'
      }
    });
  }

  if (data.tool) {
    fields.push({
      is_short: true,
      text: {
        content: `**工具：**${data.tool}`,
        tag: 'lark_md'
      }
    });
  }

  if (data.error) {
    fields.push({
      is_short: false,
      text: {
        content: `**错误：**\`${data.error}\``,
        tag: 'lark_md'
      }
    });
  }

  // 添加时间戳
  fields.push({
    is_short: true,
    text: {
      content: `**时间：**${new Date().toLocaleString('zh-CN')}`,
      tag: 'lark_md'
    }
  });

  if (fields.length > 0) {
    message.card.elements.push({
      tag: 'div',
      fields: fields
    });
  }

  try {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const result = await response.json();
    if (result.code !== 0) {
      throw new Error(`飞书 API 错误: ${result.msg}`);
    }

    console.log('✅ 飞书通知发送成功');
  } catch (error) {
    console.error('❌ 飞书通知发送失败:', error);
  }
}

async function main(): Promise<void> {
  try {
    // 从 stdin 读取数据
    let input = '';
    process.stdin.setEncoding('utf8');
    
    for await (const chunk of process.stdin) {
      input += chunk;
    }

    if (!input.trim()) {
      console.log('⚠️  没有输入数据，跳过通知');
      return;
    }

    const data: HookData = JSON.parse(input.trim());
    await sendFeishuNotification(data);
  } catch (error) {
    console.error('❌ 处理输入数据失败:', error);
    process.exit(1);
  }
}

// 直接执行时运行
if (require.main === module) {
  main().catch((error) => {
    console.error('❌ 脚本执行失败:', error);
    process.exit(1);
  });
}