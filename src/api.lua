local table = require("table")
local os = require("os")
local math = require("math")

local digest = require("openssl").digest
local ltn12 = require("ltn12")
local https = require("ssl.https")
local base64 = require("base64")
local mp = require("MessagePack")
local json = require("cjson")

local util = require("deresute.util")

local VIEWER_ID_KEY = "s%5VNQ(H$&Bqb6#3+78h29!Ft4wSg)ex"
local SID_KEY = "r!I@nt8e5i="

local Api = {}
local api = {}

function Api:call(path, args)
  math.randomseed(os.time())
  local vid_iv = util.str_random(16)
  args["timezone"] = "09:00:00"
  args["viewer_id"] = vid_iv..base64.encode(util.encrypt_cbc(self.viewer_id, VIEWER_ID_KEY, vid_iv))
  local plain = base64.encode(mp.pack(args))
  local key = util.str_random(32)
  local msg_iv = util.get_iv(self.udid)
  local body = util.create_body(args, key, msg_iv)
  local sid = self.sid or (self.viewer_id..self.udid)
  local req_headers = {
    --["Host"] = "apis.game.starlight-stage.jp",
    ["APP-VER"] = "9.0.0",
    ["IP-ADDRESS"] = "127.0.0.1",
    ["X-Unity-Version"] = "2020.3.8f1",
    ["DEVICE"] = "1",
    ["DEVICE-ID"] = digest.digest("md5", "This is a really iPhone ^^"),
    ["GRAPHICS-DEVICE-NAME"] = "Apple A11 GPU",
    ["PARAM"] = digest.digest("sha1", self.udid..self.viewer_id..path..plain),
    ["PLATFORM-OS-VERSION"] = "iOS 14.3",
    ["UDID"] = util.lolfuscate(self.udid),
    ["CARRIER"] = "docomo",
    ["SID"] = digest.digest("md5", sid..SID_KEY),
    ["RES-VER"] = self.res_ver,
    --["IDFA"] = "00000000-0000-0000-0000-000000000000",
    --["UV"] = "0123456789abcdef0123456789abcdef01234567", --何かのsha1?
    --["KEYCHAIN"] = self.viewer_id,
    ["PROCESSOR-TYPE"] = "arm64",
    ["USER-ID"] = util.lolfuscate(tostring(self.user)),
    ["DEVICE-NAME"] = "iPhone10,1",
    --["Connection"] = "keep-alive",
    ["Content-Type"] = "application/octet-stream",
    ["Content-Length"] = #body,
    --["Accept"] = "*/*",
    --["Accept-Encoding"] = "gzip, deflate, br",
    ["User-Agent"] = "BNEI0242/317 CFNetwork/1209 Darwin/20.2.0",
  }
  local res = {}
  local _, code, res_headers, status = https.request {
    url = self.BASE..path,
    sink = ltn12.sink.table(res),
    method = "POST",
    source = ltn12.source.string(body),
    headers = req_headers,
  }
  if code ~= 200 then
    error("status code: "..status)
  end
  local msg = util.unpack_body(table.concat(res), msg_iv)
  self.sid = msg["data_headers"]["sid"]
  return msg
end

function api.new(user, viewer_id, udid, res_ver)
  local self = {}
  setmetatable(self, { __index = Api })
  self.BASE = "https://apis.game.starlight-stage.jp"
  self.user = user
  self.viewer_id = viewer_id
  self.udid = udid
  self.sid = nil
  self.res_ver = res_ver or "10092700"
  return self
end

return api
