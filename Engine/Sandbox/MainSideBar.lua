--Author : Ramilego4Game - This File Is Part Of PixelizerBox--
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
local PlayerManager = require("Engine.PlayerManager")

local INF = require("Engine.Menu.InfoFrame")
local ObjS = require("Engine.Sandbox.ObjectSelect")

local MSB, SandboxAPI = {}

function MSB:build(state)
  SandboxAPI = require("Engine.Sandbox.API")
  
  self.showGUI = true
  
  self.state = state
  self.panel = loveframes.Create("panel")
  self.panel:SetPos(_Width-80,0):SetSize(80,_Height):SetState(self.state)
  
  self.tButton = loveframes.Create("button",self.panel)
  self.tButton:SetPos(5,5):SetSize(20,20):SetText("T"):SetClickable(false)
  
  self.eButton = loveframes.Create("button",self.panel)
  self.eButton:SetPos(30,5):SetSize(20,20):SetText("E"):SetClickable(false)
  
  self.pButton = loveframes.Create("button",self.panel)
  self.pButton:SetPos(55,5):SetSize(20,20):SetText("P"):SetClickable(false)
  
  --self:initBounds(9)
  self:initObjs()
  
  self.qSaveButton = loveframes.Create("button",self.panel)
  self.qSaveButton:SetPos(5,_Height-30):SetSize(20,20):SetText("Q"):SetClickable(false)
  
  self.overlayButton = loveframes.Create("button",self.panel)
  self.overlayButton:SetPos(30,_Height-30):SetSize(20,20):SetText("M"):SetClickable(false) --TODO New overlay for Sandbox
  
  self.helpButton = loveframes.Create("button",self.panel)
  self.helpButton:SetPos(55,_Height-30):SetSize(20,20):SetText("?"):SetClickable(false)
  
  --[[self.overlayButton.OnClick = function()
    LEUI:toggleOverlay()
  end]]
end

function MSB:initObjs()
  self.objs = {}
  for i=0,9 do
    local x, y = 9,i*74+35
    local obj = loveframes.Create("imagebutton",self.panel)
    obj:SetText(""):SetImage(_Images["NewBound"]):SetSize(64,64):SetPos(x,y)
    obj.OnClick = function()
      local OBJSelect = ObjS(self.state)
      OBJSelect.OnSelect = function(name,generator,handler,objtype,objargs,GUIData)
        self:setObj(i,name,GUIData)
      end
    end
    self.objs[i] = obj
  end
end

function MSB:setObj(num,name,GUIData)
  local obj = self.objs[num]
  local ModObjs = ModManager:getObjects()
  if obj:GetType() == "imagebutton" then
    local newObj = loveframes.Create("radiobutton",self.panel)
    newObj:SetPos(9,num*74+35):SetSize(64,64):SetText("")
    newObj.num = num
    newObj.image = ModObjs[name].thumbimage
    newObj.objName = name
    newObj.GUIMain = GUIData["_GUIMain"] GUIData["_GUIMain"]=nil
    newObj.GUIData = GUIData
    newObj.draw = function(object)
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
      
      newObj.Update = function(object,dt)
        local checked = object:GetChecked()
        local hover = object:GetHover()
        
        if (hover or (checked and self.showGUI)) and object.GUIMain then
          if not object.guiPanel then
            object.guiPanel = loveframes.Create("panel")
            object.guiPanel:SetState(self.state):SetSize(200,270):SetPos(_Width-285,5)
            
            object.GUIMain:SetParent(object.guiPanel)
            object.GUIMain:SetVisible(true):SetPos(5,5):SetSize(190,260)
            object.GUIMain:update(0)
          end
        else
          if object.guiPanel and object.GUIMain then
            object.guiPanel:SetVisible(false)
            object.GUIMain:SetVisible(false)
            object.guiPanel = nil
          end
        end
      end
    end
    
    newObj.OnChanged = function(object,state)
      if not state then return end
      if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
        local OBJSelect = ObjS(self.state,true)
        OBJSelect.OnSelect = function(name,generator,handler,objtype,objargs,objgui,GUIData)
          self:setObj(num,name,GUIData)
        end
        return
      end
      SandboxAPI:setObject(PlayerManager:getUserPlayerID(),object.objName,object.GUIData)
    end
    if not self.objsGroup then self.objsGroup = newObj:GetGroup() end
    newObj:SetGroup(self.objsGroup)
    self.objs[num] = newObj
    
    obj:Remove()
  else
    self:UnCheckAll()
    obj.image = ModObjs[name].thumbimage
    obj.objName = name
  end
end

function MSB:toggleGUI()
  self.showGUI = not self.showGUI
end

function MSB:UnCheckAll()
  for k,obj in pairs(self.objs) do
    if obj:GetType() == "radiobutton" then
      obj:SetChecked(false)
    end
  end
end

return MSB