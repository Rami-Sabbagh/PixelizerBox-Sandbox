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
local ModManager = require("Engine.ModManager")

local OL = Class{}

function OL:init(parent,x,y,width,height,center)
  self.parent = parent
  
  self.tabsframe = loveframes.Create("tabs",self.parent)
  self.tabsframe:SetPos(x,y):SetSize(width,height)
  
  self.tabs = {}
  self.objectsButtons = {}
  
  local ModsTabs = ModManager:getTabs()
  for tabname,tab in pairs(ModsTabs) do
    self:newTab(tabname,tab.tooltip,tab.thumbimage)
  end
  
  local ModsObjects = ModManager:getObjects()
  for objname,obj in pairs(ModsObjects) do
    self:newObject(obj.tab,objname,obj.generator,obj.handler,obj.thumbimage,obj.type,obj.args,obj.gui)
  end
end

function OL:newTab(Name,ToolTip,Image)
  local list = loveframes.Create("list")
  list:EnableHorizontalStacking(true):SetPadding(5):SetSpacing(15)
  self.tabsframe:AddTab(Name,list,ToolTip,Image)
  self.tabs[Name] = list
end

function OL:newObject(TabName,Name,Generator,Handler,Image,Type,Args,GUI)
  local radiobutton = loveframes.Create("radiobutton")
  radiobutton.image = Image
  radiobutton.name = Name
  radiobutton.generator = Generator
  radiobutton.handler = Handler
  radiobutton.objargs = Args or {}
  radiobutton.objtype = Type
  radiobutton.gui = GUI
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
    local image = object.image
    local imagewidth, imageheight = image:getDimensions()
      
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(object.image,x+width/2,y+height/2,0,1,1,imagewidth/2,imageheight/2)
    
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
    if not state or not self.onChange then return end
    self.onChange(object.name,object.generator,object.handler,object.objtype,object.objargs,object.gui)
  end
  
  self.tabs[TabName]:AddItem(radiobutton)
  self.objectsButtons[Name] = radiobutton
end

function OL:uncheckAll()
  for k,v in pairs(self.objectsButtons) do
    v:SetChecked(false)
  end
end

return OL