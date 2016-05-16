module("luci.controller.torctl", package.seeall)

function index()
    require("luci.i18n")
    local i18n = luci.i18n.translate

    local page = node("admin", "services", "tor")
    page.target = alias("admin", "services", "tor")
    page.order = 70
    page.index = true
    page.title = i18n("Tor")

    page = entry({"admin", "services", "tor"}, cbi("tor/tor", {hideresetbtn=true, hideapplybtn=true}), i18n("Tor"), 1)
    page.leaf = true
    page.subindex = true

    page = entry({"admin", "status", "tor"}, template("tor_status"), i18n("Tor"), 20)
    page.leaf = true
    
    page = entry({"admin", "status", "torrestart"}, call("restart_tor"), nil)
end

function fork_exec(command)
	local pid = nixio.fork()
	if pid > 0 then
		return
	elseif pid == 0 then
		-- change to root dir
		nixio.chdir("/")

		-- patch stdin, out, err to /dev/null
		local null = nixio.open("/dev/null", "w+")
		if null then
			nixio.dup(null, nixio.stderr)
			nixio.dup(null, nixio.stdout)
			nixio.dup(null, nixio.stdin)
			if null:fileno() > 2 then
				null:close()
			end
		end

		-- replace with target command
		nixio.exec("/bin/sh", "-c", command)
	end
end

function restart_tor()
        local reboot = luci.http.formvalue("reboot")
        fork_exec("/etc/tor/tor.sh reload; sleep 5")
        luci.template.render("tor_status", {reboot=reboot})
end
