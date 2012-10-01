BraLa
=====

[![Flattr this](http://api.flattr.com/button/flattr-badge-large.png)](http://flattr.com/thing/854394/Dav1ddeBraLa-on-GitHub)

BraLa is an opensource minecraft (S)MP Client:

![Brala with default texture pack](https://raw.github.com/wiki/Dav1dde/BraLa/screenshots/brala_02.png)

This screenshot was taken with the original 16x16 minecraft texture. This texture pack does *not* come with BraLa!
If you have minecraft installed, BraLa will try to extract the texture from minecraft
(when started with the `--default-tp=true` argument.

BraLa comes with an awesome 128x128 texture, called [R3D-Craft](http://www.minecraftforum.net/topic/1182714-13112),
made by [UniblueMedia](http://www.youtube.com/user/UniblueMedia).

## Features ##

BraLa is at this state just a minecraft (S)MP viewer, it is able to connect to 1.3 servers
and display the world (only solid blocks) and has no transparency or light.
BraLa also doesn't have any kind of physics (to use BraLa you must set the client into
creative mod or allow to fly).

What BraLa *can* do:
* Connect to 1.3 servers (with encryption)
* Supports the whole 1.3 protocol
* Authenticate with the official login servers
* Read the lastlogin file
* Send "snoop" requests
* Display biome colors, based on rainfall/temperature
* Display all solid blocks (including stairs and half slabs)

Not a whole lot, but a start.


## Getting Started/Linux ##

### Dependencies ###

BraLa brings most of the dependencies as gitsubmodules, but there are still a few things you need:
* A D compiler, if you want to help developing BraLa I recommend you to use DMD or GDC since these allow
you to use the gdb debugger.
* A C compiler (e.g. gcc)
* OpenGL
* [OpenSSL](http://www.openssl.org/)
* [Zlib](http://www.zlib.net/)

### Cloning ###

Since BraLa makes use of git submodules, it's a few commands more to successfully clone BraLa.

```
git clone git://github.com/Dav1dde/BraLa.git
cd BraLa
git submodule init
git submodule update
```

### D compiler ###

Since BraLa is written mostly in D, you need a D2 compiler. BraLa compiles with all major D compilers,
[DMD](http://dlang.org/download.html), [LDC](https://github.com/ldc-developers/ldc) and 
[GDC](https://github.com/D-Programming-GDC/GDC).

#### DMD ####

Building BraLa with DMD is easy:

```
make # builds BraLa, this may take a while, to speed things up you can use the -j switch
./bralad -c -h"localhost" # starts brala
```

#### LDC ####

Building with LDC is nearly the same:

```
make DC=ldc2
```

#### GDC ####

To build with GDC you have to specify `gdc` as D compiler:

```
make DC=gdc
```

## Getting Started/Windows ##

To setup BraLa you need a few things first. I will guide you throught the needed steps.

### Basic Setup ###

Download the latest [MinGW Installer][http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/] and
select the C and C++ compiler together with the `MSYS Basic System`. After installing MinGW/Msys you have to add
`C:\MinGW\bin` to `$PATH` (replace the path according to your installation).

Next step is to get `git`, if you already have git installed, omit this step. I for myself use
[msysgit](http://code.google.com/p/msysgit/) but any git should work. Installing [msysgit] will take quite a while.

Now get the latest **DMD** compiler **.zip** (Important: not the installer, it seems to be broken). Extract it e.g.
to `C:\D` and add `C:\D\dmd2\windows\bin` to `$PATH`.

Download [cmake](http://www.cmake.org/cmake/resources/software.html) and install it.

After cmake, you need OpenSSL dlls `libssl32.dll` and `libeay32.dll` and put them somewhere in `C:\OpenSSL-Win32` or
`C:\OpenSSL-Win64` (the folder really doesn't matter, the script searches for an `OpenSSL*` folder), if you don't have
these DLLs, you can download a setup from:
[http://slproweb.com/products/Win32OpenSSL.html](http://slproweb.com/products/Win32OpenSSL.html).

That's it with the basic setup.

### Compilation/Running ###

Download [setup_brala.sh](https://github.com/Dav1dde/BraLa/blob/master/setup_brala.sh) and run it from any directory
(through the MinGW-Shell), just make sure that no folder named `BraLa` exists. This will clone BraLa into `./BraLa`
and setup a few tools and libraries needed for Windows in `./BraLa/tools/`

It also creates three shell scripts in `./BraLa`:

* `recompile.sh`: launch this if you want to recompile BraLa (e.g. after pulling the latest changes)
* `launch.sh`: this will start BraLa (`./launch.sh -c -hlocalhost`, see section "Running" for commandline arguments)
* `pack.sh`: this will "pack" all .dlls needed for BraLa and the executable itself into the folder `./BraLa/packed`, so
you can start BraLa from the normal `cmd.exe` without adjusting the `$PATH`


## Running ##

BraLa supports a few commandline options:

```
-u, --username              specifies the username, which will be used to auth with the login servers,
                            if this is not possible and the server is in offline mode, it will be used
                            as playername.

-p, --password              the password which is used to authenticate with the login servers, set this
                            to a random value if you don't want to authenticate with the servers

-c, --credentials           minecrafts lastlogin file will be used for authentication and logging in,
                            --username and --password are used as fallback

-h, --host                  the IP/adress of the minecraft server
--port                      the port of the minecraft server, defaults to 25565

--no-snoop                  disables "snooping" (= sending completly anonym information to mojang)
--tesselation-threads       specifies the number of threads used to tessellate the terrain, defaults to 3.
                            More threads: more used memory (each thread needs his own tessellation-buffer),
                            more CPU usage, but faster terrain tessellation.

--default-tp                try to extract the minecraft terrain.png from the installed minecraft.jar
                        
--width                     specifies the width of the window
--height                    specifies the height of the window
```

## License ##

See [COPYING](https://github.com/Dav1dde/BraLa/blob/master/COPYING) for the GNU GENERAL PUBLIC LICENSE v3