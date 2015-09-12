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
local SRectHC = Class{}

local MathUtils = require("Engine.MathUtils")
local DimensionManager = require("Engine.DimensionManager")
local B2Rectangle = require("Engine.B2Object.Rectangle")

function SRectHC:init(x,y,dimName,snap,GUIData)
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.snap = snap
  self.guiData = GUIData
  
  self.startX, self.startY  = x,y
  self.endX, self.endY = x,y
end

function SRectHC:create(x,y)
  self.endX, self.endY = x,y
  
  self.object = B2Rectangle(self.world:getWorld(),self.startX,self.startY,self.endX-self.startX,self.endY-self.startY,true)
  
  if not self.object.failed then return true else
    self.object = nil
    return false
  end
end

function SRectHC:draw(mx,my)
  if self.dead then return end
  if self.object then
    self.object:draw({150,150,150,255},{0,0,0,0},0)
    return
  end
  
  self.endX, self.endY = mx, my
  
  love.graphics.setColor(150,150,150,255)
  love.graphics.rectangle("fill",self.startX,self.startY,self.endX-self.startX,self.endY-self.startY)
  
  love.graphics.setColor(100,100,100,255)
  love.graphics.setLineWidth(5)
  love.graphics.rectangle("line",self.startX,self.startY,self.endX-self.startX,self.endY-self.startY)
end

function SRectHC:drawBack()
  if not self.object or self.dead then return end
  
  self.object:draw({0,0,0,0},{100,100,100,255},11)
end

function SRectHC:invokePoint(x,y)
  if not self.object or self.dead then return end
  return MathUtils.isInRect(x,y,self.startX,self.startY,self.endX-self.startX,self.endY-self.startY)
end

function SRectHC:destroy()
  self.object:destroy()
  self.dead = true
end

return {HoldCreate=SRectHC}