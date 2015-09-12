--Remove the comments to enable this mod !--
--[[local B2World = require("Engine.B2World")

B2World.oldInit = B2World.init

function B2World:init(GravityX,GravityY,Meter,AllowSleeping)
  self:oldInit(0,0,Meter,AllowSleeping)
end

local Player = require("Engine.Player")

Player.oldInit = Player.init

function Player:init(dimName,x,y,name,color,controls,id)
  self:oldInit(dimName,x,y,"Zero",color,controls,id)
  self.zeroGravity = true
end]]