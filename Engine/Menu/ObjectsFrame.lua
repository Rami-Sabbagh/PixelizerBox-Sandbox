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
local B2Rectangle = require("Engine.B2Object.Rectangle")

local OF = Class{}

function OF:init(state,world,x,y,center)
  self.state = state
  
  self.frame = loveframes.Create("frame")
  self.frame:SetState(self.state):SetSize(200,200):SetPos(x,y,center):ShowCloseButton(false):SetScreenLocked(true)
  self.frame:SetName("Objects"):SetDockable(true):SetIcon("Helpers/loveframes/skins/Flat/images/expand.png")
  
  self.frame.physics = B2Rectangle(world,x,y,200,200,true)
  self.frame.Update = function(object,dt)
    object.physics.body:setPosition(object:GetPos())
  end
  
  self.frame.OnClose = function(object)
    object.physics.body:setActive(false)
  end
  
  self.tabsframe = loveframes.Create("tabs",self.frame)
  self.tabsframe:SetPos(0,25):SetSize(200,175)
  
  self.onChange = function(objName) end
  
  self.tabs = {}
  self.objectsButtons = {}
end

function OF:newTab(Name,ToolTip,Image)
  local list = loveframes.Create("list")
  list:EnableHorizontalStacking(true):SetPadding(5):SetSpacing(15)
  --list:SetSize(200,270)
  self.tabsframe:AddTab(Name,list,ToolTip,Image)
  self.tabs[Name] = list
end

function OF:newObject(TabName,Name,Image)
  local radiobutton = loveframes.Create("radiobutton")
  --imagebutton:SetImage(Image):SetText(""):SizeToImage()
  --imagebutton.objectName = Name
  radiobutton.image = Image
  radiobutton.name = Name
  if not self.objectsgroup then self.objectsgroup = radiobutton:GetGroup() end
  radiobutton:SetGroup(self.objectsgroup)
  radiobutton:SetText(""):SetSize(64,64)
  
  radiobutton.draw = function(object)
    local x = object:GetX()
    local y = object:GetY()
    local width = object:GetBoxWidth()
    local height = object:GetBoxHeight()
    local checked = object:GetChecked()
    local hover = object:GetHover()
    
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(object.image,x,y)
    
    if checked then
      love.graphics.setColor(20,70,255,255)
      love.graphics.setLineWidth(5)
      love.graphics.rectangle("line",x,y,width,height)
    end
    
    if hover then
      love.graphics.setColor(70,120,255,255)
      love.graphics.setLineWidth(3)
      love.graphics.rectangle("line",x,y,width,height)
    end
  end
  
  radiobutton.OnChanged = function(object,state)
    if not state then return end
    self.onChange(object.name)
  end
  
  self.tabs[TabName]:AddItem(radiobutton)
  self.objectsButtons[Name] = radiobutton
end

function OF:uncheckAll()
  for k,v in pairs(self.objectsButtons) do
    v:SetChecked(false)
  end
end

return OF