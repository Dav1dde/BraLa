export PROJECT_NAME     = BraLa
export AUTHOR           = David Herberth
export DESCRIPTION      = A Minecraft SMP Client written in D
export VERSION          =
export LICENSE          = GPLv3

DCFLAGS_IMPORT      = -Ibrala/ -Isrc/d/glamour -Isrc/d/gl3n/ -Isrc/d/ -Isrc/d/openssl/
DCFLAGS_LINK        = $(LDCFLAGS) $(LINKERFLAG)-lDerelictGL3 $(LINKERFLAG)-lDerelictGLFW3 $(LINKERFLAG)-lDerelictUtil -L-lcurl -L-lssl -L-lcrypto

ifeq ($(DC),ldc2)
	ADDITIONAL_FLAGS = -d-version=Derelict3 -d-version=gl3n -d-version=stb -d-debug -unittest -g -gc -L-export-dynamic
else
	ADDITIONAL_FLAGS = -version=Derelict3 -version=gl3n -version=stb -debug -unittest -g -gc -L-export-dynamic
endif


include command.make

OBJDIRS		     = $(DBUILD_PATH)$(PATH_SEP)brala $(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d $(CBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)c $(CBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)c$(PATH_SEP)nbt
DSOURCES             = $(call getSource,brala,d)
DOBJECTS             = $(patsubst %.d,$(DBUILD_PATH)$(PATH_SEP)%.o,   $(DSOURCES))

DSOURCES_GL3N	     = $(call getSource,src$(PATH_SEP)d$(PATH_SEP)gl3n$(PATH_SEP)gl3n,d)
DOBJECTS_GL3N	     = $(patsubst %.d,$(DBUILD_PATH_GL3N)$(PATH_SEP)%.o,   $(DSOURCES_GL3N))

DSOURCES_GLAMOUR     = $(call getSource,src$(PATH_SEP)d$(PATH_SEP)glamour$(PATH_SEP)glamour,d)
DOBJECTS_GLAMOUR     = $(patsubst %.d,$(DBUILD_PATH_GLAMOUR)$(PATH_SEP)%.o,   $(DSOURCES_GLAMOUR))

CSOURCES             = $(call getSource,src$(PATH_SEP)c,c)
COBJECTS             = $(patsubst %.c,$(CBUILD_PATH)$(PATH_SEP)%.o,   $(CSOURCES))


all: brala

.PHONY: clean

brala: buildDir $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DSOURCES_GLAMOUR)
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) $(COBJECTS) $(DOBJECTS) $(DOBJECTS_GL3N) $(DSOURCES_GLAMOUR) $(OUTPUT)bralad

	
# create object files
$(DBUILD_PATH)$(PATH_SEP)%.o : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GL3N)$(PATH_SEP)%.o : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(DBUILD_PATH_GLAMOUR)$(PATH_SEP)%.o : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@
	
$(CBUILD_PATH)$(PATH_SEP)%.o : %.c
	gcc -c -std=c99 -lz $< -o $@

buildDir: $(OBJDIRS)

$(OBJDIRS) :
	$(MKDIR) $@

clean:
	$(RM) build$(PATH_SEP)brala
	
clean-all:
	$(RM) build