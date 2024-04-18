# CC=gcc
# CC=gcc -fanalyzer
# CC=zig cc 
# CC=clang

CFLAGS:=-g  -Wall -Wextra -pedantic -Iinclude -Ibdwgc/include
STRICT_CFLAGS:= -Werror

BUILD=./build

LAM_OBJDIR=build
LAM_SRCDIR=./src
LAM_INCLUDE=include
LAM_HEADERS=$(wildcard include/*.h)
LAM_SRCS=$(wildcard src/*.c)
LAM_OBJ=$(LAM_SRCS:src/%.c=$(LAM_OBJDIR)/%.o)


FLEX_SRC=$(BUILD)/lex.yy.c
PARSER_DIR=parser
PARSER_INCLUDE=$(PARSER_DIR)/include
FLEX_OBJ=$(BUILD)/lex.yy.o
BISON_SRC=$(BUILD)/parser.tab.c
BISON_OBJ=$(BUILD)/parser.tab.o
FLEXBISON_OBJ=$(FLEX_OBJ) $(BISON_OBJ)
PARSER_UTIL=$(PARSER_DIR)/parser-lam-reader.c 
PARSER_SRCS=$(wildcard $(PARSER_DIR)/*.c)

all: build/filter_ok build/interpreter build/lexer build/parser run-tests

run-tests: $(BUILD)/utests $(BUILD)/itests
	$(BUILD)/utests
	$(BUILD)/itests


$(BUILD)/filter_ok: $(LAM_OBJ)
	$(CC) $(STRICT_CFLAGS) $(CFLAGS) \
		-o $@ parser/filter_ok.c $^ -lreadline

$(BUILD)/interpreter: $(LAM_OBJ)
	$(CC) $(STRICT_CFLAGS) $(CFLAGS) \
		-o $@ parser/interpreter.c $^ -lreadline

$(BUILD)/utests: utests.c $(LAM_OBJ)
	$(CC) $(STRICT_CFLAGS) $(CFLAGS) -Iutest.h  -I$(PARSER_INCLUDE) -o $@ $^ 

$(BUILD)/itests: itests.c $(LAM_OBJ)
	$(CC) $(STRICT_CFLAGS) $(CFLAGS) -Iutest.h -I$(PARSER_INCLUDE) -o $@ $^ 

$(LAM_OBJDIR)/%.o: $(LAM_SRCDIR)/%.c $(LAM_HEADERS)
	$(CC) $(LAMF) $(STRICT_CFLAGS) $(CFLAGS) -c -o $@  $<

$(BUILD)/parser: $(FLEX_OBJ) $(BISON_OBJ) $(PARSER_UTIL) $(LAM_OBJ) $(GCOBJ)
	$(CC) $(CFLAGS) -I$(PARSER_INCLUDE) \
		-o $@ $(PARSER_DIR)/parser.c \
		$^ -lfl -lc -lreadline

$(BUILD)/lexer: $(LAM_OBJ)
	$(CC) $(CFLAGS)  \
		-o $@ $(PARSER_DIR)/lexer.c \
		$^ -lreadline


#$(GCOBJ):
#	$(CC) -c -o $(BUILD)/gc.o bdwgc/extra/gc.c -I bdwgc/include/

$(BUILD)/lex.yy.c: $(PARSER_DIR)/lexer.l $(BUILD)/parser.tab.c 
	flex -o $@ $<

$(BISON_SRC): $(PARSER_DIR)/parser.y
	bison -Werror=all -Wcex -t -d -o $@ $<

$(BISON_OBJ): $(BISON_SRC)
	$(CC) -g -Wall -c -o $@ $^ -I$(LAM_INCLUDE) -I$(PARSER_INCLUDE)

$(FLEX_OBJ): $(FLEX_SRC)
	$(CC) -g -Wall -c -o $@ $^ -I$(LAM_INCLUDE) -I$(PARSER_INCLUDE)


tags: $(LAM_HEADERS) $(LAM_SRCS) $(PARSER_DIR) utests.c itests.c
	ctags -R .

cscope:
	cscope -b -k -R

clean:
	find ./build/ -type f -delete


bison: build/parser.tab.c
bison-no-warnings:
	bison -t -d -o $(BISON_SRC) $(PARSER_DIR)/parser.y


valgrind-t:
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out ./build/interpreter $T

valgrind-var:
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out ./build/interpreter samples/var

valgrind-app:
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out ./build/interpreter samples/app

valgrind-abs:
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out ./build/interpreter samples/abs

valgrind-foo:
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out ./build/interpreter ~/ulci/foo

valgrind-samples:
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out ./build/interpreter ~/ulci/samples
