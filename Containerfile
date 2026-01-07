# greatlem0n-os
#
# Build:
#   podman build -t greatlem0n-os:stable .
#
# Inspect (fast - no VM needed):
#   podman run --rm greatlem0n-os:stable rpm -qa | grep <package>
#   podman run --rm greatlem0n-os:stable ls /usr/lib/systemd/system/ | grep <service>
#   podman run --rm -it greatlem0n-os:stable bash
#
# Test (slow - builds VM):
#   just build-qcow2
#   just run-vm-qcow2

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build /build
COPY custom /custom
COPY system_files /system_files

###############################################################################
# PROJECT NAME CONFIGURATION
###############################################################################
# Name: greatlem0n-os
#
# IMPORTANT: Change "Name" above to your desired project name.
# This name should be used consistently throughout the repository in:
#   - Justfile: export image_name := env("IMAGE_NAME", "your-name-here")
#   - README.md: # your-name-here (title)
#   - artifacthub-repo.yml: repositoryID: your-name-here
#   - custom/ujust/README.md: localhost/your-name-here:stable (in bootc switch example)
#
# The project name defined here is the single source of truth for your
# custom image's identity. When changing it, update all references above
# to maintain consistency.
###############################################################################

###############################################################################
# Base Image
###############################################################################
FROM ghcr.io/ublue-os/bluefin:stable@sha256:26efd0df5ad4643b8d37790f2362d5796e594b2bc7ee44c48ed149f8f1bbba62

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest@sha256:71a51c4faf8cec6401b8c99ab319d1e7705a77f2253817710093eb3b436132cd
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable@sha256:23a6ec0dc3a2f887d30eef4a34ac6a14c2c7644b09ddcd0f7a4a6ef09b938a60
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41@sha256:8422f122a1567759c5dd5dcda2007e0ff8c01c1dfd67c4146364196c8e078e4c
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10@sha256:eecf595823c3f85d86912fec95e27899248c5271e4bd9fd23c626d0ebdfec053

### /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build scripts
## the following RUN directive does all the things required to run scripts as recommended.
## Scripts are run in numerical order (10-build.sh, 20-example.sh, etc.)

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
