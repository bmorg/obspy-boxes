# Fully Automatic ObsPy Builds with Vagrant

Build a complete [ObsPy](http://obspy.org) stack from source with a single line:

```bash
$ vagrant up
```

This performs all of the following steps:
 - Download a pre-built base box (first run only)
 - Initialize a new virtual machine from the base box
 - Configure the virtual machine
 - Boot the virtual machine
 - Fetch and install all required packages for building Python and ObsPy
 - Build Python and install ObsPy dependencies using the script provided in the ObsPy buildbots ([Python 2](https://github.com/bmorg/sandbox/blob/master/buildbots/install_python.sh), [Python 3](https://github.com/bmorg/sandbox/blob/master/buildbots/install_python3.sh))
 - Build ObsPy

The first four of these steps are performed by [Vagrant](http://www.vagrantup.com/), a software for automatic setup and management of virtual machines. The others are handled by bootstrap scripts contained in the individual folders of this repository.

**Note:** fetching and building the virtual machines takes quite some time (e.g. between x:xx and x:xx on my desktop machine, but YMMV) as well as bandwidth.

## Setup

You will need the following software to use the virtual machines:
 - [VirtualBox](https://www.virtualbox.org/) ([Download](https://www.virtualbox.org/wiki/Downloads))
 - [Vagrant](http://www.vagrantup.com/) ([Download](http://www.vagrantup.com/downloads.html))

Then get a copy of the repository, e.g. by cloning it using Git:

```bash
$ git clone https://github.com/bmorg/obspy-boxes.git
```

## Usage

Each of the contained folders contains configuration for a specific OS/platform/Python combination. Currently these are:
 - Debian Wheezy / i386 / Python 2
 - Debian Wheezy / i386 / Python 3

To start the build process, change into a directory and type:

```bash
$ vagrant up
```

This performs all the steps mentioned above. After the build has finished, you can log in to your new machine and start using it:

```bash
$ vagrant ssh

[...]

vagrant@debian-wheezy-i386-python3-obspy:~$ obspy-runtests

[...]

vagrant@debian-wheezy-i386-python3-obspy:~$ ipython
Python 3.3.5 (default, Apr  9 2014, 18:06:08) 
Type "copyright", "credits" or "license" for more information.

IPython 2.0.0 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.

In [1]: import obspy

In [2]:
```

Once you are done, log out of the machine and shut it down using `vagrant halt`. You can bring the machine with the finished build back up at any time using `vagrant up`.

`vagrant destroy` completely removes an existing machine. (After this you can rebuild the machine from scratch with `vagrant up`.)

For more information, check out the extensive [Vagrant documentation](http://docs.vagrantup.com/v2/networking/private_network.html).


## Improvements

The following can still be improved:
 - Add option to place the cloned ObsPy repository into a shared folder (for easy development).
 - Explore possibility of utilizing multiple CPUs to speed up build.


## Local installation without virtual machine

If you just want to build Python and ObsPy on your local machine without setting up a VM, check out the bootstrap scripts for hints regarding the full dependencies.

Note that the buildbot scripts for Python 2 and Python 3 differ substantially in the way they install some of the dependencies (building from downloaded source vs. installation using pip) and the amount of additional dependencies included (e.g. Qt support, ObsPy documentation dependencies, SeisHub dependencies). This is reflected in the different bootstrap scripts.

