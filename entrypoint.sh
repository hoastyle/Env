#!/bin/bash
# entrypoint.sh - 独立的entrypoint脚本文件

set -e

USER_ID=${LOCAL_USER_ID:-1000}
GROUP_ID=${LOCAL_GROUP_ID:-1000}
USERNAME=${LOCAL_USERNAME:-developer}
GROUPNAME=${LOCAL_GROUPNAME:-developer}

echo "🚀 启动容器，用户ID: $USER_ID, 组ID: $GROUP_ID, 用户名: $USERNAME"

# 创建组
if ! getent group $GROUP_ID >/dev/null 2>&1; then
    echo "📝 创建组: $GROUPNAME (GID: $GROUP_ID)"
    groupadd -g $GROUP_ID $GROUPNAME
else
    GROUPNAME=$(getent group $GROUP_ID | cut -d: -f1)
    echo "✅ 使用现有组: $GROUPNAME"
fi

# 创建用户
if ! getent passwd $USER_ID >/dev/null 2>&1; then
    echo "👤 创建用户: $USERNAME (UID: $USER_ID)"
    useradd -u $USER_ID -g $GROUP_ID -m -s /bin/bash $USERNAME
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
else
    USERNAME=$(getent passwd $USER_ID | cut -d: -f1)
    echo "✅ 使用现有用户: $USERNAME"
fi

# 设置Git配置（预防性）
runuser -l $USERNAME -c 'git config --global --add safe.directory "*"' 2>/dev/null || true

# 修复工作目录权限
if [ -d "/workspace" ]; then
    chown -R $USER_ID:$GROUP_ID /workspace 2>/dev/null || true
fi

echo "🎯 切换到用户 $USERNAME 执行命令..."
exec gosu $USERNAME "$@"
