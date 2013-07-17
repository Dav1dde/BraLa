export PROJECT_NAME	= BraLa
export AUTHOR		= David Herberth
export DESCRIPTION	= A Minecraft SMP Client written in D
export VERSION		=
export LICENSE		= GPLv3

DCFLAGS_IMPORT		= -Ibrala/ -Isrc/d/derelict3/import -Isrc/d/glamour -Isrc/d/gl3n/ \
				-Isrc/d/ -Isrc/d/openssl/ -Isrc/d/glfw/ -Isrc/d/nbd/ -Isrc/d/glwtf/

include command.make

DCFLAGS_LINK	= $(LDCFLAGS) $(LINKERFLAG)-lssl $(LINKERFLAG)-lcrypto \
			$(LINKERFLAG)-Lbuild/glfw/src \
			$(addprefix $(LINKERFLAG),$(shell env PKG_CONFIG_PATH=./build/glfw/src pkg-config --static --libs glfw3))

VERSIONS	= Derelict3 gl3n glamour stb BraLa

ifeq ($(DC),ldc2)
	ADDITIONAL_FLAGS = $(addprefix -d-version=,$(VERSIONS)) -d-debug -unittest -g -gc
else ifeq ($(DC),gdc)
	ADDITIONAL_FLAGS = $(addprefix -fversion=,$(VERSIONS)) -fdebug -g
else
	ADDITIONAL_FLAGS = $(addprefix -version=,$(VERSIONS)) -debug -unittest -g -gc
endif


OBJDIRS		= $(DBUILD_PATH)/brala \
			$(DBUILD_PATH)/src/d/arsd \
			$(DBUILD_PATH)/src/d/derelict3 \
			$(DBUILD_PATH)/src/d/etc \
			$(DBUILD_PATH)/src/d/gl3n \
			$(DBUILD_PATH)/src/d/glamour \
			$(DBUILD_PATH)/src/d/glfw \
			$(DBUILD_PATH)/src/d/glwtf \
			$(DBUILD_PATH)/src/d/minilib \
			$(DBUILD_PATH)/src/d/nbd \
			$(DBUILD_PATH)/src/d/openssl \
			$(CBUILD_PATH)/src/c \
			bin \

DSOURCES	= $(call getSource,brala,d)
DOBJECTS	= $(patsubst %.d,$(DBUILD_PATH)/%$(EXT),   $(DSOURCES))

DSOURCES_GL3N	= $(call getSource,src/d/gl3n/gl3n,d)
DOBJECTS_GL3N	= $(patsubst %.d,$(DBUILD_PATH_GL3N)/%$(EXT),   $(DSOURCES_GL3N))

DERELICT_DIR	= src/d/derelict3/import/derelict
DSOURCES_DERELICT	= $(call getSource,$(DERELICT_DIR)/opengl3,d) $(call getSource,$(DERELICT_DIR)/util,d)
DOBJECTS_DERELICT	= $(patsubst %.d,$(DBUILD_PATH_GLAMOUR)/%$(EXT),   $(DSOURCES_DERELICT))

DSOURCES_GLAMOUR	= $(call getSource,src/d/glamour/glamour,d)
DOBJECTS_GLAMOUR	= $(patsubst %.d,$(DBUILD_PATH_GLAMOUR)/%$(EXT),   $(DSOURCES_GLAMOUR))

DSOURCES_OTHER		= $(call getSource,src/d/arsd,d) $(call getSource,src/d/etc,d) \
				src/d/nbd/nbt.d $(call getSource,src/d/glwtf,d) \
				$(call getSource,src/d/minilib,d)
DOBJECTS_OTHER		= $(patsubst %.d,$(DBUILD_PATH_OTHER)/%$(EXT),   $(DSOURCES_OTHER))

CSOURCES	= src/c/stb_image.c src/c/stb_image_write.c
COBJECTS	= $(patsubst %.c,$(CBUILD_PATH)/%$(EXT),   $(CSOURCES))

DC_UPPER	= `echo $(DC) | tr a-z A-Z`
CC_UPPER	= `echo $(CC) | tr a-z A-Z`


all: brala
#all: brala

.PHONY: clean

brala: buildDir glfw $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DOBJECTS_DERELICT) $(DOBJECTS_GLAMOUR) $(DOBJECTS_OTHER)
	@echo "    LD     bin/bralad"
	@$(DC) $(DCFLAGS_LINK) $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DOBJECTS_GLAMOUR) $(DOBJECTS_DERELICT) \
	$(DOBJECTS_OTHER) $(DCFLAGS) $(OUTPUT)bin/bralad

glfw:
	@$(MKDIR) $(CBUILD_PATH)/glfw
	@echo "    CMAKE  src/c/glfw/*"
	@cd $(CBUILD_PATH)/glfw && \
	cmake -DBUILD_SHARED_LIBS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF ../../src/c/glfw 2>&1 >/dev/null
	@cd $(CBUILD_PATH)/glfw && $(MAKE) --silent $(MFLAGS) >/dev/null


# create object files
$(DBUILD_PATH)/%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GL3N)/%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_DERELICT)/%$(EXT): %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GLAMOUR)/%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_OTHER)/%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(CBUILD_PATH)/%$(EXT) : %.c
	@echo "    $(CC_UPPER)    $<"
	@$(CC) $(CFLAGS) -c $< -o $@

buildDir: $(OBJDIRS)

$(OBJDIRS) :
	@echo "    MKDIR  $@"
	@$(MKDIR) $@

clean:
	@echo "    RM     build/brala"
	@$(RM) build/brala

clean-all:
	@echo "    RM     build/"
	@$(RM) build
