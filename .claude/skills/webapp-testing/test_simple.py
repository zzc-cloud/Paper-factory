#!/usr/bin/env python3
"""
简单测试 Demo 页面
检查 WebSocket 连接和基本功能
"""
import time
from playwright.sync_api import sync_playwright

def test_demo():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        print("🌐 导航到 Demo 页面...")
        page.goto('http://127.0.0.1:8765', wait_until='domcontentloaded')

        # 检查标题
        print(f"📄 页面标题: {page.title()}")

        # 等待更长时间让 WebSocket 连接
        print("⏳ 等待 WebSocket 连接 (10秒)...")
        time.sleep(10)

        # 检查状态
        status = page.locator('#status').inner_text()
        print(f"🔌 连接状态: {status}")

        # 获取终端输出
        terminal = page.locator('#terminalOutput')
        output = terminal.inner_text()
        print(f"\n📝 终端输出:\n{'='*50}\n{output}\n{'='*50}")

        # 检查输入框是否可用
        input_box = page.locator('#userInput')
        is_disabled = input_box.is_disabled()
        print(f"\n⌨️  输入框状态: {'可用' if not is_disabled else '禁用'}")

        # 截图
        page.screenshot(path='/tmp/demo_test_final.png', full_page=True)
        print(f"📸 截图已保存: /tmp/demo_test_final.png")

        browser.close()

if __name__ == '__main__':
    test_demo()
