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

local Class = require("Helpers.hump.class")
local PhysicsEditor = Class{}

function PhysicsEditor:init(world,modelsMap,bodyName,x,y,bodyImage)
  self.world = world
  self.modelsMap = modelsMap
  self.bodyName = bodyName
  self.x = x
  self.y = y
  self.bodyImage = bodyImage
  
  if self.modelsMap[self.bodyName].static then
    self.body = love.physics.newBody(self.world,self.x,self.y)
  else
    self.body = love.physics.newBody(self.world,self.x,self.y,"dynamic")
  end
  
  self.body:setFixedRotation(self.modelsMap[self.bodyName].fixedRotation)
  self.body:setGravityScale(self.modelsMap[self.bodyName].gravityScale)
  
  self.shapes = {}
  self.fixtures = {}
  
  for k,v in ipairs(self.modelsMap[self.bodyName].fixtures) do
    local shape, fixture
    if v.type == "Circle" then
      shape = love.physics.newCircleShape(v.shape.x, v.shape.y, v.shape.radius)
    elseif v.type == "Polygon" then
      shape = love.physics.newPolygonShape(unpack(v.shape))
    end
    fixture = love.physics.newFixture(self.body,shape)
    fixture:setDensity(v.density)
    fixture:setFriction(v.friction)
    fixture:setRestitution(v.restitution)
    fixture:setFilterData(v.filter.categoryBits,v.filter.maskBits,0)
    fixture:setUserData({Type="PhysicsEditor"})
    table.insert(self.shapes,shape)
    table.insert(self.fixtures,fixture)
  end
end

function PhysicsEditor:draw()
  if self.failed then return end
  if not self.body:isActive() then return end
  
  love.graphics.push()
  love.graphics.setColor(255,255,255,255)
  love.graphics.translate(self.body:getPosition())
  love.graphics.rotate(self.body:getAngle())
  love.graphics.draw(self.bodyImage,0,0)
  love.graphics.pop()
end

function PhysicsEditor:destroy()
  self.body:destroy()
  self.failed = true
end

return PhysicsEditor