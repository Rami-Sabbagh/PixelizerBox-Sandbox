--This file is part of PixelizerBox--
--Type : Hump-Class/API--
local Class = require("Helpers.hump.class")
local Balloon = Class{}

local MathUtils = require("Engine.MathUtils")
local DimensionManager = require("Engine.DimensionManager")
local B2Circle = require("Engine.B2Object.Circle")

function Balloon:init(x,y,dimName,snap,GUIData)
  self.world = DimensionManager:getDimension(dimName):getWorld()
  self.snap = snap
  self.guiData = GUIData
  
  self.x, self.y, self.radius, self.usage  = x,y,0,0
end

function Balloon:create(x,y)
  self:calcRadius(x,y)
  
  if self.radius < 15 then return end
  
  self.object = B2Circle(self.world:getWorld(),self.x,self.y,self.radius)
  self.object.body:setGravityScale(self.guiData["GravityScale"] or -1)
  
  if self.object then return true else
    self.object = nil
    return false
  end
end

function Balloon:draw(mx,my)
  if self.dead then return end
  if self.object then self.object:draw({75,75,75,255},{0,0,0,0},1) return end
  
  self:calcRadius(mx,my)
  
  love.graphics.setColor(75,75,75,255)
  love.graphics.circle("fill",self.x,self.y,self.radius,100)
  
  love.graphics.setColor(175,175,175,255)
  love.graphics.setLineWidth(5)
  love.graphics.circle("line",self.x,self.y,self.radius,100)
end

function Balloon:drawBack()
  if not self.object or self.dead then return end
  
  love.graphics.setColor(75,75,75,150)
  love.graphics.circle("fill",self.x,self.y,self.radius,100)
  
  love.graphics.setColor(175,175,175,150)
  love.graphics.setLineWidth(5)
  love.graphics.circle("line",self.x,self.y,self.radius,100)
  
  if self.object then self.object:draw({0,0,0,0},{175,175,175,255},11) end
end

function Balloon:calcRadius(x,y)
  self.radius = MathUtils.calcDistance(self.x,self.y,x,y)
  self.used = math.abs(self.radius*2*3.14)
end

function Balloon:invokePoint(x,y)
  if not self.object or self.dead then return end
  return MathUtils.isInCircle(x,y,self.x,self.y,self.radius)
end

function Balloon:destroy()
  self.object:destroy()
  self.dead = true
end

return {HoldCreate=Balloon}