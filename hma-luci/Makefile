#
# Copyright (C) 2015 Promwad.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=hma-luci
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-hma
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  DEPENDS:=+luci +openvpn-openssl +wget +unzip
  TITLE:=Hide My Ass! configuration module
  URL:=https://www.hidemyass.com
endef

define Package/luci-app-hma/conffiles
/etc/config/hma
endef

define Package/luci-app-hma/description
 This package contains a graphical interface for HMA management on OpenWrt.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/luci-app-hma/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/hmactl.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/hma
	$(INSTALL_DATA) ./files/hma.lua $(1)/usr/lib/lua/luci/model/cbi/hma/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./files/public_ip.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/hma.config $(1)/etc/config/hma
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/hma.sh $(1)/usr/bin/hma.sh
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/hma.init $(1)/etc/init.d/hma
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/luci-hma $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/hmavpn $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(INSTALL_DATA) ./files/hma.png $(1)/www/luci-static/resources
	$(INSTALL_DIR) $(1)/etc/openvpn
	$(INSTALL_DATA) ./files/hma.list $(1)/etc/openvpn
	$(INSTALL_DATA) ./files/vpn-config.zip $(1)/etc/openvpn
endef

$(eval $(call BuildPackage,luci-app-hma))
