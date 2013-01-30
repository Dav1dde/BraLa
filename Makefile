export PROJECT_NAME     = BraLa
export AUTHOR           = David Herberth
export DESCRIPTION      = A Minecraft SMP Client written in D
export VERSION          =
export LICENSE          = GPLv3

DCFLAGS_IMPORT      = -Ibrala/ -Isrc/d/derelict3/import -Isrc/d/glamour -Isrc/d/gl3n/ \
			-Isrc/d/ -Isrc/d/openssl/ -Isrc/d/glfw/ -Isrc/d/nbd/ -Isrc/d/glwtf/ \
			-Isrc/d/wonne/ -Isrc/d/awesomium/

# libawesomium does only exist as 32bit library, so we have to build a 32 bit executable
ifeq ($(shell uname),Darwin)
	MODEL = 32
endif

include command.make

DCFLAGS_LINK = 	$(LDCFLAGS) $(LINKERFLAG)-lssl $(LINKERFLAG)-lcrypto \
		$(LINKERFLAG)-Lbuild/glfw/src \
		$(addprefix -L,$(shell env PKG_CONFIG_PATH=./build/glfw/src pkg-config --static --libs glfw3))

ifeq ($(DC),ldc2)
	ADDITIONAL_FLAGS = -d-version=Derelict3 -d-version=gl3n -d-version=stb -d-debug -unittest -g -gc
else ifeq ($(DC),gdc)
	ADDITIONAL_FLAGS = -fversion=Derelict3 -fversion=gl3n -fversion=stb -fdebug -g -fdebug-c
else
	ADDITIONAL_FLAGS = -version=Derelict3 -version=gl3n -version=stb -debug -g -gc
endif


ifeq ($(OS),"Linux")
	ifeq ($(MODEL),32)
		LIBAWESOMIUM       = https://www.dropbox.com/sh/95wwklnkdp8em1w/tXk15uf14H/lib/linux32/libawesomium-1.6.5.so?dl=1
		LIBAWESOMIUM_PATH  = lib/linux32/libawesomium-1.6.5.so
		DCFLAGS_LINK      += $(LINKERFLAG)"-rpath=\$$ORIGIN/../lib/linux32/" $(LINKERFLAG)-Llib/linux32/ $(LINKERFLAG)-lawesomium-1.6.5
	else
		LIBAWESOMIUM       = https://www.dropbox.com/sh/95wwklnkdp8em1w/qnjAYrvvX-/lib/linux64/libawesomium-1.6.5.so?dl=1
		LIBAWESOMIUM_PATH  = lib/linux64/libawesomium-1.6.5.so
		DCFLAGS_LINK      += $(LINKERFLAG)"-rpath=\$$ORIGIN/../lib/linux64/" $(LINKERFLAG)-Llib/linux64/ $(LINKERFLAG)-lawesomium-1.6.5
	endif
else ifeq ($(OS),"Darwin")
	POST_BUILD_CMD     = install_name_tool -change '@loader_path/../Frameworks/Awesomium.framework/Versions/A/Awesomium' '@loader_path/../lib/osx/libawesomium.dylib' bin$(PATH_SEP)bralad
	LIBAWESOMIUM       = https://www.dropbox.com/sh/95wwklnkdp8em1w/8mLO7apE4s/lib/osx32/awesomium.dylib?dl=1
	LIBAWESOMIUM_PATH  = lib/osx/libawesomium.dylib
	DCFLAGS_LINK      += $(LINKERFLAG)-Llib/osx/ $(LINKERFLAG)-lawesomium
endif


DERELICT_DIR = src$(PATH_SEP)d$(PATH_SEP)derelict3$(PATH_SEP)import$(PATH_SEP)derelict

OBJDIRS		     = $(DBUILD_PATH)$(PATH_SEP)brala \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)arsd \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)derelict3 \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)gl3n \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)glamour \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)openssl \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)std \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)nbd \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)glwtf \
			$(CBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)c \
			bin \
			lib$(PATH_SEP)osx \
			lib$(PATH_SEP)linux32 \
			lib$(PATH_SEP)linux64 \

DSOURCES             = $(call getSource,brala,d)
DOBJECTS             = $(patsubst %.d,$(DBUILD_PATH)$(PATH_SEP)%$(EXT),   $(DSOURCES))

DSOURCES_GL3N	     = $(call getSource,src$(PATH_SEP)d$(PATH_SEP)gl3n$(PATH_SEP)gl3n,d)
DOBJECTS_GL3N	     = $(patsubst %.d,$(DBUILD_PATH_GL3N)$(PATH_SEP)%$(EXT),   $(DSOURCES_GL3N))

