local we = LoadModule("WE.Online.lua")

local handler = function(self)
  return function(event)
    self:queuecommand(event.GameButton..ToEnumShortString(event.type))
  end
end

local af = Def.ActorFrame {
  OnCommand = function(self)
    self
      :sleep(7)
      :queuecommand("InitInput")
  end,
  InitInputCommand = function(self)
    SCREENMAN:GetTopScreen():AddInputCallback(handler(self))
  end,
  OffCommand = function(self)
    SCREENMAN:GetTopScreen():RemoveInputCallback(handler(self))
  end,
}

af[#af + 1] = we

-- Background
af[#af + 1] = Def.Quad {
  InitCommand = function(self)
    self
      :diffuse(0.75, 0.75, 0.75, 1)
      :FullScreen()
  end,
}

-- Input Actor
af[#af + 1] = Def.Actor {
  StartFirstPressCommand = function(self)
    self
      :sleep(2)
      :queuecommand("NextScreen")
  end,
  NextScreenCommand = function(self)
    SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
  end,
}

-- Title Text
af[#af + 1] = Def.ActorFrame {
  InitCommand = function(self)
    self
      :x(SCREEN_CENTER_X)
      :y(SCREEN_TOP + 200)
      :wag()
      :effectmagnitude(0, 0, 2)
      :effectperiod(4.5)
      :addy(-SCREEN_HEIGHT * 1.5)
      :sleep(2)
      :easeoutexpo(3)
      :addy(SCREEN_HEIGHT * 1.5)
  end,
  Def.Text {
    Font = THEME:GetPathF("", "GreyQo.ttf"),
    Text = "White Elephant 2024",
    Size = 64,
    StrokeSize = 2,
    InitCommand = function(self)
      self:MainActor()
        :diffuse(0, 0, 0, 1)
      self:StrokeActor()
        :diffuse(1, 1, 1, 1)
      self:Regen()
    end,
    StartFirstPressCommand = function(self)
      self
        :easeoutexpo(1)
        :zoom(4)
        :diffusealpha(0)
    end,
  },
}

-- Start Text
af[#af + 1] = Def.Text {
  Font = THEME:GetPathF("", "Urbanist.ttf"),
  Text = "Press Start",
  Size = 32,
  StrokeSize = 2,
  InitCommand = function(self)
    self
      :x(SCREEN_CENTER_X)
      :y(SCREEN_BOTTOM - 200)
    self:MainActor()
      :diffuse(0, 0, 0, 1)
    self:StrokeActor()
      :diffuse(1, 1, 1, 1)
    self
      :Regen()
      :diffusealpha(0)
      :sleep(6)
      :linear(1)
      :diffusealpha(1)
  end,
  StartFirstPressCommand = function(self)
    self
      :easeoutexpo(1)
      :zoom(4)
      :diffusealpha(0)
  end,
}

return af
