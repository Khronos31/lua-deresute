#!/usr/bin/env lua

local string = require("string")
local util = require("deresute.util")

local user_id = util.unlolfuscate(arg[1])
local viewer_id = arg[2]
local udid = util.unlolfuscate(arg[3])
local file = io.open((arg[4] or "account")..".lua", "w")
file:write(string.format([[
return {
   ["user_id"] = "%s",
   ["viewer_id"] = "%s",
   ["udid"] = "%s",
}
]], user_id, viewer_id, udid))
file:close()
