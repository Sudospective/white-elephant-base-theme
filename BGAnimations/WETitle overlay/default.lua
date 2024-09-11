local af = Def.ActorFrame {}

local online_dir = THEME:GetCurrentThemeDirectory().."Online/"

af[#af + 1] = Def.Quad {
  InitCommand = function(self)
    self
      :diffuse(0.75, 0.75, 0.75, 1)
      :FullScreen()
  end,
}

af[#af + 1] = Def.Actor {
  OnCommand = function(self)
    local j = {
      command = 0,
      message = "Ping"
    }
    File.Write(online_dir.."receive.txt", "");
    File.Write(online_dir.."send.txt", JsonEncode(j, true))
    local res = ""
    while res == "" do
      res = File.Read(online_dir.."receive.txt")
    end
    res = JsonDecode(res)
  end,
}

return af
