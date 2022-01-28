local string = require("string")
local os = require("os")
local math = require("math")

local cipher = require("openssl").cipher
local base64 = require("base64")
local mp = require("MessagePack")

local util = {}

function util.hex2bytes(str)
  return (str:gsub("..", function(cc) return string.char(tonumber(cc, 16)) end))
end

function util.bytes2hex(str)
  return (str:gsub(".", function(c) return string.format("%02x", string.byte(c)) end))
end

function util.str_random(num)
  math.randomseed(os.time())
  local s = ""
  for i = 1, num do
    s = s..string.format("%x", math.random(0x0, 0xf))
  end 
  return s 
end

function util.decrypt_cbc(str, key, iv)
  return cipher.decrypt("aes-256-cbc", str, key, iv)
end

function util.encrypt_cbc(str, key, iv)
  return cipher.encrypt("aes-256-cbc", str, key, iv)
end

function util.lolfuscate(str)
  math.randomseed(os.time())
  return (string.format("%04x%s%s", #str, str:gsub(".", function(c) return string.format("%02d%c%d", math.random(0, 99), c:byte() + 10, math.random(0, 9)) end), util.str_random(32)))
end

function util.unlolfuscate(str)
  return (string.gsub(str:sub(5, 4 + tonumber(str:sub(1, 4), 16) * 4) ,"..(.).", function(c) return string.char(c:byte() - 10) end))
end

function util.get_iv(udid)
  return util.hex2bytes(udid:gsub("-", ""))
end

function util.create_body(obj, key, iv)
  local body = ""
  body = base64.encode(mp.pack(obj))
  body = base64.encode(util.encrypt_cbc(body, key, iv)..key)
  return body
end

function util.unpack_body(str, iv)
  local data = base64.decode(str)
  data = util.decrypt_cbc(data:sub(1, -33), data:sub(-32), iv)
  data = mp.unpack(base64.decode(data))
  return data
end

return util
