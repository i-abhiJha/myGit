# Compiler
CXX = g++

# Locate OpenSSL / zlib. On macOS (Homebrew) these are not on the default
# search path, so query `brew --prefix`. On Linux these stay empty and the
# system headers/libs are found by default.
OPENSSL_PREFIX := $(shell brew --prefix openssl@3 2>/dev/null)
ZLIB_PREFIX    := $(shell brew --prefix zlib 2>/dev/null)

INCS := $(if $(OPENSSL_PREFIX),-I$(OPENSSL_PREFIX)/include) \
        $(if $(ZLIB_PREFIX),-I$(ZLIB_PREFIX)/include) \
        -I/usr/local/include
LIBDIRS := $(if $(OPENSSL_PREFIX),-L$(OPENSSL_PREFIX)/lib) \
           $(if $(ZLIB_PREFIX),-L$(ZLIB_PREFIX)/lib) \
           -L/usr/local/lib

# Compiler flags
CXXFLAGS = -std=c++20 -Wall -Wextra -pedantic $(INCS)
# OpenSSL + zlib libraries
LIBS = $(LIBDIRS) -lssl -lcrypto -lz

# Executable name
TARGET = ./mygit

# Source files
SRCS = main.cpp inputHandler.cpp command.cpp encoder.cpp

# Object files
OBJS = $(SRCS:.cpp=.o)

# Header
HDRS = $(wildcard *.h)

# Default rule
all: $(TARGET)

# Rule to build the executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LIBS)

# Rule to build object files
%.o: %.cpp $(HDRS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean rule
clean:
	rm -f $(OBJS) $(TARGET);
	rm -r ".mygit"

# Installation
install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/bin/

# Phony targets
.PHONY: all clean install
