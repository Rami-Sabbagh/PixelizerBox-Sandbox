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
--Type : Class/API--

local Dimension = require("Engine.Dimension")
local JSON = require("Helpers.json")

---
-- The DimensionManager.
-- Where you register the dimensions.
-- @module DimensionManager
-- @return #DimensionManager
local DM = { dimensions = {} }

---
-- Checks if a dimension exists.
-- 
-- @function [parent=DimensionManager] exists
-- @param self The DimensionManager.
-- @param #string name The dimension name.
-- @return Dimension#Dimension The dimension (may be nil), Can be used as a boolean.
function DM:exists(name)
  if not name then return error("Nil passed as a name !") end
  if not type(name)=="String" then return error("Name can be only a string !, Passed name type : "..type(name)) end
  
  return self.dimensions[name]
end

---
-- Returns a existing dimension
-- 
-- @function [parent=DimensionMananger] getDimension
-- @param self The DimensionManager.
-- @param #string name The dimension name.
-- @return Dimension#Dimension The dimension.
function DM:getDimension(name)
  if not name then return error("Nil passed as a name !") end
  if not type(name)=="String" then return error("Name can be only a string !, Passed name type : "..type(name)) end
  if not self.dimensions[name] then return error("No dimension exists with this name ("..name..") !") end
  
  return self.dimensions[name]
end

---
-- Returns a cloned copy of the dimensions list.
-- IDs as keys, Dimensions as values.
-- 
-- @function [parent=#DimensionManager] getDimensionsList
-- @param self The DimensionManager.
-- @return #table The cloned dimensions list.
function DM:getDimensionsList()
  self:refreshDimensions()
  
  local dimensionsList = {}
  for k,v in pairs(self.dimensions) do
    if v then dimensionsList[k] = v end
  end
  return dimensionsList
end

---
-- Creates a new dimension and registers it automaticaly.
-- 
-- @function [parent=#DimensionManager] newDimension
-- @param self The DimensionManager.
-- @param #string name The new dimension name.
-- @param #table data The data to pass to the new dimension.
-- @return Dimension#Dimension The new dimension.
function DM:newDimension(name,data)
  if not name then return error("Nil passed as a name !") end
  if not type(name)=="String" then return error("Name can be only a string !, Passed name type : "..type(name)) end
  if self.dimensions[name] then return error("Another dimension exists with the same name ("..name..") !") end
  
  local newDimension = Dimension(data)
  self:registerDimension(name,newDimension)
  return newDimension
end

---
-- Registers a dimension created manually.
-- 
-- @function [parent=#DimensionManager] registerDimension
-- @param self The DimensionManager
-- @param #string name The name of the dimension to register at.
-- @param Dimension#Dimension dimension The dimension to register.
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:registerDimension(name,dimension)
  self:refreshDimensions()
  
  if not name then return error("Nil passed as a name !") end
  if not type(name)=="String" then return error("Name can be only a string !, Passed name type : "..type(name)) end
  if self.dimensions[name] then return error("Another dimension exists with the same name ("..name..") !") end
  if not dimension then return error("Nil passed as a dimensions !") end
  if not type(dimension)=="Table" and not type(dimension)=="Userdata" then return error("Dimension can be only a table or a class !, Passed dimension type : "..type(dimension)) end
  
  self.dimensions[name] = dimension
  
  return self
end

---
-- Unregisters a dimension and destroyies it.
-- 
-- @function [parent=#DimensionManager] unregisterDimension
-- @param self The DimensionManager.
-- @param #string name The dimension name to unregister.
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:unregisterDimension(name)
  if not name then return error("Nil passed as a name !") end
  if not type(name)=="String" then return error("Name can be only a string !, Passed name type : "..type(name)) end
  if not self.dimensions[name] then return error("No dimension exists with this name ("..name..") !") end
  self.dimensions[name]:destroy()
  self.dimensions[name] = nil
  
  self:refreshDimensions()
  
  return self
end

---
-- Refreshes the dimension list and clears it from the nils.
-- 
-- @function [parent=#DimensionManager]
-- @param self The DimensionManager.
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:refreshDimensions()
  local newDimensions = {}
  for k,v in pairs(self.dimensions) do
    if v then newDimensinos[k] = v end
  end
  self.dimensions = newDimensions
  
  return self
end

---
-- Saves the dimensions data.
-- TODO Dimension Saving.
-- 
-- @function [parent=#DimensionManager] saveDimensions
-- @param self The DimensionManager
-- @param #string path The path to save at.
-- @param #string author The author of the dimensions save.
-- @param #string discription The discription of the dimension save.
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:saveDimensions(path,author,discription)
  local save = {}
  save.version = 1
  save.author = author or ""
  save.discription = discription or ""
  save.dimensions = {}
  
  for k,v in pairs(self.dimensions) do
    if v then
      save.dimensions[k] = v:getData()
    end
  end
  
  save = JSON:encode(save)
  love.filesystem.write(path,save)
  
  return self
end

---
-- Returns the dimensions save info (Version, Author, Discription).
-- 
-- @function [parent=#DimensionManager] loadInfo
-- @param self The DimensionManager
-- @param #string path The dimensions save path
-- @return #number, #string, #string Version, Author, Discription.
-- @return #nil If the save version is not supported.
function DM:loadInfo(path)
  local save = love.filesystem.read(path)
  save = JSON:decode(save)
  
  if save.version < 1 then
    return error("This level version is too old and not supported any more")
  elseif save.version > 1 then
    return error("This Level version is for a newer version of this game")
  end
  
  if save.version == 1 then
    return save.version, save.author, save.discription
  end
end

---
-- Loads a dimensions save.
-- Note: Destroys all dimensions before loading.
-- 
-- @function [parent=#DimensionManager] loadDimensions
-- @param self The DimensionManager.
-- @param #string path The dimensions save path.
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:loadDimensions(path)
  self:destroyDimensions()
  
  local save = love.filesystem.read(path)
  save = JSON:decode(save)
  if save.version < 1 then
    return error("This level version is too old and not supported any more")
  elseif save.version > 1 then
    return error("This Level version is for a newer version of this game")
  end
  
  if save.version == 1 then
    for k,v in pairs(save.dimensions) do
      if v then
        self:newDimension(k,v)
      end
    end
  end
  
  return self
end

---
-- Updates all registered dimensions.
-- 
-- @function [parent=#DimensionManager] updateDimensions
-- @param self The DimensionManager.
-- @param #number dt The delta time.
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:updateDimensions(dt)
  for k,v in pairs(self.dimensions) do
    if v and v.update then
      v:update(dt)
    end
  end
  
  return self
end

---
-- Destroyes all registered dimensions and clears the list.
-- 
-- @function [parent=#DimensionManager] destroyDimensions
-- @param self The DimensionManager
-- @return DimensionManager#DimensionManager The DimensionManager.
function DM:destroyDimensions()
  for k,v in pairs(self.dimensions) do v:destroy() end
  self.dimensions = {}
end

return DM