#=============================================================================
# ASM Primitives Lab - Makefile
# 
# Build system for x86-64 assembly examples
# Note: ARM64 files are reference only (require ARM64 toolchain)
#=============================================================================

# Tools
NASM ?= nasm
LD ?= ld
RM ?= rm
MKDIR ?= mkdir

# Compiler flags
NASM_FLAGS := -f elf64 -w+all
LD_FLAGS :=

# Directories
BUILD_DIR := build
SRC_DIR := src

# x86_64 executable files (files with _start entry point)
X86_64_EXECUTABLES := \
	hello_world \
	file_operations \
	stack_frame \
	stack_operations \
	system_v_amd64 \
	microsoft_x64

# x86_64 reference files (not meant to be executed)
X86_64_REFERENCE := \
	syscall_numbers

# All x86_64 files
X86_64_FILES := $(X86_64_EXECUTABLES) $(X86_64_REFERENCE)

# Pattern rule for x86_64 files
$(BUILD_DIR)/%: $(SRC_DIR)/x86_64/syscalls/%.asm
	@echo "Building: $@"
	@$(MKDIR) -p $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) $< -o $@.o
	$(LD) $(LD_FLAGS) $@.o -o $@
	@$(RM) -f $@.o

$(BUILD_DIR)/%: $(SRC_DIR)/x86_64/stack/%.asm
	@echo "Building: $@"
	@$(MKDIR) -p $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) $< -o $@.o
	$(LD) $(LD_FLAGS) $@.o -o $@
	@$(RM) -f $@.o

$(BUILD_DIR)/%: $(SRC_DIR)/x86_64/calling_conventions/%.asm
	@echo "Building: $@"
	@$(MKDIR) -p $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) $< -o $@.o
	$(LD) $(LD_FLAGS) $@.o -o $@
	@$(RM) -f $@.o

# Targets
.PHONY: all x86_64 clean rebuild test help

all: x86_64

x86_64: $(patsubst %,$(BUILD_DIR)/%,$(X86_64_FILES))

clean:
	@echo "Cleaning build directory..."
	@$(RM) -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*

rebuild: clean all

test: x86_64
	@echo "Running tests..."
	@echo ""
	@echo "=== x86_64 Tests ==="
	@for f in $(patsubst %,$(BUILD_DIR)/%,$(X86_64_EXECUTABLES)); do \
		if [ -f "$$f" ]; then \
			echo "Running: $$f"; \
			./$$f || echo "Failed: $$f"; \
			echo ""; \
		fi; \
	done

help:
	@echo "ASM Primitives Lab - Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build all x86_64 examples"
	@echo "  x86_64    - Build all x86_64 examples"
	@echo "  clean     - Remove all build artifacts"
	@echo "  rebuild   - Clean and rebuild everything"
	@echo "  test      - Build and run all tests"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Individual targets:"
	@echo "  make build/hello_world           - Build x86_64 hello world"
	@echo "  make build/stack_frame           - Build x86_64 stack frame demo"
	@echo "  make build/system_v_amd64        - Build x86_64 calling convention demo"
	@echo ""
	@echo "Note:"
	@echo "  ARM64 files in src/arm64/ are reference implementations"
	@echo "  They require an ARM64 toolchain (aarch64-linux-gnu-*)"
	@echo ""
	@echo "Environment variables:"
	@echo "  NASM      - NASM executable (default: nasm)"
	@echo "  LD        - Linker executable (default: ld)"

# Ensure build directory exists
$(BUILD_DIR):
	@$(MKDIR) -p $(BUILD_DIR)
