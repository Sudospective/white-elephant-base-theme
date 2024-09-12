local we = LoadModule("WE.Online.lua")

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
    local res = we.ping()
    SCREENMAN:SystemMessage(res.data.message)
  end,
}

return af
