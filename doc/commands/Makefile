
CC=				gcc
CCFLAGS=	-ObjC -Wall -DBUILD_FOR_TEST_APPLICATION

LD=				gcc
LDFLAGS=	-framework Foundation

PROGRAM=	main

SOURCES=	main.m Commands.m Commands_implementation.m Logger.m
OBJECTS=	$(SOURCES:%.m=%.o)

all:	$(PROGRAM)

$(PROGRAM): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(PROGRAM)

.m.o:
	$(CC) $(CCFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(PROGRAM) 

main.o: Commands.h Logger.h
Commands.o: Commands.h Commands_private.h Commands_implementation.h Logger.h
Commands_implementation.o: Commands.h Commands_implementation.h Logger.h
Logger.o: Logger.h
