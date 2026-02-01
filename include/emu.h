// MAME Compatibility Shim for Z8000 Standalone Emulator
// Provides minimal definitions to replace MAME's emu.h

#ifndef EMU_H
#define EMU_H

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>
#include <memory>
#include <functional>

// Basic integer types
using u8  = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;
using s8  = int8_t;
using s16 = int16_t;
using s32 = int32_t;
using s64 = int64_t;

using offs_t = u32;

// Endianness definitions
enum endianness_t {
    ENDIANNESS_LITTLE = 0,
    ENDIANNESS_BIG = 1
};

// Byte swap helpers
inline u16 swapendian_int16(u16 val) {
    return (val >> 8) | (val << 8);
}

inline u32 swapendian_int32(u32 val) {
    return ((val >> 24) & 0xff) | ((val >> 8) & 0xff00) |
           ((val << 8) & 0xff0000) | ((val << 24) & 0xff000000);
}

// Endian-aware byte index macros (for big-endian Z8000)
// These macros handle the mapping between Z8000's big-endian register file
// and the host's memory layout.
//
// The Z8000 register file has:
// - Word registers R0-R15 accessed via RW(n) = W[BYTE4_XOR_BE(n)]
// - Byte registers RH0-RL7 accessed via RB(n) = B[BYTE8_XOR_BE(formula(n))]
// - Long registers RR0,RR2,etc accessed via RL(n) = L[BYTE_XOR_BE(n>>1)]
//
// On little-endian hosts, these XOR patterns ensure:
// - BYTE4_XOR_BE: swaps word pairs so RR0=(R0<<16)|R1 works correctly
// - BYTE8_XOR_BE: compensates so RH3/RL3 access the bytes of R3 (not R2)
// - BYTE_XOR_BE: identity so RL(n) indexes to the correct long register
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    #define BYTE8_XOR_BE(x) (x)
    #define BYTE4_XOR_BE(x) (x)
    #define BYTE_XOR_BE(x)  (x)
#else
    // On little-endian hosts, these values ensure byte/word/long alignment:
    // - BYTE8_XOR_BE(x) = x^3: keeps byte within same long-register pair
    // - BYTE4_XOR_BE(x) = x^1: swaps word pairs for long register byte order
    // - BYTE_XOR_BE(x) = x: identity for long register indexing
    #define BYTE8_XOR_BE(x) ((x) ^ 3)
    #define BYTE4_XOR_BE(x) ((x) ^ 1)
    #define BYTE_XOR_BE(x)  (x)
#endif

// Bit helper
inline int BIT(u32 val, int bit) {
    return (val >> bit) & 1;
}

// Logging macros (can be enabled/disabled)
#ifndef VERBOSE
#define VERBOSE 0
#endif

#define LOG(...)  do { if (VERBOSE) printf(__VA_ARGS__); } while(0)
#define logerror(...) do { fprintf(stderr, __VA_ARGS__); } while(0)

// IRQ line constants
constexpr int CLEAR_LINE = 0;
constexpr int ASSERT_LINE = 1;
constexpr int INPUT_LINE_NMI = 2;

// Address space constants
constexpr int AS_PROGRAM = 0;
constexpr int AS_DATA = 1;
constexpr int AS_IO = 2;
constexpr int AS_OPCODES = 3;

// Device type stubs
#define DECLARE_DEVICE_TYPE(Type, Class)
#define DEFINE_DEVICE_TYPE(Type, Class, ShortName, FullName)

// Forward declarations
class Memory;
class IOPorts;

// Stub for z8000_disassembler::config
namespace z8000_disassembler {
    struct config {
        virtual ~config() = default;
        virtual bool get_segmented_mode() const = 0;
    };
}

// Stub device callback types
template<typename T>
class devcb_read {
public:
    template<int N>
    class array {
    public:
        void resolve_all_safe(T default_val) {}
        T operator[](int index) const { return m_default; }
        T operator()(int param) const { return m_default; }
    private:
        T m_default = 0;
    };
};

class devcb_write_line {
public:
    void resolve_safe() {}
    void operator()(int state) {}
};

using devcb_read16 = devcb_read<u16>;

// Stub for string_format (simple version)
template<typename... Args>
std::string string_format(const char* fmt, Args... args) {
    char buf[256];
    snprintf(buf, sizeof(buf), fmt, args...);
    return std::string(buf);
}

#endif // EMU_H
