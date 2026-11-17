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

| Workflow | Purpose | Ref to use |
|----------|---------|------------|
| **Build and Pack FE Packages** | Builds and packages frontend packages for the MOV.AI platform | v2.3 |
| **Build and Pack Npm Components** | Builds and packages npm components for the MOV.AI platform | v2.1 |
| **Build and Pack ROS Packages** | Builds and publishes ROS packages (Debian) for ROS 1 (Noetic) and ROS 2 (Humble). Automatically builds and publishes Python wheel packages for ROS packages containing a setup.py file. | v3 |
| **Build and Validate Platform** | Builds and validates the MOV.AI platform | v3 |
| **Build Docker Images** | Builds and publishes Docker images with static analysis, Snyk scanning, and optional multi-platform support | v3 |
| **Build Packer Images** | Builds ISO images for CICD using Packer, QEMU/KVM/Libvirt, and cloud-init | v2.1 |
| **Build Product** | Orchestrates complete product build pipeline including validation, workspace build, simulator setup, and testing | v2.3 |
| **Build Product Composite** | Builds composite projects (multiple products/squads) | v2.1 |
| **Generic Local Standalone Tests** | Runs QA tests on locally deployed platform instances (install tests, UI tests, etc.) | v3 |
| **Generic Remote Fleet Tests** | Runs QA tests on provisioned remote fleet infrastructure with Terraform provisioning and Ansible deployment, including infrastructure recreation with dedicated robotics-sim, redhat-oracle, and packer runner pools | v3 |
| **Install Tests** | Runs QA install tests on platform deployments | v3 |
| **Rust Tests and Coverage** | Runs the white-box stage for Rust repositories: rustfmt, clippy with SARIF upload, unit and optional Docker-backed component tests, coverage, and the SonarCloud quality gate | v3 |
| **Robotic Component Pipeline** | Builds and tests robotic stack components with remote provisioning and test execution | v3 |
| **Robotic Tests** | Runs comprehensive robotic stack integration tests with simulator support | v3 |
| **UI Tests** | Runs UI tests on platform instances | v3 |
| **Build and Pack Python Packages** | Builds and packages Python packages | v2.3 |
| **Build and Pack movai-service Packages** | Builds and packs movai-service distribution packages | v3 |
| **Component Pipeline** | Builds and tests platform components | v3 |
| **Infrastructure Recreation** | Recreates CI infrastructure (runner pools / test VMs) | v3 |
| **Build Offline ISO** | Builds the offline installation ISO | v2.3 |

## Composite Actions
- **publish-to-nexus**: Publishes artifacts (Debian/RPM packages) to Nexus repository.
- **push-to-protected-branch**: Pushes changes to branches protected by organization rulesets or classic branch protection using a temporary PR which is automatically merged.
- **infrastructure-setup**: Provisions Proxmox test VMs with Terraform (a fleet manager plus optional fleet peers), then configures SSH and, on Marvin cluster nodes, NVIDIA container support. Outputs `host_ip`, `host_user` and `ssh_connect_string` for the manager VM, `peer_ips` (comma-separated, empty when `fleet_peer_nr` is `0`), `env_configs_dir` and `provision_infra_dir`.
- **infrastructure-teardown**: Destroys the VMs created by `infrastructure-setup` (`terraform destroy`, up to 3 attempts). Outputs `teardown_success`.

### Infrastructure setup and teardown inputs
Both actions take the same inputs. The VM names and the Terraform state key are derived from these inputs, so **pass identical values to `infrastructure-setup` and `infrastructure-teardown`**. A different value makes teardown use a different state and leaves the VMs running, and teardown still passes because it destroys nothing. This also applies to `platform_repo`, `platform_version`, `project_repo`, `project_version` and `provision_infra_env_version`.

| Input | Default | Description |
|-------|---------|-------------|
| `cluster_node` | `bb-9` | Proxmox node: `hel0`, `hel1`, `bb-8`, `bb-9`, `marvin`, `mary`, `kx-01`, `kx-02`. |
| `name_prefix` | `sanity` | First part of the VM names and of the Terraform state key (`<cluster_node>-<name_prefix>-<manager name>.tfstate`). |
| `fleet_peer_nr` | `0` | Number of fleet peer VMs to create besides the manager. `0` creates a single VM. |
| `fleet_peer_name_prefix` | `''` | Prefix for peer VM names (a number is appended). If empty: `<manager name>-worker`. |
| `enable_traefik_exposure` | `false` | Expose the VM through Traefik under `vm.hel.mov.ai`. Only on `hel0`; other nodes fail. |
| `provision_infra_env_file` | `''` | tfvars file in the environment configs group folder. If empty: `<node>_fleet_test.tfvars` (hel) or `<node>_simul_bpg.tfvars` (Marvin). |

The manager VM name is `<name_prefix>-platform|project-<version>-<cluster_node>`, cut to 63 characters. Setup waits for cloud-init on the manager and on each peer. Only the manager VM gets the workspace and NVIDIA setup. `peer_ips` needs a `provision_infra_version` whose Terraform module has the `peers_ip_addresses` output (the default `2.2.0-3` has it).

Credentials and versions (`proxmox_*`, `aws_*`, `registry_*`, `github_api_*`, `fleet_password`, `ssh_private_key`, `provision_infra_*_version`, `ci_integration_scripts_version`) are documented in each `action.yml`.

```yaml
- uses: MOV-AI/.github/.github/actions/infrastructure-setup@v3
  id: infra
  with:
    cluster_node: hel0
    platform_version: ${{ inputs.platform_version }}
    name_prefix: fleet
    fleet_peer_nr: '2'
    enable_traefik_exposure: 'true'
    # ...credentials...

# ...tests using steps.infra.outputs.ssh_connect_string...

- uses: MOV-AI/.github/.github/actions/infrastructure-teardown@v3
  if: always()
  with:
    cluster_node: hel0
    platform_version: ${{ inputs.platform_version }}
    name_prefix: fleet
    fleet_peer_nr: '2'
    enable_traefik_exposure: 'true'
    # ...credentials...
```

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
