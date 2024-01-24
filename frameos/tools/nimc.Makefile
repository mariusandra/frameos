# This Makefile is used for compiling C sources generated by Nim
CC ?= gcc

SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)
TOTAL = $(words $(SOURCES))
EXECUTABLE = frameos
LIBS = -pthread -lm -lm -lrt -ldl
CFLAGS = -w -fmax-errors=3 -pthread -O3 -fno-strict-aliasing -fno-ident -fno-math-errno

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	@echo "Linking frameos"
	@$(CC) -o $(EXECUTABLE) $(OBJECTS) $(LIBS)

clean:
	rm -f *.o $(EXECUTABLE)

pre-build:
	mkdir -p ../cache/obj

$(OBJECTS): pre-build

%.o: %.c
	@md5sum=$$(md5sum $< | awk '{print $1}'); \
	cache_obj=../cache/obj/$$md5sum.c.o; \
	if [ -f "$$cache_obj" ]; then \
		if [ ! -L $@ ]; then \
			ln -s "$$cache_obj" $@; \
		fi; \
	else \
		$(CC) -c $(CFLAGS) $< -o $@; \
		cp $@ "$$cache_obj"; \
	fi; \
	echo "[$$(ls *.o | wc -l)/$(TOTAL)] $$(echo '$<' | sed 's/@s/\//g' | sed 's/@m//g' | sed 's/.*nimble\/pkgs2\/\(.*\)/\1/' | sed 's/.*\/\(nim\/lib\/.*\)/\1/')"

.PHONY: all clean pre-build
