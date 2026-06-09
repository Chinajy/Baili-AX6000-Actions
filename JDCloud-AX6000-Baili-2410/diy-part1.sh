#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
# DIY PART1：拉取第三方插件源码，适配 ImmortalWrt 24.10 / 内核 6.6
# 适配设备：京东云百里 AX6000 (RE-CP-03)
#
# 注意：SmartDNS 的递归依赖已修复
# 原因：smartdns-ui 依赖 smartdns，而 smartdns 的 PKG_CONFIG_DEPENDS 又依赖 smartdns-ui
# 修复方案：只编译 smartdns + luci-app-smartdns，不编译 smartdns-ui

echo "=== diy-part1.sh start ==="

# 清理临时文件
rm -rf package/*tmp*

# ============ 第三方插件源码拉取 ============
# 每个 git clone 都添加了错误处理，即使某个插件拉取失败也不会中断整个编译

# 1. AdGuardHome 广告拦截
echo "=== Cloning AdGuardHome ==="
git clone --depth 1 https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome 2>/dev/null || echo "WARN: AdGuardHome clone failed (will not be built)"

# 2. OpenClash 科学上网
echo "=== Cloning OpenClash ==="
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash 2>/dev/null || echo "WARN: OpenClash clone failed (will not be built)"

# 3. DiskMan 磁盘管理
echo "=== Cloning DiskMan ==="
git clone --depth 1 https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman 2>/dev/null || echo "WARN: DiskMan clone failed (will not be built)"

# 4. AdvancedPlus 文件管理
echo "=== Cloning AdvancedPlus ==="
git clone --depth 1 https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus 2>/dev/null || echo "WARN: AdvancedPlus clone failed (will not be built)"

# 5. Lucky 端口转发
echo "=== Cloning Lucky ==="
git clone --depth 1 https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky 2>/dev/null || echo "WARN: Lucky clone failed (will not be built)"

# 6. EasyTier 异地组网
echo "=== Cloning EasyTier ==="
git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier 2>/dev/null || echo "WARN: EasyTier clone failed (will not be built)"

# 7. Argon 主题
echo "=== Cloning Argon Theme ==="
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon 2>/dev/null || echo "WARN: Argon Theme clone failed (will not be built)"
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config 2>/dev/null || echo "WARN: Argon Config clone failed (will not be built)"

# 8. SmartDNS（只拉取 luci-app-smartdns，smartdns 本体在 feeds 中）
echo "=== Cloning SmartDNS LuCI ==="
git clone --depth 1 https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns 2>/dev/null || echo "WARN: SmartDNS LuCI clone failed (will use feeds version)"

# 9. SmartDNS 官方源码（可选，如果需要最新版本）
# echo "=== Cloning SmartDNS ==="
git clone --depth 1 https://github.com/pymumu/smartdns.git package/smartdns 2>/dev/null || echo "WARN: SmartDNS clone failed (will use feeds version)"

echo "=== diy-part1.sh completed ==="
