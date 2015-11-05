local Class = require("Helpers.hump.class")

local PlayerManager = require("Engine.PlayerManager")

local GDG = Class{}

function GDG:init(dimName,Snap,guiData,args)
  self.player = PlayerManager:getUserPlayer()
  self.player:setWeapon(_Images["DeleteGun"],4,-12)
  self.dimension = self.player:getDimension()
  self.world = self.dimension:getWorld():getWorld()
end

function GDG:draw(mx,my)
  if self.BC then
    love.graphics.setColor(255,0,0,255)
    love.graphics.setLineWidth(5)
    love.graphics.line(unpack(self.BC:render()))
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line",mx-5,my-5,10,10)
  end
end

function GDG:update(dt,mx,my)
  if self.BC then
    local Wx, Wy, Wi = self.player:getWeaponCenter()
    local BCSX = Wx if Wi then BCSX = BCSX-8 else BCSX = BCSX+8 end
    local BCSY = Wy
    local HX, HY = BCSX+(mx-BCSX)/2, BCSY+(my-BCSY)/2
    local FB, boost = 4, 6
    local dx, dy = HX-self.BCX, HY-self.BCY
    self.BCX, self.BCY = self.BCX+dx*dt*boost, self.BCY+dy*dt*boost
    self.FX, self.FY = self.BCX-HX, self.BCY-HY
    self.BC = love.math.newBezierCurve(BCSX,BCSY,BCSX+100,BCSY,self.BCX,self.BCY,mx,my)
    local SelectedFixture self.world:queryBoundingBox(mx-5,my-5,mx+5,my+5,function(fixture) SelectedFixture=fixture return false end)
    if SelectedFixture then
      local UData = SelectedFixture:getUserData() if UData and type(UData)=="table" and not (UData.NoSW or UData.NoDG) then
        SelectedFixture:getBody():setActive(false)
      end
    end
  end
end

function GDG:mousepressed(x,y,button)
  local Wx, Wy, Wi = self.player:getWeaponCenter()
  local BCSX = Wx if Wi then BCSX = BCSX-8 else BCSX = BCSX+8 end
  local BCSY = Wy
  self.FX, self.FY = 0,0
  self.BCX, self.BCY = BCSX+(x-BCSX)/2, BCSY+(y-BCSY)/2
  self.BC = love.math.newBezierCurve(BCSX,BCSY,BCSX+100,BCSY,x,BCSY,x,y)
  local SelectedFixture self.world:queryBoundingBox(x-5,y-5,x+5,y+5,function(fixture) SelectedFixture=fixture return false end)
  if SelectedFixture then
    local UData = SelectedFixture:getUserData() if UData and type(UData)=="table" and not (UData.NoSW or UData.NoDG) then
      SelectedFixture:getBody():setActive(false)
    end
  end
end

function GDG:mousereleased(x,y,button)
  self.BC, self.BCX, self.BCY, self.FX, self.FY = nil, nil, nil, nil, nil
end

function GDG:destroy()
  self.player:setWeapon(nil)
end

return {GWeapon=GDG}