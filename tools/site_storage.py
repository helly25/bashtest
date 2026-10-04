#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) M. Boerger, the MBO Works authors
# SPDX-License-Identifier: Apache-2.0
"""Measure the complete publication tree without changing retained releases."""

import argparse
import json
from pathlib import Path


def sizes(root):
    result = {}
    for path in root.rglob('*'):
        relative = path.relative_to(root)
        if '.git' in relative.parts or relative.as_posix() == 'storage-report.json' or not path.is_file():
            continue
        section = relative.parts[0] if len(relative.parts) > 1 else 'root'
        stats = result.setdefault(section, {'files': 0, 'bytes': 0})
        stats['files'] += 1
        stats['bytes'] += path.stat().st_size
    return result


def report(root):
    result = sizes(root)
    total = sum(entry['bytes'] for entry in result.values())
    report = {'schema': 1, 'total_bytes': total, 'sections': result,
              'review_bytes': 250_000_000}
    (root / 'storage-report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2), flush=True)
    if total >= report['review_bytes']:
        print('::warning::Published site reached 250 MB; review storage-report.json and docs/infrastructure.md.')
    if total > 9_000_000_000:
        raise ValueError('Published site exceeds the Pages deployment ceiling')
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', type=Path)
    args = parser.parse_args()
    report(args.root)


if __name__ == '__main__':
    main()
