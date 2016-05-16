# tor-hmavpn-luci
Collection of OpenWRT packages for Tor and HMA

To use these packages you need to add this feed to your openwrt feeds list
dy adding following line in openwrt_source_tree/feeds.conf.default file:
src-git tor https://github.com/unomano/tor.git

Update/download all feeds:
./scripts/feeds update

Install all (-a) packages from this feed (-p) tor:
./scripts/feeds install -a -p tor

Then select needed packages in menuconfig and make the firmware.
