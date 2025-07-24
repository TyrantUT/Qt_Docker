# Cross-Compiling Qt 6.9.1 for Raspberry Pi Using Docker

This guide explains how to cross-compile Qt 6.9.1 for Raspberry Pi using Docker. The process involves building a host environment, compiling Qt for the host, and then cross-compiling Qt for the Raspberry Pi. The resulting binaries can be used to develop and deploy Qt applications on the Raspberry Pi 4.

## Prerequisites

- **Docker**: Ensure Docker is installed and running on your system.
- **Raspberry Pi**: Target device for cross-compiled Qt binaries.
- **Host System**: A Linux-based system (Ubuntu recommended) for running Docker.
- **Directory Structure**: Clone or set up a working directory containing the necessary Dockerfiles (`Dockerfile.host` and `Dockerfile.rpi`).

## Directory Setup

Create directories to store the Raspberry Pi Qt Build:
```bash
mkdir -p built
```
- `built/`: Stores the Raspberry Pi cross-compiled Qt 6.9.1 tar.gz archive.

## Step-by-Step Instructions

### 1. Build the Host Docker Image

Build the Docker image for the host environment, which sets up the necessary tools and dependencies for compiling Qt.

```bash
docker build -f Dockerfile -t qt-crosscompile-host:pre-compile-6.9.1 .
```

### 2. Compile Qt 6.9.1 for the Host

Run the host container to compile Qt 6.9.1. This step prepares the host environment for cross-compilation.

```bash
docker run -it qt-crosscompile-host:pre-compile-6.9.1 /usr/local/bin/build_qt6Host.sh
```

### 3. Commit the Host Container to a New Image

After compilation, commit the container to a new image to preserve the compiled host environment.

```bash
# Find the container ID
docker ps -a

# Commit the container (replace {CONTAINER_ID} with the actual ID)
docker commit {CONTAINER_ID} qt-crosscompile-host:host-compile-6.9.1
```

### 4. Cross-Compile Qt 6.9.1 for Raspberry Pi

Run the Raspberry Pi container to perform the cross-compilation. Mount the `build/` directory to store the output tar.gz file.

```bash
docker run -it --mount type=bind,source="$(pwd)/built",target=/built \
  qt-crosscompile-host:host-compile-6.9.1 /usr/local/bin/build_qt6Rpi.sh
```

### 5. Commit Build environment

After compilation, commit the container to a new image to preserve the environment.
```bash
# Find the container ID
docker ps -a

# Commit the container (replace {CONTAINER_ID} with the actual ID)
docker commit {CONTAINER_ID} qt-crosscompile-host:post-compile-6.9.1

# For pre built image
git clone git@github.com:TyrantUT/BrewberryPi_Qt6.git
docker run -it --rm --mount type=bind,source="$(pwd)/BrewberryPi_Qt6,target=/build/BrewberryPi_Qt6" tyrantut/qt-crosscompile:post-compile-6.9.1-clean /bin/bash
mkdir built && cd built
../qt-raspi/bin/qt-cmake ../BrewberryPi_Qt6
cmake --build . --parallel
cmake --install .
cp BrewberryPiApp ../BrewberryPi_Qt6/
exit
```
## Output

- The `built/` directory will contain the cross-compiled Qt 6.9.1 tar.gz archive.
- Use the new qt-crosscompile-host:post-compile-6.9.1 image to compile Qt projects
