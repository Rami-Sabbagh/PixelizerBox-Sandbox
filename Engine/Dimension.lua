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
local B2World = require("Engine.B2World")
local B2Rectangle = require("Engine.B2Object.Rectangle")
local ModManager = require("Engine.ModManager")
local PlayerManager = require("Engine.PlayerManager")

local Signal = require("Helpers.hump.signal")
local Class = require("Helpers.hump.class")

---
-- Dimension Class.
-- Responsable of the World + Players + Objects.
-- 
-- @module Dimension
-- @extends Class#Class
-- @return #Dimension

--- @type Dimension
-- @field B2World#B2World world [parent=#Dimension] The love.physics world object.
local Dimension = Class{}

---
-- Creates new dimension.
-- 
-- @callof Dimension#Dimension
-- @param self This dimension.
-- @param #table data Data to load.
-- @return Dimension#Dimension The new dimension.
function Dimension:init(data)
  self.world = B2World()
  self.spawnBase = B2Rectangle(self.world:getWorld(),-64,128,128,64,true)
  self.objects = {}
  self.handlers = {}
end

---
-- Draws the spawnBase & the registered objects of this Dimension.
-- This is not called automaticaly !
-- 
-- @function [parent=#Dimension] draw
-- @param self This dimension.
-- @return Dimension#Dimension This dimension.
function Dimension:draw()
  self.spawnBase:draw({0,0,0,0},{100,100,100,255},11)
  
  for k,object in pairs(self.objects) do
    if object and self.handlers[k] and self.handlers[k].drawBack then
      self.handlers[k]:drawBack()
    end
  end
  
  for k,object in pairs(self.objects) do
    if object and self.handlers[k] and self.handlers[k].draw then
      self.handlers[k]:draw()
    end
  end
  
  self.spawnBase:draw({70,120,255,255},{0,0,0,0},0)
  
  return self
end

---
-- Updates the dimension B2World & Its objects.
-- Not call automaticaly ! But can be handled by the DimensionManager.
-- 
-- @function [parent=#Dimension] update
-- @param self This dimension.
-- @param number dt The delta time.
-- @return Dimension#Dimension This dimension.
function Dimension:update(dt)
  self.world:update(dt)
  for k,object in pairs(self.objects) do
    if object and self.handlers[k] and self.handlers[k].update then
      self.handlers[k]:update(dt)
    end
  end
  
  return self
end

---
-- Register a object to be handled by this dimension.
-- 
-- @function [parent=#Dimension] registerObject
-- @param self This dimension.
-- @param #Generator object The generator.
-- @param #Handler handler The handler.
-- @return Dimension#Dimension This dimension.
function Dimension:registerObject(object,handler)
  self.objects[#self.objects+1] = object
  self.handlers[#self.objects] = handler
  
  return self
end

---
-- Refreshs the objects & handlers tables.
-- Clears them from nil values and changes the order of them.
-- Used to prevend a bug where objects get replaced.
-- 
-- @function [parent=#Dimension] refreshObjectSystem
-- @param self This dimension.
-- @return Dimension#Dimension This dimension.
function Dimension:refreshObjectSystem()
  local newObjects, newHandlers = {}, {}
  for id,object in pairs(self.objects) do
    if object then
      table.insert(newObjects,#newObjects+1,object)
      table.insert(newObjects,#newObjects,self.handlers[id])
    end
  end
  
  return self
end

---
-- TODO Dimension Saving.
-- @function [parent=#Dimension] getData
-- @param self This dimension.
function Dimension:getData()
  
end

---
-- Invokes all objects and deletes the hoverd objects.
-- 
-- @function [parent=#Dimension] deletePoint
-- @param self This dimension.
-- @param #number x The point x position.
-- @param #number y The point y position.
-- @return Dimension#Dimension This dimension.
function Dimension:deletePoint(x,y)
  for id,handler in pairs(self.handlers) do
    if handler and handler.invokePoint and handler:invokePoint(x,y) then
      if handler.destroy then handler:destroy() end
      self.objects[id] = false
      self.handlers[id] = false
      self:refreshObjectSystem()
    end
  end
  
  return self
end

---
-- Returns the B2World of this dimension.
-- 
-- @function [parent=#Dimension] getWorld
-- @param self This dimension.
-- @return B2World#B2World The B2World of this dimension.
function Dimension:getWorld()
  return self.world
end

---
-- Destroies this dimension & Its registered objects.
-- 
-- @function [parent=#Dimension] destroy
-- @param self This dimension.
-- @return Dimension#Dimension This destroyed dimension (DO NOT USE)
function Dimension:destroy()
  for id,handler in pairs(self.handlers) do
    if handler and handler.destroy then handler:destroy() end
    self.objects[id] = false
    self.handlers[id] = false
  end
  self:refreshObjectSystem()
  
  self.spawnBase:destroy()
  self.world:destroy()
  
  return self
end

return Dimension