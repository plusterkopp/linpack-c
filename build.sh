
if [ $(uname -m) == x86_64 ]; then
	GCCArchitectures="nocona core2 nehalem corei7 westmere sandybridge corei7-avx ivybridge core-avx-i haswell core-avx2 broadwell skylake skylake-avx512 cannonlake icelake-client icelake-server cascadelake bonnell atom silvermont slm goldmont goldmont-plus tremont knl knm intel x86-64 eden-x2 nano nano-1000 nano-2000 nano-3000 nano-x2 eden-x4 nano-x4 k8 k8-sse3 opteron opteron-sse3 athlon64 athlon64-sse3 athlon-fx amdfam10 barcelona bdver1 bdver2 bdver3 bdver4 znver1 znver2 btver1 btver2 generic native"
	ClangArchitectures="nocona core2 penryn bonnell atom silvermont slm goldmont goldmont-plus tremont nehalem corei7 westmere sandybridge corei7-avx ivybridge core-avx-i haswell core-avx2 broadwell skylake skylake-avx512 skx cascadelake cannonlake icelake-client icelake-server knl knm k8 athlon64 athlon-fx opteron k8-sse3 athlon64-sse3 opteron-sse3 amdfam10 barcelona btver1 btver2 bdver1 bdver2 bdver3 bdver4 znver1 x86-64"
elif [ $(uname -m) == armv7l ]; then
	GCCArchitectures="armv4 armv4t armv5t armv5te armv5tej armv6 armv6j armv6k armv6z armv6kz armv6zk armv6t2 armv6-m armv6s-m armv7 armv7-a armv7ve armv7-r armv7-m armv7e-m armv8-a armv8.1-a armv8.2-a armv8.3-a armv8.4-a armv8.5-a armv8-m.base armv8-m.main armv8-r iwmmxt iwmmxt2 native"
	ClangArchitectures="nocona core2 penryn bonnell atom silvermont slm goldmont goldmont-plus tremont nehalem corei7 westmere sandybridge corei7-avx ivybridge core-avx-i haswell core-avx2 broadwell skylake skylake-avx512 skx cascadelake cannonlake icelake-client icelake-server knl knm k8 athlon64 athlon-fx opteron k8-sse3 athlon64-sse3 opteron-sse3 amdfam10 barcelona btver1 btver2 bdver1 bdver2 bdver3 bdver4 znver1 x86-64"
else
	echo unknown architecture
	exit 1
fi

Name=linpack

GCCFLAGS="-O3 -fexpensive-optimizations"
CLANGFLAGS="-Ofast"

GCC=gcc	# /usr/local/bin/gcc
CLANG=clang-8	# /usr/bin/clang

if [ "$1" == "-b" ]; then
	for arch in $GCCArchitectures
	do
		ARCHNAME=${Name}-$arch
		if [ ! -r ${ARCHNAME}.s ] || [ ${ARCHNAME}.s -ot ${Name}.c ]; then
			$GCC $GCCFLAGS -mtune=$arch -march=$arch -fverbose-asm -S -o ${ARCHNAME}.s ${Name}.c &
		fi
		if [ ! -x ${ARCHNAME} ] || [ ${ARCHNAME} -ot ${Name}.c ]; then
			#	echo building $arch
			if [ $arch != generic ]; then
				$GCC $GCCFLAGS -mtune=$arch -march=$arch -o ${ARCHNAME} ${Name}.c &
			else
				$GCC $GCCFLAGS  -o ${ARCHNAME} ${Name}.c &
			fi
		fi
	done
	for arch in $ClangArchitectures
	do
		ARCHNAME=${Name}C-$arch
		if [ ! -r ${ARCHNAME}.s ] || [ ${ARCHNAME}.s -ot ${Name}.c ]; then
			$CLANG $CLANGFLAGS -mtune=$arch -march=$arch -S -o ${ARCHNAME}.s ${Name}.c &
		fi
		if [ ! -x ${ARCHNAME} ] || [ ${ARCHNAME} -ot ${Name}.c ]; then
			#	echo building $arch
			if [ $arch != generic ]; then
				$CLANG $CLANGFLAGS -mtune=$arch -march=$arch -o ${ARCHNAME} ${Name}.c &
			else
				$CLANG $CLANGFLAGS  -o ${ARCHNAME} ${Name}.c &
			fi
		fi
	done
	wait	# Compile-Jobs abwarten
fi

Combined=$GCCArchitectures" "$ClangArchitectures
IFS=' ' read -ra Split <<< "${Combined}"
Sorted=($(printf '%s\n' "${Split[@]}" | sort -u))

Machine=`uname -n`
LogName=results-${Machine}.log

echo > ${LogName}

for arch in "${Sorted[@]}" 
do
	GCCFile=${Name}-$arch
	if [ -x $GCCFile ]; then
		echo running $GCCFile
		./$GCCFile | tee -a ${LogName}
	fi
	ClangFile=${Name}C-$arch
	if [ -x $ClangFile ]; then
		echo running $ClangFile
		./$ClangFile | tee -a ${LogName}
	fi
done

