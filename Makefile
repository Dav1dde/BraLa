export PROJECT_NAME     = BraLa
export AUTHOR           = David Herberth
export DESCRIPTION      = A Minecraft SMP Client written in D
export VERSION          =
export LICENSE          = 

DCFLAGS_IMPORT      = -Ibrala/ `pkg-config --libs --cflags gl3n glamour` -Isrc/d/
DCFLAGS_LINK        = $(LDCFLAGS) $(LINKERFLAG)-lDerelictGL3 $(LINKERFLAG)-lDerelictGLFW3 $(LINKERFLAG)-lDerelictIL $(LINKERFLAG)-lDerelictUtil

ADDITIONAL_FLAGS = -version=Derelict3 -version=gl3n -version=stb -debug -unittest -g -gc

include command.make

OBJDIRS		     = $(DBUILD_PATH)$(PATH_SEP)brala $(DBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)d $(CBUILD_PATH)$(PATH_SEP)src$(PATH_SEP)c
DSOURCES             = $(call getSource,brala,d)
DOBJECTS             = $(patsubst %.d,$(DBUILD_PATH)$(PATH_SEP)%.o,   $(DSOURCES))

CSOURCES             = $(call getSource,src$(PATH_SEP)c,c) 
COBJECTS             = $(patsubst %.c,$(CBUILD_PATH)$(PATH_SEP)%.o,   $(CSOURCES))



all: brala

.PHONY: clean

brala: buildDir $(COBJECTS) $(DOBJECTS)
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) $(COBJECTS) $(DOBJECTS) $(OUTPUT)bralad

# create object files
$(DBUILD_PATH)$(PATH_SEP)%.o : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@

$(CBUILD_PATH)$(PATH_SEP)%.o : %.c
	gcc -c $< -o $@

buildDir: $(OBJDIRS)

$(OBJDIRS) :
	$(MKDIR) $@

clean:
	$(RM) build/
