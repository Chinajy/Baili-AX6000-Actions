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
# 注意：SmartDNS 使用 feeds 中的版本，不在此处克隆
# 原因：pymumu/luci-app-smartdns 仓库结构与 ImmortalWrt 24.10 不兼容
# feeds 中已包含 smartdns + luci-app-smartdns，直接使用即可

echo "=== diy-part1.sh start ==="

# 清理临时文件
rm -rf package/*tmp*

# ============ 第三方插件源码拉取 ============

# 1. AdGuardHome 广告拦截
echo "=== Cloning AdGuardHome ==="
git clone --depth 1 https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# 2. OpenClash 科学上网
echo "=== Cloning OpenClash ==="
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 3. DiskMan 磁盘管理
echo "=== Cloning DiskMan ==="
git clone --depth 1 https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman

# 4. AdvancedPlus 文件管理
echo "=== Cloning AdvancedPlus ==="
git clone --depth 1 https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus

# 5. Lucky 端口转发
echo "=== Cloning Lucky ==="
git clone --depth 1 https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# 6. EasyTier 异地组网
echo "=== Cloning EasyTier ==="
git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# 7. Argon 主题
echo "=== Cloning Argon Theme ==="
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# ============ SmartDNS 不克隆 ============
# SmartDNS 使用 feeds 中的版本（feeds/packages/net/smartdns + feeds/luci/applications/luci-app-smartdns）
# 不克隆 pymumu/luci-app-smartdns，因为其仓库结构（包含 package/openwrt/Makefile）
# 与 ImmortalWrt 24.10 的 feeds 结构冲突，会导致编译失败

echo "=== diy-part1.sh completed ==="
