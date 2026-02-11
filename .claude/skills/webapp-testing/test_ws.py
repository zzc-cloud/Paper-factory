#!/usr/bin/env python3
"""
直接测试 Demo 的 WebSocket 连接
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

            # 接收消息
            print("\n📨 接收消息中...")

            # 等待初始化完成的消息
            init_done = False
            message_count = 0
            max_messages = 20
            all_output = []

            while message_count < max_messages:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=15)
                    data = json.loads(message)
                    message_count += 1

                    msg_type = data.get('type', 'unknown')
                    print(f"\n[{message_count}] 类型: {msg_type}")

                    if msg_type == 'output':
                        content = data.get('data', '')
                        all_output.append(content)
                        # 只打印前 200 字符
                        print(f"内容: {content[:200]}...")
                    elif msg_type == 'system':
                        print(f"系统消息: {data.get('message', '')}")
                        if '初始化完成' in data.get('message', ''):
                            init_done = True
                            break
                    elif msg_type == 'error':
                        print(f"错误: {data.get('message', '')}")

                except asyncio.TimeoutError:
                    print("\n⏱️  15秒内没有新消息")
                    break

            print(f"\n\n{'='*60}")
            print(f"总共接收 {message_count} 条消息")
            print(f"初始化完成: {init_done}")
            print(f"{'='*60}\n")

            # 如果初始化完成，发送测试问题
            if init_done:
                print("✏️  发送测试问题: '查询小微企业贷款余额'")
                await websocket.send(json.dumps({
                    "type": "input",
                    "data": "查询小微企业贷款余额"
                }))

                # 接收响应
                print("\n📨 等待响应 (最多60秒)...")
                responses = []
                start_time = asyncio.get_event_loop().time()
                timeout = 60

                while asyncio.get_event_loop().time() - start_time < timeout:
                    try:
                        message = await asyncio.wait_for(websocket.recv(), timeout=2)
                        data = json.loads(message)

                        msg_type = data.get('type')
                        if msg_type == 'output':
                            content = data.get('data', '')
                            responses.append(content)
                            print(f"收到输出: {content[:100]}...")
                        elif msg_type == 'system':
                            sys_msg = data.get('message', '')
                            print(f"[系统] {sys_msg}")
                        else:
                            print(f"[{msg_type}] {data}")

                    except asyncio.TimeoutError:
                        # 继续等待，直到达到总超时时间
                        continue

                print(f"\n\n{'='*60}")
                print(f"响应摘要 (共 {len(responses)} 条输出，{asyncio.get_event_loop().time() - start_time:.1f}秒):")
                full_response = ''.join(responses)
                print(full_response[:500])
                if len(full_response) > 500:
                    print(f"\n... (还有 {len(full_response) - 500} 字符)")
                print(f"{'='*60}")

    except websockets.exceptions.WebSocketException as e:
        print(f"❌ WebSocket 错误: {e}")
    except Exception as e:
        print(f"❌ 错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    asyncio.run(test_websocket())
