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


def parse_from_manifest(manifest_file, global_args):
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

    def get_val(img, key, global_val, default):
        val = img[key] if key in img and img[key] is not None else global_val if global_val not in [None, ""] else default
        if key in ["download_artifact", "push_latest"]:
            return normalize_bool(val)
        return val

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
                "build_args": get_val(img, "build_args", global_args["build_args"], ""),
                "push_latest": get_val(img, "push_latest", global_args["push_latest"], False),
                "download_artifact": get_val(img, "download_artifact", global_args["download_artifact"], False),
                "download_artifact_name": get_val(img, "download_artifact_name", global_args["download_artifact_name"], "artifacts"),
                "download_artifact_path": get_val(img, "download_artifact_path", global_args["download_artifact_path"], "./dist"),
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
    # Validate required parameters
    if not args.docker_file:
        print("Error: --docker-file is required when not using --manifest-file", file=sys.stderr)
        sys.exit(1)

    if not args.docker_image:
        print("Error: --docker-image is required when not using --manifest-file", file=sys.stderr)
        sys.exit(1)

    print("Building matrix from inputs:")
    print(f"  docker_file: {args.docker_file}")
    print(f"  docker_image: {args.docker_image}")
    print(f"  platforms: {args.platforms}")

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
                "build_args": args.build_args,
                "push_latest": global_args["push_latest"],
                "download_artifact": global_args["download_artifact"],
                "download_artifact_name": args.download_artifact_name,
                "download_artifact_path": args.download_artifact_path,
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


def generate_release_notes(matrix, version, push_latest, output_file):
    """Generate release notes markdown file."""
    if not version:
        return  # Don't generate if no version provided

    # Read registry URLs from environment variables
    docker_registry = os.environ.get("DOCKER_REGISTRY", "registry.cloud.mov.ai")
    public_registry = os.environ.get("PUBLIC_REGISTRY", "pubregistry.aws.cloud.mov.ai")
    github_registry = os.environ.get("GITHUB_REGISTRY", "ghcr.io/mov-ai")

    print(f"Generating release notes to: {output_file}")
    print(f"Using registries - Docker: {docker_registry}, Public: {public_registry}, GitHub: {github_registry}")

    try:
        with open(output_file, "w") as f:
            f.write("## Docker Image Release\n\n")
            f.write(f"**Version:** `{version}`\n\n")

            for item in matrix["include"]:
                name = item.get("name", "unknown")
                docker_image = item.get("docker_image", "")
                public_image = item.get("public_image", "")
                is_public = item.get("public", False)
                platforms = item.get("platforms", "linux/amd64")
                dockerfile = item.get("docker_file", "")
                target = item.get("target", "")
                snyk = item.get("snyk_check", False)

                if name == "single":
                    name = docker_image  # Use image name if single image

                f.write(f"## {name}\n\n")
                f.write("**Private Registry:**\n")
                f.write(f"- `{docker_registry}/{docker_image}:{version}`\n")
                if push_latest:
                    f.write(f"- Latest: `{docker_registry}/{docker_image}:latest`\n")

                if is_public and public_image:
                    f.write("\n**Public Registries:**\n")
                    f.write(f"- AWS Public: `{public_registry}/{public_image}:{version}`")
                    if push_latest:
                        f.write(f" (latest: `{public_registry}/{public_image}:latest`)")
                    f.write("\n")
                    f.write(f"- GitHub: `{github_registry}/{public_image}:{version}`")
                    if push_latest:
                        f.write(f" (latest: `{github_registry}/{public_image}:latest`)")
                    f.write("\n")

                f.write(f"\n**Build:** {platforms}\n")
                f.write(f"\n**Dockerfile:** `{dockerfile}`")
                if target:
                    f.write(f" (target: `{target}`)")
                f.write("\n")
                if snyk:
                    f.write("\n**Security scan:** enabled\n")
                f.write("\n\n")

            f.write("---\n\n")
            f.write("*Release notes generated during build*\n")

        print(f"✓ Release notes written to {output_file}")
    except OSError as e:
        print(f"Warning: Failed to write release notes: {e}", file=sys.stderr)
        # Don't fail the workflow if release notes can't be written


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
    parser.add_argument("--build-args", default="", help="Build arguments (comma separated)")
    parser.add_argument("--push-latest", default="false", help="Whether latest tag will be pushed")
    parser.add_argument("--download-artifact", default="false", help="Enable download of 'packages' artifacts")
    parser.add_argument("--download-artifact-name", default="artifacts", help="Artifact name to download")
    parser.add_argument("--download-artifact-path", default="./dist", help="Path where package is downloaded")

    # Release notes generation arguments (optional)
    parser.add_argument("--version", default="{{VERSION}}", help="Version for release notes")
    parser.add_argument(
        "--release-notes-output", default="release_notes_template.md", help="Output file for release notes"
    )

    args = parser.parse_args()

    def normalize_bool(val):
        if isinstance(val, bool):
            return val
        return str(val).lower() == "true"

    global_args = {
        "build_args": args.build_args,
        "push_latest": normalize_bool(args.push_latest),
        "download_artifact": normalize_bool(args.download_artifact),
        "download_artifact_name": args.download_artifact_name,
        "download_artifact_path": args.download_artifact_path,
    }

    # Determine which mode to use
    outputs = (
        parse_from_manifest(args.manifest_file, global_args)
        if args.manifest_file
        else parse_from_inputs(args)
    )

    # Write outputs to GitHub Actions
    write_github_output(outputs)

    # Generate release notes if version is provided
    if args.version:
        matrix = json.loads(outputs["matrix"])
        generate_release_notes(
            matrix=matrix,
            version=args.version,
            push_latest=args.push_latest.lower() == "true",
            output_file=args.release_notes_output,
        )


if __name__ == "__main__":
    main()
