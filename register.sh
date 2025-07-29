#!/bin/bash

# This script registers a license certificate to the n8n database
# and updates the encryption key in the config file.

# Check if all required arguments are provided.
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "错误：参数不足。"
  echo "用法: $0 <数据库路径> <encryptionKey> <配置文件路径>"
  exit 1
fi

DB_PATH="$1"
ENCRYPTION_KEY="$2"
CONFIG_FILE_PATH="$3"
CERT_FILE="license.cert"

# --- Update Config File ---
echo "正在更新配置文件 '$CONFIG_FILE_PATH'..."

# Create the new config content. Using printf is safer for special characters.
CONFIG_CONTENT=$(printf '{\n\t"encryptionKey": "%s"\n}\n' "$ENCRYPTION_KEY")

# Write the new content to the config file, overwriting it.
echo "$CONFIG_CONTENT" > "$CONFIG_FILE_PATH"

if [ $? -eq 0 ]; then
  echo "配置文件已成功更新。"
else
  echo "错误：更新配置文件失败。"
  exit 1
fi


# --- Register License Certificate ---
# Check if the license certificate file exists and is readable.
if [ ! -f "$CERT_FILE" ] || [ ! -r "$CERT_FILE" ]; then
  echo "错误：许可证文件 '$CERT_FILE' 不存在或无法读取。"
  exit 1
fi

# Read the license certificate from the file.
LICENSE_CERT=$(cat "$CERT_FILE")

# Check if the license certificate is empty.
if [ -z "$LICENSE_CERT" ]; then
  echo "错误：许可证文件 '$CERT_FILE' 为空。"
  exit 1
fi

echo "正在将许可证从 '$CERT_FILE' 注册到 '$DB_PATH'..."

# In SQL, single quotes are escaped by doubling them up (' -> '').
ESCAPED_LICENSE_CERT=$(echo "$LICENSE_CERT" | sed "s/'/''/g")

# Construct the full SQL command.
SQL_COMMAND="INSERT OR REPLACE INTO settings (key, value) VALUES ('license.cert', '$ESCAPED_LICENSE_CERT');"

# Execute the sqlite3 command.
sqlite3 "$DB_PATH" "$SQL_COMMAND"

# Check if the command was successful.
if [ $? -eq 0 ]; then
  echo "许可证已成功注册。"
else
  echo "错误：注册许可证失败。"
  exit 1
fi