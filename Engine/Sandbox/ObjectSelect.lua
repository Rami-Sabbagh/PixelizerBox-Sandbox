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
local ObjectsList = require("Engine.Menu.ObjectsList")

local ModManager = require("Engine.ModManager")

local ObjS = Class{}

function ObjS:init(state,noclose)
  self.state = state
  self.frame = loveframes.Create("frame")
  self.frame:SetState(self.state):SetSize(420,400):SetPos(_Width/2,_Height/2,true):SetName("Select Object"):SetModal(true)
  self.frame:SetDraggable(false)
  if noclose then self.frame:ShowCloseButton(false) end
  
  self.modsObjects = {}
  local ModsObjects = ModManager:getObjects()
  for objname,obj in pairs(ModsObjects) do
    self.modsObjects[objname] = {tab=obj.tab,generator=obj.generator,handler=obj.handler,thumbimage=obj.thumbimage,type=obj.type,args=obj.args}
  end
  
  self.objList = ObjectsList(self.frame,5,30,410,365)
  self.objList.onChange = function(name,generator,handler,objtype,objargs,objgui)
    --self.setButton:SetClickable(true)
    self.selectedObjData = {name,generator,handler,objtype,objargs,{},self.modsObjects[name].thumbimage}
    local guiData = self:setGUI(objgui,name)
    
    self:hideGUI()
    self.frame:Remove()
    if self.OnSelect then self.OnSelect(unpack(self.selectedObjData)) end
  end
  
  self.objsGUI = {}
end

function ObjS:hideGUI()
  if not self.selectedGUI then return end
  
  self.selectedGUI.main:SetVisible(false)
end

