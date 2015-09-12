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
local SoftHC = Class{}

local MathUtils = require("Engine.MathUtils")
local DimensionManager = require("Engine.DimensionManager")
local B2Soft = require("Helpers.loveballs")

function SoftHC:init(x,y,dimName,snap,GUIData)
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.snap = snap
  self.guiData = GUIData
  
  self.x, self.y, self.radius, self.usage  = x,y,0,0
end

function SoftHC:create(x,y)
  self:calcRadius(x,y)
  
  if self.radius < 15 then return end
  
  self.object = B2Soft(self.world:getWorld(),self.x,self.y,self.radius,self.guiData["Smoothing"],self.guiData["Tesselate"])
  self.object:setFrequency(self.guiData["Frequency"] or 5)
  self.object:setDamping(self.guiData["Damping"] or 5)
  self.object:setFriction(self.guiData["Friction"] or 0)
  
  if self.object then return true else
    self.object = nil
    return false
  end
end

function SoftHC:draw(mx,my)
  if self.dead then return end
  if self.object then
    if _DebugKey then
      love.graphics.setColor(175,175,175,255)
      love.graphics.setLineStyle("smooth")
      love.graphics.setLineWidth(1)
      
      for i,v in ipairs(self.object.nodes) do
        love.graphics.circle("line", v.body:getX(), v.body:getY(), self.object.nodeShape:getRadius())
      end
    else
      love.graphics.setColor(75,75,75,255)
      self.object:draw()
      
      love.graphics.setColor(175,175,175,255)
      self.object:draw("line")
    end
    return
  end
  
  self:calcRadius(mx,my)
  
  love.graphics.setColor(75,75,75,255)
  love.graphics.circle("fill",self.x,self.y,self.radius,100)
  
  love.graphics.setColor(175,175,175,255)
  love.graphics.setLineWidth(5)
  love.graphics.circle("line",self.x,self.y,self.radius,100)
end

function SoftHC:drawBack()
  if not self.object or self.dead then return end
  
  love.graphics.setColor(75,75,75,150)
  love.graphics.circle("fill",self.x,self.y,self.radius,100)
  
  love.graphics.setColor(175,175,175,150)
  love.graphics.setLineWidth(5)
  love.graphics.circle("line",self.x,self.y,self.radius,100)
end

function SoftHC:update(dt)
  if self.object and not self.dead then self.object:update(dt) end
end

function SoftHC:calcRadius(x,y)
  self.radius = MathUtils.calcDistance(self.x,self.y,x,y)
  self.used = math.abs(self.radius*2*3.14)
end

function SoftHC:invokePoint(x,y)
  if not self.object or self.dead then return end
  return MathUtils.isInCircle(x,y,self.x,self.y,self.radius)
end

function SoftHC:destroy()
  self.object:destroy()
  self.dead = true
end

return {HoldCreate=SoftHC}