DSOURCES_DERELICT    =  \
		       $(call getSource,$(DERELICT_DIR)$(PATH_SEP)opengl3,d) \
		       $(call getSource,$(DERELICT_DIR)$(PATH_SEP)util,d)
DOBJECTS_DERELICT    = $(patsubst %.d,$(DBUILD_PATH_GLAMOUR)$(PATH_SEP)%$(EXT),   $(DSOURCES_DERELICT))

DSOURCES_GLAMOUR     = $(call getSource,src$(PATH_SEP)d$(PATH_SEP)glamour$(PATH_SEP)glamour,d)
DOBJECTS_GLAMOUR     = $(patsubst %.d,$(DBUILD_PATH_GLAMOUR)$(PATH_SEP)%$(EXT),   $(DSOURCES_GLAMOUR))

DSOURCES_OTHER	     = $(call getSource,src$(PATH_SEP)d$(PATH_SEP)arsd,d) $(call getSource,src$(PATH_SEP)d$(PATH_SEP)std,d) \
			src$(PATH_SEP)d$(PATH_SEP)nbd$(PATH_SEP)nbt.d $(call getSource,src$(PATH_SEP)d$(PATH_SEP)glwtf,d) \
			$(call getSource,src$(PATH_SEP)d$(PATH_SEP)wonne,d) $(call getSource,src$(PATH_SEP)d$(PATH_SEP)awesomium,d)
DOBJECTS_OTHER       = $(patsubst %.d,$(DBUILD_PATH_OTHER)$(PATH_SEP)%$(EXT),   $(DSOURCES_OTHER))

CSOURCES             = src$(PATH_SEP)c$(PATH_SEP)stb_image.c
COBJECTS             = $(patsubst %.c,$(CBUILD_PATH)$(PATH_SEP)%$(EXT),   $(CSOURCES))


all: brala
#all: brala

.PHONY: clean

awesomium:
ifeq ($(OS),"Linux")
	# wget exists with $? of 2 if file already exists
	wget -nc -O $(LIBAWESOMIUM_PATH) $(LIBAWESOMIUM) || true
	# if the symlink already exists, ln fails
	cd $(dir $(LIBAWESOMIUM_PATH)) && ln -s $(notdir $(LIBAWESOMIUM_PATH)) $(notdir $(LIBAWESOMIUM_PATH)).0 || true
	mkdir -p bin/locales
	wget -nc -O "bin/chrome.pak" "https://dl.dropbox.com/sh/95wwklnkdp8em1w/cI4GWU2oyr/lib/linux64/chrome.pak?dl=1" || true
	wget -nc -O "bin/locales/en-US.pak" "https://dl.dropbox.com/sh/95wwklnkdp8em1w/j2rzeo_1cK/lib/linux64/locales/en-US.pak?dl=1" || true
else ifeq ($(OS),"Darwin")
	if ! [ -f $(LIBAWESOMIUM_PATH) ]; then \
		curl -L -o $(LIBAWESOMIUM_PATH) $(LIBAWESOMIUM); \
	fi
endif


brala: buildDir awesomium glfw $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DOBJECTS_DERELICT) $(DOBJECTS_GLAMOUR) $(DOBJECTS_OTHER)
	$(DC) $(DCFLAGS_LINK) $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DOBJECTS_GLAMOUR) $(DOBJECTS_DERELICT) \
	$(DOBJECTS_OTHER) $(DCFLAGS) $(OUTPUT)bin$(PATH_SEP)bralad
	$(POST_BUILD_CMD)

glfw:
	$(MKDIR) $(CBUILD_PATH)$(PATH_SEP)glfw
	cd $(CBUILD_PATH)$(PATH_SEP)glfw && \
	cmake -DBUILD_SHARED_LIBS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF ..$(PATH_SEP)..$(PATH_SEP)src$(PATH_SEP)c$(PATH_SEP)glfw
	cd $(CBUILD_PATH)$(PATH_SEP)glfw && $(MAKE) $(MFLAGS)


# create object files
$(DBUILD_PATH)$(PATH_SEP)%$(EXT) : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GL3N)$(PATH_SEP)%$(EXT) : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_DERELICT)$(PATH_SEP)%$(EXT): %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GLAMOUR)$(PATH_SEP)%$(EXT) : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_OTHER)$(PATH_SEP)%$(EXT) : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(CBUILD_PATH)$(PATH_SEP)%$(EXT) : %.c
	$(CC) $(CFLAGS) -c $< -o $@

buildDir: $(OBJDIRS)

$(OBJDIRS) :
	$(MKDIR) $@

clean:
	$(RM) build$(PATH_SEP)brala

clean-all:
	$(RM) build