function ObjS:buildGUI(gui,name)
  --if not self.gui then self:destroyGUI() end
  local object = ModManager:getObjects()[name]
  
  self.sorted = {}
  
  self.objsGUI[name] = {}
  self.objsGUI[name].main = loveframes.Create("list",self.frame)
  self.objsGUI[name].main:SetPos(420,30):SetSize(190,330)
  
  self.objsGUI[name].gen = loveframes.Create("text")
  self.objsGUI[name].gen:SetFont(_Fonts["Roboto-Bold"][16]):SetText("Generator: "..object.generatorName)
  self.objsGUI[name].main:AddItem(self.objsGUI[name].gen)
  
  self.objsGUI[name].hand = loveframes.Create("text")
  self.objsGUI[name].hand:SetFont(_Fonts["Roboto-Light"][12]):SetText("Handler: "..object.handlerName)
  self.objsGUI[name].main:AddItem(self.objsGUI[name].hand)
  self.objsGUI[name].objs = {}
  
  self.selectedObjData[6]["_GUIMain"] = self.objsGUI[name].main
  
  if gui then
    self.objsGUI[name].paddingPanel = loveframes.Create("panel")
    self.objsGUI[name].paddingPanel:SetHeight(5)
    self.objsGUI[name].main:AddItem(self.objsGUI[name].paddingPanel)
    
    for k,v in pairs(gui) do
      self.sorted[v.id] = k
    end
    
    for k,v in ipairs(self.sorted) do
      local d = gui[v]
      if d.type == "Number Box" then
        local nb = loveframes.Create("numberbox")
        nb:SetSize(d.width,d.height):SetMin(d.min):SetMax(d.max):SetValue(d.value)
        nb.OnValueChanged = function(object,value) self.selectedObjData[6][v] = value end
        
        self.objsGUI[name].main:AddItem(nb)
        
        self.selectedObjData[6][v] = d.value
        table.insert(self.objsGUI[name].objs,nb)
      elseif d.type == "Slider" then
        local s = loveframes.Create("slider")
        if d.direction == "v" then
          s:SetSlideType("vertical"):SetHeight(d.length)
        end
        s:SetMin(d.min):SetMax(d.max):SetValue(d.value):SetDecimals(d.decimals)
        
        s.draw = function(object)
          local skin = object:GetSkin()
          local x, y = object:GetPos()
          local width = object:GetWidth()
          skin.DrawSlider(object)
          
          love.graphics.setColor(32,32,32,255)
          love.graphics.setFont(_Fonts["Roboto-Light"][12])
          local tw = _Fonts["Roboto-Light"][12]:getWidth(object:GetValue().."/"..object:GetMax())
          local th = _Fonts["Roboto-Light"][12]:getHeight(object:GetValue().."/"..object:GetMax())
          love.graphics.print(object:GetValue().."/"..object:GetMax(),(x+width)-tw,y-th)
          
          skin.DrawSliderButton(object:GetInternals()[1])
        end
        
        s.OnValueChanged = function(object,value) self.selectedObjData[6][v] = value end
        
        self.objsGUI[name].main:AddItem(s)
        
        self.selectedObjData[6][v] = d.value
        table.insert(self.objsGUI[name].objs,s)
      elseif d.type == "Text" then
        local t = loveframes.Create("text")
        if d.largFont == "v" then t:SetFont(_Fonts["Roboto-Bold"][16]) else t:SetFont(_Fonts["Roboto-Light"][12]) end
        t:SetText(d.text)
        
        local p1, p2
        
        p1 = loveframes.Create("panel")
        p1:SetHeight(2)
          
        if d.autoSpace then
          p2 = loveframes.Create("panel")
          p2:SetHeight(3)
        end
        
        self.objsGUI[name].main:AddItem(p1)
        self.objsGUI[name].main:AddItem(t)
        if d.autoSpace then self.objsGUI[name].main:AddItem(p2) end
        
        --self.selectedObjData[6][v] = d.text
        table.insert(self.objsGUI[name].objs,p1)
        table.insert(self.objsGUI[name].objs,t)
        if d.autoSpace then table.insert(self.objsGUI[name].objs,p2) end
      elseif d.type == "Space" then
        local p = loveframes.Create("panel")
        p:SetHeight(v.length)
        
        self.objsGUI[name].main:AddItem(p)
        
        --self.selectedObjData[6][v] = d.length
        table.insert(self.objsGUI[name].objs,p)
      elseif d.type == "Check Box" then
        local p = loveframes.Create("panel")
        p:SetHeight(30)
        
        local cb = loveframes.Create("checkbox",p)
        cb:SetY(5):SetText(d.text):SetChecked(d.default)
        
        cb.OnChanged = function(object,value) self.selectedObjData[6][v] = value end
        
        self.objsGUI[name].main:AddItem(p)
        
        self.selectedObjData[6][v] = d.default
        table.insert(self.objsGUI[name].objs,p)
      end
    end
  else
    self.objsGUI[name].noPanel = loveframes.Create("panel")
    self.objsGUI[name].noPanel:SetHeight(250)
    
    self.objsGUI[name].noText = loveframes.Create("text", self.objsGUI[name].noPanel)
    self.objsGUI[name].noText:SetFont(_Fonts["Roboto-Bold"][16]):SetText("There is no object options\n            available :|"):Center()
    self.objsGUI[name].main:AddItem(self.objsGUI[name].noPanel)
    
    self.selectedObjData[6]["_GUIMain"] = nil
  end
  
  for k,v in pairs(self.objsGUI[name]) do
    if k ~= "objs" then
      v:update(0)
    end
  end
  
  for k,v in ipairs(self.objsGUI[name].objs) do
    if v:GetType() == "slider" then v:SetValue(v:GetValue()) end
    v:update(0)
  end
  
  return self.objsGUI[name]
end

function ObjS:setGUI(gui,name)
  if self.objsGUI[name] then
    if self.selectedGUI then self:hideGUI(self.selectedGUI) end
    self.selectedGUI = self.objsGUI[name]
    self.selectedGUI.main:SetVisible(true)
  else
    if self.selectedGUI then self:hideGUI(self.selectedGUI) end
    self.selectedGUI = self:buildGUI(gui,name)
  end
end

return ObjS