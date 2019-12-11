RM=rm -f
CXX=g++
CXXFLAGS= -g -Wall
LDFLAGS=-lm -lfl
TARGET=komp

OBJDIR := obj
DEPDIR := $(OBJDIR)/.deps
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d

UNIQUESRCS= lex.yy.c parser.cpp parser.h
SRCS := $(filter-out $(UNIQUESRCS),$(wildcard *.c))
DEPS=$(patsubst %.c, $(DEPDIR)/%.d, $(SRCS))
OBJS=$(patsubst %.c, $(OBJDIR)/%.o, $(SRCS)) lex.yy.o parser.o

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS) 


COMPILE.c = $(CXX) $(DEPFLAGS) $(CXXFLAGS) -c

$(OBJDIR)/%.o : %.c $(DEPDIR)/%.d | $(DEPDIR) lex.yy.c parser.h
	$(COMPILE.c) $< -o $@


$(DEPDIR): ; @mkdir -p $@

$(DEPS):
include $(wildcard $(DEPS))

lex.yy.o: lex.yy.c global.h parser.h

parser.o: parser.cpp global.h parser.h

lex.yy.c: flexer.l
	lex flexer.l

parser.h parser.cpp: bison_parser.y
		bison --defines=parser.h --output=parser.cpp bison_parser.y

.SILENT : clean
.PHONY : clean
clean:
	-$(RM) $(TARGET) $(OBJS) $(DEPS) $(UNIQUESRCS)
   
