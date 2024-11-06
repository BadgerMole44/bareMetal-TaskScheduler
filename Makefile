# Cross Compiler to be used.
CC=arm-none-eabi-gcc

# Machine architecture     				
MACH=cortex-m4						

# Compliler Flags:
# -c: compile to object files without linking.
# -mcpu(): specifies target cpu.
# -mthumb: generate thumb code.
# -mfloat-abi=soft: specify fpu to use software implementation rather than hardware.
# -std: specifies c11 standard with gnu extensions.
# -Wall: turn on all warnings.
# -o0: disable optimizations for debugger.
CFLAGS= -c -mcpu=$(MACH) -mthumb -mfloat-abi=soft -std=gnu11 -Wall -o0

# linker flags:
# -nostdlib: dont include c std lib
# -mfloat-abi=soft: specify fpu to use software implementation rather than hardware.
# use for telenet connection: --spec=nano.specs: spec file from GNU embedded toolchain. link with nano c std lib.
# -Wl: specify that the following arg is a linker arg. This is because arm-none-eabi-gcc is the compiler arg and may not recognize a linker arg.
# -Map=final.map: create a file to analyze final.elf. (linker arg)
LDFLAGS= -mcpu=$(MACH) -mthumb -mfloat-abi=soft --specs=nano.specs -T stm32_ls.ld -Wl,-Map=final.map
#LDFLAGS_SEMI_HOSTING= -mcpu=$(MACH) -mthumb -mfloat-abi=soft --specs=rdimon.specs -T stm32_ls.ld -Wl,-Map=final.map



# all targests: make all will try to resolve dependencies (main.o and led.o) 
all: main.o led.o stm32_startup.o syscalls.o final.elf

#semi: main.o led.o stm32_startup.o final_semi_hosting.elf

# Create the target
# target: main.o (@)
# dependency: main.c (^)
# -o: output file = target
main.o: main.c
	$(CC) $(CFLAGS) -o $@ $^

led.o: led.c
	$(CC) $(CFLAGS) -o $@ $^

stm32_startup.o: stm32_startup.c
	$(CC) $(CFLAGS) -o $@ $^

syscalls.o: syscalls.c
	$(CC) $(CFLAGS) -o $@ $^

final.elf: main.o led.o stm32_startup.o syscalls.o
	$(CC) $(LDFLAGS) -o $@ $^

final_semi_hosting.elf: main.o led.o stm32_startup.o syscalls.o
	$(CC) $(LDFLAGS_SEMI_HOSTING) -o $@ $^

# keep workspace clean
clean:
	rm -rf *.o *.elf *.map

# load to targer OpenOCD command specifying script related to the target board
load:
	openocd -f board/stm32f4discovery.cfg
