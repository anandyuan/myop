#!/bin/bash
#
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Add essential feed sources
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default

# Add luci-theme-argon (compatible with 24.10)
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# Add essential applications
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
git clone --depth=1 https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman

# Add smartdns
git clone --depth=1 -b lede https://github.com/pymumu/openwrt-smartdns package/smartdns
git clone --depth=1 https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
