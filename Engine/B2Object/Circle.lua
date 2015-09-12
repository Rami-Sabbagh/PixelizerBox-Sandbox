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
local Circle = Class{}:clone(Base)--Create the object while cloning the base.

function Circle:init(world,x,y,radius,static,obj)
  self.world = world
  self.x = x
  self.y = y
  self.obj = obj
  self.radius = radius
  self.static = static
  
  self.type = "Circle"
  
  if self.radius < 5 then
    self.failed = true
    return
  end
    
  if self.static then
    self.body = love.physics.newBody(self.world,self.x,self.y)
  else
    self.body = love.physics.newBody(self.world,self.x,self.y,"dynamic")
  end
    
  self.shape = love.physics.newCircleShape(self.radius)
  self.fixture = love.physics.newFixture(self.body,self.shape)
  self.fixture:setUserData({Type="Circle",Object=self.obj,HoldFlag=false})
end

function Circle:draw(incolor,outcolor,thick)
  local inc, outc, lt = incolor or {255,255,255,255}, outcolor or {175,175,175,255}, thick or 5
  if self.failed then return end
  if not self.body:isActive() then return end
  
  if self.fixture:getUserData().HoldFlag then outc = {0,139,204,outc[4]} end
  
  love.graphics.setColor(inc)
  love.graphics.circle("fill",self.body:getX(),self.body:getY(),self.radius,100)
  love.graphics.setColor(outc)
  love.graphics.setLineWidth(lt)
  love.graphics.circle("line",self.body:getX(),self.body:getY(),self.radius,100)
end

function Circle:destroy()
  self.body:destroy()
  self.failed = true
end

return Circle