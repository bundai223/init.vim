#!/bin/sh
conf_dir=~/.config/nvim
mkdir -p $conf_dir
dir=$(cd $(dirname $0)/../ && pwd)
ln -s $dir/init.vim $conf_dir/init.vim
ln -s $dir/ginit.vim $conf_dir/ginit.vim
