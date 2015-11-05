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

---
-- The sandbox state.
-- For use with Hump.GameState.
-- 
-- @module Sandbox
-- @return #Sandbox

--- @type Sandbox
local Sandbox = {}

local loveframes = require("Helpers.loveframes")
local Tweens = require("Helpers.tween")
local Signal = require("Helpers.hump.signal")

local ModManager = require("Engine.ModManager")
local DimensionManager = require("Engine.DimensionManager")
local PlayerManager = require("Engine.PlayerManager")

local SandboxAPI = require("Engine.Sandbox.API")
local SandboxUI = require("Engine.Sandbox.UI")

---
-- Sandbox Initialization
-- 
-- @callof Sandbox#Sandbox
-- @param self The Sandbox.
function Sandbox:init()
  ModManager:loadBasicMods()
  SandboxUI:build()
end

---
-- Called when entering Sandbox state.
-- 
-- @function [parent=#Sandbox] enter
-- @param self The Sandbox.
-- @param state prev The previous state.
function Sandbox:enter(prev)
  DimensionManager:destroyDimensions()
  PlayerManager:destroyPlayers()
  
  love.graphics.setBackgroundColor(50,50,50,0)
  
  loveframes.SetState("Sandbox")
  DimensionManager:newDimension("Main")
  SandboxAPI:setDimensionName("Main")
  PlayerManager:setUserPlayerID(PlayerManager:createPlayer(SandboxAPI:getDimensionName(),-40,21,"",{255,255,255,255}))
  
  SandboxAPI:setDimensionName("Main")
  SandboxAPI:spawnCamera()
  
  loveframes.SetState(SandboxUI.mainState)
  
  --Fade--
  self.alpha = {255}
  self.tween = Tweens.new(0.5,self.alpha,{0})
end

function Sandbox:draw()
  SandboxAPI:getCamera():attach()
  SandboxAPI:drawGrid()
  
  DimensionManager:getDimension(SandboxAPI:getDimensionName()):draw()
  
  SandboxAPI:drawCreations()
  SandboxAPI:drawPlayers()
  SandboxAPI:getCamera():detach()
  
  loveframes.draw()
  
  if _DebugKey then
    local MoveSpeed, FallSpeed = PlayerManager:getUserPlayer():getSpeed()
    local PlayerX, PlayerY = PlayerManager:getUserPlayer().object.body:getPosition()
    
    love.graphics.setFont(_PixelFont[14])
    love.graphics.setColor(0,255,0,255)
    love.graphics.print(_State.." V".._Version.." FPS: "..love.timer.getFPS(),15,15)
    love.graphics.print("Player Moving Speed: "..math.floor(MoveSpeed),15,35)
    love.graphics.print("Player Falling Speed: "..math.floor(FallSpeed),15,55)
  end
  
  --Fade--
  love.graphics.setColor(0,0,0,self.alpha[1])
  love.graphics.rectangle("fill",0,0,_Width,_Height)
end

function Sandbox:update(dt)
  DimensionManager:updateDimensions(dt)
  SandboxAPI:updateCamera(dt)
  SandboxAPI:updateCreations(dt)
  
  local MoveSpeed, FallSpeed = PlayerManager:getUserPlayer():getSpeed()
  local SkipSpeedSpawn = PlayerManager:getUserPlayer():isDown("down")
  
  --[[if FallSpeed >= 2500 and not SkipSpeedSpawn then
    DimensionManager:getDimension(PlayerManager:getUserPlayer():getDimensionName()):deletePoint(0,64)
    PlayerManager:getUserPlayer():setPosition(-40,21,nil,0)
  end]]
  
  --Fade--
  self.tween:update(dt)
end

function Sandbox:mousepressed(x,y,button)
  SandboxAPI:pressUserCreation(x,y,button)
end

function Sandbox:mousereleased(x,y,button)
  SandboxAPI:releaseUserCreation(x,y,button)
end

function Sandbox:keypressed(key,isrepeat)
  if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
    if key == "g" then
      if SandboxAPI:getSnap() then SandboxAPI:setSnap(nil) else SandboxAPI:setSnap(32) end
    elseif key == "c" then
      PlayerManager:getUserPlayer():setPosition(-40,21,0,0)
    elseif key == "z" then
      SandboxAPI:zoomTo(1)
    end
  end
  
  if key == "f1" then
    local Files = love.filesystem.getDirectoryItems("/Screenshots/")
    love.graphics.newScreenshot():encode("/Screenshots/PixelizerBox ".._State.." - "..#Files..".png")
  end
  
  if key == "escape" then love.event.quit() end
end

function Sandbox:leave()
  DimensionManager:destroyDimensions()
  PlayerManager:destroyPlayers()
  SandboxAPI:setDimensionName(nil)
  loveframes.SetState("none")
end

return Sandbox