#!/usr/bin/env python3
import sys
import json
from typing import Any, Dict
import yaml  # PyYAML required for YAML specs


# Load an OpenAPI spec from JSON or YAML path
def load_spec(path: str) -> Dict[str, Any]:
    try:
        if path.lower().endswith('.json'):
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        else:
            with open(path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Spec file not found: {path}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"Failed to parse spec '{path}': {e}", file=sys.stderr)
        sys.exit(4)


# Count HTTP operations in the OpenAPI 'paths' section
def count_operations(spec: Dict[str, Any]) -> int:
    if not isinstance(spec, dict):
        return 0
    paths = spec.get('paths') or {}
    if not isinstance(paths, dict):
        return 0
    methods = {"get", "post", "put", "delete", "patch", "head", "options", "trace"}
    total = 0
    for _path, item in paths.items():
        if not isinstance(item, dict):
            continue
        for k, v in item.items():
            if k.lower() in methods and isinstance(v, dict):
                total += 1
    return total


# CLI entrypoint: prints total operation count
def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: count_operations.py <openapi.{yaml|yml|json}>", file=sys.stderr)
        return 1
    spec_path = sys.argv[1]
    spec = load_spec(spec_path)
    total = count_operations(spec)
    print(total)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
