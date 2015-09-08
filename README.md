## nanobox-docker-build

This repo contains the files necessary to create a docker 'build' image for [Nanobox](http://nanobox.io) consumption.

#### Requirements

* [vagrant](vagrantup.com)
* [dockerhub](hub.docker.com) account

## Overview

The nanobox/build image is split into two separate images:

- nanobox/build-pre
- nanobox/build

The build image is split into two images for the express purpose of development iteration. Since the build environment requires the build tools, which are very large in size compared to other images, the upload process for incremental script changes would be largely incumbered. 

Essentially, the build-pre image includes the build tools, whereas the build image contains the scripts. The build image also includes the build tools since the build image inherits from the build-pre image. 

## Usage

#### Vagrant

Before building docker containers, we must initialize the virtual machine with vagrant:

```bash
vagrant up
```

#### Build

To build the image:

```bash
make build
```

To build the pre image:

```bash
make build-pre
```

#### Publish

To publish the image:

```bash
make publish
```

To publish the pre image:

```bash
make publish-pre
```

To publish the image tagged as alpha:

```bash
make publish stability=alpha
```

#### Combo

To build and publish the image:

```bash
make
```

To build and publish the pre image:

```bash
make pre
```

To build and publish the image tagged as alpha:

```bash
make stability=alpha
```

#### Cleaning

To remove all images from the Vagrant machine:

```bash
make clean
```

## Testing

All changes, experimental or not, should be published using the alpha tag. The alpha image can be tested by using [Nanobox](http://nanobox.io), and adding the following to an application's Boxfile:

```yaml
build:
  stability: alpha
```

## Caveat

#### Authentication

If during a publish, you receive the error:

```bash
unauthorized: access to the requested resource is not authorized
```

Run the following command and follow the login prompt:

```bash
make login
```

Subsequent publishes will use a stored api token.

#### Cleanup

Don't forget to halt the Vagrant machine when you're done:

```bash
vagrant halt
```

## License

Mozilla Public License, version 2.0
