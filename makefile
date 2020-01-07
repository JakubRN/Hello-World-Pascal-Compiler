RM=rm -f
CXX=g++
CXXFLAGS= -std=c++1z -g -Wall 
LDFLAGS=-lm -lfl
TARGET=komp

OBJDIR := obj
DEPDIR := $(OBJDIR)/.deps
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d


UNIQUESRCS= flexer.cpp parser.cpp parser.h
SRCS := $(filter-out $(UNIQUESRCS),$(wildcard *.cpp))
DEPS=$(patsubst %.cpp, $(DEPDIR)/%.d, $(SRCS))
OBJS=$(patsubst %.cpp, $(OBJDIR)/%.o, $(SRCS))  $(OBJDIR)/flexer.o  $(OBJDIR)/parser.o

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS) 


COMPILE.c = $(CXX) $(DEPFLAGS) $(CXXFLAGS) -c

$(OBJDIR)/%.o : %.cpp $(DEPDIR)/%.d parser.h | $(DEPDIR) 
	$(COMPILE.c) $< -o $@


$(DEPDIR): ; @mkdir -p $@

$(DEPS):
include $(wildcard $(DEPS))

$(OBJDIR)/flexer.o: flexer.cpp global.h parser.h
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(OBJDIR)/parser.o: parser.cpp global.h parser.h
	$(CXX) -c $(CXXFLAGS) $< -o $@

flexer.cpp: flexer.l
	lex -o flexer.cpp flexer.l

parser.h parser.cpp: bison_parser.y
		bison --defines=parser.h --output=parser.cpp bison_parser.y

.SILENT : clean
.PHONY : clean
clean:
	-$(RM) $(TARGET) $(OBJS) $(DEPS) $(UNIQUESRCS)
   
