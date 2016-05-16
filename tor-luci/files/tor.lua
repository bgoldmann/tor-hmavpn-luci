--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

fs = require "nixio.fs"
require("luci.sys")                                                                    
require("luci.util")                                                                         
require("luci.cbi")

m = Map("system", translate("Tor Status and Configuration"),
	translate(""))

m:chain("luci")

local init_path = "/etc/rc.d/S50tor"

s = m:section(TypedSection, "system", translate(""))
s.anonymous = true
s.addremove = false



s:tab("torstatus",  translate("Tor Status"))                                              
s:tab("bridge",  translate("Bridge Configuration"))                                                       
s:tab("proxy", translate("Proxy Configuration"))
s:tab("advanced", translate("Advanced Configuration"))


--[[=======================TOR STATUS===============]]--

-- if enabled
if fs.access(init_path) then
	tor_restart_button = s:taboption("torstatus", Button, "_list", translate(""))
	tor_restart_button.inputtitle = translate("Restart Tor")
	tor_restart_button.inputstyle = "reload"
	tor_restart_button.rmempty = true
	function tor_restart_button.write(self, section)
		luci.http.redirect(luci.dispatcher.build_url("admin", "status", "torrestart") .. "?reboot=1")
	end

	stop = s:taboption("torstatus", Button, "_stop", translate(""))
	stop.inputtitle = translate("Stop Tor")
	stop.inputstyle = "remove"
	stop.write = function(self, section)
		luci.sys.call("/etc/tor/tor.sh stop")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "tor"))
	end
else
	start = s:taboption("torstatus", Button, "_start", translate(""))
	start.inputtitle = translate("Start Tor")
	start.inputstyle = "apply"
	start.write = function(self, section)
		luci.http.redirect(luci.dispatcher.build_url("admin", "status", "torrestart") .. "?reboot=1")
	end
end

function s.on_apply(self, section)
    luci.sys.call('/etc/tor/tor.sh reload')
end

tor_refresh = s:taboption("torstatus", Button, "_list", "")
tor_refresh.template = "refresh"


tor_status = s:taboption("torstatus", Value, "_data", "")                                                                                                                                                             
tor_status.legend = translate("Tor Connection Status")
tor_status.template = "label"

tor_rec = s:taboption("torstatus", Value, "_data","" )
tor_rec.legend = "Tor Version"
tor_rec.template = "label"

tor_bw = s:taboption("torstatus", Value, "_data", "")
tor_bw.legend = translate("Tor Bandwidth")
tor_bw.template = "label"

tor_circ = s:taboption("torstatus", Value, "_data", "")
tor_circ.legend = "Tor Circuit Status"
tor_circ.template = "label" 

function tor_status.cfgvalue()                                                                                                                                                                                                  
        returnstring = ""                                                                                                                                                                                                 
	sock = nixio.socket("inet", "stream")
        if sock and sock:connect("127.0.0.1", 9051) then
            res, data = tor_request("AUTHENTICATE \"\"\r\n")
            if not res then
                    returnstring = returnstring .. data 
            end
-- Is tor connected and circuits established
            res, data = tor_request("GETINFO status/circuit-established\r\n")
            if not res then
                    returnstring = returnstring .. data
            end
            status = string.sub(data, string.find(data,"=%d*"))
            if status == "=1" then 
                returnstring = returnstring .. "Connected to the Tor network"
            else 
                returnstring = "Not connected to the Tor network (please allow up to 60 seconds if you have just applied changes, then click 'Refresh')"
            end
	else
            returnstring = "Tor Not running"
	end                                                                                                                                                                                                                      
        sock:close()
	return translate(returnstring)                                                                                                                                                                                               
                                                                                                                                                                                                                          
end   

function tor_rec.cfgvalue()                                     
        returnstring = ""                                                                                        
	sock = nixio.socket("inet", "stream")                                                                                                                 
        if sock and sock:connect("127.0.0.1", 9051) then            
            res, data = tor_request("AUTHENTICATE \"\"\r\n")       
            if not res then                                                  
               returnstring = returnstring .. data                      
            end                                                              

-- current verion 
            res, data = tor_request("GETINFO version\r\n")
            if not res then
                    returnstring = returnstring .. data
                return returnstring
            else
                returnstring = returnstring .. string.match(data, "%d.%d.%d.%d+") .. " : "

            end 
-- current verion recomended            
            res, data = tor_request("GETINFO status/version/current\r\n")
            if not res then
                    returnstring = returnstring .. data
                return returnstring
            else
                returnstring = returnstring .. string.match(data,"%w+",string.find(data,"="))
            end  	
        else                                                                                                 
            returnstring = "Tor Not running"                                                                 
        end                                                                                 
        sock:close()                                                                            
        return returnstring                                                         
                                                                                    
end 

