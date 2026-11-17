# v2.3

- integration-build-product : Build-Workspace warns when `docker/<distro>/Dockerfile` does not use the `BASE_IMAGE` and `TAG` build args, because the image is then not built on the base selected from the platform (DP-2189)
- integration-build-product : Validate-boostrap-configs fails when a `ros-<distro>-*` entry in `product_config`/`system_config` has a `distro` or `type` that does not match its name, and Build-Workspace fails when the workspace image does not have every `ros-<distro>-*` package of `product_config` at the manifest version, or has another distro's package (DP-2189, DP-2209)
- py-workflow : added support for pre-commit, build, and test on different versions of python (excluding Python 3.8, and other versions)
- service-py-deb-workflow : dedicated workflow for building, packaging and testing movai-service for Debian and RPM Linux distributions
