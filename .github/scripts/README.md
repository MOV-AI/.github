# GitHub Actions Scripts

This directory contains utility scripts used by GitHub Actions workflows.

## parse_docker_manifest.py

Parses Docker build matrix configuration for multi-image builds and generates release notes.

### Usage

**Parse matrix from manifest file:**
```bash
python3 parse_docker_manifest.py --manifest-file path/to/manifest.yaml
```

**Parse matrix from individual inputs:**
```bash
python3 parse_docker_manifest.py \
  --docker-file Dockerfile \
  --docker-image org/image-name \
  --platforms "linux/amd64,linux/arm64" \
  --public true \
  --snyk-check true
```

**Generate release notes (requires matrix parsing arguments and registry environment variables):**
```bash
python3 parse_docker_manifest.py \
  --manifest-file path/to/manifest.yaml \
  --version 1.2.3 \
  --release-notes-output release_notes.md
```

### Manifest File Format

```yaml
images:
  - name: image-1
    docker_file: docker/Dockerfile.image1
    docker_image: org/image-1
    public_image: org/public-image-1
    platforms: linux/amd64
    public: true
    snyk_check: true
    target: production
  - name: image-2
    docker_file: docker/Dockerfile.image2
    docker_image: org/image-2
    public_image: org/public-image-2
    platforms: linux/amd64,linux/arm64
    public: false
    snyk_check: false
    target: ""
```

### Outputs

The script writes to `$GITHUB_OUTPUT`:
- `is_matrix`: "true" if using manifest, "false" otherwise
- `matrix`: JSON-encoded build matrix for GitHub Actions
- `first_image`: Name of the first image (used for version bumping)
- `last_image`: Name of the last image (used for release creation)

The script also generates release notes based on the provided information:
- Creates a markdown file at the specified `--release-notes-output` path
- Contains formatted information about all Docker images in the build
- Includes version, registry URLs, platform details, and build configuration
- Designed to be uploaded as a GitHub Actions artifact and downloaded by the `create-release` job

### Workflow Integration

The script is used in two places in the Docker workflow:

1. **parse-matrix job**: Parses the manifest to generate the build matrix, and conditionally generates release notes template with version placeholder `{{VERSION}}`
2. **create-release job**: Downloads the artifact and uses sed to replace `{{VERSION}}` with the actual version from raise-version output

This approach ensures the script is only called once per workflow run, with simple text replacement handling the version substitution.

### Dependencies

- Python 3.7+
- PyYAML (`pip install pyyaml`)
