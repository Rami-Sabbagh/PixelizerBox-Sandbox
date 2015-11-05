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
local RectHC = Class{}

local MathUtils = require("Engine.MathUtils")
local DimensionManager = require("Engine.DimensionManager")
local B2Rectangle = require("Engine.B2Object.Rectangle")

function RectHC:init(x,y,dimName,snap,GUIData)
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.snap = snap
  self.guiData = GUIData
  
  self.startX, self.startY  = x,y
  self.endX, self.endY = x,y
end

function RectHC:create(x,y)
  self.endX, self.endY = x,y
  
  self.object = B2Rectangle(self.world:getWorld(),self.startX,self.startY,
    self.endX-self.startX,self.endY-self.startY,self.guiData["Static"])
  
  
  if not self.object.failed then
    self.object.fixture:setFriction(self.guiData["Friction"] or 1)
    self.object.fixture:setRestitution(self.guiData["Restitution"] or 0)
    return true
  else
    self.object = nil
    return false
  end
end

function RectHC:draw(mx,my)
  if self.dead then return end
  if self.object then self.object:draw() return end
  
  self.endX, self.endY = mx,my
  
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("fill",self.startX,self.startY,self.endX-self.startX,self.endY-self.startY)
  
  love.graphics.setColor(175,175,175,255)
  love.graphics.setLineWidth(5)
  love.graphics.rectangle("line",self.startX,self.startY,self.endX-self.startX,self.endY-self.startY)
end

function RectHC:invokePoint(x,y)
  if not self.object or self.dead then return end
  return MathUtils.isInRect(x,y,self.startX,self.startY,self.endX-self.startX,self.endY-self.startY)
end

function RectHC:destroy()
  self.object:destroy()
  self.dead = true
end

local RectOL = Class{}

function RectOL:init(dimName,snap,GUIData,width,height)
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.snap = snap
  self.guiData = GUIData
  
  self.width, self.height = width, height
end

function RectOL:setSnap(SNAP)
  self.snap = SNAP
end

function RectOL:create(x,y)
  self.x, self.y = x, y
  
  self.object = B2Rectangle(self.world:getWorld(),x-self.width/2,y-self.height/2,self.width,self.height,self.guiData["Static"])
  
  if not self.object.failed then
    self.object.fixture:setFriction(self.guiData["Friction"] or 1)
    self.object.fixture:setRestitution(self.guiData["Restitution"] or 0)
    return true
  else
    self.object = nil
    return false
  end
end

function RectOL:draw(mx,my)
  if self.dead then return end
  if self.object then self.object:draw() return end
  
  self.x, self.y = mx, my
  
  love.graphics.setColor(255,255,255,150)
  love.graphics.rectangle("fill",self.x-self.width/2,self.y-self.height/2,self.width,self.height)
  
  love.graphics.setColor(175,175,175,150)
  love.graphics.setLineWidth(5)
  love.graphics.rectangle("line",self.x-self.width/2,self.y-self.height/2,self.width,self.height)
end

function RectOL:invokePoint(x,y)
  if not self.object or self.dead then return end
  return MathUtils.isInRect(x,y,self.x-self.width/2,self.y-self.height/2,self.width,self.height)
end

function RectOL:destroy()
  self.object:destroy()
  self.dead = true
end

return {HoldCreate=RectHC, Overlay=RectOL}