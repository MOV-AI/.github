#!/usr/bin/env python3
"""
Parse Docker build matrix from manifest file or workflow inputs.

This script generates a build matrix for GitHub Actions workflows,
either from a YAML manifest file or from direct input parameters.
"""

import argparse
import json
import os
import sys

import yaml


def parse_from_manifest(manifest_file):
    """Parse matrix from YAML manifest file."""
    print(f"Reading manifest file: {manifest_file}")

    try:
        with open(manifest_file) as f:
            manifest = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: Manifest file '{manifest_file}' not found", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error: Failed to parse YAML manifest: {e}", file=sys.stderr)
        sys.exit(1)

    images = manifest.get("images", [])
    print(f"Found {len(images)} images in manifest")

    if not images:
        print("Error: No images found in manifest", file=sys.stderr)
        sys.exit(1)

    # Convert to matrix
    matrix = {
        "include": [
            {
                "name": img["name"],
                "docker_file": img["docker_file"],
                "docker_image": img["docker_image"],
                "public_image": img["public_image"],
                "platforms": img["platforms"],
                "public": img["public"],
                "snyk_check": img["snyk_check"],
                "target": img["target"] if img["target"] else "",
            }
            for img in images
        ]
    }

    matrix_json = json.dumps(matrix)
    first_image = images[0]["name"]
    last_image = images[-1]["name"]

    print(f"First image: {first_image}")
    print(f"Last image: {last_image}")
    print(f"Matrix JSON: {matrix_json}")

    return {
        "is_matrix": "true",
        "matrix": matrix_json,
        "first_image": first_image,
        "last_image": last_image,
    }


def parse_from_inputs(args):
    """Parse matrix from workflow input parameters."""
    matrix = {
        "include": [
            {
                "name": "single",
                "docker_file": args.docker_file,
                "docker_image": args.docker_image,
                "public_image": args.public_image,
                "platforms": args.platforms,
                "public": args.public == "true",
                "snyk_check": args.snyk_check == "true",
                "target": args.target if args.target else "",
            }
        ]
    }

    matrix_json = json.dumps(matrix)

    return {
        "is_matrix": "false",
        "matrix": matrix_json,
        "first_image": "single",
        "last_image": "single",
    }


def write_github_output(outputs):
    """Write outputs to GitHub Actions output file."""
    github_output = os.environ.get("GITHUB_OUTPUT", "GITHUB_OUTPUT")
    print(f"Writing to: {github_output}")

    try:
        with open(github_output, "a") as f:
            for key, value in outputs.items():
                f.write(f"{key}={value}\n")
        print("Successfully wrote outputs")
    except OSError as e:
        print(f"Error: Failed to write to {github_output}: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Parse Docker build matrix for GitHub Actions")
    parser.add_argument(
        "--manifest-file",
        help="Path to YAML manifest file containing images configuration",
    )
    parser.add_argument("--docker-file", default="", help="Path to Dockerfile")
    parser.add_argument("--docker-image", default="", help="Docker image name")
    parser.add_argument("--public-image", default="", help="Public Docker image name")
    parser.add_argument("--platforms", default="linux/amd64", help="Build platforms")
    parser.add_argument("--public", default="false", help="Enable public registry push")
    parser.add_argument("--snyk-check", default="false", help="Enable Snyk security scan")
    parser.add_argument("--target", default="", help="Docker build target")

    args = parser.parse_args()

    # Determine which mode to use
    outputs = parse_from_manifest(args.manifest_file) if args.manifest_file else parse_from_inputs(args)

    # Write outputs to GitHub Actions
    write_github_output(outputs)


if __name__ == "__main__":
    main()
