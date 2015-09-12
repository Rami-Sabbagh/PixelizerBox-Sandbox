--This file is part of PixelizerBox--
--[[
  * Copyright 2015 RamiLego4Game
  * 
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  * 
  *     http://www.apache.org/licenses/LICENSE-2.0
  * 
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
--]]

--Type : Hump-Class/API--
local Class = require("Helpers.hump.class")
local loveframes = require("Helpers.loveframes")

local TP = Class{}

function TP:init(state,x,y,width,height,center,parent)
  self.state = state
  self.parent = parent
  
  self.buttons = {}
  
  self.panel = loveframes.Create("panel",self.parent)
  self.panel:SetState(self.state):SetSize(width,height):SetPos(x,y,center)
end

function TP:refreshButtons()
  local Width = self.panel:GetWidth()/(#self.buttons)
  for k,v in ipairs(self.buttons) do
    v:SetPos((k-1)*Width,0):SetSize(Width,self.panel:GetHeight())
  end
end

function TP:newButton(text,action)
  local button = loveframes.Create("button",self.panel)
  button:SetText(text)
  if action then button.OnClick = action else button:SetClickable(false) end
  table.insert(self.buttons,button)
  self:refreshButtons()
  return button
end

return TP