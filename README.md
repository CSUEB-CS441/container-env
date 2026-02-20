# CS CS441: development environment

This repo contains a minimal dev environment setup for CS 441. 

## Getting started

### Detailed setup instructions, refer to our [setup guide](container-setup.md)

```bash
# 1. load pre-built docker image
./run-container setup

# 2. start development environment
./run-container
```

## Advanced setup (for staff)

*Note*: If you are a student, you should not need the instructions
below, unless you need to configure a custom version of the
development environment.  This should not be necessary in most
circumstances.

This repository contains scripts to create and load course container
images.  The default configuration loads a pre-built container image
stored in the course Github organization.  This script can also be
used to build a new container image and update the pre-built image
(eg. for per-semester setup).

This repository is organized as follows:
 - `run-container`:  Main script to download and create the images
 - `docker/`:  Contains scripts to create the container image,
   including
    - `Dockerfile`/`Dockerfile.arm64`:  Dockerfiles for x86-64 and
      ARM64 systems
     - `container-setup-amd64.sh`:  Setup script for x86-64 systems
       (installs packages, etc.)
     - `container-setup-arm64.sh`:  Setup script for ARM64 systems
    - `container-setup-common.sh`:  Setup script for common packages
      (used on both architectures).  Most configuration should happen
      in this script.
	  
### Building a custom container image

To build a custom container image (or, as a staff member, to set up a
new image for each semester), do the following:

1. Make any adjustments necessary to any of the container
   configuration scripts above
   
2. Run the following:

```
$ ./run-container build-image
```

This will build the container environment from the scripts above,
rather than attempting to download it from the course container
repository.  This process will take several minutes.

3. Once the build completes successfully, enter the container
   environment as normal:
   
```
$ ./run-container setup
```

*(Staff only)* Once you are happy with the container image, you must push the image
to the Github package repository so that students can use it. To do
this, see the next section.


### Pushing a container image

To create and push a container image, consult [this
guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
for instructions on how to create a Personal Access Token and use it
to authenticate with Docker.

Once you have successfully logged into docker, you will need to create
and push the image.  This process must actually upload two container
image:  one for x86-64 systems, and one for ARM64 systems.  To build
and push both images, run the following:

```
./run-container build-push-allarch
```

This command uses Docker's buildx setup to create a container image
for both architectures, which will take some time.  If you encounter
problems, see the "Alternate method" below.

When the build completes, check [this
page](https://github.com/CSUEB-CS441/container-env),
which lists the current published images.  You should see recent
updated image versions for the tag `latest` **and** `arm64`, which
corresponds to each architecture.

#### Alternate method for pushing container images

If you are unable to use `build-push-allarch` to push the container
image, try the following instead:

```
$ ./run-container build-image
$ ./run-container push-image  # Push image for THIS ARCHITECTURE ONLY
```

The command `./run-container push-image` pushes a new container image
for **your CPU architecture only**.  Thus, if you have an arm64
system, it will not update the x86-64 image:  you will need to repeat
the process on another system with the different architecture.

After you have pushed both images, you should be able to verify they
have updated correctly, based on the Github Packages link in the
previous section.

## Acknowledgments

This setup is a modified version of the setup used by
[CSCI0300](https://cs.brown.edu/courses/csci0300) and reused with
permission, which is based on [Harvard's CS61](https://cs61.seas.harvard.edu/site/2021/).  
For wireshark, we have used the setup described in [Wireshark Web Container Image](https://github.com/ffeldhaus/docker-wireshark).
