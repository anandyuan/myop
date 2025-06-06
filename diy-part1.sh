#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages' >>feeds.conf.default
echo 'src-git OpenClash https://github.com/vernesong/OpenClash' >>feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default

# Add luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# Add luci-theme-edge
git clone --depth=1 https://github.com/kiddin9/luci-theme-edge.git package/luci-theme-edge

# Add luci-app-adguardhome
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# Add luci-app-diskman
git clone --depth=1 https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman
mkdir -p package/luci-app-diskman/luci-app-diskman/root/usr/share/diskman/scripts
wget -O package/luci-app-diskman/luci-app-diskman/root/usr/share/diskman/scripts/disk_info.sh https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/files/diskman_config

# Add luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman

# Add luci-app-amlogic
git clone --depth=1 https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# Add mentohust & luci-app-mentohust
git clone --depth=1 https://github.com/BoringCat/luci-app-mentohust.git package/luci-app-mentohust
git clone --depth=1 https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk.git package/mentohust

# Add ServerChan
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush.git package/luci-app-serverchan

# Add OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# Add luci-app-onliner (need luci-app-nlbwmon)
git clone --depth=1 https://github.com/rufengsuixing/luci-app-onliner.git package/luci-app-onliner

# Add luci-app-gowebdav
git clone --depth=1 https://github.com/project-lede/luci-app-gowebdav.git package/luci-app-gowebdav

# Add luci-app-cpufreq
git clone --depth=1 https://github.com/immortalwrt/luci-app-cpufreq.git package/luci-app-cpufreq

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package

# Add luci-app-bypass
git clone --depth=1 https://github.com/garypang13/luci-app-bypass

# Add luci-app-vssr <M>
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 https://github.com/jerrykuku/luci-app-vssr

# Add mentohust & luci-app-mentohust
git clone --depth=1 https://github.com/BoringCat/luci-app-mentohust
git clone --depth=1 https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk

# Add minieap & luci-proto-minieap
git clone --depth=1 https://github.com/ysc3839/openwrt-minieap
git clone --depth=1 https://github.com/ysc3839/luci-proto-minieap

# Add smartdns
git clone --depth=1 -b lede https://github.com/pymumu/openwrt-smartdns
git clone --depth=1 https://github.com/pymumu/luci-app-smartdns

# Add ddnsto & linkease
git clone --depth=1 https://github.com/linkease/nas-packages-luci
git clone --depth=1 https://github.com/linkease/nas-packages

# Add iStore
git clone --depth=1 https://github.com/linkease/istore
git clone --depth=1 https://github.com/linkease/istore-ui

popd

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/90-mt76-usb' Makefile
popd

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
