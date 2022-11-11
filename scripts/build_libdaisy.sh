#!/bin/bash

mkdir -p Heavy/usr/bin
mkdir -p Heavy/usr/lib
mkdir -p Heavy/usr/utils
mkdir -p Heavy/usr/include

cp -f $(which make) Heavy/usr/bin/make
cp -f ./scripts/Makefile Heavy/usr/utils/daisy_makefile

if [[ "$OSTYPE" == "darwin"* ]]; then
    
# path variable
echo "Installing DaisyToolchain"
SCRIPTPATH=./scripts

# install brew
if ! command -v brew &> /dev/null
then
    echo "Installing Homebrew: Follow onscreen instructions"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#upgrade homebrew
echo "Updating Homebrew"
brew update

echo "Installing packages with Homebrew"
brew install openocd dfu-util
brew install $SCRIPTPATH/gcc-arm-embedded.rb --cask

cp -f $(which arm-none-eabi-gcc) Heavy/usr/bin/arm-none-eabi-gcc
cp -f $(which dfu-util) Heavy/usr/bin/dfu-util
cp -f $(which openocd) Heavy/usr/bin/openocd

else

# https://askubuntu.com/a/1371525
# https://developer.arm.com/downloads/-/gnu-rm

URL=https://developer.arm.com/-/media/Files/downloads/gnu/12.2.mpacbti-bet1/binrel/arm-gnu-toolchain-12.2.mpacbti-bet1-x86_64-arm-none-eabi.tar.xz?rev=bad6fbd075214a34b48ddbf57e741249&hash=F87A67141928852E079463E67E2B7A02

echo "Downloading arm-none-eabi-gcc"
curl -fSL -A "Mozilla/4.0" -o gcc-arm-none-eabi.tar.xz "$URL"

echo "Extracting..."
mkdir tmp
pushd tmp
tar -xf ../gcc-arm-none-eabi.tar
popd
rm gcc-arm-none-eabi.tar

mv tmp/gcc-arm-*/* usr/

fi

cd ./libDaisy/
make
cd ..

cp -rf ./libDaisy ./Heavy/usr/utils/libDaisy