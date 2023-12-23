AS = nasm
AFLAGS = -f elf -g -Fdwarf
LN = ld
LFLAGS = -m elf_i386

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = .

SRC_FILES = $(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(SRC_FILES))

PROGRAMS = calc

.PHONY: all
all: setup $(PROGRAMS)

.PHONY: setup
setup:
	mkdir -p $(BIN_DIR) $(OBJ_DIR)

calc: $(OBJ_FILES)
	$(LN) $(LFLAGS) $^ -o $(BIN_DIR)/$@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(AS) $(AFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)/*.o $(addprefix $(BIN_DIR)/,$(PROGRAMS))