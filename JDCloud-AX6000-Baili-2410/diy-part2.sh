#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# 适配 ImmortalWrt 24.10 / 内核 6.6 / JDCloud RE-CP-03 (京东云百里AX6000)

##-----------------DTS说明------------------
# 源码分支 openwrt-24.10-6.6 已内置 JDCloud RE-CP-03 的 DSA DTS
# 路径: target/linux/mediatek/dts/mt7986a-jdcloud-re-cp-03.dts
# 无需额外注入自定义DTS

##-----------------删除重复包------------------
rm -rf feeds/packages/net/open-app-filter

##-----------------OpenClash Meta内核下载（arm64适配MT7986）------------------
curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
chmod +x /tmp/clash >/dev/null 2>&1
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

##-----------------MT7986A CPU频率设置2.0GHz------------------
# 兼容21.02和24.10不同autocore路径
CPUINFO_PATHS=(
    "package/emortal/autocore/files/generic/cpuinfo"
    "package/base-files/files/etc/cpuinfo"
)
for cpuinfo_path in "${CPUINFO_PATHS[@]}"; do
    if [ -f "$cpuinfo_path" ]; then
        sed -i '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="2.0GHz" ;;/}' "$cpuinfo_path"
        echo "Set CPU frequency to 2.0GHz in $cpuinfo_path"
        break
    fi
done

##-----------------删除DDNS多余示例-----------------
if [ -f "feeds/packages/net/ddns-scripts/files/etc/config/ddns" ]; then
    sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns
fi

##-----------------修改mtwifi默认WiFi名称和密码-----------------
MTWIFI_SH="package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
if [ -f "$MTWIFI_SH" ]; then
    # 修改默认SSID名称
    sed -i 's/ImmortalWrt-2.4G/Baili-2.4G/g' "$MTWIFI_SH"
    sed -i 's/ImmortalWrt-5G/Baili-5G/g' "$MTWIFI_SH"
    # 设置默认WiFi密码（加密方式改为psk2）
    sed -i 's/encryption=none/encryption=psk2/' "$MTWIFI_SH"
    sed -i '/encryption=psk2/a\\t\t\t\t\tset wireless.default_${dev}.key=password' "$MTWIFI_SH"
    echo "Modified default WiFi SSID and password"
fi

##-----------------修改默认IP（可选，按需开启）-----------------
# sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate
