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
local MathUtils = require("Engine.MathUtils")
local Class = require("Helpers.hump.class")

---
-- The B2World Class.
-- 
-- @module B2World
-- @extends Class#Class
-- @return #B2World

--- @type B2World
local B2World = Class{}

---
-- Creates new Box2D world.
-- 
-- @callof B2World#B2World
-- @param self The world instance.
-- @param #number GravityX The gravity x of the world.
-- @param #number GravityY The gravity y of the world.
-- @param #number Meter The meter of the world.
-- @param #boolean AllowSleeping To allow object sleeping in the world.
function B2World:init(GravityX,GravityY,Meter,AllowSleeping)
  GravityX, GravityY, Meter = GravityX or 0, GravityY or 9.81, Meter or 64
  GravityX, GravityY = GravityX*Meter, GravityY*Meter
  
  love.physics.setMeter(Meter)
  ---
  -- The love.physics world object.
  -- 
  -- @field world [parent=#B2World] The love.physics world object.
  self.world = love.physics.newWorld(GravityX,GravityY,AllowSleeping or false)
end

---
-- Returns the love.physics world object.
-- 
-- @function [parent = #B2World] getWorld
-- @param self The B2World instance.
-- @return World The love.physics world object.
function B2World:getWorld()
  return self.world
end

---
-- Updates the world.
-- Must be handled.
-- 
-- @function [parent=#B2World] update
-- @param self The B2World instance.
-- @param #number dt The update delta time.
-- @return B2World#B2World This B2World.
function B2World:update(dt)
  self.world:update(dt)
  
  return self
end

return B2World