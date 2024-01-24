# This Makefile is used for compiling C sources generated by Nim
CC ?= gcc

SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)
TOTAL = $(words $(SOURCES))
EXECUTABLE = frameos
LIBS = -L. -pthread -pthread -lm -lm -lrt -levdev -ldl -L.
CFLAGS = -w -fmax-errors=3 -pthread -O3 -fno-strict-aliasing -fno-ident -fno-math-errno

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	@echo "Linking frameos"
	@$(CC) -o $(EXECUTABLE) $(OBJECTS) $(LIBS)

clean:
	rm -f *.o $(EXECUTABLE)

%.o: %.c
	@$(CC) -c $(CFLAGS) $< -o $@	
	@echo "[$$(ls *.o | wc -l)/$(TOTAL)] $$(echo '$<' | sed 's/@s/\//g' | sed 's/@m//g' | sed 's/.*nimble\/pkgs2\/\(.*\)/\1/' | sed 's/.*\/\(nim\/lib\/.*\)/\1/')"

.PHONY: all