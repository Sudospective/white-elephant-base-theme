local we = {}
local path = THEME:GetCurrentThemeDirectory().."Online/"

local timeout = 5
local status = "invalid"
local ping = 0
local sending = false

local server_offset = 128
GAMESTATE:Env().WEOnlineID = GAMESTATE:Env().WEOnlineID or CRYPTMAN:GenerateRandomUUID()
local id = GAMESTATE:Env().WEOnlineID

local actor = Def.ActorFrame {}

local function msg(m)
  SCREENMAN:SystemMessage("WEOnline: "..m)
end

local function err(m)
  SCREENMAN:SystemMessage("WEOnline Error: "..m)
end

local function switch(val)
  return function(t)
    if not t[val] then
      if t._ then t._() end
      return
    end
    t[val]()
  end
end

local function send_request(packet, response)
  sending = true
  response = response or true
  if status ~= "connected" then
    err("Not connected.")
    return
  end
  File.Write(path.."receive.txt", "")
  local now = GetTimeSinceStart()
  local time = 0
  local req = coroutine.create(function(p)
    local j = JsonEncode(p, true)
    File.Write(path.."send.txt", j)
    while true do
      time = time + (GetTimeSinceStart() - now)
      now = GetTimeSinceStart()
      local res = File.Read(path.."receive.txt")
      if res ~= "" then
        coroutine.yield(JsonDecode(res))
        break
      end
      if time > timeout then
        res = {
          command = -1,
          data = {
            message = "Connection timed out"
          }
        }
        coroutine.yield(res)
        break
      end
    end
  end)
  local _, ret = coroutine.resume(req, packet)
  if ret and response then MESSAGEMAN:Broadcast("Response", ret) end
  sending = false
end

local function receive_request()
  --[[
    TODO: figure out this part
    (is this even needed?) ~Sudo
  --]]
  if sending then return end
  local packet = File.Read(path.."receive.txt")
  if packet == "" then return end
  MESSAGEMAN:Broadcast("Response", packet)
end

function we.get_status()
  return status
end

function we.ping()
  local packet = {
    command = 0,
    data = {
      message = "Ping"
    }
  }
  send_request(packet)
end
function we.hello(name) -- must be called first
  local packet = {
    command = 2,
    data = {
      message = "Hello",
      name = name,
      ID = id
    }
  }
  send_request(packet)
end
function we.client_event(info)
  local packet = {
    command = 3,
    data = {
      message = "Client Event",
    }
  }
  for k, v in pairs(info) do
    packet.data[k] = v
  end
  send_request(packet)
end

actor.OnCommand = function(self)
  self:SetUpdateFunction(receive_request)
end

actor.ResponseMessageCommand = function(self, ret)
  print("WEOnline", "Command "..ret.command.." received.")
  switch (ret.command) {
    -- Error
    [-1] = function()
      err(ret.data.message..".")
    end,
    -- Ping
    [server_offset + 0] = function()
      local packet = {
        command = 1,
        data = {
          message = "Pong"
        }
      }
      send_request(packet, false)
    end,
    -- Ping Response
    [server_offset + 1] = function()
      ping = ret.data.delay
      print("WEOnline", "Ping took "..ping.."ms.")
    end,
    -- Hello
    [server_offset + 2] = function()
      switch (ret.status) {
        connected = function()
          msg("Connected to server.")
        end,
        inactive = function()
          err("Unable to connect to server.")
        end,
        unknown = function()
          err("Unknown connection status.")
        end,
      }
    end,
    -- Client Event (DO NOT SEND PACKET HERE)
    [server_offset + 3] = function()
      switch (ret.data.action) {
        [0] = function()
          if ret.data.message == "Success" then
            print("WEOnline", "Successfully joined room.")
          end
        end,
      }
    end,
    -- Server Event
    [server_offset + 4] = function()
      switch (ret.data.action) {
        [0] = function()
          PrintTable(ret.data.players)
          local packet = {
            command = 4,
            data = {
              action = 0,
              message = "OK",
            },
          }
          send_request(packet, false)
        end
      }
    end,
    -- White Elephant Event
    [server_offset + 5] = function()
      switch (ret.data.action) {
  
      }
    end,
    -- StepMania Event
    [server_offset + 6] = function()
      switch (ret.data.action) {
  
      }
    end,
  }
end

for k, v in pairs(we) do
  if type(v) == "function" then actor[k] = v end
end

return actor
