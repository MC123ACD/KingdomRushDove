#!/bin/bash

if [ -f "../Kingdom Rush.zip" ]; then
    echo "已存在 Kingdom Rush.zip，正在删除..."
    rm "../Kingdom Rush.zip"
fi

OUTPUT_ZIP="../Kingdom Rush_$(date +%y%m%d).zip"

echo "打包至: $OUTPUT_ZIP"

if [ $# -eq 0 ]; then
    find . -name "*.lua" -type f ! -path "./patches/config.lua" ! -path "./_assets/kr1-desktop/strings/*" ! -path "./lib/*" | zip "$OUTPUT_ZIP" -@
else
    find . -name "*.lua" -type f ! -path "./_assets/kr1-desktop/strings/*" ! -path "./lib/*" | zip "$OUTPUT_ZIP" -@
fi

zip "$OUTPUT_ZIP" "./必读说明.md"
zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/strings/zh-Hans.lua"
zip "$OUTPUT_ZIP" "./存档位置.lnk"