#!/bin/sh

# assuming git is installed

if [ `uname -o` != "Msys" ] ; then
    echo you are not running msys
    exit 1
fi

# brala <3
if [ -d brala ] ; then
    if [ -d .git ] ; then
        git pull
    else
        cd brala
    fi
else
    git clone git://github.com/Dav1dde/BraLa.git BraLa || exit
    cd BraLa
    git submodule init
    git submodule update
fi

# setup
mingw-get install mingw32-make msys-unzip msys-wget 2> nul

if [ -d tools ] ; then
    rm -rf tools
fi

mkdir tools
cd tools

# dmd/linker stuff
wget ftp://ftp.digitalmars.com/dmc.zip
unzip -o dmc.zip
mv dm/bin/make.exe dm/bin/dmake.exe

wget ftp://ftp.digitalmars.com/bup.zip
unzip -o bup.zip

wget ftp://ftp.digitalmars.com/coffimplib.zip
unzip -o coffimplib.zip
mv coffimplib.exe dm/bin

wget http://www.agner.org/optimize/objconv.zip
unzip -o objconv.zip
mv objconv.exe dm/bin/

PATH=$PATH:`pwd`/dm/bin

# libs

# TODO: Find downloadable OpenSSL dlls
#wget "http://downloads.sourceforge.net/project/gnuwin32/openssl/0.9.8h-1/openssl-0.9.8h-1-lib.zip?&use_mirror=garr" -O openssl.zip
#unzip -o openssl.zip

# downloads complete, now COFF -> OMV and other setups
mkdir lib
cd lib/

#cp C:/WINDOWS/system32/opengl32.dll .
# yay workarounds
#echo "implib /s opengl32.lib opengl32.dll && exit" | cmd
#rm opengl32.lib

if [ -f /c/windows/system32/libssl32.dll ] && [ -f /c/windows/system32/libeay32.dll ] ; then
    openssl="windows/system32/"
else 
    openssl=$(ls /c/ | tr ' ' '\n' | grep -i openssl | head -n 1)
fi

if [ "$openssl" == "" ] ; then
    echo you have to install openssl
    echo http://slproweb.com/products/Win32OpenSSL.html
    exit 1
fi
cp /c/${openssl}/libssl32.dll .
cp /c/${openssl}/libeay32.dll .
echo "implib /s libssl.lib libssl32.dll && exit" | cmd
echo "implib /s libcrypto.lib libeay32.dll && exit" | cmd

objconv -fomf -nu libssl.a
objconv -fomf -nu libcrypto.a

cd ../..

echo "#!/bin/sh" > recompile.sh
echo 'PATH="$PATH:tools/dm/bin"' >> recompile.sh
echo 'make IMPLIB="tools\\dm\\bin\\implib" glfw" >> recompile.sh
echo 'make $* CC=dmc LIB_PREFIX=tools/lib CFLAGS="-Itools/include" brala' >> recompile.sh

echo "#!/bin/sh" > launch.sh
echo 'env "PATH=$PATH:tools/lib:build/glfw/src" ./bralad $*' >> launch.sh

echo "#!/bin/sh" > pack.sh
echo "./recompile.sh" >> pack.sh
echo "rm -r packed 2>nul" >> pack.sh
echo "mkdir packed" >> pack.sh
echo "cp tools/bin/libssl32.dll packed/" >> pack.sh
echo "cp tools/bin/libeay32.dll packed/" >> pack.sh
echo "cp build/glfw/src/glfw3.dll packed/" >> pack.sh
echo "cp bralad packed/" >> pack.sh

echo -e "\n\nI am done. Now go enjoy BraLa. Compile it with ./recompile.sh and launch it with ./launch.sh"
echo -e "\nYou don't like to run ./launch.sh every time? Use ./pack.sh, now double-click packed/bralad :)."
