#	%M%(%I%)	%U%	%E%
#
CFLAGS=		-Wall -g
CC=		gcc
#
HH_FILES=	util.h names.h symtab.h types.h check.h three-adresss.h trace.h backpatching.h
CC_FILES=	util.c names.c symtab.c types.c check.c three-adresss.c trace.c backpatching.c
SOURCE=		Makefile $(CC_FILES) $(HH_FILES) tiny.y lex.l mct.sh
#
#
all:		tiny mct
tiny:		tiny.tab.o lex.yy.o $(CC_FILES:%.c=%.o)
		gcc $(CFLAGS) -o $@ $^

lex.yy.c:	lex.l tiny.tab.h
		flex lex.l
#
include		make_dependencies
#
#	Bison options:
#
#	-v	Generate tiny.output showing states of LALR parser
#	-d	Generate tiny.tab.h containing token type definitions
#
tiny.tab.h\
tiny.tab.c:	tiny.y
		bison -v -d $^
#
clean:
		rm -f lex.yy.c tiny.tab.[hc] *.o mct tiny *.jasm *.class tiny.output
#
tar:
		tar cvf tiny.tar $(SOURCE)
source:
		@echo $(SOURCE)
#
####### creating dependencies
#
make_dependencies: lex.yy.c tiny.tab.c $(CC_FILES)
		$(CC) -M $(CC_FILES) lex.yy.c tiny.tab.c >make_dependencies
#
####### sccs rules
#
delta:		
		@echo "Comment: \c"; read inp; \
		for f in $(SOURCE); do\
			[ -f SCCS/p.$$f ] && \
			{ echo "#$$f:"; sccs delget -y"\"$$inp\"" $$f; } done;\
			true
edit:
		@for f in $(SOURCE); do\
			[ ! -f SCCS/p.$$f ] && \
			{ echo "#$$f:"; sccs edit $$f; } done; true
create:
		@for f in $(SOURCE); do\
			[ ! -f SCCS/s.$$f ] && \
			{ echo "#$$f:"; sccs create $$f; } done; rm -f ,*; true


