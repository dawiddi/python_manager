#!/bin/bash

while getopts v:f flag
do
    case "${flag}" in
        v) VERSION="${OPTARG}";;
    esac
done

HOME_DIR=/home/dawid
SYMLINK_DIRECTORY=$HOME_DIR/.venvs/bin

# make sure directories exist
mkdir -p $HOME_DIR/.venvs/builds

MINORVERSION=${VERSION%.*}
BUGFIXVERSION=$(echo $VERSION | rev | cut -d. -f1 | rev)
VERSION_FILE_NAME=python_${VERSION//./-}
INSTALL_DIRECTORY=$HOME_DIR/.venvs/builds/$VERSION_FILE_NAME
DOWNLOAD_DIRECTORY=$HOME_DIR/.venvs/$VERSION_FILE_NAME

INSTALL=true

# check if version already exists
if [ -d "$INSTALL_DIRECTORY" ];
then
  while true; do
    read -p "Version already exists. Do you want to recompile? (yY/nN): " yn
    case $yn in
      [Yy]* ) rm -rf $INSTALL_DIRECTORY; break;;
      [Nn]* ) INSTALL=false; break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
fi

# if we want to compile, go for it
if $INSTALL; then

  # get file and save it as tar.gz
  wget -O $DOWNLOAD_DIRECTORY.tar.gz https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz

  # create directory
  if [ -d "$DOWNLOAD_DIRECTORY" ];
  then
    rm -rf $DOWNLOAD_DIRECTORY
  fi

  mkdir $DOWNLOAD_DIRECTORY

  # unpack
  tar -xzf $DOWNLOAD_DIRECTORY.tar.gz -C $DOWNLOAD_DIRECTORY --strip-components=1 

  cd $DOWNLOAD_DIRECTORY

  # configure
  ./configure --prefix=$INSTALL_DIRECTORY --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi > /dev/null

  # make
  make -j "$(nproc)" > /dev/null

  # make install
  make altinstall > /dev/null

  $INSTALL_DIRECTORY/bin/python$MINORVERSION -m pip install --upgrade pip setuptools wheel

  # remove directory
  rm -rf $DOWNLOAD_DIRECTORY

  # remove tar.gz
  rm $DOWNLOAD_DIRECTORY.tar.gz

fi

# set softlink to current version
while true; do
  read -p "Do you want to use this bugfix version ($BUGFIXVERSION) as main minor version ($MINORVERSION)? (yY/nN): " yn
  case $yn in
    [Yy]* ) rm -rf $SYMLINK_DIRECTORY/python$MINORVERSION; ln -s $INSTALL_DIRECTORY/bin/python$MINORVERSION $SYMLINK_DIRECTORY/python$MINORVERSION; rm -rf $SYMLINK_DIRECTORY/pip$MINORVERSION; ln -s $INSTALL_DIRECTORY/bin/pip$MINORVERSION $SYMLINK_DIRECTORY/pip$MINORVERSION; break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done



