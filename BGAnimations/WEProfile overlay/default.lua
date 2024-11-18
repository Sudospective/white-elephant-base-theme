local we = LoadModule("WE.Online.lua")

local handler = function(self)
  return function(event)
    self.Player = ToEnumShortString(event.PlayerNumber)
    self:queuecommand(event.GameButton..ToEnumShortString(event.type))
  end
end

local af = Def.ActorFrame {
  OnCommand = function(self)
    SCREENMAN:GetTopScreen():AddInputCallback(handler(self))
  end,
  OffCommand = function(self)
    SCREENMAN:GetTopScreen():RemoveInputCallback(handler(self))
  end,
}

af[#af + 1] = we

af[#af + 1] = Def.Quad {
  InitCommand = function(self)
    self
      :diffuse(0.75, 0.75, 0.75, 1)
      :FullScreen()
  end,
}

af[#af + 1] = Def.Text {
  Font = THEME:GetPathF("", "GreyQo.ttf"),
  Text = "Enter Name",
  Size = 32,
  StrokeSize = 2,
  InitCommand = function(self)
    self:MainActor()
      :diffuse(0, 0, 0, 1)
    self:StrokeActor()
      :diffuse(1, 1, 1, 1)
    self
      :Regen()
      :xy(SCREEN_LEFT + 105, SCREEN_TOP + 32)
  end,
}

return af
