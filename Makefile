ARCH = armv7-a
MCPU = cortex-a8

TARGET = rvpb

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy
OD = arm-none-eabi-objdump

LINKER_SCRIPT = ./navilos.ld
MAP_FILE = build/navilos.map
ASM_FILE = build/navilos.asm

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

VPATH = boot \
		hal/$(TARGET) \
		lib

C_SRCS = $(wildcard boot/*.c)
C_SRCS += $(notdir $(wildcard lib/*c))
C_SRCS += $(notdir $(wildcard hal/$(TARGET)/*c))
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS))

INC_DIRS = -I include		\
		   -I hal			\
		   -I hal/$(TARGET) \
		   -I lib

CFLAGS = -c -g -std=c11 -mthumb-interwork
LDFLAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

navilos = build/navilos.axf
navilos_bin = build/navilos.bin

.PHONY: all clean run debug gdb

all: $(navilos)

clean:
	@rm -fr build
	
run: $(navilos)
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -nographic -audiodev id=none,driver=none 

debug: $(navilos)
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -S -nographic -audiodev id=none,driver=none -gdb tcp::1234,ipv4

gdb:
	gdb-multiarch
	
$(navilos): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(navilos) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFLAGS)
	$(OC) -O binary $(navilos) $(navilos_bin)
	$(OD) -d $(navilos) >> $(ASM_FILE)
	rm build/*.o
	
build/%.os: %.S
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mtune=$(MCPU) $(INC_DIRS) $(CFLAGS) -o $@ $<

build/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mtune=$(MCPU) $(INC_DIRS) $(CFLAGS) -o $@ $<
