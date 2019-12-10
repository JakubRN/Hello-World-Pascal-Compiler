RM=rm -f
CXX=gcc
CXXFLAGS= -g -Wall
LDFLAGS=-lm -lfl
TARGET=komp

UNIQUESRCS= lex.yy.c bison_parser.tab.c bison_parser.tab.h
SRCS := $(filter-out $(UNIQUESRCS),$(wildcard *.c))
DEPS=$(patsubst %.c, %.d, $(SRCS))
OBJS=$(patsubst %.c, %.o, $(SRCS)) lex.yy.o bison_parser.tab.o

.c.o:
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS) 

$(DEPS): %.d : %.c bison_parser.tab.h
	$(CXX) -MM $< > $@
lex.yy.o: lex.yy.c global.h

bison_parser.tab.o: bison_parser.tab.c global.h bison_parser.tab.h

lex.yy.c: flexer.l
	lex flexer.l

bison_parser.tab.h bison_parser.tab.c: bison_parser.y
	bison -d bison_parser.y

-include $(DEPS)

.SILENT : clean
.PHONY : clean

clean:
	-$(RM) $(TARGET) $(OBJS) $(DEPS) $(UNIQUESRCS)
   
