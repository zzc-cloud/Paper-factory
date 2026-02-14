#!/usr/bin/env python3
"""修复错误编码的 Box Drawing 字符

这些字符 (U+2500-U+257F) 被错误地编码为 e5 b7 a5 格式
而不是正确的 UTF-8 e2 95 xx 格式
"""

from pathlib import Path

# 错误编码的 Box Drawing 字符映射
# 键: 字节序列 -> 正确的 UTF-8 字节
BOX_DRAWING_FIXES = {
    # 双线横线
    b'\xe5\xb7\xa5': b'\xe2\x95\x90',  # ═
    b'\xe5\xb7\xa4': b'\xe2\x95\x94',  # ─
    # 双线竖线
    b'\xe5\xb8\xa1': b'\xe2\x95\x91',  # ║
    b'\xe5\xb8\xa0': b'\xe2\x95\x90',  # │
    # 其他双线字符
    b'\xe5\xb6\x95': b'\xe2\x95\x95',  # ╕
    b'\xe5\xb6\x96': b'\xe2\x95\x96',  # ╖
    b'\xe5\xb7\x94': b'\xe2\x95\x94',  # └
    b'\xe5\xb7\x99': b'\xe2\x95\x99',  # ┘
    b'\xe5\xb6\x98': b'\xe2\x95\x98',  # ╗
    b'\xe5\xb7\x8d': b'\xe2\x95\x8d',  # █
}

def fix_box_drawing(content_bytes):
    """修复 Box Drawing 字符的字节序列"""
    result = content_bytes
    for wrong, correct in BOX_DRAWING_FIXES.items():
        result = result.replace(wrong, correct)
    return result

def fix_file(file_path):
    """修复单个文件"""
    try:
        with open(file_path, 'rb') as f:
            content_bytes = f.read()

        fixed_bytes = fix_box_drawing(content_bytes)

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
