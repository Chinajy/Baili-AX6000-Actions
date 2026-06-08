#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
# DIY PART1：拉取第三方插件源码，适配ImmortalWrt 24.10

# 清理临时文件
rm -rf package/*tmp*

# 1. AdGuardHome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# 2. SmartDNS
git clone https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
git clone https://github.com/pymumu/smartdns.git package/smartdns

# 3. OpenClash
git clone -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 4. DiskMan 磁盘管理
git clone https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman

# 5. AdvancedPlus 文件管理
git clone https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus

# 6. Lucky 端口转发
git clone https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# 7. EasyTier 异地组网
git clone https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# 8. Argon 主题
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 9. OpenList2 (可选，注释掉默认不编译)
# git clone https://github.com/sbwml/luci-app-openlist2 package/openlist2

# 10. OpenAppFilter (可选，注释掉默认不编译)
# git clone https://github.com/destan19/OpenAppFilter package/OpenAppFilter
