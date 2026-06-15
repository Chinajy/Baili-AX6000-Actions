#!/bin/bash
# DIY PART1：拉取第三方插件源码，适配ImmortalWrt 24.10
# 在Update feeds之前执行

# 删除旧的多余源码
rm -rf package/*tmp*

# 1. AdGuardHome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# 2. OpenClash
git clone -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 3. DiskMan磁盘管理
git clone https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman

# 4. AdvancedPlus 文件管理
git clone https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus

# 5. Lucky端口转发
git clone https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# 6. EasyTier异地组网
git clone https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# 7. Argon主题
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 注意：SmartDNS使用feeds中的版本，不单独克隆，避免递归依赖问题
