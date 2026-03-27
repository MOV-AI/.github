<!-- Keep a Changelog: https://keepachangelog.com/en/1.0.0/ -->
# Changelog

All notable changes to this repository will be documented in this file.

## [v3] - 2026-03-27
### Added
- Support for multiple ROS distros (Noetic and Humble) in `ros-workflow.yml` with dynamic Docker image selection based on distro
- New input parameter `test_publish_repo` for `ros-workflow.yml` to specify the repository name for testing builds (defaults to `ppa-testing`)
- Comprehensive documentation for `Build and Pack ROS Packages` workflow in README.md with detailed parameter descriptions and usage examples

### Changed
- Enhanced ros-workflow documentation to include full input/output specifications and workflow stages

### Fixed
- N/A

### Removed
- N/A

---

## [v3] - 2025-08-04
### Added
- Initial version of shared workflows for MOV.AI projects.
- `service-py-deb-workflow`: Build, package, and test movai-service for Debian and RPM.
- `publish-to-nexus`: Composite action to publish artifacts to Nexus (Debian/RPM).

### Changed
- Documentation improvements in README.md.

### Fixed
- N/A

### Removed
- N/A

---
Older changes and details can be found in previous branches or releases.
