local Class = require("Helpers.hump.class")

local PlayerManager = require("Engine.PlayerManager")

local GPG = Class{}

function GPG:init(dimName,Snap,guiData,args)
  self.player = PlayerManager:getUserPlayer()
  self.player:setWeapon(_Images["PhysicsGunClosed"],4,-12)
  self.dimension = self.player:getDimension()
  self.world = self.dimension:getWorld():getWorld()
end

function GPG:draw()
  if self.BC then
    love.graphics.setColor(0,139,204,255)
    love.graphics.setLineWidth(10)
    love.graphics.line(unpack(self.BC:render()))
  end
end

function GPG:update(dt,mx,my)
  if self.BC then
    local Wx, Wy, Wi = self.player:getWeaponCenter()
    local BCSX = Wx if Wi then BCSX = BCSX-8 else BCSX = BCSX+8 end
    local BCSY = Wy
    local HX, HY = BCSX+(mx-BCSX)/2, BCSY+(my-BCSY)/2
    local FB, boost = 4, 6
    local dx, dy = HX-self.BCX, HY-self.BCY
    self.BCX, self.BCY = self.BCX+dx*dt*boost, self.BCY+dy*dt*boost
    self.FX, self.FY = self.BCX-HX, self.BCY-HY
    self.BC = love.math.newBezierCurve(BCSX,BCSY,self.BCX,self.BCY,mx,my)
    
    if self.body then self.body:setPosition(mx+self.shiftX,my+self.shiftY) self.body:setLinearVelocity(-self.FX*FB,-self.FY*FB) self.body:setAngularVelocity(0) end
  end
end

function GPG:mousepressed(x,y,button)
  local Wx, Wy, Wi = self.player:getWeaponCenter()
  local BCSX = Wx if Wi then BCSX = BCSX-8 else BCSX = BCSX+8 end
  local BCSY = Wy
  self.FX, self.FY = 0,0
  self.BCX, self.BCY = BCSX+(x-BCSX)/2, BCSY+(y-BCSY)/2
  self.BC = love.math.newBezierCurve(BCSX,BCSY,x,BCSY,x,y)
  local SelectedFixture self.world:queryBoundingBox(x-5,y-5,x+5,y+5,function(fixture) SelectedFixture=fixture return false end)
  if SelectedFixture then
    local UData = SelectedFixture:getUserData() if UData and type(UData)=="table" and not (UData.NoSW or UData.NoPG) then
      self.fixture = SelectedFixture
      self.body = self.fixture:getBody()
      self.shiftX, self.shiftY = self.body:getX()-x, self.body:getY()-y
      UData.HoldFlag = true self.fixture:setUserData(UData)
    end
  end
end

function GPG:mousereleased(x,y,button)
  if self.fixture then
    local FB = 4
    self.body:setLinearVelocity(-self.FX*FB,-self.FY*FB)
    local UData = self.fixture:getUserData() if UData and type(UData)=="table" then UData.HoldFlag = false self.fixture:setUserData(UData) end
    self.fixture, self.body, self.shiftX, self.shiftY = nil, nil, nil, nil
  end
  self.BC, self.BCX, self.BCY, self.FX, self.FY = nil, nil, nil, nil, nil
end

function GPG:destroy()
  self.player:setWeapon(nil)
end

return {GWeapon=GPG}