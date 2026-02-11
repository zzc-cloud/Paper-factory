#!/usr/bin/env python3
"""
调试 Demo 的 WebSocket 连接
带更详细的日志
"""
import asyncio
import websockets
import json

async def test_websocket():
    uri = "ws://127.0.0.1:8765/ws/cli"

    print(f"🔌 连接到 {uri}...")

    try:
        async with websockets.connect(uri) as websocket:
            print("✅ WebSocket 连接成功!")

            # 首先读取初始化消息
            print("\n📨 阶段1: 初始化...")

            init_done = False
            all_init_messages = []

            for i in range(50):  # 最多50条消息
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=5)
                    data = json.loads(message)
                    all_init_messages.append(data)

                    msg_type = data.get('type', 'unknown')
                    print(f"  [{i+1}] {msg_type}: ", end='')
                    if msg_type == 'output':
                        print(f"{len(data.get('data', ''))} 字节")
                    elif msg_type == 'system':
                        msg = data.get('message', '')
                        print(f"{msg}")
                        if '初始化完成' in msg:
                            init_done = True
                    else:
                        print(f"{data}")

                    if init_done:
                        break

                except asyncio.TimeoutError:
                    print(f"\n  ⏱️  超时，已接收 {len(all_init_messages)} 条消息")
                    break

            if not init_done:
                print("\n⚠️  初始化未完成，但继续测试...")

            # 发送测试问题
            print("\n✏️  阶段2: 发送测试问题...")
            test_question = "查询小微企业贷款余额"
            await websocket.send(json.dumps({
                "type": "input",
                "data": test_question
            }))
            print(f"  已发送: {test_question}")

            # 读取响应 - 首先读取"已发送"确认
            print("\n📨 阶段3: 等待确认...")
            try:
                ack_msg = await asyncio.wait_for(websocket.recv(), timeout=5)
                ack_data = json.loads(ack_msg)
                print(f"  收到: {ack_data}")
            except asyncio.TimeoutError:
                print("  ⏱️  没有收到确认消息")

            # 读取实际响应
            print("\n📨 阶段4: 等待响应 (最多90秒)...")
            responses = []
            all_messages = []
            start_time = asyncio.get_event_loop().time()
            timeout = 90

            while asyncio.get_event_loop().time() - start_time < timeout:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=2)
                    data = json.loads(message)
                    all_messages.append(data)

                    msg_type = data.get('type')
                    if msg_type == 'output':
                        content = data.get('data', '')
                        if content.strip():  # 只记录非空内容
                            responses.append(content)
                            print(f"  📝 [{len(responses)}] {len(content)} 字节: {content[:80]}...")
                    elif msg_type == 'system':
                        print(f"  [系统] {data.get('message', '')}")
                    else:
                        print(f"  [{msg_type}] {data}")

                except asyncio.TimeoutError:
                    # 每次超时打印一个点表示还在等待
                    print(".", end="", flush=True)
                    continue

            print(f"\n\n{'='*60}")
            print(f"测试完成!")
            print(f"  初始化消息: {len(all_init_messages)} 条")
            print(f"  响应消息: {len(responses)} 条")
            print(f"  总消息数: {len(all_messages)} 条")
            print(f"  用时: {asyncio.get_event_loop().time() - start_time:.1f}秒")

            if responses:
                print(f"\n📄 响应内容预览:")
                full_response = ''.join(responses)
                print(full_response[:1000])
                if len(full_response) > 1000:
                    print(f"\n... (还有 {len(full_response) - 1000} 字符)")
            else:
                print("\n⚠️  没有收到任何响应内容")

            print(f"{'='*60}")

    except Exception as e:
        print(f"❌ 错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    asyncio.run(test_websocket())
