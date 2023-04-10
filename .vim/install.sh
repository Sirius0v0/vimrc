#!/bin/bash

set -e
echo '== 欢迎使用Sirius的Vim安装脚本 =='
echo '== 确保在通畅的GitHub环境下以获得最佳体验 =='

FORCE=${1}

cd "$(dirname $0)"/..
test -d ./.vim || (echo "[ERROR] .vim not found!" && exit 1)
test -f ./.vim/install.sh || (echo "[ERROR] .vim/install.sh not found!" && exit 1)
test -f ./clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz || (echo "[ERROR] clang+llvm not found!" && exit 1)

if [ `id -u` -eq 0 ] && [ "${FORCE}" != "y" ]; then
    echo -n "-- 此脚本无需添加sudo，如需要root权限请输入Y确认（Y/n）"; read -n1 x; echo
    if [ "$x" == "n" ]; then exit 1; fi
fi

echo "-- Installing for user: $USER ($UID)"

get_linux_distro() {
    if grep -Eq "Ubuntu" /etc/*-release 2> /dev/null; then
        echo "Ubuntu"
    elif grep -Eq "Deepin" /etc/*-release 2> /dev/null; then
        echo "Deepin"
    elif grep -Eq "Raspbian" /etc/*-release 2> /dev/null; then
        echo "Raspbian"
    elif grep -Eq "uos" /etc/*-release 2> /dev/null; then
        echo "UOS"
    elif grep -Eq "LinuxMint" /etc/*-release 2> /dev/null; then
        echo "LinuxMint"
    elif grep -Eq "elementary" /etc/*-release 2> /dev/null; then
        echo "elementaryOS"
    elif grep -Eq "Debian" /etc/*-release 2> /dev/null; then
        echo "Debian"
    elif grep -Eq "Kali" /etc/*-release 2> /dev/null; then
        echo "Kali"
    elif grep -Eq "Parrot" /etc/*-release 2> /dev/null; then
        echo "Parrot"
    elif grep -Eq "CentOS" /etc/*-release 2> /dev/null; then
        echo "CentOS"
    elif grep -Eq "fedora" /etc/*-release 2> /dev/null; then
        echo "fedora"
    elif grep -Eq "openSUSE" /etc/*-release 2> /dev/null; then
        echo "openSUSE"
    elif grep -Eq "Arch Linux" /etc/*-release 2> /dev/null; then
        echo "ArchLinux"
    elif grep -Eq "ManjaroLinux" /etc/*-release 2> /dev/null; then
        echo "ManjaroLinux"
    elif grep -Eq "Gentoo" /etc/*-release 2> /dev/null; then
        echo "Gentoo"
    elif grep -Eq "alpine" /etc/*-release 2> /dev/null; then
        echo "Alpine"
    elif [ "x$(uname -s)" == "xDarwin" ]; then
        echo "MacOS"
    else
        echo "Unknown"
    fi
}

backup_vimrc() {
    if [ "z$PWD" != "z$HOME" ]; then
        if [ -f ~/.vimrc ]; then
            echo "-- Backup existing .vimrc to ~/.vimrc.backup.$$"
            mv ~/.vimrc ~/.vimrc.backup.$$
        fi
        if [ -d ~/.vim ]; then
            echo "-- Backup existing .vim to ~/.vim.backup.$$"
            mv ~/.vim ~/.vim.backup.$$
        fi
    fi
}

install_ripgrep_deb() {
    echo '-- Downloading ripgrep.deb from GitHub (please wait)...'
    RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+')
    curl -Lo /tmp/vimrc-$$-ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_${RIPGREP_VERSION}_amd64.deb"
    sudo apt install -y /tmp/vimrc-$$-ripgrep.deb
    rm -rf /tmp/vimrc-$$-ripgrep.deb
}

install_vimrc() {
    if [ "z$PWD" != "z$HOME" ]; then
        echo "-- Installing .vimrc and .vim"
        cp -r .vimrc .vim ~/
    else
        echo "-- Already in home directory, skipping..."
    fi
}

install_ccls_from_source() {
    if which ccls 2> /dev/null && ccls --version; then
        echo '-- ccls already installed, skipping...'
    else
        if ! [ -d .vim/ccls ]; then
            echo '-- Cloning ccls source code from GitHub (please wait)...'
            mkdir -p /tmp/ccls-work.$$
            pushd /tmp/ccls-work.$$
            git clone https://github.com/MaskRay/ccls.git --depth=1 --recursive
            popd
            mv /tmp/ccls-work.$$/ccls .vim/
        fi
        cd .vim/ccls
        rm -rf /tmp/ccls-build.$$
        rm -rf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
        if [ ! -f clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz ]; then
            cp ../../clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz .
        fi
        tar xf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz

        echo '-- Building ccls from source...'
	    cmake -H. -B /tmp/ccls-build.$$ -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$PWD/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
        cmake --build /tmp/ccls-build.$$ --config Release --parallel `grep -c ^processor /proc/cpuinfo || echo 1`
        sudo cmake --build /tmp/ccls-build.$$ --config Release --target install
        echo '-- Installed ccls successfully'
        rm -rf /tmp/ccls-build.$$
        rm -rf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
        cd ../..
    fi
}

install_coc_plugins() {
    bash <<EOF
set -e
pushd ~/
vim -c "PlugInstall"

echo '-- coc plugins installed successfully'

popd
EOF
}

update_vim() {
    ver=`vim --version | grep 'IMproved' | grep -oE "d .*\(" | grep -oE "[^d ].*[^\(]"` 
    if [ `echo "$ver <= 8.1" | bc` -eq 1 ]; then
        echo '-- Upgrading Vim Version...'
        sudo add-apt-repository ppa:jonathonf/vim
        sudo apt-get update
        sudo apt-get install -y vim
    fi
}

install_node() {
    if ! node --version; then
        curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
        sudo apt-get update
        sudo apt-get install -y nodejs
    fi
}

install_apt() {
    update_vim
    sudo apt-get install -y zlib1g zlib1g-dev libtinfo-dev
    sudo apt-get install -y curl
    sudo apt-get install -y gdb
    # Ubuntu 18.04 doesn't have the ripgrep package...
    sudo apt-get install -y ripgrep || install_ripgrep_deb
    sudo apt-get install -y ccls || install_ccls_from_source
    install_node
    install_vimrc
    install_coc_plugins
}

do_install() {
    distro=`get_linux_distro`
    echo "-- Linux distro detected: $distro"

    backup_vimrc

    install_apt

    echo "-- Installation complete!"

}

do_install
