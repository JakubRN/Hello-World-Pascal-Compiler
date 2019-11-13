RM=rm -f
CXX=gcc
CXXFLAGS= -g -Wall
LDFLAGS=-lm -lfl
TARGET=komp



LEX=$(wildcard *.yy.c)
ifeq ($(LEX), lex.yy.c)
	SRCS=$(wildcard *.c)
else
	SRCS=$(wildcard *.c) lex.yy.c 
endif
OBJS=$(patsubst %.c, %.o, $(SRCS))
DEPS=$(patsubst %.c, %.d, $(SRCS))
#$(info    srcs is $(SRCS))
#$(info    objs is $(OBJS))
#$(info    deps is $(DEPS))
.c.o:
	gcc -c $(CXXFLAGS) $< -o $@

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS) 

$(DEPS): %.d : %.c
	$(CXX) -MM $< > $@

lex.yy.c: flexer.l
	lex flexer.l

-include $(DEPS)

.SILENT : clean $(DEPS)
.PHONY : clean

clean:
	-$(RM) $(TARGET) $(OBJS) $(DEPS) lex.yy.c 
   
