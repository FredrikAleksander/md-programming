# This project requires binutils-2.16.1 built for the m68k-coff target.
#
BLASTEM?=blastem
M68K_AS?=m68k-coff-as
M68K_LD?=m68k-coff-ld
M68K_OBJCOPY?=m68k-coff-objcopy
M68K_EMULATOR?=$(BLASTEM) -D
EXEC_SUFFIX?=

COMPRESSOR_OBJ=obj/tools/compressor.c.o
COMPRESSOR_BIN=bin/compressor$(EXEC_SUFFIX)

OBJS= obj/init.S.o obj/main.S.o obj/z80code.S.o obj/compression_nemesis.S.o
TOOL_LIB_OBJS=obj/tools/md_compression_nemesis.c.o obj/tools/md_getoption.c.o
TOOL_BIN_OBJS=$(COMPRESSOR_OBJ)
TOOL_OBJS=$(TOOL_LIB_OBJS) $(TOOL_BIN_OBJS)
BIN = bin/rom.bin
TOOLS = $(COMPRESSOR_BIN)
SYM = bin/rom.sym

.PHONY: all clean debug

all: $(BIN) $(SYM) $(TOOLS)
clean:
	rm -rf cfg/
	rm -rf nvram/
	rm -rf bin/
	rm -rf obj/
debug: $(BIN) $(SYM)
	$(M68K_EMULATOR) bin/rom.bin > /dev/null 2>&1 &
	m68k-coff-gdb bin/rom.sym -ex 'shell clear' -ex 'target remote :1234' 

obj/rom.bin: $(OBJS) obj
	$(M68K_LD) $(OBJS) -T src/linker.ld -o $@

$(BIN): obj/rom.bin bin
	$(M68K_OBJCOPY) -O binary $< $@
$(SYM): obj/rom.bin bin
	$(M68K_OBJCOPY) --only-keep-debug $< $@

$(COMPRESSOR_BIN): $(TOOL_LIB_OBJS) $(COMPRESSOR_OBJ)
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(TOOL_LIB_OBJS) $(COMPRESSOR_OBJ)

obj/tools:
	mkdir -p obj/tools

obj:
	mkdir -p obj
bin:
	mkdir -p  bin

obj/tools/%.c.o: tools/%.c obj/tools
	$(CC) -c -o $@ $(CFLAGS) $<
obj/%.bin.o: src/%.bin obj
	$(M68K_OBJCOPY) -B m68k -I binary -O coff-m68k $< $@
obj/%.S.o: src/%.S obj
	$(M68K_AS) -g $< -o $@
