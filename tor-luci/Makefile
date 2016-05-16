#
# Copyright (C) 2007-2010 OpenWrt.org
# Copyright (C) 2010 Vertical Communications
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=tor-luci
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-tor
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  DEPENDS:=+luci +tor
  TITLE:=Tor GUI
  URL:=https://www.torproject.org
endef

define Package/luci-app-tor/conffiles
endef

define Package/luci-app-tor/description
 This package contains a graphical interface for Tor management on OpenWrt.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/luci-app-tor/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/torctl.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/tor
	$(INSTALL_DATA) ./files/tor.lua $(1)/usr/lib/lua/luci/model/cbi/tor/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DATA) ./files/tor_status.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DATA) ./files/label.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DATA) ./files/refresh.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DIR) $(1)/etc/tor/
	$(INSTALL_DATA) ./files/torrc.base $(1)/etc/tor/
	$(INSTALL_DATA) ./files/proxy $(1)/etc/tor/
	$(INSTALL_DATA) ./files/bridges $(1)/etc/tor/
	$(INSTALL_BIN) ./files/tor.sh $(1)/etc/tor/
	$(INSTALL_DATA) ./files/tor.firewall $(1)/etc/tor/
endef

$(eval $(call BuildPackage,luci-app-tor))
