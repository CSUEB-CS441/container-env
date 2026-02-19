#!/bin/bash

set -eu

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
target_user="${1:-cs441-user}"

CI_UID=1001
CI_GID=1001

# set up default locale
export LANG=en_US.UTF-8

# set up libraries
apt-get -y install\
 libreadline-dev\
 locales\
 wamerican\
 libssl-dev

# set up default locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

# install programs used for system exploration
apt-get -y install\
 blktrace\
 linux-tools-generic\
 strace\
 tcpdump\
 htop

apt-get install -y python3 \
	python3-pip \
	python3-dev \
	python3-setuptools \
	python3-venv

# set up default locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

# install interactive programs (emacs, vim, nano, man, sudo, etc.)
apt-get -y install\
 bc\
 curl\
 dc\
 git\
 git-doc\
 man\
 micro\
 nano\
 psmisc\
 sudo\
 wget\
 screen\
 tmux\
 emacs-nox\
 vim\
 jq \
 file

# install programs used for networking
apt-get -y install\
 dnsutils\
 inetutils-ping\
 iproute2\
 net-tools\
 netcat-openbsd\
 telnet\
 time\
 pv\
 traceroute\
 iperf3\
 whois

# install extra programs for assignments
apt-get -y install \
	python3-scapy \
	python3-pexpect \
	python3-requests

apt-get -y install \
	golang-goprotobuf-dev golang-google-protobuf-dev


echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections

# Rust
export RUSTUP_HOME=/opt/rust
export CARGO_HOME=/opt/rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -E sh -s -- -y

# ###### Graphical setup ######
# Install wireshark and xterm (as a graphical demo)
apt-get -y install xterm wireshark tshark

# Install xpra (used for backup display method if X11 forwarding doesn't work)
UBUNTU_VERSION=$(cat /etc/os-release | grep UBUNTU_CODENAME | sed 's/UBUNTU_CODENAME=//') && \
    curl http://xpra.org/gpg.asc | apt-key add - && \
    echo "deb http://xpra.org/ $UBUNTU_VERSION main" >> /etc/apt/sources.list.d/xpra.list
    apt-get update && \
    apt-get install -y --no-install-recommends xpra xpra-html5 xpra-x11

# #############################

# remove unneeded .deb files
rm -r /var/lib/apt/lists/*

# Set up the container user
if [[ $target_user == "cs441-user" ]]; then
    userdel ubuntu || true
    groupdel ubuntu || true
    useradd -m -s /bin/bash $target_user

    # Also add a runner user
    groupadd -g ${CI_GID} runner
    useradd -s /bin/bash -u ${CI_UID} -g ${CI_GID} -m runner
else
    # If using the host's user, don't create one--podman will do this
    # automatically.  However, the default shell will be wrong, so set
    # a profile rule to update this
    chmod +x /etc/profile.d/20-fix-default-shell.sh # Copied in Podmanfile
fi


# set up passwordless sudo for user cs441-user
echo "cs441-user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/cs441-init

if [[ $target_user == "cs300-user" ]]; then
    echo "runner ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/cs300-init
fi

# Add user to the wireshark group
#groupadd wireshark
usermod -a -G wireshark cs441-user
usermod -a -G wireshark runner

# create binary reporting version of dockerfile
(echo '#\!/bin/sh'; echo 'echo 1') > /usr/bin/cs441-docker-version
chmod ugo+rx,u+w,go-w /usr/bin/cs441-docker-version

rm -f /root/.bash_logout
