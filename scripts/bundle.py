#!/usr/bin/env python3
"""
bundle.py - Pack a folder into a .bundle file (Lua table format).
Usage: python bundle.py <sourceDir> [outputFile]
"""

import os
import sys


def lua_quote(s):
    """Encode a string using Lua's string.format("%q", ...) style escaping."""
    result = ['"']
    for ch in s:
        code = ord(ch)
        if ch == '"':
            result.append('\\"')
        elif ch == '\\':
            result.append('\\\\')
        elif ch == '\n':
            result.append('\\n')
        elif ch == '\r':
            result.append('\\r')
        elif code == 0:
            result.append('\\0')
        elif code < 32 or code == 127:
            result.append(f'\\{code}')
        else:
            result.append(ch)
    result.append('"')
    return ''.join(result)


def bundle(source_dir, output_file=None):
    source_dir = os.path.abspath(source_dir)

    if not os.path.exists(source_dir):
        print(f"Error: Source path does not exist: {source_dir}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(source_dir):
        print(f"Error: Source path must be a directory: {source_dir}", file=sys.stderr)
        sys.exit(1)

    source_name = os.path.basename(source_dir)
    if output_file is None:
        output_file = source_name + '.bundle'

    entries = []

    def walk(abs_path, rel_path):
        if rel_path != '':
            if os.path.isdir(abs_path):
                entries.append({'type': 'dir', 'path': rel_path})
            else:
                with open(abs_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                entries.append({'type': 'file', 'path': rel_path, 'content': content})
                return

        for child in sorted(os.listdir(abs_path)):
            child_abs = os.path.join(abs_path, child)
            child_rel = child if rel_path == '' else rel_path + '/' + child
            walk(child_abs, child_rel)

    walk(source_dir, '')

    with open(output_file, 'w', encoding='utf-8') as out:
        out.write('return {\n')
        out.write(f'  root = {lua_quote(source_name)},\n')
        out.write('  version = 1,\n')
        out.write('  entries = {\n')
        for entry in entries:
            if entry['type'] == 'dir':
                out.write(f'    {{ type = "dir", path = {lua_quote(entry["path"])} }},\n')
            else:
                out.write(f'    {{ type = "file", path = {lua_quote(entry["path"])}, content = {lua_quote(entry["content"])} }},\n')
        out.write('  }\n')
        out.write('}\n')

    print(f"Bundled {source_dir} -> {output_file} ({len(entries)} entries)")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: bundle.py <sourceDir> [outputFile]")
        sys.exit(1)

    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else None
    bundle(src, out)
