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
local Player = require("Engine.Player")
local Signal = require("Helpers.hump.signal")

---
-- Player Manager.
-- The managing system of the players.
-- 
-- @module PlayerManager
-- @return #PlayerManager
local PlayerManager = {players={}, user=nil}

--- @type PlayerManager
-- @field #table players [parent=#PlayerManager] The table containing all the players objects.
-- @field #nil user [parent=#PlayerManager] The id of the current player using this client.

---
-- Returns The User Player Object.
-- The current player using this client.
-- 
-- @function [parent=#PlayerManager] getUserPlayer
-- @param self The PlayerManager
-- @return Player#Player The player object.
function PlayerManager:getUserPlayer()
  if not self.user then return nil end
  return self.players[self.user]
end

---
-- Returns The User Player ID.
-- The current player using this client.
-- 
-- @function [parent=#PlayerManager] getUserPlayerID
-- @param self The PlayerManager
-- @return #number The User Player ID.
function PlayerManager:getUserPlayerID()
  if not self.user then return nil end
  return self.user
end

---
-- Sets The User Player ID.
-- The current player using this client.
-- 
-- @function [parent=#PlayerManager] setUserPlayerID
-- @param self The PlayerManager
-- @param #number id The User Player ID To Set.
-- @return PlayerManager#PlayerManager The PlayerManager.
function PlayerManager:setUserPlayerID(id)
  self.user = id
  
  return self
end

---
-- Returns the player object with the given id.
-- 
-- @function [parent=#PlayerManager] getPlayer
-- @param self The PlayerManager
-- @param #number id The Player ID.
-- @return Player#Player The player object.
function PlayerManager:getPlayer(id)
  return self.players[id]
end

---
-- Returns the table containing all the players with their IDs as Keys.
-- This is a cloned copy of the one in PlayerManager.
-- 
-- @function [parent=#PlayerManager] getPlayersList
-- @param self The PlayerManger
-- @return #table The players list table
function PlayerManager:getPlayersList()
  local newPlayers = {}
  for k,v in ipairs(self.players) do
    if v then newPlayers[k] = v end
  end
  return newPlayers
end

---
-- Creates a new player and returns the id of the player.
-- 
-- @function [parent=#PlayerManager] createPlayer
-- @param self The PlayerManager.
-- @param #string dimName The dimension name to create the player in.
-- @param #number x The player x position to spawn at.
-- @param #number y The player y position to spawn at.
-- @param #string name The player name.
-- @param #table color A table containing red green blue values.
-- @param Player#Controls controls The controls table of the player.
-- @return #number, Player#Player The player id and his instance.
function PlayerManager:createPlayer(dimName,x,y,name,color,controls)
  self:refreshPlayers()
  return self:registerPlayer(Player(dimName,x,y,name,color,controls,#self.players+1))
end

---
-- Registers a player and returns the id and the player object.
-- 
-- @function [parent=#PlayerManager] registerPlayer
-- @param self The PlayerManager.
-- @param Player#Player player The player to register.
-- @return #number, Player#Player The player id and his instance.
function PlayerManager:registerPlayer(player)
  self:refreshPlayers()
  table.insert(self.players,player)
  return #self.players, player
end

---
-- Unregisters a player.
-- Remember to destroy him manually.
-- 
-- @function [parent=#PlayerManager] unregisterPlayer
-- @param self The PlayerManager
-- @param #number id The player id to unregister
-- @return PlayerManager#PlayerManager The PlayerManager.
function PlayerManager:unregisterPlayer(id)
  self.players[id] = nil
  self:refreshPlayers()
  
  return self
end

---
-- Refreshs the internal players list
-- Used to clear it from nil players and to fix the length of the table.
-- 
-- @function [parent=#PlayerManager] refreshPlayers
-- @param self The PlayerManager
-- @return PlayerManager#PlayerManager The PlayerManager.
function PlayerManager:refreshPlayers()
  local newPlayers = {}
  for k,v in ipairs(self.players) do
    if v then newPlayers[k] = v end
  end
  self.players = newPlayers
  
  return self
end

---
-- Destorys all the players and clears the list.
-- 
-- @function [parent=#PlayerManager] destroyPlayers
-- @param self The PlayerManager
-- @return PlayerManager#PlayerManager The PlayerManager.
function PlayerManager:destroyPlayers()
  for id,player in ipairs(self.players) do
    if player and player.destroy then player:destroy() end
  end
  self.players = {}
  
  return self
end

return PlayerManager