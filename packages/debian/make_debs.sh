#! /bin/bash
# Written by catdotjs <catdotjs@gmail.com> 2024
builddeps=("golang" "dpkg-dev")
arc=$(dpkg --print-architecture)
clipsedir=clipse_$arc

# $1 Name of the package
package_check() {
  if dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -q "install ok installed"; then
    echo "$1 is already installed ($(dpkg-query -W -f='${Version}' $1))."
  else
    echo "$1 is missing! $1 is needed to compile!"
    sudo apt install "$1"
  fi
}

# Get build dependencies
for d in ${builddeps[*]}; do
  package_check $d
done

# Build clipse
cd ../..
go mod tidy
go build -o clipse
echo "This clipse deb is currently only being made for your current architecture($arc) only!"

# Make the folder
cd packages/debian/
mkdir $clipsedir/ $clipsedir/usr $clipsedir/usr/bin
cp DEBIAN $clipsedir -r
echo Architecture: $arc >>$clipsedir/DEBIAN/control
mv ../../clipse $clipsedir/usr/bin
dpkg --build $clipsedir
