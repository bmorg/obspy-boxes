#!/usr/bin/env bash

#####################################################################
# Bootstrap file for building the Debian Wheezy Python 3 ObsPy box.
#
# Note: ...
#       ...
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
apt-get -q -y install libreadline6 libreadline6-dev libsqlite3-dev libbz2-dev libncurses5-dev libgdbm-dev liblzma-dev libssl-dev tk8.5-dev

# matplotlib dependencies
apt-get -q -y install libpng12-dev

# SciPy dependencies
apt-get -q -y install libblas3 libblas-dev liblapack-dev

# basemap dependencies
apt-get -q -y install libgeos-3.3.3 libgeos-c1 libgeos-dev

# lxml dependencies
apt-get -q -y install libxml2-dev libxslt1-dev

# Additional dependencies for ObsPy build
apt-get -q -y install git gfortran libgfortran3


# Start the build
banner "Starting Python 3 / ObsPy Environment build"

# wget fails downloading the install script with a GnuTLS error -> curl
apt-get -q -y install curl

su vagrant <<'EOF'
curl -O https://raw.githubusercontent.com/bmorg/sandbox/bash_enhancements/buildbots/install_python3.sh
bash install_python3.sh
echo "export PATH=~/python3/bin:$PATH" >> .profile
EOF

# Install ObsPy (login shell to make sure .profile is executed)
banner "Installing ObsPy"
su - vagrant <<'EOF'
git clone https://github.com/obspy/obspy.git
cd obspy
python3 setup.py develop -N -U --verbose
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
