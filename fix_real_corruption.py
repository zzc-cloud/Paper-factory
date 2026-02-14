#!/usr/bin/env python3
"""修复 UTF-8 中文字符的编码损坏问题

问题：UTF-8 字符被错误地拆分和重组
例如：e5 8e 82 应该是 e5 b7 (工)
"""

from pathlib import Path

# 常见的错误编码模式
# 错误字节序列 -> 正确字节序列
ENCODING_FIXES = {
    # 3 字节错误 -> 2 字节正确
    b'\xe5\x8e\x82': b'\xe5\xb7\xa5',  # 厂 -> 工
    b'\xef\xbc\x9a': b'\xe5\xa4\x9a',  # ： -> ：
    b'\xe5\xa4\x9a': b'\xe5\xa4\x9a',  # ：已正确，保留
    b'\xe6\x99\xba': b'\xe6\x99\xba',  # 智 已正确
    b'\xe8\x88\xbd': b'\xe8\x88\xbd',  # 能 已正确
    b'\xe4\xbd\x93': b'\xe4\xbd\x93',  # 体 已正确
    # 添加更多模式...
}

def fix_corrupted_bytes(content_bytes):
    """修复损坏的字节序列"""
    result = content_bytes
    for wrong, correct in ENCODING_FIXES.items():
        result = result.replace(wrong, correct)
    return result

def fix_file(file_path):
    """修复单个文件"""
    try:
        with open(file_path, 'rb') as f:
            content_bytes = f.read()

        fixed_bytes = fix_corrupted_bytes(content_bytes)

        if fixed_bytes != content_bytes:
            with open(file_path, 'wb') as f:
                f.write(fixed_bytes)
            return True
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    root_dir = Path('/Users/yyzz/Desktop/MyClaudeCode/paper-factory')
    dirs = [root_dir, root_dir / 'docs', root_dir / '.claude' / 'skills',
             root_dir / 'workspace', root_dir / 'agents']

    fixed = 0
    checked = 0
    for base_dir in dirs:
        if not base_dir.exists():
            continue
        for ext in ('*.md', '*.txt'):
            for file_path in base_dir.rglob(ext):
                checked += 1
                if fix_file(file_path):
                    print(f"Fixed: {file_path.relative_to(root_dir)}")
                    fixed += 1

    print(f"\nChecked: {checked}, Fixed: {fixed}")

if __name__ == '__main__':
    main()
