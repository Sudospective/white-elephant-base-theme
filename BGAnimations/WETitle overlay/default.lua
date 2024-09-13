local we = LoadModule("WE.Online.lua")

local af = Def.ActorFrame {}

af[#af + 1] = we

af[#af + 1] = Def.Quad {
  InitCommand = function(self)
    self
      :diffuse(0.75, 0.75, 0.75, 1)
      :FullScreen()
  end,
}

af[#af + 1] = Def.Actor {
  OnCommand = function(self)
    --we.hello(profile_name_here)
  end,
}

return af
