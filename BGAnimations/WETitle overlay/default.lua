local af = Def.ActorFrame {}

af[#af + 1] = Def.Quad {
  InitCommand = function(self)
    self
      :diffuse(0.75, 0.75, 0.75, 1)
      :FullScreen()
  end,
}

af[#af + 1] = Def.Actor {
  OnCommand = function(self)
    --File.Write(THEME:GetCurrentThemeDirectory().."Online/send.txt", "9test")
  end,
}

return af
