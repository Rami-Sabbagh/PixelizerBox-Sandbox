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

--Requirements--
local loveframes = require("Helpers.loveframes")
local JSON = require("Helpers.json")

---
-- ModManager for mods loading.
-- 
-- @module ModManager
-- @return #ModManager

--- @type ModManager
local MM = {}

---
-- Loads the .mod files for tabs, objects, etc...
-- 
-- @function [parent=#ModManager] loadBasicMods
-- @param self The ModManager.
-- @return ModManager#ModManager The ModManager.
function MM:loadBasicMods()
  self.Mods = {}
  self.Generators = {}
  self.GeneratorsGUIs = {}
  self.GeneratorsHandlers = {}
  local EngineGenerators = loveframes.util.GetDirectoryContents("/Engine/Generators")
  for k,v in ipairs(EngineGenerators) do
    if v.extension == "lua" then
      self.Generators[v.name] = require(v.requirepath)
    end
  end
  
  local EngineGeneratorsGUIs = loveframes.util.GetDirectoryContents("/Engine/GeneratorsGUIs")
  for k,v in ipairs(EngineGeneratorsGUIs) do
    if v.extension == "gui" then
      self.GeneratorsGUIs[v.name] = JSON:decode(love.filesystem.read(v.fullpath))
    end
  end
  
  local EngineGeneratorsHandlers = loveframes.util.GetDirectoryContents("/Engine/GeneratorsHandlers")
  for k,v in ipairs(EngineGeneratorsHandlers) do
    if v.extension == "lua" then
      self.GeneratorsHandlers[v.name] = require(v.requirepath)
    end
  end
  
  local ModsFolder = love.filesystem.getDirectoryItems("/Mods/")
  for k,name in ipairs(ModsFolder) do
    if love.filesystem.isDirectory("/Mods/"..name) then
      if love.filesystem.exists("/Mods/"..name.."/Generators") and love.filesystem.isDirectory("/Mods/"..name.."/Generators") then
        local ModGenerators = loveframes.util.GetDirectoryContents("/Mods/"..name.."/Generators/")
        for k,v in ipairs(ModGenerators) do
          if v.extension == "lua" then
            self.Generators[v.name] = require(v.requirepath)
          end
        end
      end
      
      if love.filesystem.exists("/Mods/"..name.."/Handlers") and love.filesystem.isDirectory("/Mods/"..name.."/Handlers") then
        local ModHandlers = loveframes.util.GetDirectoryContents("/Mods/"..name.."/Handlers/")
        for k,v in ipairs(ModHandlers) do
          if v.extension == "lua" then
            self.GeneratorsHandlers[v.name] = require(v.requirepath)
          end
        end
      end
    end
  end
  
  local ModsGeneratorsGUIs = loveframes.util.GetDirectoryContents("/Mods/")
  for k,v in ipairs(ModsGeneratorsGUIs) do
    if v.extension == "gui" then
      self.GeneratorsGUIs[v.name] = JSON:decode(love.filesystem.read(v.fullpath))
    end
  end
  
  local EngineMods = loveframes.util.GetDirectoryContents("/Engine/EngineMods/")
  for k,v in ipairs(EngineMods) do
    if v.extension == "mod" then
      self:loadMod(v.fullpath)
    end
  end
  
  local ModsDir = loveframes.util.GetDirectoryContents("/Mods/")
  for k,v in ipairs(ModsDir) do
    if v.extension == "mod" then
      self:loadMod(v.fullpath)
    end
  end
  
  return self
end

---
-- Runs the main.lua file inside /Mods/A Mod/SRC/.
-- 
-- @function [parent=#ModManager] runSRCs
-- @param self The ModManager.
-- @return ModManager#ModManager The ModManager.
function MM:runSRCs()
  local ModsFolder = love.filesystem.getDirectoryItems("/Mods/")
  for k,name in ipairs(ModsFolder) do
    if love.filesystem.isDirectory("/Mods/"..name) then
      if love.filesystem.exists("/Mods/"..name.."/SRC") and love.filesystem.isDirectory("/Mods/"..name.."/SRC") then
        if love.filesystem.exists("/Mods/"..name.."/SRC/main.lua") and love.filesystem.isFile("/Mods/"..name.."/SRC/main.lua") then
          require("Mods."..name..".SRC.main")
        end
      end
    end
  end
  
  return self
end

---
-- Loads the .mod files from folder path given.
-- 
-- @function [parent=#ModManager] loadMod
-- @param self The ModManager.
-- @param #string path The path to the folder to load from.
-- @return ModManager#ModManager The ModManager.
function MM:loadMod(path)
  print("Loading Mod With Path : "..path)
  local RawJSON = love.filesystem.read(path)
  local ArrayJSON = JSON:decode(RawJSON)
  
  if ArrayJSON.tabs then
    for k,v in pairs(ArrayJSON.tabs) do
      if not v.thumbname then v.thumbname = "NullTabThumb" end
      if not _Images[v.thumbname] then v.thumbname = "NullTabThumb" end
      v.thumbimage = _Images[v.thumbname]
    end
  end
  
  if ArrayJSON.objects then
    for k,v in pairs(ArrayJSON.objects) do
      print("----------Loading Object: "..k)
      v.generatorName = v.generator
      v.handlerName = v.handler
      print("Generator Name: "..v.generatorName)
      
      if self.GeneratorsGUIs[v.generator] and self.GeneratorsGUIs[v.generator][v.handler] then v.gui = self.GeneratorsGUIs[v.generator][v.handler] end
      v.generator = self.Generators[v.generator][v.handler]
      v.handler = self.GeneratorsHandlers[v.handler]
      if not v.args then v.args = {} end
      print("Generator: "..tostring(v.generator))
      
      if not v.thumbname then v.thumbname = "NullObjectThumb" end
      if not _Images[v.thumbname] then v.thumbname = "NullObjectThumb" end
      v.thumbimage = _Images[v.thumbname]
      print("Thumb: "..tostring(v.thumbimage))
    end
  end
  
  self.Mods[ArrayJSON.meta.aurthor.."_"..ArrayJSON.meta.modname] = ArrayJSON
  
  return self
end

---
-- Returns a list containing the tabs.
-- Key -> Tab Name, Value.tooltip -> The tooltip of the tab, Value.thumbimage -> The icon of the tab.
-- 
-- @function [parent=#ModManager] getTabs
-- @param self The ModManager.
-- @return #table The tabs table.
function MM:getTabs()
  local Tabs = {}
  for modname,mod in pairs(self.Mods) do
    if mod.tabs then
      for tabname,tab in pairs(mod.tabs) do
        Tabs[tabname] = tab
      end
    end
  end
  
  return Tabs
end

---
-- Returns a list containing the tabs.
-- Key -> Object Name, Value.generatorName -> The name of the generator, Value.handlerName -> The name of the handler.
-- Value.generator -> The generator class, Value.handler -> The handler class, Value.args -> The args of the object.
-- Value.thumbimage -> The thumb image of the object.
-- 
-- @function [parent=#ModManager] getObjects
-- @param self The ModManager.
-- @return #table The objects table.
function MM:getObjects()
  local Objs = {}
  for modname,mod in pairs(self.Mods) do
    if mod.objects then
      for objname,obj in pairs(mod.objects) do
        Objs[objname] = obj
      end
    end
  end
  
  return Objs
end

return MM