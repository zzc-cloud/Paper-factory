# MCP 工具参考

## 概述

Paper Factory 通过 MCP（Model Context Protocol）协议集成了外部工具服务器，扩展 Agent 的能力边界。本文档列出所有可用的 MCP 工具及其在论文生成流程中的应用场景。

## Chrome MCP Server

### 配置

配置文件位置：`.mcp.json`

```json
{
  "mcpServers": {
    "chrome": {
      "command": "node",
      "args": [
        "/opt/homebrew/lib/node_modules/mcp-chrome-bridge/dist/mcp/mcp-server-stdio.js"
      ]
    }
  }
}
```

### 可用工具分类

#### 页面导航与交互

| 工具 | 说明 |
|------|------|
| chrome_navigate | 导航到 URL、刷新页面、前进/后退 |
| chrome_read_page | 获取页面可访问性树（可见元素） |
| chrome_computer | 鼠标键盘交互、截图 |
| chrome_click_element | 点击页面元素（CSS/XPath/ref） |
| chrome_fill_or_select | 填写表单元素 |
| chrome_keyboard | 模拟键盘输入 |
| chrome_switch_tab | 切换浏览器标签页 |
| chrome_close_tabs | 关闭标签页 |

#### 内容获取

| 工具 | 说明 |
|------|------|
| chrome_get_web_content | 获取页面文本/HTML 内容 |
| chrome_screenshot | 页面截图（支持全页/元素/区域） |
| chrome_console | 捕获浏览器控制台输出 |
| chrome_javascript | 在页面中执行 JavaScript |
| get_windows_and_tabs | 获取所有浏览器窗口和标签页 |

#### 网络与下载

| 工具 | 说明 |
|------|------|
| chrome_network_request | 从浏览器发送网络请求（携带 Cookie） |
| chrome_network_capture | 捕获网络请求（启动/停止模式） |
| chrome_handle_download | 等待并获取下载文件信息 |
| chrome_upload_file | 上传文件到网页表单 |

#### 书签与历史

| 工具 | 说明 |
|------|------|
| chrome_history | 搜索浏览历史 |
| chrome_bookmark_search | 搜索书签 |
| chrome_bookmark_add | 添加书签 |
| chrome_bookmark_delete | 删除书签 |

#### 性能分析

| 工具 | 说明 |
|------|------|
| performance_start_trace | 启动性能追踪录制 |
| performance_stop_trace | 停止追踪并保存结果 |
| performance_analyze_insight | 分析追踪数据摘要 |

#### 录制与交互辅助

| 工具 | 说明 |
|------|------|
| chrome_gif_recorder | 录制浏览器操作为 GIF 动画 |
| chrome_handle_dialog | 处理 JavaScript 对话框（alert/confirm/prompt） |
| chrome_request_element_selection | 请求用户手动选择页面元素 |

## 在论文工厂中的应用场景

### Phase 1: Research（素材收集）

- **A1 (Literature Surveyor)**: 使用 `chrome_navigate` + `chrome_get_web_content` 访问学术数据库（Google Scholar、arXiv、DBLP），自动检索和下载论文元数据

### Phase 3: Writing（论文撰写）

- **C2 (Visualization Designer)**: 使用 `chrome_javascript` 在浏览器中渲染数据可视化图表（如 D3.js、ECharts），然后通过 `chrome_screenshot` 导出高质量图片

### 通用场景

- **文献下载**: 使用 `chrome_handle_download` 自动等待 PDF 文件下载完成
- **表单填写**: 使用 `chrome_fill_or_select` 自动填写学术数据库的高级搜索表单
- **网络调试**: 使用 `chrome_network_capture` 捕获 API 请求，分析数据源结构

## 前置条件

1. 安装 mcp-chrome-bridge：
   ```bash
   npm install -g mcp-chrome-bridge
   ```

2. 确保 Chrome 浏览器已安装并运行

3. 在 `.claude/settings.local.json` 中授权相关工具权限

## 注意事项

- Chrome MCP 工具需要浏览器处于运行状态
- 部分工具（如 `chrome_javascript`）可能受到页面 CSP（内容安全策略）限制
- 使用 `chrome_network_capture` 时，建议设置合理的 `inactivityTimeout` 避免长时间等待
- 截图工具默认保存到 `~/Downloads`，可通过参数自定义路径
