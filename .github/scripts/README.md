# GitHub Actions Scripts

This directory contains utility scripts used by GitHub Actions workflows.

## parse_docker_manifest.py

Parses Docker build matrix configuration for multi-image builds.

### Usage

**From manifest file:**
```bash
python3 parse_docker_manifest.py --manifest-file path/to/manifest.yaml
```

**From individual inputs:**
```bash
python3 parse_docker_manifest.py \
  --docker-file Dockerfile \
  --docker-image org/image-name \
  --platforms "linux/amd64,linux/arm64" \
  --public true \
  --snyk-check true
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

### Dependencies

- Python 3.7+
- PyYAML (`pip install pyyaml`)
