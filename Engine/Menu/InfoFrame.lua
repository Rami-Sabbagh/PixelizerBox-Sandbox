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

local INF = Class{}

function INF:init(state,title,text,ignore)
  local textWidth, textHeight = _Fonts["Roboto-Bold"][14]:getWidth(text), _Fonts["Roboto-Bold"][14]:getHeight(text)
  local igWidth, igHeight = _Fonts["Roboto-Light"][12]:getWidth(ignore), _Fonts["Roboto-Light"][12]:getHeight(ignore)
  
  local frameWidth = textWidth+80
  local frameHeight = 30+10+textHeight+5+igHeight+5
  
  self.state = state
  self.frame = loveframes.Create("frame")
  self.frame:SetSize(frameWidth,frameHeight):SetPos(_Width/2,_Height/2,true):SetName(title):SetState(self.state)
  self.frame:SetModal(true):SetDraggable(false)
  
  self.text = loveframes.Create("text",self.frame)
  self.text:SetShadow(false):SetFont(_Fonts["Roboto-Bold"][14]):SetText(text)
  self.text:SetPos((frameWidth-textWidth)/2,30)
  
  self.ignore = loveframes.Create("button",self.frame)
  self.ignore:SetSize(frameWidth-10,igHeight+10):SetPos(5,30+textHeight+2):SetText(ignore)
  
  self.ignore.OnClick = function(obj)
    self.frame:Remove()
    if obj.click then obj.click() end
  end
  
  self.frame.OnClose = function()
    if self.ignore.click then self.ignore.click() end
  end
end

return INF