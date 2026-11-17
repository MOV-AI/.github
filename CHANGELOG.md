# v2.3

- integration-build-product : Build-Workspace warns when `docker/<distro>/Dockerfile` does not use the `BASE_IMAGE` and `TAG` build args, because the image is then not built on the base selected from the platform (DP-2189)
- py-workflow : added support for pre-commit, build, and test on different versions of python (excluding Python 3.8, and other versions)
- service-py-deb-workflow : dedicated workflow for building, packaging and testing movai-service for Debian and RPM Linux distributions
