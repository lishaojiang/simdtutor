#!/bin/bash
# rayhunterli
# 2023-8-26 17:30
# wath - linux
# inotify-tools gtest benchmark clang python sed lldb

file="main.cpp"
out="./build/watch/watched.s"
bench="./build/watch/benched.cpp"
result="./build/watch/result.json"
record="./build/watch/record.json"
cflags="-masm=intel -mavx2 -mfma -O3 -fopenmp -std=c++2a"
cc="clang++"

#count=0
rm -r build
mkdir build
mkdir build/watch

lastmd5=
set -o pipefail
while inotifywait "$file" -o ./build/watch/.W$$.ionotify.log -e close --timefmt '%y/%m/%d %H:%M:%S' --format '%T %w %f %e' || true
#while [ $count -lt 3 ]
do
    #count=$((count + 1))
    newmd5=$(md5sum "$file" | cut -d' ' -f1)
    if [ "x$newmd5" == "x$lastmd5" ]
    then
        echo "file not changed ($newmd5), ignoring..."
    else
        lastmd5="$newmd5"
        rm -f ./build/watch/.W$$.clang-error.log
        echo '-- Compiling...'
        cat "$file" | sed '/\#include <benchmark\/benchmark.h>/d; /^static void \w\+(benchmark::State/,/^BENCHMARK(\w\+)/d' | sed '/\#include <gtest\/gtest.h>/d;  /^TEST(\w\+, \w\+)/,/^}$/d' | "$cc" -S -x c++ /dev/stdin $cflags -o /dev/stdout 2> ./build/watch/.W$$.clang-error.log | sed 's/^\t\.\(align\|byte\|short\|long\|float\|quad\|rept\|string\|ascii\|asciz\)\t/  \.\1  /g' | sed '/^\t\..*[^:]$/d' | sed 's/\t/  /g' | sed '$a ; '"$(date +'Compiled at %Y\/%m\/%d %H:%M:%S')" | tee "$out" > /dev/null
        if [ -s ./build/watch/.W$$.clang-error.log ]
        then
            cat ./build/watch/.W$$.clang-error.log >> "$out"
            echo '-- Compile error '
        else
            echo '-- Testing...'
            rm -f ./build/watch/.W$$.executable.out
            cat "$file" | sed '/\#include <benchmark\/benchmark.h>/d; /^static void \w\+(benchmark::State/,/^BENCHMARK(\w\+)/d' | "$cc" -x c++ /dev/stdin $cflags -o ./build/watch/.W$$.executable.out -lgtest -lgtest_main 2> ./build/watch/.W$$.clang-error.log
            if [ -f ./build/watch/.W$$.executable.out ]
            then
                echo '-- Start Testing...'
                ./build/watch/.W$$.executable.out | tee "$bench"
                if [ x"$?" == x0 ]
                then
                    # sed -n '/^\/\/ BEGIN CODE$/,/^\/\/ END CODE$/p' "$file" | sed '1d; $d' | python .watcher-helper.py "$result" "$record" "$bench"
                    echo '-- Benchmarking...'
                    rm -f ./build/watch/.W$$.executable.out
                    cat "$file" | sed '/\#include <gtest\/gtest.h>/d; /^TEST(\w\+, \w\+)/,/^}$/d' | "$cc" -x c++ /dev/stdin $cflags -o ./build/watch/.W$$.executable.out -lbenchmark -lbenchmark_main 2> ./build/watch/.W$$.clang-error.log
                    if [ -f ./build/watch/.W$$.executable.out ]
                    then
                        echo '-- Start Benchmarking...'
                        ./build/watch/.W$$.executable.out --benchmark_min_time=0.2s --benchmark_repetitions=5 --benchmark_out="$result" 2>&1 | tee "$bench"
                        if [ x"$?" == x0 ]
                        then
                            # sed '/^\#include <benchmark\/benchmark.h>$/d; /^\#include <gtest\/gtest.h>$/d' "$file" | sed -n '/^\(\#include\|namespace \w\+ =\|using namespace \)/p' | sed '$a' > "$bench"
                            echo '-- Start Python Calc Bench...'
                            sed -n '/^\/\/ BEGIN CODE$/,/^\/\/ END CODE$/p;' "$file" | sed '1d; $d' | python3 .watcher-helper.py "$result" "$record" > "$bench"
                            echo '-- End All Work Bench And Test, wait again ...'
                        fi
                    else
                        cat ./build/watch/.W$$.clang-error.log | tee "$bench"
                    fi
                else
                    echo '-- Debugging...'
                    cat "$file" | sed '/\#include <benchmark\/benchmark.h>/d; /^static void \w\+(benchmark::State/,/^BENCHMARK(\w\+)/d' > ./build/watch/.W$$.debugsource.cpp && "$cc" -x c++ ./build/watch/.W$$.debugsource.cpp $cflags -O0 -g -gstabs+ -o ./build/watch/.W$$.executable.out -lgtest -lgtest_main 2> /dev/null
                    if [ -f ./build/watch/.W$$.executable.out ]
                    then
                        which lldb > /dev/null 2>&1 && lldb -q ./build/watch/.W$$.executable.out -ex 'set confirm off' -ex 'set debuginfod enabled off' -ex 'set auto-load safe-path /' -ex 'set pagination off' -ex 'set environment CK_FORK=no' -ex 'b testing::AssertionResult::failure_message' -ex r -ex bt -ex q || true
                    else
                        echo '-- Compile Debug exec error'
                    fi
                fi
            else
                cat ./build/watch/.W$$.clang-error.log | tee "$bench"
            fi
        fi
    fi
done
