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
local loveframes = require("Helpers.loveframes")
local B2Obj = require("Engine.B2Object")
local Player = require("Engine.Player")

local PF = Class{}

function PF:init(state,world,players,x,y,center)
  self.state = state
  
  self.frame = loveframes.Create("frame")
  self.frame:SetState(self.state):SetSize(200,200):SetPos(x,y,center):SetScreenLocked(true)
  self.frame:SetName("Physics Control"):SetDockable(true):ShowCloseButton(false)
  
  self.gravity = loveframes.Create("button",self.frame)
  self.gravity:SetText("Normal Gravity"):SetSize(175,25):SetPos(100,50,true)
  self.gravity.world = world
  self.gravity.players = players
  self.gravity.OnClick = function(object)
    if object.zero then
      object:SetText("Normal Gravity")
      object.world:setGravity(0,9.82*64)
      object.zero = nil
      if object.players then
        for k,v in pairs(object.players) do
          v.zeroGravity = false
        end
      end
    else
      object:SetText("Zero Gravity")
      object.world:setGravity(0,0)
      object.zero = true
      if object.players then
        for k,v in pairs(object.players) do
          v.zeroGravity = true
        end
      end
    end
  end
  
  self.fillram = loveframes.Create("button",self.frame)
  self.fillram:SetText("Delete Objects"):SetSize(175,25):SetPos(100,75,true)
  self.fillram.OnClick = function(object)
    local SB = require("States.Sandbox")
    SB.ram.filled = _Width*_Height
    SB.frames.ramProg:SetLerp(false):SetValue(SB.ram.filled):SetLerp(true)
    for k,v in pairs(SB.objects) do
      if k > 4 then
        if v.object then
          v.object.body:setActive(false)
        end
      end
    end
  end
  
  self.respawn = loveframes.Create("button",self.frame)
  self.respawn:SetText("Respawn Players"):SetSize(175,25):SetPos(100,100,true)
  self.respawn.world = world
  self.respawn.players = players
  self.respawn.OnClick = function(object)
    for k,v in ipairs(object.players) do
      local controls = object.players[k].controls
      local zeroGravity = object.players[k].zeroGravity
      object.players[k].object.body:setActive(false)
      object.players[k] = Player(object.world,v.name,v.color)
      object.players[k].controls = controls
      object.players[k].zeroGravity = zeroGravity
    end
  end
  
  self.frame.physics = B2Obj(world,"Rect",x,y,200,200,true)
  self.frame.Update = function(object,dt)
    object.physics.body:setPosition(object:GetPos())
  end
  
  self.frame.OnClose = function(object)
    object.physics.body:setActive(false)
  end
  
  self.text = loveframes.Create("text",self.frame)
  self.text:SetText("        V".._Version.." ".._State.."\n \n More Objects Coming Soon !"):SetPos(100,155,true)
end


return PF