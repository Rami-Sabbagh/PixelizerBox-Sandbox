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

local Class = require("Helpers.hump.class") --Require the class library.
local Base = require("Engine.B2Object") --Require the base object.
local Edge = Class{}:clone(Base) --Create the object while cloning the base.

function Edge:init(world,x1,y1,x2,y2,static,obj,lightworld)
  self.world = world
  self.x1 = x1
  self.y1 = y1
  self.x2 = x2
  self.y2 = y2
  self.width = self.x2 - self.x1
  self.height = self.y2 - self.y1
  self.static = static
  self.lightworld = lightworld
  
  self.obj = obj
  self.type = "Edge"
  
  if self.width < 10 and self.width > -10 and self.height < 10 and self.height > -10 then
    self.failed = true
    return
  end
  
  if self.static then
    self.body = love.physics.newBody(self.world,self.x1,self.y1)
  else
    self.body = love.physics.newBody(self.world,self.x1,self.y1,"dynamic")
  end
  
  self.shape = love.physics.newEdgeShape(0,0,self.width,self.height)
  self.fixture = love.physics.newFixture(self.body,self.shape)
  self.fixture:setUserData({Type="Edge",Object=self.obj,HoldFlag=false})
  if self.lightWorld then
    self.lightObj = self.lightworld.newRectangle(self.x1+self.width/2,self.y1+self.height/2,self.width,self.height)
  end
end

function Edge:draw(color,thick)
  if self.failed then return end
  if not self.body:isActive() then return end
  local c = color or {175,175,175,255}
  local t = thick or 5
  
  love.graphics.setColor(c)
  love.graphics.setLineWidth(t)
  love.graphics.line(self.body:getWorldPoints(self.shape:getPoints()))
end

function Edge:destroy()
  self.body:destroy()
  self.failed = true
end

return Edge