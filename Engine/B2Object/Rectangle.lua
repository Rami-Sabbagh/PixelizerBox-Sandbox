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
local Rectangle = Class{}:clone(Base) --Create the object while cloning the base.

function Rectangle:init(world,x,y,width,height,static,obj,lightworld)
  self.world = world
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.static = static
  self.obj = obj
  self.lightworld = lightworld
  
  self.type = "Rectangle"
  
  if self.width < 10 and self.width > -10 then
    self.failed = true
    return
  end
   
  if self.height < 10 and self.height > -10 then
    self.failed = true
    return
  end
  
  if self.static then
    self.body = love.physics.newBody(self.world,self.x,self.y)
  else
    self.body = love.physics.newBody(self.world,self.x,self.y,"dynamic")
  end
    
  self.shape = love.physics.newPolygonShape(0,0,self.width,0,self.width,self.height,0,self.height)
  self.fixture = love.physics.newFixture(self.body,self.shape)
  self.fixture:setUserData({Type="Rectangle",Object=self.obj,HoldFlag=false})
  if self.lightworld then
    self.lightObj = self.lightworld.newPolygon(0,0,self.x-1,self.y-1,self.width+1,self.height+1)
  end
end

function Rectangle:draw(incolor,outcolor,outThick)
  if self.failed then return end
  if not self.body:isActive() then return end
  incolor = incolor or {255,255,255,255}
  outcolor = outcolor or {175,175,175,255}
  
  if self.fixture:getUserData().HoldFlag then outcolor = {0,139,204,outcolor[4]} end
  
  love.graphics.setColor(incolor)
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
  love.graphics.setColor(outcolor)
  love.graphics.setLineWidth(outThick or 5)
  love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end

function Rectangle:update(dt)
  if self.lightworld then
    self.lightObj.setPoints(self.body:getWorldPoints(self.shape:getPoints()))
  end
end

function Rectangle:destroy()
  self.body:destroy()
  self.failed = true
end

return Rectangle