# This project requires binutils-2.16.1 built for the m68k-coff target.
#
BLASTEM?=blastem
M68K_AS?=m68k-coff-as
M68K_LD?=m68k-coff-ld
M68K_OBJCOPY?=m68k-coff-objcopy
M68K_EMULATOR?=$(BLASTEM) -D

OBJS= obj/init.S.o obj/main.S.o
BIN = bin/rom.bin
SYM = bin/rom.sym

.PHONY: all clean debug

all: $(BIN) $(SYM)
clean:
	rm -rf cfg/
	rm -rf nvram/
	rm -rf bin/
	rm -rf obj/
debug: $(BIN) $(SYM)
	$(M68K_EMULATOR) bin/rom.bin > /dev/null 2>&1 &
	m68k-coff-gdb bin/rom.sym -ex 'target remote :1234'

obj/rom.bin: $(OBJS) obj
	$(M68K_LD) $(OBJS) -o $@

$(BIN): obj/rom.bin bin
	$(M68K_OBJCOPY) -O binary $< $@
$(SYM): obj/rom.bin bin
	$(M68K_OBJCOPY) --only-keep-debug $< $@

obj:
	mkdir -p obj
bin:
	mkdir -p  bin

obj/%.bin.o: src/%.bin obj
	$(M68K_OBJCOPY) -B m68k -I binary -O coff-m68k $< $@
obj/%.S.o: src/%.S obj
	$(M68K_AS) -g $< -o $@
