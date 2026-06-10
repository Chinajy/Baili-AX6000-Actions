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
# 适配设备：京东云百里 AX6000 (RE-CP-03)
#
# 重要：此脚本在 feeds 更新后运行，主要任务是：
# 1. 注入自定义 DTS（京东云百里 AX6000 / RE-CP-03，DSA 交换机模式）
# 2. 下载 OpenClash Meta 内核
# 3. 设置 CPU 频率为 2.0GHz
# 4. 修改默认 WiFi SSID
# 5. 固件版本标识
# 6. 在 .config 中确认关键包状态（SmartDNS、automount 等）

echo "=== diy-part2.sh start ==="

# ============ 1. 注入自定义 DTS（京东云百里 AX6000 / RE-CP-03，DSA 交换机模式） ============
# padavanonly/immortalwrt-mt798x-24.10 源码中可能已有 mt7986a-jdcloud-re-cp-03.dts
# 但这里用我们经过验证的自定义 DTS 覆盖，确保 DSA 交换机模式和硬件配置正确
echo "=== Step 2: Injecting custom DTS for JDCloud RE-CP-03 (DSA mode) ==="

# 2.1 检查自定义 DTS 文件是否存在（从仓库复制）
# 自定义 DTS 位于仓库根目录下 JDCloud-AX6000-Baili-2410/mt7986a-dsa-jdcloud-re-cp-03.dts
CUSTOM_DTS="$GITHUB_WORKSPACE/JDCloud-AX6000-Baili-2410/mt7986a-dsa-jdcloud-re-cp-03.dts"

# 2.2 目标路径（MediaTek 目标的 DTS 目录）
DTS_TARGET_DIR="target/linux/mediatek/dts"
DTS_TARGET_FILE="$DTS_TARGET_DIR/mt7986a-jdcloud-re-cp-03.dts"

if [ -f "$CUSTOM_DTS" ]; then
    echo "  Found custom DTS: $CUSTOM_DTS"

    # 创建目标目录（如果不存在）
    mkdir -p "$DTS_TARGET_DIR"

    # 备份原始 DTS（如果存在）
    if [ -f "$DTS_TARGET_FILE" ]; then
        cp "$DTS_TARGET_FILE" "${DTS_TARGET_FILE}.bak"
        echo "  Original DTS backed up to: ${DTS_TARGET_FILE}.bak"
    fi

    # 复制自定义 DTS 到目标位置
    cp "$CUSTOM_DTS" "$DTS_TARGET_FILE"
    echo "  Custom DTS copied to: $DTS_TARGET_FILE"

    # 2.3 检查 Makefile 是否正确引用了目标设备
    # 目标设备的 Makefile 应该包含对 jdcloud-re-cp-03 的定义
    # 通常在 target/linux/mediatek/image/mt7986.mk
    MAKEFILE_PATH="target/linux/mediatek/image/mt7986.mk"
    if [ -f "$MAKEFILE_PATH" ]; then
        if grep -q "jdcloud.re-cp-03\|jdcloud-re-cp-03\|RE-CP-03" "$MAKEFILE_PATH"; then
            echo "  ✓ Device definition already exists in: $MAKEFILE_PATH"
        else
            echo "  ⚠ Device definition NOT found in $MAKEFILE_PATH"
            echo "  This may be OK if the target name differs (e.g. jdcloud_re-cp-03)"
        fi
    else
        echo "  ⚠ Makefile not found at: $MAKEFILE_PATH"
    fi

    echo "  DTS injection completed successfully"
else
    echo "  ⚠ Custom DTS file not found at: $CUSTOM_DTS"
    echo "  Falling back to source tree's built-in DTS (if it exists)"
    # 如果源码中已有内置的 DTS，则使用它
    if [ -f "$DTS_TARGET_FILE" ]; then
        echo "  Using built-in DTS from source tree"
    else
        echo "  ERROR: No DTS file available for JDCloud RE-CP-03!"
        echo "  The build may fail for this device."
    fi
fi

echo "=== Step 2 completed: DTS injection done ==="

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
        # 使用 sed 替换 mediatekm 频率为 2.0GHz
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
    "package/feeds/luci/luci-app-mtwifi-cfg/root/etc/init.d/mtwifi.sh"
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
    # 修改默认 SSID 名称（2.4G 和 5G）
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

# ============ 7. 确认关键包状态 ============
# 注意：SmartDNS 递归依赖已修复（只编译 smartdns + luci-app-smartdns，不编译 smartdns-ui）

echo "=== Step 7: Verifying essential packages ==="

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

echo "=== Step 7 completed ==="
echo "=== diy-part2.sh all done! Ready to compile. ==="
