# .github

Shared workflows for the MOV.AI GitHub repositories.

## - name: Publish to project data viewer
This step publishes data to the [project data viewer website](https://personal-7vf0v2cu.outsystemscloud.com/ProjectDataViewer5/). The site is used to visualize which packages are installed in the spawner container in the projects. By default this step is disabled. To enable set the `use_project_data_viewer` parameter to true in the workflow file of your project. If failed the step is skipped.

The credentials to the site is given in the [confluence page](https://movai.atlassian.net/wiki/spaces/MF/pages/2403074053/Project+Data+Viewer).

## - name: Build Packer images
This workflow builds ISO images for CICD usage.
The images are built using the packer tool and rely on a self-hosted runner which should have the following tools installed:
- Packer
- QEMU / KVM / Libvirt
- cloud-init
The images are built and tested but not published to GitHub releases or artifacts, instead the images are stored in the runner's filesystem and deployed to the CICD environment.

The images are built for the following platforms:
- Server and desktop images for Ubuntu 22.04
- GitHub runner for Ubuntu 22.04

## - name: Build Docker images
This workflow builds Docker images for CICD usage. The images are built and tested but not published to GitHub releases or artifacts, instead the images are stored in our private Docker registry and deployed to the CICD environment.

The workflow also supports automatic version management using bump-my-version to enable multi-release line support. When the version input is omitted the workflow reads and manages versions from a .bumpversion.toml file in the target repository.

On deployment it automatically bumps the patch version, commits the change, and pushes it back to the branch. The workflow also adds OCI-compliant docker labels including version, source, and description to all images. Manual version input can still be specified to bypass all automatic version management.

## - name: Build and pack FE packages
This workflow builds and packs the frontend packages for the MOV.AI platform.

## - name: Build and pack Npm components
This workflow builds and packs the npm components for the MOV.AI platform.

## - name: Build and pack Ros packages
This workflow builds and packs the ROS packages for the MOV.AI platform.

## - name: Build and Validate Platform
This workflow builds and validates the MOV.AI platform.

## - name: Build Product Composite
This workflow builds projects of type composite (multiple products/squads in one project repository) running on the MOV.AI platform.

## - name: Build Product
This workflow builds projects running on the MOV.AI platform.

## - name: Install Tests
This workflow run QA install tests for the MOV.AI platform.

## - name: UI Tests
This workflow run UI tests for the MOV.AI platform.
