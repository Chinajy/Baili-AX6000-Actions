#!/bin/bash
# DIY PART2：feeds更新后的自定义操作
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>

# ============ 1. OpenClash Meta内核下载 ============
echo "=== Step 1: Downloading OpenClash Meta core for arm64 ==="
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
chmod +x /tmp/clash >/dev/null 2>&1
mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
echo "=== Step 1 completed: OpenClash Meta core ready ==="

# ============ 2. MT7986A CPU频率设置为2.0GHz ============
echo "=== Step 2: Setting CPU frequency to 2.0GHz ==="
sed -i '/"mediatek"\/\*|"mvebu"\/\*/{n; s/.*/\tcpu_freq="2.0GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo
echo "=== Step 2 completed: CPU frequency set to 2.0GHz ==="

# ============ 3. 修改默认WiFi名称（SSID） ============
echo "=== Step 3: Configuring default WiFi settings ==="
# 2.4G: Baili-2.4G, 5G: Baili-5G
sed -i 's/ImmortalWrt/Baili-2.4G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh 2>/dev/null || true
sed -i 's/ImmortalWrt_5G/Baili-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh 2>/dev/null || true
echo "=== Step 3 completed: WiFi SSID configured ==="

# ============ 4. 固件版本标识 ============
echo "=== Step 4: Setting firmware version banner ==="
BUILD_DATE=$(date +"%Y%m%d")
sed -i "/DISTRIB_DESCRIPTION/d" package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION='ImmortalWrt 24.10 for Baili AX6000 (Build ${BUILD_DATE})'" >> package/base-files/files/etc/openwrt_release
echo "=== Step 4 completed ==="

# ============ 5. 禁用automount和ntfs3-mount ============
echo "=== Step 5: Disabling automount and ntfs3-mount ==="
# 5.1 从.config中禁用
sed -i '/^CONFIG_PACKAGE_automount=/d' .config 2>/dev/null || true
sed -i '/^CONFIG_PACKAGE_ntfs3-mount=/d' .config 2>/dev/null || true
echo "# CONFIG_PACKAGE_automount is not set" >> .config
echo "# CONFIG_PACKAGE_ntfs3-mount is not set" >> .config

# 5.2 物理删除package/emortal/automount（如果存在）
if [ -d "package/emortal/automount" ]; then
    echo "  Removing package/emortal/automount..."
    rm -rf package/emortal/automount
fi

# 5.3 物理删除feeds中的automount和ntfs3-mount
if [ -d "feeds/packages/utils/automount" ]; then
    echo "  Removing feeds/packages/utils/automount..."
    rm -rf feeds/packages/utils/automount
fi
if [ -d "feeds/packages/utils/ntfs3-mount" ]; then
    echo "  Removing feeds/packages/utils/ntfs3-mount..."
    rm -rf feeds/packages/utils/ntfs3-mount
fi

# 5.4 确认ntfs-3g不会被禁用（luci-app-diskman需要它）
# 不需要操作，ntfs-3g由luci-app-diskman的依赖自动拉入
echo "=== Step 5 completed ==="

# ============ 6. 确认关键包状态 ============
echo "=== Step 6: Verifying essential packages ==="
echo "  Checking SmartDNS..."
grep -q "CONFIG_PACKAGE_smartdns=y" .config && echo "    SmartDNS: enabled" || echo "    SmartDNS: not enabled"

echo "  Checking mtwifi-cfg..."
grep -q "CONFIG_PACKAGE_mtwifi-cfg=y" .config && echo "    mtwifi-cfg: enabled" || echo "    mtwifi-cfg: not enabled"

echo "  Checking luci-app-turboacc-mtk..."
grep -q "CONFIG_PACKAGE_luci-app-turboacc-mtk=y" .config && echo "    turboacc-mtk: enabled" || echo "    turboacc-mtk: not enabled"

echo "  Checking kmod-mediatek_hnat..."
grep -q "CONFIG_PACKAGE_kmod-mediatek_hnat=y" .config && echo "    hnat: enabled" || echo "    hnat: not enabled"

echo "=== Step 6 completed ==="

echo ""
echo "============================================"
echo "All DIY Part 2 steps completed successfully!"
echo "============================================"
