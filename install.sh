#!/bin/bash

echo 'The "~/bin/prjsetup.sh" and "~/.vim" will be removed.'
read -p "Are you sure to setup environment for $USER(yes/no):" confirmr

if [ "$confirmr" != "yes" -a "$confirmr" != "y" -a "$confirmr" != "Y" -a "$confirmr" != "YES" ]; then
    echo "The install is canceled."
    exit 0
fi

#Clear old data
sudo rm -rf ~/bin/prjsetup.sh
sudo rm -rf ~/.vim

#Check distribution version
osv=Unknown
uname -a|grep Ubuntu
if [ "$?"x = "0"x ]; then
	osv="Ubuntu"
fi

uname -a|grep CentOS
if [ "$?"x = "0"x ]; then
	osv="CentOS"
fi

uname -a|grep Cygwin
if [ "$?"x = "0"x ]; then
	osv="Cygwin"
fi

# Preinstall app for different os
if [ "$osv"x = "Ubuntu"x ]; then
    sudo apt-get install -y exuberant-ctags cscope gkermit vim screen
fi

if [ "$osv"x = "CentOS"x ]; then
    sudo yum install -y ctags cscope vim screen minicom
fi

#Config the app
mkdir -p ~/bin
cp -r bin/* ~/bin/

if [ "$osv"x = "Cygwin"x ]; then
	vimcfgpath="/cygdrive/c/Program Files (x86)/Vim"
	sudo cp -r vim/* "$vimcfgpath/"
else
	pushd ~ >/dev/null
	vimcfgpath=`pwd`
	popd >/dev/null
	vimcfgpath="$vimcfgpath/.vim"
	#mkdir -p $vimcfgpath
	cp -r vim "$vimcfgpath"
	cp kermrc ~/.kermrc
	
	sudo chown -R $USER: "$vimcfgpath"
fi

sudo chown -R $USER: ~/bin

searchr=`grep 'export PATH=\$PATH:~/bin' ~/.bashrc`
if [ "$searchr" = "" ]; then
    echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
fi

if [ "$osv"x != "Cygwin"x ]; then
	searchr=`grep 'caption always' /etc/screenrc`
	if [ "$searchr" = "" ]; then
	    sudo sed -i '$acaption always "%{.bW}%-w%{.rW}%n %t%{-}%+w %=%H %Y/%m/%d "' /etc/screenrc
	fi
fi

if [ "$osv"x != "Ubuntu"x ]; then
    sed -i 's/[^"]cs add .\//"cs add .\//g' "$vimcfgpath/vimrc"
fi
sed -i 's/^function! s:handleMiddleMouse()/&\n\treturn/g' "$vimcfgpath/plugin/NERD_tree.vim"

if [ "$osv"x = "Cygwin"x ]; then
	sudo mv "$vimcfgpath/vimrc" "$vimcfgpath/_vimrc"
fi

echo ""
echo "The installation is over!" 
