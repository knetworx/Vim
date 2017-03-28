#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
# MACHOME is the directory in which this script exists
MACHOME="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

lnfiles=(.bashrc .bash_aliases .profile .vim .vimrc)
cpfiles=(.bash_os_env)

function cleanfile {
	if [ -e $file ]; then
		if [ -h $1 ]; then
			echo "Removing symbolic link: $1"
			rm "$1"
		else
			echo "Moving $1 to ${1}.bak"
			mv "$1" "${1}.bak"
		fi
	fi
}

pushd ~
echo "Creating symlinks from machome directory"
for file in ${lnfiles[@]}; do
	cleanfile $file
	echo "ln: ${MACHOME##*/}/$file => $file"
	ln -s "$MACHOME/$file" "$file"
done
echo "Copying files from machome directory"
for file in ${cpfiles[@]}; do
	cleanfile $file
	echo "cp: ${MACHOME##*/}/$file => $file"
	cp "$MACHOME/$file" "$file"
done
popd
#TODO: Can the update --init be used without arguments? Need to try this on an uninitialized box to see if it works...
pushd $MACHOME
echo "Updating/initing vim submodules"
git submodule update --init .vim/bundle/Vundle.vim/
git submodule update --init .vim/bundle/vc.vim/
popd
