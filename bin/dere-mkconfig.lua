#!/usr/bin/env lua

local string = require("string")
local util = require("deresute.util")

local udid = util.unlolfuscate(arg[1])
local user = util.unpack_body(arg[2], util.get_iv(udid)).data_headers
local file = io.open("account.lua", "w")
file:write(string.format([[
return {
   ["user_id"] = "%s",
   ["viewer_id"] = "%s",
   ["udid"] = "%s",
}
]], user.user_id, user.viewer_id, udid))
file:close()
