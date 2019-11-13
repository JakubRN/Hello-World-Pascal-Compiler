RM=rm -f
CXX=gcc
CXXFLAGS= -g -Wall
LDFLAGS=-lm -lfl
TARGET=komp

SRCS=$(wildcard *.c)
OBJS=$(patsubst %.c, %.o, $(SRCS))
DEPS=$(patsubst %.c, %.d, $(SRCS))

.c.o:
	gcc -c $(CXXFLAGS) $< -o $@

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS) 

$(DEPS): %.d : %.c
	$(CXX) -MM $< > $@

-include $(DEPS)

.SILENT : clean 
.PHONY : clean

clean:
	-$(RM) $(TARGET) $(OBJS) $(DEPS)
   
