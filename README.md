<p align="center">
  <img src="images/MOV.AI-logo-3.png" alt="MOV.AI Logo" width="200"/>
</p>

# MOV.AI .github Repository

[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](LICENSE)

Centralized GitHub workflows, composite actions, and community files for MOV.AI projects.

## Table of Contents
1. [Purpose](#purpose)
2. [Shared Workflows](#shared-workflows)
3. [Composite Actions](#composite-actions)
4. [Usage](#usage)
5. [Contributing](#contributing)
6. [Support](#support)

## Purpose
This repository contains shared GitHub Actions workflows, composite actions, and community health files (e.g., `CONTRIBUTING.md`, `LICENSE`) for all MOV.AI repositories. It helps standardize CI/CD, testing, and publishing processes across projects.

## Shared Workflows

### Publish to Project Data Viewer
Publishes data to the [project data viewer website](https://personal-7vf0v2cu.outsystemscloud.com/ProjectDataViewer5/). Enable by setting `use_project_data_viewer: true` in your workflow. Credentials are on [Confluence](https://movai.atlassian.net/wiki/spaces/MF/pages/2403074053/Project+Data+Viewer).

### Build Packer Images
Builds ISO images for CICD using Packer, QEMU/KVM/Libvirt, and cloud-init. Images are stored on the runner and deployed to CICD environments (Ubuntu 22.04).

### Build Docker Images
Performs static analysis (Hadolint), builds Docker images for single or multiple platforms, optionally runs Snyk security scans, auto-increments versions, and publishes registries with optional release creation. Supports matrix builds via YAML manifest to build multiple images in parallel with individual configurations, or single-image builds using direct input parameters.

**Inputs:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `docker_file` | string | - | Path to the Dockerfile used for build |
| `docker_image` | string | - | Image name in format `<directory>/<name>` |
| `manifest_file` | string | - | Path to YAML manifest for multi-image builds |
| `build_args` | string | - | Comma-separated list of build arguments |
| `platforms` | string | `linux/amd64` | Comma-separated list of platforms to build |
| `version` | string | `auto` | Version tag; `auto` to auto-increment on deploy |
| `deploy` | boolean | `false` | Enable image push to registries |
| `push_latest` | boolean | `false` | Override `latest` tag on push |
| `docker_registry` | string | `registry.cloud.mov.ai` | Primary registry for push |
| `public` | boolean | `false` | Enable secondary public registry push |
| `public_registry` | string | `pubregistry.aws.cloud.mov.ai` | AWS public registry for push |
| `github_registry` | string | `ghcr.io/mov-ai` | GitHub registry for push |
| `public_image` | string | - | Image name for public registries |
| `snyk_check` | boolean | `false` | Enable Snyk security scanning |
| `download_artifact` | boolean | `false` | Download build artifacts before build |
| `download_artifact_name` | string | `artifacts` | Artifact name to download |
| `download_artifact_path` | string | `./dist` | Path where artifact is downloaded |
| `target` | string | - | Docker build target stage |
| `create_release` | boolean | `false` | Create GitHub Release with metadata |

**Manifest File Format:**
```yaml
images:
  - name: image1
    docker_file: docker/Dockerfile-1
    docker_image: ci/app-1
    public_image: app-1
    platforms: linux/amd64,linux/arm64
    public: true
    snyk_check: true
    target: production
  - name: image2
    docker_file: docker/Dockerfile-2
    docker_image: ci/app-2
    public_image: app-2
    platforms: linux/amd64
    public: false
    snyk_check: false
    target: ""
```

**Required Secrets:**
- `registry_user`: Private registry username
- `registry_password`: Private registry password
- `pub_registry_user`: (Optional) AWS public registry username
- `pub_registry_password`: (Optional) AWS public registry password
- `github_registry_user`: (Optional) GitHub registry username
- `github_registry_password`: (Optional) GitHub registry password
- `snyk_token`: (Optional) Snyk API token for security scanning
- `commit_user`: (Optional) Git user for version bumps
- `commit_mail`: (Optional) Git email for version bumps
- `commit_token`: (Optional) Git token for pushing version bumps and releases

### Build and Pack FE Packages
Builds and packs frontend packages for the MOV.AI platform.

### Build and Pack Npm Components
Builds and packs npm components for the MOV.AI platform.

### Build and Pack ROS Packages
Builds and packs ROS packages for the MOV.AI platform.

### Build and Validate Platform
Builds and validates the MOV.AI platform.

### Build Product Composite
Builds composite projects (multiple products/squads) for MOV.AI platform.

### Build Product
Builds projects for MOV.AI platform.

### Install Tests
Runs QA install tests for MOV.AI platform.

### UI Tests
Runs UI tests for MOV.AI platform.

## Composite Actions
- **publish-to-nexus**: Publishes artifacts (Debian/RPM packages) to Nexus repository.

## Usage
To use a shared workflow or composite action, reference it in your repository's workflow YAML:

```yaml
jobs:
  build:
    uses: MOV-AI/.github/.github/workflows/shared_workflow.yml@v3
    with:
      option_to_use: true
```

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. Maintainers are defined in `CODEOWNERS`.

## Support
For questions or issues, open a GitHub issue or contact the MOV.AI team via Confluence or internal channels.

---
© MOV.AI. See [LICENSE](LICENSE) for usage rights.
