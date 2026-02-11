#!/usr/bin/env python3
"""
测试智能问数 Demo 页面
1. 测试能否连接
2. 测试能否输入问题
3. 测试能否看到输出
"""
import time
from playwright.sync_api import sync_playwright

def test_smart_query_demo():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # 显示浏览器以便观察
        context = browser.new_context(
            viewport={'width': 1280, 'height': 800}
        )
        page = context.new_page()

        # 捕获控制台日志
        console_messages = []
        def on_console(msg):
            console_messages.append(f"[{msg.type}] {msg.text}")
        page.on("console", on_console)

        print("🌐 正在导航到 Demo 页面...")
        page.goto('http://127.0.0.1:8765')

        # 等待页面加载完成
        try:
            page.wait_for_load_state('networkidle', timeout=10000)
            print("✅ 页面加载成功")
        except:
            print("⚠️ 页面加载超时，继续...")

        # 截图初始状态
        screenshot_path = '/tmp/demo_initial.png'
        page.screenshot(path=screenshot_path, full_page=True)
        print(f"📸 初始状态截图: {screenshot_path}")

        # 检查关键元素
        print("\n🔍 检查页面元素...")

        # 检查标题
        title = page.title()
        print(f"  页面标题: {title}")

        # 检查连接状态
        status_el = page.locator('#status')
        status_text = status_el.inner_text() if status_el.count() > 0 else "未找到"
        print(f"  连接状态: {status_text}")

        # 检查输入框
        input_el = page.locator('#userInput')
        if input_el.count() > 0:
            print(f"  输入框: 存在, disabled={input_el.is_disabled()}")
        else:
            print("  输入框: 未找到!")

        # 检查发送按钮
        send_btn = page.locator('#sendBtn')
        if send_btn.count() > 0:
            print(f"  发送按钮: 存在, disabled={send_btn.is_disabled()}")
        else:
            print("  发送按钮: 未找到!")

        # 等待 WebSocket 连接建立
        print("\n⏳ 等待 WebSocket 连接...")
        time.sleep(5)  # 给 WebSocket 一些时间连接

        # 再次检查状态
        status_el = page.locator('#status')
        status_text = status_el.inner_text()
        print(f"  当前连接状态: {status_text}")

        # 再次截图
        screenshot_path2 = '/tmp/demo_after_connect.png'
        page.screenshot(path=screenshot_path2, full_page=True)
        print(f"📸 连接后截图: {screenshot_path2}")

        # 尝试输入问题
        if input_el.count() > 0 and not input_el.is_disabled():
            print("\n✏️  尝试输入测试问题...")
            test_question = "查询小微企业贷款余额"

            # 尝试点击示例问题芯片
            example_chip = page.locator('text=查询小微企业贷款余额')
            if example_chip.count() > 0:
                print("  点击示例问题芯片...")
                example_chip.first.click()
            else:
                print("  示例芯片未找到，直接在输入框输入...")
                input_el.fill(test_question)

            # 截图输入后状态
            screenshot_path3 = '/tmp/demo_after_input.png'
            page.screenshot(path=screenshot_path3)
            print(f"📸 输入后截图: {screenshot_path3}")

            # 按回车或点击发送按钮
            print("  发送问题...")
            input_el.press('Enter')

            # 等待响应
            print("\n⏳ 等待响应 (最多 30 秒)...")
            time.sleep(30)

            # 最终截图
            screenshot_path4 = '/tmp/demo_final.png'
            page.screenshot(path=screenshot_path4, full_page=True)
            print(f"📸 最终截图: {screenshot_path4}")

            # 检查终端输出区域
            terminal_output = page.locator('#terminalOutput')
            if terminal_output.count() > 0:
                output_text = terminal_output.inner_text()
                print(f"\n📝 终端输出内容 ({len(output_text)} 字符):")
                print("=" * 60)
                # 只打印前 1000 个字符
                print(output_text[:1000])
                if len(output_text) > 1000:
                    print(f"\n... (还有 {len(output_text) - 1000} 个字符)")
                print("=" * 60)

                # 检查是否有错误
                if "错误" in output_text or "error" in output_text.lower():
                    print("\n⚠️  输出中包含错误信息")
                elif "贷款" in output_text or "余额" in output_text:
                    print("\n✅ 输出包含预期内容!")
                else:
                    print("\n❓ 输出内容不确定")
            else:
                print("\n⚠️  未找到终端输出区域")

        else:
            print("\n❌ 输入框不可用，无法测试")

        # 打印控制台日志
        if console_messages:
            print("\n📋 浏览器控制台日志:")
            for msg in console_messages[:20]:  # 只显示前 20 条
                print(f"  {msg}")

        print("\n等待 5 秒后关闭浏览器...")
        time.sleep(5)

        browser.close()

if __name__ == '__main__':
    test_smart_query_demo()
