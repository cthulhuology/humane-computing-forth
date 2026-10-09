/* Test-only foreign library: the runtime and linker implementation remain Forth. */
#include <stdint.h>
#include <unistd.h>

static long initialized;
static _Thread_local long local_value = 37;
__attribute__((constructor)) static void initialize(void) { initialized = 100; }
__attribute__((destructor)) static void finalize(void) {
    (void)write(1, "library closed\n", 15);
}
long ffi_zero(void) { return initialized; }
long ffi_one(long a) { return a + initialized; }
long ffi_two(long a, long b) { return a + b * 10; }
long ffi_three(long a, long b, long c) { return a + b * 10 + c * 100; }
long ffi_four(long a, long b, long c, long d) { return ffi_three(a,b,c) + d * 1000; }
long ffi_five(long a, long b, long c, long d, long e) { return ffi_four(a,b,c,d) + e * 10000; }
long ffi_six(long a, long b, long c, long d, long e, long f) { return ffi_five(a,b,c,d,e) + f * 100000; }
long ffi_tls(void) { return local_value++; }
long ffi_pointer(long *p) { return ++*p; }
/* Check the ABI at the exact entry, before a compiler-generated prologue. */
__attribute__((naked)) uintptr_t ffi_alignment(void) {
    __asm__("mov %rsp, %rax; and $15, %rax; ret");
}

#include <stdarg.h>
struct pair { long a, b; };
struct mixed { double d; long i; };
struct vector3 { float x, y, z; };
struct large { long a, b, c; };
struct doubles { double a, b; };
struct odd { unsigned char a, b, c; };
long ffi_seven(long a,long b,long c,long d,long e,long f,long g) { return ffi_six(a,b,c,d,e,f) + g*1000000; }
struct pair ffi_pair(struct pair x) { x.a += 10; x.b += 20; return x; }
struct mixed ffi_mixed(struct mixed x) { x.d += 1.0; x.i += 2; return x; }
struct vector3 ffi_vector3(struct vector3 x) { x.x += 1; x.y += 2; x.z += 3; return x; }
struct large ffi_large(struct large x) { x.a++; x.b += 2; x.c += 3; return x; }
long ffi_rollback(long a,long b,long c,long d,long e,struct pair x,long f) { return a+b+c+d+e+x.a+x.b+f; }
double ffi_sse_rollback(double a,double b,double c,double d,double e,double f,double g,struct doubles x,double h) { return a+b+c+d+e+f+g+x.a+x.b+h; }
double ffi_nine(double a,double b,double c,double d,double e,double f,double g,double h,double i) { return a+b+c+d+e+f+g+h+i; }
double ffi_var(long n, double fixed, ...) {
    va_list ap; va_start(ap, fixed);
    double d = va_arg(ap, double); long i = va_arg(ap, long);
    va_end(ap); return n + fixed + d + i;
}
struct odd ffi_odd(struct odd x) { x.a++; x.b++; x.c++; return x; }
float ffi_float(float f) { return f + 1.0f; }
int ffi_negative(void) { return -23; }
void ffi_void(long *p) { *p = 99; }
