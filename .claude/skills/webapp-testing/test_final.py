#!/usr/bin/env python3
"""
最终测试 - 等待所有消息
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

            # 接收所有初始化消息
            print("\n📨 阶段1: 初始化...")
            init_done = False

            while not init_done:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=10)
                    data = json.loads(message)
                    msg_type = data.get('type', 'unknown')

                    if msg_type == 'system':
                        msg = data.get('message', '')
                        print(f"  [系统] {msg}")
                        if '初始化完成' in msg:
                            init_done = True
                    elif msg_type == 'output':
                        print(f"  [输出] {len(data.get('data', ''))} 字节")
                except asyncio.TimeoutError:
                    print("  超时，继续...")
                    break

            # 发送问题
            print(f"\n✏️  阶段2: 发送问题...")
            await websocket.send(json.dumps({
                "type": "input",
                "data": "查询小微企业贷款余额"
            }))
            print("  已发送")

            # 接收所有响应
            print(f"\n📨 阶段3: 等待响应 (120秒)...")
            all_messages = []
            start = asyncio.get_event_loop().time()

            while asyncio.get_event_loop().time() - start < 120:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=3)
                    data = json.loads(message)
                    all_messages.append(data)

                    msg_type = data.get('type')
                    if msg_type == 'output':
                        content = data.get('data', '')
                        print(f"  📝 输出: {len(content)} 字节")
                    elif msg_type == 'system':
                        print(f"  [系统] {data.get('message', '')}")
                    else:
                        print(f"  [{msg_type}] {data}")

                except asyncio.TimeoutError:
                    print(".", end="", flush=True)
                    continue

            print(f"\n\n{'='*60}")
            print(f"总共收到 {len(all_messages)} 条消息")

            outputs = [m for m in all_messages if m.get('type') == 'output']
            print(f"其中 {len(outputs)} 条是输出")

            if outputs:
                full_text = ''.join(m.get('data', '') for m in outputs)
                print(f"\n响应内容 ({len(full_text)} 字符):")
                print("="*60)
                print(full_text[:2000])
                if len(full_text) > 2000:
                    print(f"\n... (还有 {len(full_text)-2000} 字符)")
                print("="*60)

    except Exception as e:
        print(f"❌ 错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    asyncio.run(test_websocket())
