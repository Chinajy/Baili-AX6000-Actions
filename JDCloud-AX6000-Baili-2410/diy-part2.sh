#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# DIY PART2：feeds 拉取后的自定义操作，适配 ImmortalWrt 24.10 / 内核 6.6
# 适配设备：京东云百里 AX6000 (RE-CP-03) | 使用仓库根目录的自定义DTS

echo "=== diy-part2.sh start ==="

# ============ 新增：注入自定义DTS文件（核心） ============
echo "=== Step 2: Inject custom DTS from repo root ==="

# 定义路径
REPO_DTS="./jdcloud-re-cp-03.dts"
SRC_DTS="target/linux/mediatek/filogic/dts/jdcloud-re-cp-03.dts"

if [ -f "$REPO_DTS" ]; then
    echo "  Found custom DTS: $REPO_DTS"
    mkdir -p target/linux/mediatek/filogic/dts/
    cp -f "$REPO_DTS" "$SRC_DTS"
    echo "  Copied to: $SRC_DTS"
else
    echo "  ERROR: DTS file missing!"
    exit 1
fi

echo "=== Step 2 completed: Custom DTS injected ==="

# ============ 3. OpenClash Meta 内核下载（arm64 适配 MT7986） ============
echo "=== Step 3: Downloading OpenClash Meta core for arm64 ==="

mkdir -p /tmp/clash_download
curl -sL -m 30 --retry 2 --retry-delay 5 \
  https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz \
  -o /tmp/clash_download/clash-linux-arm64.tar.gz 2>/dev/null || echo "WARN: Failed to download clash core"

if [ -s /tmp/clash_download/clash-linux-arm64.tar.gz ]; then
    tar zxvf /tmp/clash_download/clash-linux-arm64.tar.gz -C /tmp/clash_download >/dev/null 2>&1 || true
    chmod +x /tmp/clash_download/clash >/dev/null 2>&1 || true
    mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
    if [ -f /tmp/clash_download/clash ]; then
        mv /tmp/clash_download/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta
        echo "  OpenClash Meta core installed successfully"
    fi
fi
rm -rf /tmp/clash_download

echo "=== Step 3 completed: OpenClash Meta core ready ==="

# ============ 4. MT7986A CPU 频率设置为 2.0GHz ============
echo "=== Step 4: Setting CPU frequency to 2.0GHz ==="

CPUINFO_PATHS=(
    "package/emortal/autocore/files/generic/cpuinfo"
    "package/base-files/files/etc/cpuinfo"
    "feeds/packages/utils/autocore/files/generic/cpuinfo"
)

for cpuinfo_path in "${CPUINFO_PATHS[@]}"; do
    if [ -f "$cpuinfo_path" ]; then
        sed -i '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="2.0GHz" ;;/}' "$cpuinfo_path"
        echo "  Set CPU frequency in: $cpuinfo_path"
    fi
done

echo "=== Step 4 completed: CPU frequency set to 2.0GHz ==="

# ============ 5. 修改默认 WiFi 名称（SSID） ============
echo "=== Step 5: Configuring default WiFi settings ==="

MTWIFI_SEARCH_PATHS=(
    "package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
    "feeds/luci/applications/luci-app-mtwifi-cfg/root/etc/init.d/mtwifi.sh"
    "package/feeds/luci-app-mtwifi-cfg/root/etc/init.d/mtwifi.sh"
)

MTWIFI_SH_PATH=""
for path in "${MTWIFI_SEARCH_PATHS[@]}"; do
    if [ -f "$path" ]; then
        MTWIFI_SH_PATH="$path"
        break
    fi
done

if [ -n "$MTWIFI_SH_PATH" ] && [ -f "$MTWIFI_SH_PATH" ]; then
    echo "  Found mtwifi.sh at: $MTWIFI_SH_PATH"
    sed -i 's/ImmortalWrt-2\.4G/Baili-2.4G/g' "$MTWIFI_SH_PATH"
    sed -i 's/ImmortalWrt-5G/Baili-5G/g' "$MTWIFI_SH_PATH"
    echo "  Default WiFi SSID modified to: Baili-2.4G / Baili-5G"
fi

echo "=== Step 5 completed: WiFi SSID configured ==="

# ============ 6. 固件版本标识 ============
echo "=== Step 6: Setting firmware version banner ==="

if [ -f "package/base-files/files/etc/banner" ]; then
    echo "" >> package/base-files/files/etc/banner
    echo "  Build: JDCloud Baili-AX6000 / ImmortalWrt 24.10 / Kernel 6.6" >> package/base-files/files/etc/banner
    echo "  Date: $(date +%Y-%m-%d)" >> package/base-files/files/etc/banner
    echo "  Banner updated"
fi

echo "=== Step 6 completed ==="

# ============ 7. 禁用 automount 和 ntfs3-mount ============
echo "=== Step 7: Disabling automount and ntfs3-mount ==="

sed -i '/^CONFIG_PACKAGE_automount=/d' .config 2>/dev/null || true
sed -i '/^CONFIG_PACKAGE_ntfs3-mount=/d' .config 2>/dev/null || true
echo "# CONFIG_PACKAGE_automount is not set" >> .config
echo "# CONFIG_PACKAGE_ntfs3-mount is not set" >> .config

if [ -d "package/emortal/automount" ]; then
    echo "  Removing package/emortal/automount..."
    rm -rf package/emortal/automount
fi
if [ -d "feeds/packages/utils/automount" ]; then
    echo "  Removing feeds/packages/utils/automount..."
    rm -rf feeds/packages/utils/automount
fi
if [ -d "feeds/packages/utils/ntfs3-mount" ]; then
    echo "  Removing feeds/packages/utils/ntfs3-mount..."
    rm -rf feeds/packages/utils/ntfs3-mount
fi

echo "=== Step 7 completed ==="

# ============ 8. 确认关键包状态 ============
echo "=== Step 8: Verifying essential packages ==="

ESSENTIAL_PACKAGES=(
    "luci-app-mtwifi-cfg"
    "mtwifi-cfg"
    "luci"
    "luci-app-dockerman"
    "luci-app-openclash"
    "luci-app-adguardhome"
    "luci-app-easytier"
    "easytier"
    "tailscale"
    "kmod-mt_wifi"
    "kmod-warp"
    "kmod-mediatek_hnat"
    "smartdns"
    "luci-app-smartdns"
    "luci-app-diskman"
)

for pkg in "${ESSENTIAL_PACKAGES[@]}"; do
    if grep -q "^CONFIG_PACKAGE_${pkg}=y" .config 2>/dev/null; then
        echo "  ✓ $pkg: enabled"
    elif grep -q "^CONFIG_PACKAGE_${pkg}=m" .config 2>/dev/null; then
        echo "  ○ $pkg: module (as expected)"
    else
        echo "  ⚠ $pkg: not found in .config (may not be built)"
    fi
done

echo "=== Step 8 completed ==="
echo "=== diy-part2.sh all done! Ready to compile. ==="
