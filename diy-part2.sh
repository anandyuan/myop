#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/OpenWrt/ImmortalWrt-RPi4B/g' package/base-files/files/bin/config_generate

# Delete default password (if enable this, SSH access will be disabled)
# sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="OpenWrt-CI"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"OpenWrt-CI"@' .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"GitHub Actions"@' .config

# Modify default banner
echo ' _____                            _        _ _    _ ____  _____' > package/base-files/files/etc/banner
echo '|_   _|                          | |      | | |  | |  _ \|  __ \' >> package/base-files/files/etc/banner
echo '  | |  _ __ ___  _ __ ___   ___  _ __| |_ __ _| | |  | | |_) | |__) |' >> package/base-files/files/etc/banner
echo '  | | | '_ ` _ \| '_ ` _ \ / _ \| '__| __/ _` | | |/\| |  _ <|  ___/' >> package/base-files/files/etc/banner
echo ' _| |_| | | | | | | | | | | (_) | |  | || (_| | \  /\  / |_) | |' >> package/base-files/files/etc/banner
echo '|_____|_| |_| |_|_| |_| |_|\___/|_|   \__\__,_|_|\/  \/|____/|_|' >> package/base-files/files/etc/banner
echo '' >> package/base-files/files/etc/banner
echo ' Raspberry Pi 4B - ImmortalWrt 24.10' >> package/base-files/files/etc/banner
echo ' Build Automated by GitHub Actions' >> package/base-files/files/etc/banner
echo '' >> package/base-files/files/etc/banner

# Set default timezone
sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate

# Set default NTP servers
sed -i 's/0.openwrt.pool.ntp.org/ntp.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# Configure oh-my-zsh
mkdir -p files/root
pushd files/root

# Download oh-my-zsh
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh

# Create .zshrc config
cat > .zshrc <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="ys"
plugins=(git)
source \$ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nano'

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# OpenWrt specific aliases
alias logs='logread -f'
alias syslog='logread'
alias reload='service network reload'
alias restart='service network restart'
EOF

# Set executable permissions
chmod 755 .zshrc

popd

# Optimize for Raspberry Pi 4B
echo 'CONFIG_PACKAGE_kmod-brcmfmac=y' >> .config
echo 'CONFIG_PACKAGE_kmod-brcmutil=y' >> .config
echo 'CONFIG_PACKAGE_brcmfmac-firmware-43455-sdio=y' >> .config
echo 'CONFIG_PACKAGE_brcmfmac-firmware-43456-sdio=y' >> .config

# Enable USB3.0 support
echo 'CONFIG_PACKAGE_kmod-usb3=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb-xhci-hcd=y' >> .config

# Enable GPIO support
echo 'CONFIG_PACKAGE_kmod-gpio-button-hotplug=y' >> .config

# Remove conflicting packages
sed -i '/CONFIG_PACKAGE_dnsmasq=y/d' .config
echo '# CONFIG_PACKAGE_dnsmasq is not set' >> .config

# Remove some unused packages to save space
echo '# CONFIG_PACKAGE_luci-app-qbittorrent is not set' >> .config
echo '# CONFIG_PACKAGE_luci-app-transmission is not set' >> .config
echo '# CONFIG_PACKAGE_luci-app-aria2 is not set' >> .config

# Enable essential packages
echo 'CONFIG_PACKAGE_curl=y' >> .config
echo 'CONFIG_PACKAGE_wget-ssl=y' >> .config
echo 'CONFIG_PACKAGE_ca-certificates=y' >> .config
echo 'CONFIG_PACKAGE_ca-bundle=y' >> .config

# Add Chinese language support
echo 'CONFIG_PACKAGE_luci-i18n-base-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y' >> .config

# Configure automatic updates
cat > files/etc/crontabs/root <<EOF
# Update package lists weekly
0 4 * * 0 opkg update
# Check for firmware updates weekly  
0 5 * * 0 /usr/bin/firmware-check.sh
EOF

# Create firmware check script
mkdir -p files/usr/bin
cat > files/usr/bin/firmware-check.sh <<'EOF'
#!/bin/bash
# Simple firmware update check script
CURRENT_VERSION=$(cat /etc/openwrt_release | grep DISTRIB_RELEASE | cut -d"'" -f2)
echo "Current firmware version: $CURRENT_VERSION"
echo "Please check https://github.com/[YOUR_USERNAME]/[YOUR_REPO]/releases for updates"
EOF

chmod +x files/usr/bin/firmware-check.sh

# Configure network settings
mkdir -p files/etc/config
cat > files/etc/config/network <<EOF
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fd12:3456:789a::/48'

config interface 'lan'
	option type 'bridge'
	option ifname 'eth0'
	option proto 'static'
	option ipaddr '192.168.5.1'
	option netmask '255.255.255.0'
	option ip6assign '60'
EOF

# Configure wireless settings
cat > files/etc/config/wireless <<EOF
config wifi-device 'radio0'
	option type 'mac80211'
	option channel '36'
	option hwmode '11a'
	option path 'platform/soc/fe300000.mmcnr/mmc_host/mmc1/mmc1:0001/mmc1:0001:1'
	option htmode 'VHT80'
	option country 'CN'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'ImmortalWrt-5G'
	option encryption 'psk2'
	option key 'password123'

config wifi-device 'radio1'
	option type 'mac80211'
	option channel '11'
	option hwmode '11g'
	option path 'platform/soc/fe300000.mmcnr/mmc_host/mmc1/mmc1:0001/mmc1:0001:2'
	option htmode 'HT20'
	option country 'CN'

config wifi-iface 'default_radio1'
	option device 'radio1'
	option network 'lan'
	option mode 'ap'
	option ssid 'ImmortalWrt-2.4G'
	option encryption 'psk2'
	option key 'password123'
EOF

echo "配置完成！"
