local we = {}
local path = THEME:GetCurrentThemeDirectory().."Online/"

local timeout = 5
local status = "invalid"
local ping = 0

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

local function send_request(packet, response)
  response = response or true
  if status ~= "connected" then
    err("Not connected.")
    return
  end
  local now = GetTimeSinceStart()
  local time = 0
  File.Write(path.."receive.txt", "")
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
  local s, ret = coroutine.resume(req, packet)
  if ret and response then MESSAGEMAN:Broadcast("Response", ret) end
end

local function receive_request()
  --[[
    TODO: figure out this part
    (is this even needed?) ~Sudo
  --]]
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
  if ret.command == -1 then
    err(ret.data.message..".")
  elseif ret.command == server_offset + 0 then -- Ping
    local packet = {
      command = 1,
      data = {
        message = "Pong"
      }
    }
    send_request(packet, false)
  elseif ret.command == server_offset + 1 then -- Ping Response
    ping = ret.data.delay
    print("WEOnline", "Ping took "..ping.."ms.")
  elseif ret.command == server_offset + 2 then -- Hello
    status = ret.status
    if status == "connected" then
      msg("Connected to server.")
    elseif status == "inactive" then
      err("Unable to connect to server.")
    elseif status == "unknown" then
      err("Unknown connection status.")
    end
  elseif ret.command == server_offset + 3 then -- Client Event (DO NOT SEND PACKET HERE)
    local action = ret.data.action
    if action == 0 then
      if ret.data.message == "Success" then
        print("WEOnline", "Successfully joined room.")
      end
    end
  elseif ret.command == server_offset + 4 then -- Server Event
    local action = ret.data.action
    if action == 0 then
      PrintTable(res.data.players)
      packet = {
        command = 4,
        data = {
          action == 0,
          message == "OK"
        }
      }
      send_request(packet, false)
    end
  elseif ret.command == server_offset + 5 then -- White Elephant Event
    local action = ret.data.action
  elseif ret.command == server_offset + 6 then -- StepMania Event
    local action = ret.data.action
  end
end

for k, v in pairs(we) do
  if type(v) == "function" then actor[k] = v end
end

return actor
