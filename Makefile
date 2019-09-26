
GCCArchitectures = nocona core2 nehalem corei7 westmere sandybridge corei7-avx ivybridge core-avx-i haswell core-avx2 broadwell skylake skylake-avx512 cannonlake icelake-client icelake-server cascadelake bonnell atom silvermont slm goldmont goldmont-plus tremont knl knm intel x86-64 eden-x2 nano nano-1000 nano-2000 nano-3000 nano-x2 eden-x4 nano-x4 k8 k8-sse3 opteron opteron-sse3 athlon64 athlon64-sse3 athlon-fx amdfam10 barcelona bdver1 bdver2 bdver3 bdver4 znver1 znver2 btver1 btver2 generic native

Name = linpack

GCCFLAGS = -O3 -fexpensive-optimizations -v
CLANGFLAGS = -Ofast -v

.PHONY:	$(Architectures)

$(Architectures):
	for arch in $(Architectures); do \
	if ( )
		gcc $(GCCFLAGS) -mtune=$$arch -march=$$arch -o $(Name)-$$arch $(Name).c; \
		clang $(CLANGFLAGS) -mtune=$$arch -march=$$arch -o $(Name)-$$arch $(Name).c; \
	done

