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
- **Publish to Project Data Viewer**: Publishes data to the [project data viewer website](https://personal-7vf0v2cu.outsystemscloud.com/ProjectDataViewer5/). Enable by setting `use_project_data_viewer: true` in your workflow. Credentials are on [Confluence](https://movai.atlassian.net/wiki/spaces/MF/pages/2403074053/Project+Data+Viewer).
- **Build Packer Images**: Builds ISO images for CICD using Packer, QEMU/KVM/Libvirt, and cloud-init. Images are stored on the runner and deployed to CICD environments (Ubuntu 22.04).
- **Build Docker Images**: Builds and tests Docker images for CICD, stored in MOV.AI's private registry.
- **Build and Pack FE Packages**: Builds and packs frontend packages for the MOV.AI platform.
- **Build and Pack Npm Components**: Builds and packs npm components for the MOV.AI platform.
- **Build and Pack ROS Packages**: Builds and packs ROS packages for the MOV.AI platform.
- **Build and Validate Platform**: Builds and validates the MOV.AI platform.
- **Build Product Composite**: Builds composite projects (multiple products/squads) for MOV.AI platform.
- **Build Product**: Builds projects for MOV.AI platform.
- **Install Tests**: Runs QA install tests for MOV.AI platform.
- **UI Tests**: Runs UI tests for MOV.AI platform.

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
