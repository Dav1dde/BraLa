export PROJECT_NAME     = BraLaS
export AUTHOR           = David Herberth
export DESCRIPTION      = A Minecraft SMP Client written in D
export VERSION          =
export LICENSE          = 
export ROOT_SOURCE_DIR  = brala/

DCFLAGS_IMPORT      = -Ibrala/ `pkg-config --libs --cflags gl3n glamour`
DCFLAGS_LINK        = $(LDCFLAGS) $(LINKERFLAG)-lDerelictGL3 $(LINKERFLAG)-lDerelictGLFW3 $(LINKERFLAG)-lDerelictIL $(LINKERFLAG)-lDerelictUtil

ADDITIONAL_FLAGS = -version=Derelict3 -version=gl3n -debug -unittest -g -gc

include command.make

SOURCES             = $(getSource) 
OBJECTS             = $(patsubst %.d,$(BUILD_PATH)$(PATH_SEP)%.o,    $(SOURCES))

all: brala

.PHONY: clean

brala: $(OBJECTS)
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) $(OBJECTS) $(OUTPUT)bralad
	
# create object files
$(BUILD_PATH)$(PATH_SEP)%.o : %.d
	$(DC) $(DCFLAGS) $(DCFLAGS_LINK) $(DCFLAGS_IMPORT) $(ADDITIONAL_FLAGS) -c $< $(OUTPUT)$@
	
clean:
	$(RM) build/
	$(RM) *.o