function tor_bw.cfgvalue()                                                  
        returnstring = ""                                       
        sock = nixio.socket("inet", "stream")                                
        if sock and sock:connect("127.0.0.1", 9051) then                                                                 
            res, data = tor_request("AUTHENTICATE \"\"\r\n")                 
            if not res then                                                  
               returnstring = returnstring .. data                           
            end                                                              
            res, data = tor_request("SETEVENTS bw\r\n")
            if not res then
                    returnstring = returnstring .. data
	    end
            res, data = tor_request("")

            if not res then
                    returnstring = returnstring .. data
            else
                   returnstring = returnstring ..  string.gsub(data,"^650 BW ","")
            end
		    
        else                                                                        
            returnstring = "Tor not running"                                        
        end                                                                                                                                                                                                               
                                                                                    
        return translate(returnstring)                                                         
                                                                              
end 


function tor_circ.cfgvalue()                                                         
        returnstring = ""                                                           
        sock = nixio.socket("inet", "stream")                                                
        if sock and sock:connect("127.0.0.1", 9051) then                                                                            
            res, data = tor_request("AUTHENTICATE \"\"\r\n")                        
            if not res then                                                                                      
               returnstring = returnstring .. data                                                               
               return                                                                                            
            end                                                                 
                                                                   
            res, data = tor_request("GETINFO circuit-status\r\n")
            if not res then
                    returnstring = returnstring .. data
                else
                    returnstring = returnstring .. "Circuits: " .. string.gsub(string.gsub(string.gsub(data,"\r\n250 .+$",""),"^250\+[^\n]*",""),"\n.\r","") .. "\n"
            end
                                                                                             
            res, data = tor_request("QUIT\r\n")                                              
        else                                                                                                 
            returnstring = "Tor not running"                                                                 
        end                                                                                  
        sock:close()                                                                         
                                                                                             
        return translate(returnstring)                                                                  
                                                                                             
end


function s.cfgsections()
      return { "_pass" }
end


function tor_request(command)
        if not sock:send(command) then
                return false, translate("Cannot send the command to Tor")
        end
        reply = ""
        resp = sock:recv(1000)
        while resp do
                reply = reply .. resp
                if string.len(resp) < 1000 then break end
                resp = sock:recv(1000)
        end

        if not resp then
                return false, translate("Cannot read the response from Tor")
        end
        i, j = string.find(reply, "^%d%d%d")
        if j ~= 3 then
                return false, "Malformed response from Tor"
        end
        code = string.sub(reply, i, j)
        if code ~= "250" and (code ~= "650" or command ~= "") then
                return false, "Tor responded with an error: " .. reply
        end

        return true, reply
end

--[[======================= BRIDGE CONFIG ===============]]--

bridge_config = s:taboption("bridge", TextValue, "_data",translate("Bridge Configuration"),translate("Please enter in the bridges you want Tor to use.<br>The format is : \"ip:port [fingerprint]\" where fingerprint is optional.<br> e.g. 121.101.27.4:443 4352e58420e68f5e40ade74faddccd9d1349413.<br> To get bridge information, see <a href=\"https://bridges.torproject.org/bridges\">the Tor bridges page</a>.")) 
bridge_config.wrap    = "off"                                                                                                                     
bridge_config.rows    = 3                                                                                                                         
bridge_config.cleanempty = true                                                                                                                     
bridge_config.optional = true
                                                                                                                                         
function bridge_config.cfgvalue()                                                                                                                 
	returnstring = ""
	file = io.open("/etc/tor/bridges", "r")
	while true do
		line = file:read()
		if line == nil then break end
		if line ~= "UseBridges 1" then 
			returnstring = returnstring .. line:gsub("Bridge ", "") .. "\n"
		end
	end

	return returnstring
	
end                                                                                                                                      

function bridge_config.write(self, section, value)                                                                                                
	os.execute("echo -n > /etc/tor/bridges")
	formatted = ""
	if value and #value > 5 then
		formatted = "UseBridges 1\n" .. value:gsub("\r\n", "\n")
		formatted = formatted:gsub("\n\n", "")
		formatted = formatted:gsub("\n", "\nBridge ")
		formatted = formatted:gsub("Bridge \n", "")
		fs.writefile("/etc/tor/bridges", formatted )
	end
end




--[[======================= PROXY CONFIG ===============]]--
proxy_config = s:taboption("proxy", ListValue, "proxy_config", translate("Proxy Type"))                                                                         
proxy_config:value("None")      
proxy_config:value("HTTP/HTTPS")  
proxy_config:value("SOCKS4")
proxy_config:value("SOCKS5")

proxy_file_string = nil
local ip_from_file, port_from_file, username_from_file, password_from_file

