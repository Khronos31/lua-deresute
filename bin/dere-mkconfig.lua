#!/usr/bin/env lua

local os = require("os")
local string = require("string")
local util = require("deresute.util")

local function print_usage()
   io.stdout:write([[
Usage  : dere-mkconfig USER-ID viewer_id UDID [filename]
Example: dere-mkconfig '000922;458<440=225>056?031@449A697B470C436976440915779f7b70b507cb5d11555' 123456789 '002477;710<783=200>949?710@307A503B9617680;570<758=849>6027605;180<890=958>7147563;630<701=326>0337868;140<391=918>462?206@634A849B278C098:967;656<9cc1cd30e7b16180f9ac8bc9c7a0a02cd' producer
]])
end

if #arg < 3 then
   print_usage()
   os.exit(1)
end

local user_id = util.unlolfuscate(arg[1])
local viewer_id = arg[2]
local udid = util.unlolfuscate(arg[3])
local file = io.open((arg[4] or "account")..".lua", "w")
file:write(string.format([[
return {
   user_id = "%s",
   viewer_id = "%s",
   udid = "%s",
}
]], user_id, viewer_id, udid))
file:close()
