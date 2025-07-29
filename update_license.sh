#!/bin/bash

# This script extracts the license certificate from the n8n database
# and writes it to a file.

# Check if the database path is provided as an argument.
if [ -z "$1" ]; then
  echo "错误：未提供数据库路径。"
  echo "用法: $0 <数据库路径>"
  exit 1
fi

DB_PATH="$1"
OUTPUT_FILE="license.cert"

echo "正在从 $DB_PATH 提取许可证..."

# Execute the sqlite3 command and redirect the output to the license file.
# This will overwrite the file if it already exists.
sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key = 'license.cert';" > "$OUTPUT_FILE"

# Check if the command was successful and the output file is not empty.
if [ $? -eq 0 ] && [ -s "$OUTPUT_FILE" ]; then
  echo "许可证已成功写入到 $OUTPUT_FILE 文件。"
else
  echo "错误：无法提取许可证或许可证为空。"
  # Clean up the empty file if created
  rm -f "$OUTPUT_FILE"
  exit 1
fi