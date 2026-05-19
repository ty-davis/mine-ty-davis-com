#!/usr/bin/env python3
"""
unbundle.py - Unpack a .bundle file (Lua table format) into a folder.
Usage: python unbundle.py <bundleFile> [targetDir]
"""

import os
import sys


class BundleParser:
    """Simple parser for the Lua table bundle format."""

    def __init__(self, text):
        self.text = text
        self.pos = 0

    def skip_ws(self):
        while self.pos < len(self.text) and self.text[self.pos] in ' \t\r\n':
            self.pos += 1

    def peek(self):
        return self.text[self.pos] if self.pos < len(self.text) else None

    def expect(self, s):
        chunk = self.text[self.pos:self.pos + len(s)]
        if chunk != s:
            ctx = self.text[self.pos:self.pos + 20]
            raise ValueError(f"Expected {s!r}, got {ctx!r} at pos {self.pos}")
        self.pos += len(s)

    def parse_string(self):
        self.skip_ws()
        if self.peek() != '"':
            raise ValueError(f"Expected '\"' at pos {self.pos}, got {self.text[self.pos:self.pos+5]!r}")
        self.pos += 1
        result = []
        while self.pos < len(self.text):
            ch = self.text[self.pos]
            if ch == '"':
                self.pos += 1
                return ''.join(result)
            elif ch == '\\':
                self.pos += 1
                esc = self.text[self.pos]
                if esc == 'n':
                    result.append('\n')
                elif esc == 'r':
                    result.append('\r')
                elif esc == 't':
                    result.append('\t')
                elif esc == '\\':
                    result.append('\\')
                elif esc == '"':
                    result.append('"')
                elif esc == "'":
                    result.append("'")
                elif esc.isdigit():
                    # Lua numeric escape: up to 3 decimal digits
                    num_str = esc
                    while self.pos + 1 < len(self.text) and self.text[self.pos + 1].isdigit() and len(num_str) < 3:
                        self.pos += 1
                        num_str += self.text[self.pos]
                    result.append(chr(int(num_str)))
                else:
                    result.append(esc)
                self.pos += 1
            else:
                result.append(ch)
                self.pos += 1
        raise ValueError("Unterminated string literal")

    def parse_ident(self):
        self.skip_ws()
        start = self.pos
        while self.pos < len(self.text) and (self.text[self.pos].isalnum() or self.text[self.pos] == '_'):
            self.pos += 1
        return self.text[start:self.pos]

    def parse_number(self):
        self.skip_ws()
        start = self.pos
        while self.pos < len(self.text) and self.text[self.pos].isdigit():
            self.pos += 1
        return int(self.text[start:self.pos])

    def parse_bundle(self):
        self.skip_ws()
        self.expect('return')
        self.skip_ws()
        self.expect('{')

        bundle = {}

        while True:
            self.skip_ws()
            if self.peek() == '}':
                self.pos += 1
                break

            key = self.parse_ident()
            self.skip_ws()
            self.expect('=')
            self.skip_ws()

            if key == 'root':
                bundle['root'] = self.parse_string()
            elif key == 'version':
                bundle['version'] = self.parse_number()
            elif key == 'entries':
                bundle['entries'] = self._parse_entries()
            else:
                raise ValueError(f"Unknown bundle key: {key!r}")

            self.skip_ws()
            if self.peek() == ',':
                self.pos += 1

        return bundle

    def _parse_entries(self):
        self.skip_ws()
        self.expect('{')
        entries = []

        while True:
            self.skip_ws()
            if self.peek() == '}':
                self.pos += 1
                break
            if self.peek() == '{':
                entries.append(self._parse_entry())
            self.skip_ws()
            if self.peek() == ',':
                self.pos += 1

        return entries

    def _parse_entry(self):
        self.skip_ws()
        self.expect('{')
        entry = {}

        while True:
            self.skip_ws()
            if self.peek() == '}':
                self.pos += 1
                break

            key = self.parse_ident()
            self.skip_ws()
            self.expect('=')
            self.skip_ws()
            entry[key] = self.parse_string()

            self.skip_ws()
            if self.peek() == ',':
                self.pos += 1

        return entry


def unbundle(bundle_file, target_dir='.'):
    bundle_file = os.path.abspath(bundle_file)
    target_dir = os.path.abspath(target_dir)

    if not os.path.exists(bundle_file):
        print(f"Error: Bundle file does not exist: {bundle_file}", file=sys.stderr)
        sys.exit(1)
    if os.path.isdir(bundle_file):
        print(f"Error: Bundle path is a directory: {bundle_file}", file=sys.stderr)
        sys.exit(1)

    os.makedirs(target_dir, exist_ok=True)

    with open(bundle_file, 'r', encoding='utf-8') as f:
        text = f.read()

    try:
        bundle = BundleParser(text).parse_bundle()
    except ValueError as e:
        print(f"Error: Failed to parse bundle: {e}", file=sys.stderr)
        sys.exit(1)

    if not isinstance(bundle.get('entries'), list):
        print("Error: Invalid bundle format (missing entries)", file=sys.stderr)
        sys.exit(1)

    root_name = bundle.get('root', '')
    if not root_name:
        print("Error: Invalid bundle (missing root)", file=sys.stderr)
        sys.exit(1)

    root_path = os.path.join(target_dir, root_name)
    os.makedirs(root_path, exist_ok=True)

    for entry in bundle['entries']:
        entry_type = entry.get('type')
        entry_path = entry.get('path', '').replace('/', os.sep)
        out_path = os.path.join(root_path, entry_path)

        if entry_type == 'dir':
            os.makedirs(out_path, exist_ok=True)
        elif entry_type == 'file':
            os.makedirs(os.path.dirname(out_path), exist_ok=True)
            with open(out_path, 'w', encoding='utf-8') as f:
                f.write(entry.get('content', ''))
        else:
            print(f"Warning: Unknown entry type {entry_type!r}, skipping", file=sys.stderr)

    print(f"Unbundled {bundle_file} -> {root_path} ({len(bundle['entries'])} entries)")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: unbundle.py <bundleFile> [targetDir]")
        sys.exit(1)

    src = sys.argv[1]
    dest = sys.argv[2] if len(sys.argv) > 2 else '.'
    unbundle(src, dest)
