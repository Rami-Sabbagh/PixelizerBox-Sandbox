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

local YNF = Class{}

function YNF:init(state,title,text,note,yes,no,closeAble)
  local textWidth, textHeight = _Fonts["Roboto-Bold"][18]:getWidth(text), _Fonts["Roboto-Bold"][18]:getHeight(text)
  local noteWidth, noteHeight = _Fonts["Roboto-Light"][12]:getWidth(note), _Fonts["Roboto-Light"][12]:getHeight(note)
  local yesWidth, yesHeight = _Fonts["Roboto-Light"][12]:getWidth(yes), _Fonts["Roboto-Light"][12]:getHeight(yes)
  local noWidth, noHeight =_Fonts["Roboto-Light"][12]:getWidth(no), _Fonts["Roboto-Light"][12]:getHeight(no)
  
  local frameWidth if textWidth > noteWidth then frameWidth = textWidth+80 else frameWidth = noteWidth+80 end
  local frameHeight = 30+10+textHeight+5+noteHeight+5
  
  if yesHeight > noHeight then frameHeight = frameHeight+yesHeight+10 else frameHeight = frameHeight+noHeight+10 end
  
  self.state = state
  self.frame = loveframes.Create("frame")
  self.frame:SetSize(frameWidth,frameHeight):SetPos(_Width/2,_Height/2,true):SetName(title):SetState(self.state)
  self.frame:SetModal(true):SetDraggable(false):ShowCloseButton(closeAble or false)
  
  self.text = loveframes.Create("text",self.frame)
  self.text:SetShadow(false):SetFont(_Fonts["Roboto-Bold"][18]):SetText(text)
  self.text:SetPos((frameWidth-textWidth)/2,30)
  
  self.note = loveframes.Create("text",self.frame)
  self.note:SetShadow(false):SetFont(_Fonts["Roboto-Light"][12]):SetText(note)
  self.note:SetPos((frameWidth-noteWidth)/2,30+textHeight+5)
  
  local hLargest
  if yesHeight > noHeight then hLargest = yesHeight+5 else hLargest = noHeight+5 end
  
  self.yes = loveframes.Create("button",self.frame)
  self.yes:SetSize(frameWidth/4*1.5-5,hLargest):SetPos(5,30+10+textHeight+5+noteHeight+2):SetText(yes)
  
  self.no = loveframes.Create("button",self.frame)
  self.no:SetSize(frameWidth/4*1.5-5,hLargest)
  self.no:SetPos(frameWidth/4*2.5,30+10+textHeight+5+noteHeight+2):SetText(no)
  
  self.yes.OnClick = function(obj)
    self.frame:Remove()
    if obj.click then obj.click() end
  end
  
  self.no.OnClick = function(obj)
    self.frame:Remove()
    if obj.click then obj.click() end
  end
  
  self.frame.OnClose = function()
    if self.no.click then self.no.click() end
  end
end

return YNF