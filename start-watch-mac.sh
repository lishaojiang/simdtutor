#!/bin/bash
# rayhunterli
# 2023-8-27 10:32
# watch - mac
# fswatch gtest benchmark clang python gnu-gsed lldb
 
file="main.cpp"
fswatch -0 -v -o "$file" | xargs -0 -n 1 -I {} ./watcher-mac.sh

