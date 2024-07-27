ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy
OD = arm-none-eabi-objdump

LINKER_SCRIPT = ./navilos.ld
MAP_FILE = build/navilos.map
ASM_FILE = build/navilos.asm

OUTPUT = navilos

INC_DIRS = include

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.o, $(ASM_SRCS))

navilos = build/navilos.axf
navilos_bin = build/navilos.navilos_bin

.PHONY: all clean run debug gdb

all: $(navilos)

clean:
	@rm -fr build

run: $(navilos)
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -nographic 

debug: $(navilos)
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -S -nographic -audiodev id=none,driver=none -gdb tcp::1234,ipv4

gdb:
	gdb-multiarch

$(navilos): $(ASM_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(navilos) -Map=$(MAP_FILE) $(ASM_OBJS)
	$(OD) -d $(navilos) >> $(ASM_FILE)
	$(OC) -O binary $(navilos) $(navilos_bin)

build/%.o: boot/%.S
	mkdir -p $(shell dirname $@)
	$(CC) -flto -ffreestanding -nostdlib  -march=$(ARCH) -mtune=$(MCPU) -I $(INC_DIRS) -g -o $@ $<