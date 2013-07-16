export PROJECT_NAME     = BraLa
export AUTHOR           = David Herberth
export DESCRIPTION      = A Minecraft SMP Client written in D
export VERSION          =
export LICENSE          = GPLv3

DCFLAGS_IMPORT      = -Ibrala/ -Isrc/d/derelict3/import -Isrc/d/glamour -Isrc/d/gl3n/ \
			-Isrc/d/ -Isrc/d/openssl/ -Isrc/d/glfw/ -Isrc/d/nbd/ -Isrc/d/glwtf/

include command.make

DCFLAGS_LINK = 	$(LDCFLAGS) $(LINKERFLAG)-lssl $(LINKERFLAG)-lcrypto \
		$(LINKERFLAG)-Lbuild/glfw/src \
		$(addprefix -L,$(shell env PKG_CONFIG_PATH=./build/glfw/src pkg-config --static --libs glfw3))

VERSIONS = Derelict3 gl3n glamour stb BraLa

ifeq ($(DC),ldc2)
	ADDITIONAL_FLAGS = $(addprefix -d-version=,$(VERSIONS)) -d-debug -unittest -g -gc
else ifeq ($(DC),gdc)
	ADDITIONAL_FLAGS = $(addprefix -fversion=,$(VERSIONS)) -fdebug -g
else
	ADDITIONAL_FLAGS = $(addprefix -version=,$(VERSIONS)) -debug -unittest -g -gc
endif


ifeq ($(OS),"Linux")
	ifeq ($(MODEL),32)
		DCFLAGS_LINK      += $(LINKERFLAG)"-rpath=\$$ORIGIN/../lib/linux32/" $(LINKERFLAG)-Llib/linux32/
	else
		DCFLAGS_LINK      += $(LINKERFLAG)"-rpath=\$$ORIGIN/../lib/linux64/" $(LINKERFLAG)-Llib/linux64/
	endif
else ifeq ($(OS),"Darwin")
	DCFLAGS_LINK      += $(LINKERFLAG)-Llib/osx/
endif


DERELICT_DIR = src$(PATH_SEP)d$(PATH_SEP)derelict3$(PATH_SEP)import$(PATH_SEP)derelict

OBJDIRS		     = $(DBUILD_PATH)$(PATH_SEP)brala \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)arsd \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)derelict3 \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)gl3n \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)glamour \
			$(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d$(PATH_SEP)openssl \
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

DSOURCES_OTHER	     = $(call getSource,src$(PATH_SEP)d$(PATH_SEP)arsd,d) $(call getSource,src$(PATH_SEP)d$(PATH_SEP)etc,d) \
			src$(PATH_SEP)d$(PATH_SEP)nbd$(PATH_SEP)nbt.d $(call getSource,src$(PATH_SEP)d$(PATH_SEP)glwtf,d)
DOBJECTS_OTHER       = $(patsubst %.d,$(DBUILD_PATH_OTHER)$(PATH_SEP)%$(EXT),   $(DSOURCES_OTHER))

CSOURCES             = src$(PATH_SEP)c$(PATH_SEP)stb_image.c src$(PATH_SEP)c$(PATH_SEP)stb_image_write.c
COBJECTS             = $(patsubst %.c,$(CBUILD_PATH)$(PATH_SEP)%$(EXT),   $(CSOURCES))

DC_UPPER	= `echo $(DC) | tr a-z A-Z`
CC_UPPER	= `echo $(CC) | tr a-z A-Z`


all: brala
#all: brala

.PHONY: clean

brala: buildDir glfw $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DOBJECTS_DERELICT) $(DOBJECTS_GLAMOUR) $(DOBJECTS_OTHER)
	@echo "    LD     bin$(PATH_SEP)bralad"
	@$(DC) $(DCFLAGS_LINK) $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DOBJECTS_GLAMOUR) $(DOBJECTS_DERELICT) \
	$(DOBJECTS_OTHER) $(DCFLAGS) $(OUTPUT)bin$(PATH_SEP)bralad

glfw:
	@$(MKDIR) $(CBUILD_PATH)$(PATH_SEP)glfw
	@echo "    CMAKE  src/c/glfw/*"
	@cd $(CBUILD_PATH)$(PATH_SEP)glfw && \
	cmake -DBUILD_SHARED_LIBS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF ..$(PATH_SEP)..$(PATH_SEP)src$(PATH_SEP)c$(PATH_SEP)glfw 2>&1 >/dev/null
	@cd $(CBUILD_PATH)$(PATH_SEP)glfw && $(MAKE) --silent $(MFLAGS) >/dev/null


# create object files
$(DBUILD_PATH)$(PATH_SEP)%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GL3N)$(PATH_SEP)%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_DERELICT)$(PATH_SEP)%$(EXT): %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GLAMOUR)$(PATH_SEP)%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_OTHER)$(PATH_SEP)%$(EXT) : %.d
	@echo "    $(DC_UPPER)    $<"
	@$(DC) $(DCFLAGS) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(CBUILD_PATH)$(PATH_SEP)%$(EXT) : %.c
	@echo "    $(CC_UPPER)    $<"
	@$(CC) $(CFLAGS) -c $< -o $@

buildDir: $(OBJDIRS)

$(OBJDIRS) :
	@echo "    MKDIR  $@"
	@$(MKDIR) $@

clean:
	@echo "    RM     build$(PATH_SEP)brala"
	@$(RM) build$(PATH_SEP)brala

clean-all:
	@echo "    RM     build/"
	@$(RM) build