function proxy_config.cfgvalue()
	file = io.open("/etc/tor/proxy", "r")
	proxy_config.default = "None"
	proxy_address.default = ""
	while true do
		if (file) then
		 
			line = file:read()
			if line == nil then break end

			if line:find("HTTPSProxy ") then
				proxy_config.default = "HTTP/HTTPS"	
				colonpos,j = line:find(":")
				ip_from_file = line:sub(12,colonpos - 1)
				port_from_file = line:sub(colonpos + 1)
			elseif line:find("Socks4Proxy ") then
				proxy_config.default = "SOCKS4"
				colonpos,j = line:find(":")                                                              
                                ip_from_file = line:sub(13,colonpos - 1)                                                 
                                port_from_file = line:sub(colonpos + 1)
			elseif line:find("Socks5Proxy ") then
				proxy_config.default = "SOCKS5"
				colonpos,j = line:find(":")                                                              
                                ip_from_file = line:sub(13,colonpos - 1)                                                 
                                port_from_file = line:sub(colonpos + 1)
			elseif line:find("Socks5ProxyUsername ") then
				username_from_file = line:sub(21)
			elseif line:find("Socks5ProxyPassword ") then
				password_from_file = line:sub(21)	
			elseif line:find("HTTPSProxyAuthenticator ") then
				colonpos, j = line:find(":")
				username_from_file = line:sub(25, colonpos-1)
				password_from_file = line:sub(colonpos + 1)
			end
		else
			--create it
			file = io.open("/etc/tor/proxy", "w")
			file:write("")
			file:close()
		end
	end
end

function proxy_config.write(self, section, value)                                                                                             
	if (value == "None") then
		os.execute('rm /etc/tor/proxy')
		os.execute('touch /etc/tor/proxy')
        elseif (value == "HTTP/HTTPS") then                                                                                                   
                proxy_file_string = "HTTPSProxy "
        elseif (value == "SOCKS4") then                                                                                                       
		proxy_file_string = "Socks4Proxy "
        elseif (value == "SOCKS5") then                                                                                                                                   
		proxy_file_string = "Socks5Proxy "
        end                                                                                                                                   
end

proxy_address = s:taboption("proxy", Value, "proxy_address", translate("Proxy IP Address"))
proxy_address.placeholder = "192.168.1.5"                                                  
proxy_address.datatype = "ip4addr"

function proxy_address.cfgvalue()
	if (ip_from_file ~= nil) then
		proxy_address.default = ip_from_file	
	else
		proxy_address.default = ""
	end
end

function proxy_address.write(self, section, value)
	if proxy_file_string ~= nil then
		proxy_file_string = proxy_file_string .. value .. ":"
	end
end

proxy_port = s:taboption("proxy", Value, "proxy_port", translate("Port"))
proxy_port.placeholder = "80"
proxy_port.datatype = "port"
proxy_port.rmempty = true

function proxy_port.cfgvalue()                                                                                                             
                                                                                                                                              
end                                                                                                                                           
                                                                                                                                              
function proxy_port.write(self, section, value)                                                                                            
	proxy_port.default = port_from_file
        if proxy_file_string ~= nil then                                                                                                      
                proxy_file_string = proxy_file_string .. value .. "\n"                                                                         
		--proxy_file_string = proxy_file_string .. "ReachableAddresses *:80,*:443\nReachableAddresses reject *:*\n"
		fs.writefile("/etc/tor/proxy", proxy_file_string)
        end                                                                                                                                   
end


proxy_username = s:taboption("proxy", Value, "proxy_username", translate("Username"))
proxy_username.placeholder = "optional"
proxy_username.optional = true

function proxy_username.cfgvalue()                                                                                                                
	proxy_username.default = username_from_file                                                                                                                                              
end                                                                                                                                           
                                                                                                                                              
function proxy_username.write(self, section, value)                                                                                               
        if (proxy_file_string ~= nil and value ~= nil) then
		if (proxy_file_string:find("HTTP")) then
			proxy_file_string = proxy_file_string .. "HTTPSProxyAuthenticator " .. value .. ":"
		elseif (proxy_file_string:find("Socks5")) then
			proxy_file_string = proxy_file_string .. "Socks5ProxyUsername " .. value .. "\n"
		end
        end                                                                                                                                   
end


proxy_password = s:taboption("proxy", Value, "proxy_password", translate("Password"))
proxy_password.placeholder = "optional"
proxy_password.password = true
proxy_password.optional = true

function proxy_password.cfgvalue()                                                                                                            
	proxy_password.default = password_from_file                                                                                                                                              
end                                                                                                                                           
                                                                                                                                              
function proxy_password.write(self, section, value)                                                                                           
        if (proxy_file_string ~= nil and value ~= nil) then                                                                                   
                if (proxy_file_string:find("HTTPSProxyAuthenticator")) then
                        proxy_file_string = proxy_file_string .. value .. "\n"
                elseif (proxy_file_string:find("Socks5ProxyUsername")) then
                        proxy_file_string = proxy_file_string .. "Socks5ProxyPassword " .. value .. "\n"
		end                                                                                                                                   
	
		fs.writefile("/etc/tor/proxy", proxy_file_string)
	end
end

--[[======================= ADVANCED CONFIG ===============]]--

advanced_config = s:taboption("advanced", TextValue, "torrcbase",translate("Advanced Configuration"),translate("Please enter in custom configuration."))
advanced_config.wrap    = "off"
advanced_config.rows    = 20
advanced_config.cleanempty = true
advanced_config.optional = true

function advanced_config.cfgvalue()
	return fs.readfile("/etc/tor/torrc.base")
end

function advanced_config.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile("/etc/tor/torrc.base", value)
end

return m

