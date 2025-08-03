VERSION_FILE="./version.lua"

# 读取当前 id
current_id=$(awk -F'"' '/version\.id[ ]*=/ {print $2}' "$VERSION_FILE" | head -n 1)

if [[ ! $current_id =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "version.id 格式错误，当前值：$current_id"
    exit 1
fi

IFS='.' read -r major minor patch <<<"$current_id"

# patch自增并进位
patch=$((patch + 1))
if [ "$patch" -ge 10 ]; then
    patch=0
    minor=$((minor + 1))
    if [ "$minor" -ge 10 ]; then
        minor=0
        major=$((major + 1))
    fi
fi
new_id="$major.$minor.$patch"

# 更新 version.lua
sed -i "s/version\.id = \".*\"/version.id = \"$new_id\"/" "$VERSION_FILE"

# 压缩包名用新 id
OUTPUT_ZIP="../Kingdom Rush_${current_id}.zip"

if [ -f "../Kingdom Rush.zip" ]; then
    echo "已存在 Kingdom Rush.zip，正在删除..."
    rm "../Kingdom Rush.zip"
fi

echo "打包至: $OUTPUT_ZIP"

if [ $# -eq 0 ]; then
    find . -name "*.lua" -type f ! -path "./patches/config.lua" ! -path "./_assets/kr1-desktop/strings/*" ! -path "./lib/*" ! -path "./patches/*" | zip "$OUTPUT_ZIP" -@
else
    find . -name "*.lua" -type f ! -path "./_assets/kr1-desktop/strings/*" ! -path "./lib/*" | zip "$OUTPUT_ZIP" -@
fi

zip "$OUTPUT_ZIP" "./必读说明.md"
zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/strings/zh-Hans.lua"
zip "$OUTPUT_ZIP" "./存档位置.lnk"
zip "$OUTPUT_ZIP" "./patches/default.lua"
zip "$OUTPUT_ZIP" "./patches/keyset_default.lua"