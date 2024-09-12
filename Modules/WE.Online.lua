local we = {}
local path = THEME:GetCurrentThemeDirectory().."Online/"

local timeout = 5

local actor = Def.Actor {}

local function send_request(data)
  local now = GetTimeSinceStart()
  local time = 0
  File.Write(path.."receive.txt", "")
  local req = coroutine.create(function(d)
    local j = JsonEncode(d, true)
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
            message = "Timeout"
          }
        }
        coroutine.yield(res)
        break
      end
    end
  end)
  local s, ret = coroutine.resume(req, data)
  return ret
end

function we.ping()
  local packet = {
    command = 0,
    data = {
      message = "Ping"
    }
  }
  return send_request(packet)
end

return we
