local af = Def.ActorFrame {}

af[#af + 1] = Def.Quad {
  InitCommand = function(self)
    self
      :diffuse(0.75, 0.75, 0.75, 1)
      :FullScreen()
  end,
}

af[#af + 1] = Def.Text {
  Font = THEME:GetPathF("", "GreyQo.ttf"),
  Text = "Sea of Clouds\nPresents",
  Size = 64,
  StrokeSize = 2,
  InitCommand = function(self)
    self:Center()
    self:MainActor()
      :diffuse(0, 0, 0, 1)
    self:StrokeActor()
      :diffuse(1, 1, 1, 1)
    self
      :Regen()
      :diffusealpha(0)
      :sleep(1)
      :linear(1)
      :diffusealpha(1)
      :sleep(3)
      :linear(1)
      :diffusealpha(0)
  end,
}

return af
