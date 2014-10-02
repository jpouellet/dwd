CFLAGS = -Weverything -Werror -pedantic
LDFLAGS = -framework Cocoa

all: dwd

dwd: dwd.m

.PHONY: clean
clean:
	rm -rf dwd dwd.dSYM
