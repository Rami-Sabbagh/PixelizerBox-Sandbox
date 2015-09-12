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
local Tweens = require("Helpers.tween")
local Class = require("Helpers.hump.class")
local Signal = require("Helpers.hump.signal")

local DimensionManager
local SpriteSheet = require("Engine.SpriteSheet")
local B2Player = require("Engine.B2Object.Player")
local UI = require("Engine.UI")

---
-- The Player Module.
-- 
-- @module Player
-- @extends Class#Class
-- @return #Player

--- @type Player
local Player = Class{}

---
-- The player controls.
-- 
-- @type controls
-- @field #string up The up key name.
-- @field #string down The down key name.
-- @field #string left The left key name.
-- @field #string right The right key name.

---
-- Creates new player.
-- 
-- @callof Player#Player
-- @param self The player instance.
-- @param #string dimName The dimension name.
-- @param #number x The x position of the player.
-- @param #number y The y position of the player.
-- @param #string name The player name.
-- @param #table color A table containing red green blue values.
-- @param #controls controls The controls table of the player.
-- @param #number id The id of the player.
-- @return #Player The new player instance.
function Player:init(dimName,x,y,name,color,controls,id)
  DimensionManager = require("Engine.DimensionManager")
  self.dimensionName = dimName
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.sheet = SpriteSheet("RobotSheet")
  self.object = B2Player(self.world:getWorld(),x,y,id)
  self.direction = "right"
  self.angle = 0
  self.move = ""
  self.moveSpeed = 500
  self.jump = false
  self.jumpPower = 450
  self.zeroGravity = false
  self.id = id
  
  self.name = name or ""
  self.color = color or {255,255,255,255}
  self.controls = controls or {up = "w",down = "s",left = "a",right = "d"}
  
  self.signalRemovers = {}
  table.insert(self.signalRemovers,Signal.register("love_update",function(...) self:update(unpack({...})) end))
  table.insert(self.signalRemovers,Signal.register("love_keypressed",function(...) self:keypressed(unpack({...})) end))
  table.insert(self.signalRemovers,Signal.register("love_keyreleased",function(...) self:keyreleased(unpack({...})) end))
end

---
-- Returns the dimension name of the current player.
-- For use with Dimension Manager.
--
-- @function [parent=#Player] getDimensionName
-- @return #string The player dimension name.
function Player:getDimensionName()
  return self.dimensionName
end

---
-- Returns the dimension of the current player.
-- 
-- @function [parent=#Player] getDimension
-- @return #Dimension The player dimension.
function Player:getDimension()
  return DimensionManager:getDimension(self.dimensionName)
end

function Player:getSpeed()
  return self.object.body:getLinearVelocity()
end

function Player:setPosition(x,y,xSpeed,ySpeed)
  if xSpeed or ySpeed then
    local xV,yV = self.object.body:getLinearVelocity()
    self.object.body:setLinearVelocity(xSpeed or xV, ySpeed or yV)
  end
  self.object.body:setPosition(x,y)
end

function Player:getPosition()
  return self.object.body:getPosition()
end

function Player:isDown(key)
  return love.keyboard.isDown(self.controls[key])
end

function Player:draw()
  local x,y = self.object.body:getPosition()
  love.graphics.setFont(_PixelFont[16])
  
  love.graphics.setColor(self.color)--(255,215,0)
  
  love.graphics.push()
  love.graphics.translate(x+40,y+84)
  love.graphics.rotate(self.angle)
  
  if self.direction == "right" then
    self.sheet:draw("Robot_Normal",0,0,0,4,4,10,21)
  else
    self.sheet:draw("Robot_Normal",0,0,0,-4,4,10,21)
  end
  
  love.graphics.printf(self.name,-40,-105,80,"center")
  
  if self.weapon then
    love.graphics.setColor(255,255,255,255)
    if self.direction == "right" then
      love.graphics.draw(self.weapon,self.wX,self.wY,0,4,4,self.weapon:getWidth()/2,self.weapon:getHeight())
    else
      love.graphics.draw(self.weapon,-self.wX,self.wY,0,-4,4,self.weapon:getWidth()/2,self.weapon:getHeight())
    end
  end
  love.graphics.pop() 
end

function Player:setWeapon(image,shiftX,shiftY)
  self.weapon = image
  self.wX, self.wY = shiftX or 0, shiftY or 0
end

function Player:getWeaponCenter()
  local inverted = true if self.direction == "right" then inverted = false end
  local x,y = self.object.body:getPosition()
  x, y = x+40, y+84
  local Wx, Wy = x+self.weapon:getWidth()/2, (y-12)-(self.weapon:getHeight()*4)/2
  if inverted then Wx = Wx-4 else Wx = Wx+4 end
  return Wx, Wy, inverted
end

function Player:update(dt)
  local lx,ly = self.object.body:getLinearVelocity()
  
  if self.zeroGravity then ly = 0 end
  if love.keyboard.isDown(self.controls.down) then ly = ly + self.moveSpeed end
  if love.keyboard.isDown(self.controls.up) and self.zeroGravity then ly = ly - self.moveSpeed end
  self.object.body:setLinearVelocity( lx, ly )
  
  if self.move == "left" then
    self.object.body:setLinearVelocity( -self.moveSpeed, ly )
  elseif self.move == "right" then
    self.object.body:setLinearVelocity( self.moveSpeed ,ly )
  end
end

function Player:keypressed(key,isrepeat) 
  local lx,ly = self.object.body:getLinearVelocity()
  
  if key == self.controls.left then
    if self.move == "" then
      self.angle = math.rad(-10)
      self.move = "left"
      self.direction = "left"
    end
  elseif key == self.controls.right then
    if self.move == "" then
      self.angle = math.rad(10)
      self.move = "right"
      self.direction = "right"
    end
  elseif key == self.controls.up and not self.jump and not self.zeroGravity then
    self.jump = true
    self.object.body:setLinearVelocity( lx, ly-self.jumpPower )
  end
end

function Player:keyreleased(key)
  local lx,ly = self.object.body:getLinearVelocity()
  
  if key == self.controls.left then
    if self.move == "left" then
      self.angle = 0
      self.move = ""
      self.object.body:setLinearVelocity( 0, ly )
    end
  elseif key == self.controls.right then
    if self.move == "right" then
      self.angle = 0
      self.move = ""
      self.object.body:setLinearVelocity( 0, ly )
    end
  elseif key == self.controls.up and self.jump then
    self.jump = false
  elseif key == self.controls.down then
    self.object.body:setLinearVelocity( lx, 0 )
  end
end

function Player:destroy()
  for k,v in ipairs(self.signalRemovers) do if v then v() end end
  self.object:destroy()
end

return Player