#!/usr/bin/env bash

#####################################################################
#
# Build Python 2 and ObsPy on Debian Wheezy i386.
#
#####################################################################

function banner {
    echo "---------------------------------------------------"
    echo "| $1"
    echo "---------------------------------------------------"
}


# Set non-interacitve mode
export DEBIAN_FRONTEND=noninteractive


# Package updates & upgrades
banner "Updating packages"
apt-get -q update
banner "Upgrading packages"
apt-get -q -y upgrade


# Install dependencies
banner "Installing build dependencies"
apt-get -q -y install build-essential

# Dependencies to build full Python
apt-get -q -y install libreadline6 libreadline6-dev libsqlite3-dev libbz2-dev libncurses5-dev libgdbm-dev libssl-dev tk8.5-dev libdb5.1-dev

# NumPy & SciPy dependencies
apt-get -q -y install gfortran libblas3 libblas-dev liblapack-dev

# gobject-introspection dependencies
apt-get -q -y install flex bison libglib2.0-dev libcairo2-dev libffi-dev

# PyQt dependencies
apt-get -q -y install qt4-qmake libqt4-dev

# PySide dependencies
apt-get -q -y install cmake

# matplotlib dependencies
#apt-get -q -y install libpng12-dev

# lxml dependencies
apt-get -q -y install libxml2-dev libxslt1-dev

# mlpy dependencies
apt-get -q -y install libgsl0-dev

# psycopg2 dependencies
apt-get -q -y install libpq-dev

# Additional dependencies for ObsPy build
apt-get -q -y install git


# Start the build
banner "Starting Python 2 / ObsPy Environment build"

# wget fails downloading the install script with a GnuTLS error -> curl
apt-get -q -y install curl

su vagrant <<'EOF'
curl -O --sslv3 https://raw.githubusercontent.com/bmorg/sandbox/bash_enhancements/buildbots/install_python.sh
bash install_python.sh
echo "export PATH=~/local/bin:$PATH" >> .profile
EOF

# Install ObsPy (use login shell to make sure .profile is executed)
# XXX merge missing dependencies into buildbot script
banner "Installing ObsPy"
su - vagrant <<'EOF'
pip install suds-jurko future mock
git clone https://github.com/obspy/obspy.git
cd obspy
python setup.py develop -N -U --verbose
EOF


# Set up some minimal shell aliases
cat > /etc/profile.d/shell_aliases.sh<<EOF
alias l='ls -CF'
alias ll='ls -alF'
alias la='ls -A'
alias gst='git status'
alias gco='git checkout'
alias glgp='git log -8 --pretty=format:"%h - %s (%an, %ar)"'
alias ..='cd ..'
EOF


banner "bootstrap.sh done"
