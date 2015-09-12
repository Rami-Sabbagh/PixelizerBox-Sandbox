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
local Player = Class{}

function Player:init(world,x,y,id)
  self.world = world
  self.x = x
  self.y = y
  self.id = id
  self.body = love.physics.newBody( self.world, self.x, self.y, "dynamic" )
  self.body:setFixedRotation(true)
  self.shape = love.physics.newPolygonShape( 20,0, 59,0, 75,16, 75,87, 59,103, 20,103, 4,87, 4,16)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  if self.id then
    self.fixture:setUserData({Type="Player",ID=self.id})
  else
    self.fixture:setUserData({Type="PlayerBody"})
  end
end

function Player:destroy()
  self.body:destroy()
end

return Player