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

See [docs/workflows.md](docs/workflows.md) for detailed specifications, inputs, secrets, and examples.

### Summary

| Workflow | Purpose |
|----------|---------|
| **Build and Pack FE Packages** | Builds and packages frontend packages for the MOV.AI platform |
| **Build and Pack Npm Components** | Builds and packages npm components for the MOV.AI platform |
| **Build and Pack ROS Packages** | Builds and publishes ROS packages (Debian) for ROS 1 (Noetic) and ROS 2 (Humble) |
| **Build and Validate Platform** | Builds and validates the MOV.AI platform |
| **Build Docker Images** | Builds and publishes Docker images with static analysis, Snyk scanning, and optional multi-platform support |
| **Build Packer Images** | Builds ISO images for CICD using Packer, QEMU/KVM/Libvirt, and cloud-init |
| **Build Product** | Orchestrates complete product build pipeline including validation, workspace build, simulator setup, and testing |
| **Build Product Composite** | Builds composite projects (multiple products/squads) |
| **Generic Local Standalone Tests** | Runs QA tests on locally deployed platform instances (install tests, UI tests, etc.) |
| **Generic Remote Fleet Tests** | Runs QA tests on provisioned remote fleet infrastructure with Terraform provisioning and Ansible deployment |
| **Install Tests** | Runs QA install tests on platform deployments |
| **Publish to Project Data Viewer** | Publishes data to the [project data viewer website](https://personal-7vf0v2cu.outsystemscloud.com/ProjectDataViewer5/) |
| **Robotic Component Pipeline** | Builds and tests robotic stack components with remote provisioning and test execution |
| **Robotic Tests** | Runs comprehensive robotic stack integration tests with simulator support |
| **UI Tests** | Runs UI tests on platform instances |

## Composite Actions
- **publish-to-nexus**: Publishes artifacts (Debian/RPM packages) to Nexus repository.
- **push-to-protected-branch**: Pushes changes to branches protected by organization rulesets or classic branch protection using a temporary PR which is automatically merged.

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
