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
local Class = require("Helpers.hump.class")
local PEOL = Class{}

local MathUtils = require("Engine.MathUtils")
local DimensionManager = require("Engine.DimensionManager")

local B2PhysicsEditor = require("Engine.B2Object.PhysicsEditor")
local JSON = require("Helpers.json")

function PEOL:init(dimName,Snap,GUIData,modelname,partname,imagename)
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.snap = Snap
  self.guiData = GUIData
  
  self.x, self.y = 0, 0
  self.model = JSON:decode(_rawJData[modelname])
  self.partname = partname
  self.image = _Images[imagename]
  self.imageWidth, self.imageHeight = self.image:getDimensions()
end

function PEOL:setSnap(SNAP)
  self.snap = SNAP
end

function PEOL:create(x,y)
  if self.snap then x, y = x-self.snap, y-self.snap end
  self.x, self.y = x,y
  
  self.object = B2PhysicsEditor(self.world:getWorld(),self.model,self.partname,x-self.imageWidth/2,y-self.imageHeight/2,self.image)
  if not self.object.failed then return true else
    self.object = nil
    return false
  end
end

function PEOL:draw(mx,my)
  if self.dead then return end
  if self.object then
    self.object:draw()
  else
    if self.snap then mx, my = mx-self.snap, my-self.snap end
    love.graphics.setColor(255,255,255,155)
    love.graphics.draw(self.image,mx,my,0,1,1,self.imageWidth/2,self.imageHeight/2)
  end
end

function PEOL:invokePoint(x,y)
  if not self.object or self.dead then return end
  local iw, ih = self.object.bodyImage:getDimensions()
  if MathUtils.isInRect(x,y,self.object.x,self.object.y,iw,ih) then
    local iData = self.object.bodyImage:getData()
    x, y = x-self.object.x, y-self.object.y
    
    local r, g, b, a = iData:getPixel(x,y)
    if a > 0 then return true end
  end
  return false
end

function PEOL:destroy()
  self.object:destroy()
  self.dead = true
end

return {Overlay=PEOL}