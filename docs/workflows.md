# Shared Workflows Documentation

Detailed specifications and examples for all shared GitHub Actions workflows in MOV.AI.

## Table of Contents
1. [Build Docker Images](#build-docker-images)
2. [Build and Pack ROS Packages](#build-and-pack-ros-packages)
3. [Quick Reference](#quick-reference)

---

## Build Docker Images

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

---

## Build and Pack ROS Packages

Builds, packages, and publishes ROS packages (Debian distributions) for the MOV.AI platform. Supports both ROS 1 (Noetic) and ROS 2 (Humble) distributions. This workflow handles building with different build modes (debug/release), running tests, and publishing to Nexus repositories.

**Inputs:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `ros_distro` | string | - | **Required.** ROS distribution(s) JSON array. E.g. `["humble"]` or `["noetic"]`, or `["humble", "noetic"]` for future multi-distro builds |
| `deploy` | string | `false` | Whether to deploy/publish artifacts to repositories |
| `release` | string | `false` | Whether to perform a production release (publishes to prod repositories) |
| `install_test` | boolean | `false` | Whether to run package installation tests |
| `run_stack_tests` | boolean | `false` | Whether to run stack-level integration tests |
| `prod_publish_repos` | string | `["ppa-main"]` | JSON array of production repository names to publish releases to |
| `test_publish_repo` | string | `ppa-testing` | Repository name for testing builds (used during development/testing phase) |
| `build_modes` | string | `["release"]` | JSON array of build modes. E.g. `["release"]`, `["debug"]`, or `["debug", "release"]` |
| `MOBROS_VERSION` | string | `2.1.1.2` | Version of Mobros build tool to use |
| `MOBTEST_VERSION` | string | `0.0.6.1` | Version of Mobtest tool to use for test validation |
| `ROS_BUILDTOOLS_TAG` | string | `v2.1.3` | Docker image tag for ROS build tools |
| `FLOW_INITIATOR_TAG` | string | `4.10.1.1` | Docker image tag for Flow Initiator (ROS 1 static analysis) |
| `INSTALL_CONFLICT_HANDLING` | string | `` | Additional packages to pass for handling installation conflicts |
| `handle_submodules_on_deploy` | string | `true` | Whether to recursively update Git submodules during deployment |
| `propagate_to_projects` | boolean | `false` | Whether to propagate the release to dependent projects |
| `run_catkin_tests` | boolean | `true` | Whether to run catkin tests during build (ROS 1 only) |
| `cluster` | string | `mary` | Cluster name for stack tests |
| `debug_component_tests_keep_alive` | boolean | `false` | Keep test environment alive for debugging on failure |
| `component_name` | string | - | Component name for stack tests |
| `vs_product_name` | string | - | Product name for stack tests |
| `vs_product_version_pattern` | string | - | Product version pattern for stack tests |
| `test_repo_name` | string | - | Test repository name |
| `test_version` | string | - | Test version |
| `test_set` | string | - | Test set name for stack tests |

**Required Secrets:**
- `auto_commit_user`: Git username for automatic version bumps
- `auto_commit_mail`: Git email for automatic version bumps
- `auto_commit_pwd`: Git token/password for automatic commits
- `registry_user`: Docker registry username
- `registry_password`: Docker registry password
- `nexus_publisher_user`: Nexus repository username
- `nexus_publisher_password`: Nexus repository password
- `aws_sqs_rosdep_access_key`: AWS access key for rosdep publishing
- `aws_sqs_rosdep_secret_access_key`: AWS secret key for rosdep publishing
- `gh_token`: GitHub token for release creation
- `sonar_token`: SonarQube token for code analysis

**Optional Secrets:**
- `aws_access_key_id`: AWS access key for additional cloud operations
- `aws_secret_access_key`: AWS secret key for additional cloud operations
- `proxmox_ve_sim_username`: Proxmox VE username for simulation environment
- `proxmox_ve_sim_password`: Proxmox VE password for simulation environment
- `ssh_priv_key`: SSH private key for additional deployments
- `slack_token_id`: Slack token for notifications

**Workflow Stages:**

1. **Check-static-analysis-config**: Validates static analysis configuration and determines distro-specific settings
2. **Static-analysis**: Runs pre-commit hooks and linting checks
3. **Build**: Builds packages in specified build modes using appropriate Docker image per distro
4. **Package-Install-Test**: Tests package installation and validates with Mobtest
5. **Package-Stack-Tests**: Runs integration tests (if enabled)
6. **Publish**: Publishes built packages to test repository (when `deploy=true`)
7. **Release**: Publishes packages to production repository (when `release=true`)

**Example Usage:**

```yaml
jobs:
  build-and-pack:
    uses: MOV-AI/.github/.github/workflows/ros-workflow.yml@v3
    with:
      ros_distro: '["humble"]'
      deploy: 'true'
      install_test: true
      build_modes: '["release"]'
      test_publish_repo: 'ppa-testing'
    secrets: inherit
```

---

## Quick Reference

### Common Workflow Patterns

**Single Docker Build:**
```yaml
- uses: MOV-AI/.github/.github/workflows/docker-workflow.yml@v3
  with:
    docker_file: Dockerfile
    docker_image: myapp/myservice
    platforms: linux/amd64,linux/arm64
    deploy: true
```

**ROS Package Build and Test:**
```yaml
- uses: MOV-AI/.github/.github/workflows/ros-workflow.yml@v3
  with:
    ros_distro: '["humble"]'
    install_test: true
    deploy: false
  secrets: inherit
```

**Release to Production:**
```yaml
- uses: MOV-AI/.github/.github/workflows/ros-workflow.yml@v3
  with:
    ros_distro: '["humble"]'
    release: 'true'
    prod_publish_repos: '["ppa-main"]'
  secrets: inherit
```

---

For more information, see the [main README](../README.md) or open a GitHub issue.
