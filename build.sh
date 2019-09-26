
GCCArchitectures="nocona core2 nehalem corei7 westmere sandybridge corei7-avx ivybridge core-avx-i haswell core-avx2 broadwell skylake skylake-avx512 cannonlake icelake-client icelake-server cascadelake bonnell atom silvermont slm goldmont goldmont-plus tremont knl knm intel x86-64 eden-x2 nano nano-1000 nano-2000 nano-3000 nano-x2 eden-x4 nano-x4 k8 k8-sse3 opteron opteron-sse3 athlon64 athlon64-sse3 athlon-fx amdfam10 barcelona bdver1 bdver2 bdver3 bdver4 znver1 znver2 btver1 btver2 generic native"
ClangArchitectures="nocona core2 penryn bonnell atom silvermont slm goldmont goldmont-plus tremont nehalem corei7 westmere sandybridge corei7-avx ivybridge core-avx-i haswell core-avx2 broadwell skylake skylake-avx512 skx cascadelake cannonlake icelake-client icelake-server knl knm k8 athlon64 athlon-fx opteron k8-sse3 athlon64-sse3 opteron-sse3 amdfam10 barcelona btver1 btver2 bdver1 bdver2 bdver3 bdver4 znver1 x86-64"

Name=linpack

GCCFLAGS="-O3 -fexpensive-optimizations"
CLANGFLAGS="-Ofast"

GCC=gcc
CLANG=clang-8

for arch in $GCCArchitectures
do
#	echo building $arch
	if [ $arch != generic ]; then
 		$GCC $GCCFLAGS -mtune=$arch -march=$arch -o ${Name}-$arch ${Name}.c &
	else
		$GCC $GCCFLAGS  -o ${Name}-$arch ${Name}.c &
	fi
done

for arch in $ClangArchitectures
do
#	echo building $arch
	if [ $arch != generic ]; then
		$CLANG $CLANGFLAGS -mtune=$arch -march=$arch -o ${Name}C-$arch ${Name}.c &
	else
		$CLANG $CLANGFLAGS  -o ${Name}C-$arch ${Name}.c &
	fi
done

wait

for arch in $GCCArchitectures
do
	echo running ${Name}-$arch
	./${Name}-$arch | tee -a results.log
done

for arch in $ClangArchitectures
do
	echo running ${Name}C-$arch
	./${Name}C-$arch | tee -a results.log
done
