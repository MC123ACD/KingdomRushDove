#!/bin/bash

if [ -f "../Kingdom Rush.zip" ]; then
    echo "已存在 Kingdom Rush.zip，正在删除..."
    rm "../Kingdom Rush.zip"
fi

OUTPUT_ZIP="../Kingdom Rush_$(date +%y%m%d).zip"

echo "打包至: $OUTPUT_ZIP"

find . -name "*.lua" -type f | zip "$OUTPUT_ZIP" -@

zip "$OUTPUT_ZIP" "./必读说明.md"