# Z8000 Standalone Emulator

A standalone Z8000 CPU emulator extracted from MAME, designed for testing and debugging Z8000 code without the full MAME environment.

## Features

- Z8002 (non-segmented) CPU emulation
- Instruction tracing with disassembly
- Memory access tracing
- I/O port tracing with console I/O support
- Separate program/data/stack memory spaces (can be unified)
- Loads raw binary files

## Building

```bash
make              # Debug build (default)
make release      # Optimized build
make run-test     # Build and run test
make clean        # Remove built files
```

Output binary: `build/z8000emu`

Requirements: C++17 compatible compiler (g++ or clang++)

## Usage

```
build/z8000emu [options] <binary-file>

Options:
  -b, --base <addr>    Load address in hex (default: 0x0000)
  -e, --entry <addr>   Override entry point (writes to reset vector)
  -t, --trace          Enable instruction tracing
  -m, --memtrace       Enable memory access tracing
  -i, --iotrace        Enable I/O access tracing
  -c, --cycles <n>     Max cycles to execute (default: unlimited)
  -d, --dump           Dump memory after execution
  -h, --help           Show help
```

## Memory Map (Z8002)

```
Address     Contents
---------   ------------------------------------------
0x0000-01   Reserved
0x0002-03   FCW (Flags/Control Word) after reset
0x0004-05   PC (Program Counter) after reset
0x0006-07   FCW for Extended Instruction trap
0x0008-09   PC for Extended Instruction trap
0x000A-0B   FCW for Privileged Instruction trap
0x000C-0D   PC for Privileged Instruction trap
0x000E-0F   FCW for System Call
0x0010-11   PC for System Call
0x0012-13   FCW for Segment Trap
0x0014-15   PC for Segment Trap
0x0016-17   FCW for NMI
0x0018-19   PC for NMI
0x001A-1B   FCW for Non-Vectored Interrupt
0x001C-1D   PC for Non-Vectored Interrupt
0x001E-1F   FCW for Vectored Interrupt
0x0020-21   PC for Vectored Interrupt
0x0022+     Available for program and data
```

## Binary Format

The binary file should include the reset vector at the beginning:

```
Offset  Size  Contents
------  ----  --------
0x00    2     Reserved (typically 0x0000)
0x02    2     FCW - set to 0x4000 for system mode
0x04    2     PC - entry point address
0x06+   -     Program code and data
```

### FCW (Flags and Control Word) Bits

| Bit | Name | Description |
|-----|------|-------------|
| 15  | SEG  | Segmented mode (Z8001 only) |
| 14  | S/N  | System/Normal mode (1=system, required for HALT) |
| 13  | EPU  | Extended processor unit |
| 12  | VIE  | Vectored interrupt enable |
| 11  | NVIE | Non-vectored interrupt enable |
| 10  | -    | Reserved |
| 9   | -    | Reserved |
| 8   | -    | Reserved |
| 7   | C    | Carry flag |
| 6   | Z    | Zero flag |
| 5   | S    | Sign flag |
| 4   | P/V  | Parity/Overflow flag |
| 3   | DA   | Decimal adjust flag |
| 2   | H    | Half-carry flag |
| 1-0 | -    | Reserved |

## Examples

### Running a binary with embedded reset vector

```bash
build/z8000emu -t program.bin
```

### Running code without reset vector (override entry point)

```bash
build/z8000emu -e 0x100 -t code.bin
```

### Creating a test binary

```bash
# Create binary with reset vector
printf '\x00\x00' > test.bin           # Reserved
printf '\x40\x00' >> test.bin          # FCW = 0x4000 (system mode)
printf '\x00\x06' >> test.bin          # PC = 0x0006 (entry point)
printf '\x21\x01\x12\x34' >> test.bin  # LD R1, #0x1234
printf '\x21\x02\x56\x78' >> test.bin  # LD R2, #0x5678
printf '\x81\x21' >> test.bin          # ADD R1, R2
printf '\x7A\x00' >> test.bin          # HALT

# Run it
build/z8000emu -t test.bin
```

Or use the built-in test target:

```bash
make run-test
```

## Console I/O

The emulator provides console I/O on port 0x0000:
- Writing a byte to port 0 outputs it to stdout
- Reading a byte from port 0 reads from stdin

Use `-i` flag to trace I/O operations.

## File Structure

```
z8000_emu/
├── src/
│   ├── main.cpp          # Command-line interface and loader
│   └── z8000.cpp         # CPU implementation (adapted from MAME)
├── include/
│   ├── emu.h             # MAME compatibility shim
│   ├── memory.h          # Memory and I/O subsystem
│   ├── z8000.h           # CPU class definition
│   ├── z8000cpu.h        # Register and flag definitions
│   ├── z8000dab.h        # DAB instruction lookup table
│   ├── z8000ops.hxx      # Opcode implementations
│   └── z8000tbl.hxx      # Opcode dispatch table
├── tools/
│   ├── 8000dasm.cpp      # Disassembler (from MAME)
│   ├── 8000dasm.h
│   └── makedab.cpp       # DAB table generator
├── build/                # Compiled output (created by make)
├── test/                 # Test binaries and assembly
├── Makefile
└── README.md
```

## Origin

This emulator is based on the Z8000 CPU core from MAME (Multiple Arcade Machine Emulator). The core has been adapted to run standalone without the MAME device framework.

## License

BSD-3-Clause (inherited from MAME)
