#!/usr/bin/env python3
"""Check that a chart change renders the same manifests as a published version.

Renders each values file with the published chart (BASE) and the local chart,
parses the output and compares the objects. The helm.sh/chart label and NOTES
are ignored; any other difference fails.

    python scripts/compat_check.py --base 1.3.0 path/to/values.yaml ...

Needs helm, PyYAML, and access to the chart registry (make login-gcloud).
"""
import argparse
import difflib
import pathlib
import subprocess
import sys
import tempfile

import yaml

REGISTRY = "oci://europe-west4-docker.pkg.dev/rehive-services/rehive-helm-charts"


def render(chart, values):
    out = subprocess.run(
        ["helm", "template", "svc", str(chart), "--namespace", "ns", "--values", str(values)],
        capture_output=True, text=True,
    )
    if out.returncode:
        raise RuntimeError(out.stderr.strip())
    docs = [d for d in yaml.safe_load_all(out.stdout) if d]
    for d in docs:
        d.get("metadata", {}).get("labels", {}).pop("helm.sh/chart", None)
        for tmpl in [d.get("spec", {}).get("template", {})]:
            tmpl.get("metadata", {}).get("labels", {}).pop("helm.sh/chart", None)
    return {f'{d["kind"]}/{d["metadata"]["name"]}': d for d in docs}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--base", required=True, help="published version to compare with, e.g. 1.3.0")
    p.add_argument("--chart", default="rehive-service")
    p.add_argument("values", nargs="+", type=pathlib.Path)
    a = p.parse_args()

    root = pathlib.Path(__file__).resolve().parent.parent
    with tempfile.TemporaryDirectory() as tmp:
        subprocess.run(["helm", "pull", f"{REGISTRY}/{a.chart}", "--version", a.base,
                        "--untar", "--untardir", tmp], check=True, capture_output=True)
        base_chart = pathlib.Path(tmp) / a.chart
        failed = 0
        for values in a.values:
            try:
                old, new = render(base_chart, values), render(root / a.chart, values)
            except RuntimeError as e:
                print(f"ERROR {values}: {e}")
                failed += 1
                continue
            if old == new:
                print(f"same  {values} ({len(new)} objects)")
                continue
            failed += 1
            print(f"DIFF  {values}")
            for key in sorted(set(old) | set(new)):
                if old.get(key) != new.get(key):
                    a_ = yaml.safe_dump(old.get(key), sort_keys=True).splitlines()
                    b_ = yaml.safe_dump(new.get(key), sort_keys=True).splitlines()
                    print("\n".join(difflib.unified_diff(a_, b_, f"{a.base} {key}", f"local {key}", lineterm="")))
    print(f"\n{len(a.values) - failed}/{len(a.values)} unchanged")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
