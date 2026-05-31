#!/usr/bin/env node
/**
 * setup-claude-statusline — 一键配置 Claude Code 状态栏
 * 用法: npx setup-claude-statusline
 *      npx github:liupengbo/setup-statusline
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const HOME = os.homedir();
const CLAUDE_DIR = path.join(HOME, '.claude');
const SETTINGS_PATH = path.join(CLAUDE_DIR, 'settings.json');

const isWindows = process.platform === 'win32';

// Color output helpers
const c = { r: '\x1b[0m', b: '\x1b[1m', g: '\x1b[32m', y: '\x1b[33m', c: '\x1b[36m' };
const ok = (t) => console.log(`${c.g}✔${c.r} ${t}`);
const info = (t) => console.log(`${c.c}ℹ${c.r} ${t}`);
const warn = (t) => console.log(`${c.y}⚠${c.r} ${t}`);

function main() {
  console.log(`\n${c.b}${c.c}setup-claude-statusline${c.r} — Claude Code 状态栏配置工具\n`);

  // 1. Ensure ~/.claude/ exists
  if (!fs.existsSync(CLAUDE_DIR)) {
    fs.mkdirSync(CLAUDE_DIR, { recursive: true });
    ok(`创建目录 ${CLAUDE_DIR}`);
  }

  // 2. Copy the appropriate statusline script
  const scriptDir = path.join(__dirname, '..', 'scripts');
  const scriptName = isWindows ? 'statusline.ps1' : 'statusline.sh';
  const scriptSrc = path.join(scriptDir, scriptName);
  const scriptDst = path.join(CLAUDE_DIR, scriptName);

  if (!fs.existsSync(scriptSrc)) {
    console.error(`错误: 找不到脚本文件 ${scriptSrc}`);
    process.exit(1);
  }

  const content = fs.readFileSync(scriptSrc, 'utf8');
  fs.writeFileSync(scriptDst, content);
  ok(`写入 ${scriptDst}`);

  // Make executable on Unix
  if (!isWindows) {
    fs.chmodSync(scriptDst, 0o755);
  }

  // 3. Build the statusLine command
  let command;
  if (isWindows) {
    const ps1Path = path.join(CLAUDE_DIR, 'statusline.ps1');
    command = `powershell -NoProfile -ExecutionPolicy Bypass -File "${ps1Path}"`;
  } else {
    const shPath = path.join(CLAUDE_DIR, 'statusline.sh');
    command = `bash ${shPath}`;
  }

  // 4. Read or create settings.json
  let settings = {};
  if (fs.existsSync(SETTINGS_PATH)) {
    try {
      settings = JSON.parse(fs.readFileSync(SETTINGS_PATH, 'utf8'));
      ok('读取已有 settings.json');
    } catch (e) {
      warn('settings.json 格式有问题，将覆盖');
    }
  } else {
    info('未找到 settings.json，将新建');
  }

  // 5. Add/update statusLine config
  const hadStatusLine = !!settings.statusLine;
  settings.statusLine = {
    type: 'command',
    command: command,
  };

  fs.writeFileSync(SETTINGS_PATH, JSON.stringify(settings, null, 2) + '\n');
  ok(`${hadStatusLine ? '更新' : '新增'} statusLine 配置到 settings.json`);

  // 6. Done
  console.log('');
  console.log(`${c.b}${c.g}配置完成!${c.r}`);
  console.log('');
  console.log('状态栏将显示:');
  console.log(`  ${c.c}模型${c.r} | 上下文% | Git分支 | 工作目录 | 输出样式`);
  console.log('');
  console.log(`${c.y}请重启 Claude Code 以生效${c.r}`);
  console.log('');
}

main();
