#!/usr/bin/env bash
#
# Copyright (c) 2017 Cason Wang <wweiradio(at)gmail.com> by www.iibold.com
#
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#sudo tar zxvf jdk-8-ea-b36e-linux-arm-hflt-*.tar.gz -C /opt
#sudo update-alternatives --install "/usr/bin/java" "java" "/opt/jdk1.8.0/bin/java" 1
#sudo update-alternatives for other commands if needed (e.g. javac).
#java -version
# http://jdk.java.net/8/
java_url="http://download.java.net/java/jdk8u152/archive/b05/binaries/jdk-8u152-ea-bin-b05-linux-arm32-vfp-hflt-20_jun_2017.tar.gz"
tar_file="jdk-8u152-ea-bin-b05-linux-arm32-vfp-hflt-20_jun_2017.tar.gz"
target_dir="jdk1.8"

RC=$(which java)
if ! [ "${RC}AB" == "AB" ]; then
    exit 0
fi

if ! [ -f ${target_dir} ]; then
    wget $java_url
fi

if ! [ -d ${target_dir} ]; then
    mkdir $target_dir
fi

tar xzvf $tar_file -C $target_dir --strip-components=1

cd $target_dir

bins=$(cd bin;ls)

for item in $bins; do
    echo install $item
    sudo update-alternatives --install "/usr/bin/${item}" "$item" $PWD/bin/${item} 1
done

rm -rf $tar_file
echo 0

