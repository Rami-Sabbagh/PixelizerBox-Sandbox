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
local SandboxMSB = require("Engine.Sandbox.MainSideBar")

local ModManager = require("Engine.ModManager")
local PlayerManager = require("Engine.PlayerManager")
local DimensionManager = require("Engine.DimensionManager")
local loveframes = require("Helpers.loveframes")
local Signal = require("Helpers.hump.signal")
local Camera = require("Helpers.hump.camera")

local API = {snap=32,maxZoom=2,minZoom=0.1,creating={},dimName=nil}

function API:setDimensionName(name)
  self.dimName = name
  Signal.emit("Sandbox_API_DimensionNameChanged",name) --HOOK Sandbox_API_DimensionNameChanges(name: the new dimension name)
end

function API:getDimensionName()
  return self.dimName
end

function API:drawPlayers()
  if not self.dimName then return end
  Signal.emit("Sandbox_API_DrawPlayers") --HOOK Sandbox_API_DrawPlayers()
  local Players = PlayerManager:getPlayersList()
  for id,player in ipairs(Players) do
    if player then
      local dim = player:getDimensionName()
      if dim and dim == self.dimName and player.draw then
        player:draw()
        Signal.emit("Sandbox_API_DrawPlayer",id,player) --HOOK Sandbox_API_DrawPlayer(id: the player id,player: the player object)
      end
    end
  end
end

function API:setSnap(snap)
  self.snap = snap
  for k,v in ipairs(self.creating) do
    if v then self:creatorObject(k) end
  end
  Signal.emit("Sandbox_API_SnapChanged",snap) --HOOK Sandbox_API_SnapChanged(snap: the new snap)
end

function API:getSnap()
  return self.snap
end

function API:spawnCamera()
  local Player = PlayerManager:getUserPlayer() if not Player then return error("User Player not spawned") end
  self.cam = Camera(Player.object.body:getX()+80, Player.object.body:getY())
  
  Signal.emit("Sandbox_API_CameraSpawned",self.cam) --HOOK Sandbox_API_CameraSpawned(cam: the camera object)
end

function API:getCamera()
  return self.cam
end

function API:refocusCamera()
  local Player = PlayerManager:getUserPlayer() if not Player then return error("User Player not spawned") end
  if not self.cam then return error("Camera not spawned") end
  local pX, pY = Player.object.body:getPosition() pX = pX+80
  
  self.cam:lookAt(pX,pY)
  
  Signal.emit("Sandbox_API_CameraRefocused",self.cam,pX,pY) --HOOK Sandbox_API_CameraRefocused(cam: the camera object,pX: the new camera x position,pY: the new camera y position)
end

function API:updateCamera(dt)
  local Player = PlayerManager:getUserPlayer() if not Player then return error("User Player not spawned") end
  if not self.cam then return error("Camera not spawned") end
  local pX, pY = Player.object.body:getPosition() pX = pX+80

  local boost = 4
  local cx,cy = self.cam:pos()
  local dx, dy = pX-cx, pY-cy
  self.cam:move(dx*dt*boost,dy*dt*boost)
end

function API:zoomTo(z)
  if not self.cam then return error("Camera not spawned") end
  self.cam:zoomTo(z or 1)
  if self.cam.scale > self.maxZoom then self.cam:zoomTo(self.maxZoom) end
  if self.cam.scale < self.minZoom then self.cam:zoomTo(self.minZoom) end
  
  Signal.emit("Sandbox_API_ZoomChanged",self.cam.scale) --HOOK Sandbox_API_ZoomChanged(snap: the new snap)
end

function API:zoom(z)
  if not self.cam then return error("Camera not spawned") end
  self.cam:zoom(z or 1)
  if self.cam.scale > self.maxZoom then self.cam:zoomTo(self.maxZoom) end
  if self.cam.scale < self.minZoom then self.cam:zoomTo(self.minZoom) end
  
  Signal.emit("Sandbox_API_ZoomChanged",self.cam.scale) --HOOK Sandbox_API_ZoomChanged(snap: the new snap)
end

function API:drawGrid()
  if not self.cam then return error("Camera not spawned") end
  if not self.snap then return end if self.cam.scale < 0.6 then return end
  local cx,cy = self.cam:pos()
  local cz = self.cam.scale
  
  cx, cy = cx-((_Width/2)/cz), cy-((_Height/2)/cz)
  cx, cy = math.floor(cx/64)*64, math.floor(cy/64)*64
  
  local startX, startY = cx-64, cy-64
  local endX, endY = cx+64+_Width/cz, cy+64+_Height/cz
  
  love.graphics.setColor(255,255,255,100)
  love.graphics.setLineWidth(1)
  
  for x=startX,endX,64 do
    for y=startY,endY,64 do
      love.graphics.draw(_Images["Grid"],x,y)
    end
  end
  
  love.graphics.setColor(175,175,175,255)
  love.graphics.setPointSize(20)
  love.graphics.setPointStyle("smooth")
  love.graphics.point(0,0)
  Signal.emit("Sandbox_API_DrawGrid") --HOOK Sandbox_API_DrawPlayers()
end

function API:setObject(PlayerID,Name,GUIData)
  self.creating[PlayerID] = self.creating[PlayerID] or {}
  self.creating[PlayerID].objName = Name
  self.creating[PlayerID].guiData = GUIData
  self:creatorObject(PlayerID)
end

function API:creatorObject(PlayerID)
  if self.creating[PlayerID].creation and self.creating[PlayerID].creation.cancel then self.creating[PlayerID].creation:cancel() end
  local obj = ModManager:getObjects()[self.creating[PlayerID].objName]
  local dimName = PlayerManager:getUserPlayer():getDimensionName()
  self.creating[PlayerID].creation = obj.handler(obj.generator,obj.args,dimName,self.snap,self.creating[PlayerID].guiData)
end

function API:drawCreations()
  local cx, cy = self.cam:mousepos()
  if self.snap then
    cx = math.floor(cx/self.snap)*self.snap+self.snap
    cy = math.floor(cy/self.snap)*self.snap+self.snap
  end
  
  for PlayerID, Creating in ipairs(self.creating) do
    local Player = PlayerManager:getPlayer(PlayerID)
    if Player then
      local PlayerDim = Player:getDimensionName()
      if PlayerDim == self.dimName then
        if Creating.creation and Creating.creation.draw then
          Creating.creation:draw(cx,cy)
        end
      end
    end
  end
end

function API:updateCreations(dt)
  local cx, cy = self.cam:mousepos()
  if self.snap then
    cx = math.floor(cx/self.snap)*self.snap+self.snap
    cy = math.floor(cy/self.snap)*self.snap+self.snap
  end
  
  for PlayerID, Creating in ipairs(self.creating) do
    local Player = PlayerManager:getPlayer(PlayerID)
    if Player then
      local PlayerDim = Player:getDimensionName()
      if PlayerDim == self.dimName then
        if Creating.creation and Creating.creation.update then
          local done = Creating.creation:update(dt,cx,cy)
          if done then
            --self.level:registerObjectData(self.objName,data,self.creation)
            --self:creator()
            self:creatorObject(PlayerID)
          end
        end
      end
    end
  end
end

function API:pressUserCreation(x,y,button)
  local PlayerID = PlayerManager:getUserPlayerID()
  --[[if not loveframes.util.GetHoverObject() and not LEUI.overlayOn and button == "r" and not self.creator then
    --local obj = self.level.world:invokePoint(self.cam:mousepos())
    --if obj and obj.destroy then obj:destroy() end
  end]]
  if not loveframes.util.GetHoverObject()--[[ and not LEUI.overlayOn]] and button == "r" and not self.creating[PlayerID] then
    DimensionManager:getDimension(PlayerManager:getUserPlayer():getDimensionName()):deletePoint(self.cam:mousepos())
  end
  --FIXME New overlay system
  --FIXME New object delete system
  
  if button == "wu" and not loveframes.util.GetHoverObject() then self:zoom(1.1) elseif button == "wd" and not loveframes.util.GetHoverObject() then self:zoom(0.9) end
  if loveframes.util.GetHoverObject() or button=="r"--[[ or LEUI.overlayOn]] then return end
  --FIXME New overlay system
  
  local cx, cy = self.cam:mousepos()
  if self.snap then
    cx = math.floor(cx/self.snap)*self.snap
    cy = math.floor(cy/self.snap)*self.snap
  end
  
  if button ~= "l" then return end
  if self.creating[PlayerID] and self.creating[PlayerID].creation and self.creating[PlayerID].creation.mousepressed then
    self.creating[PlayerID].creation:mousepressed(cx,cy,button)
  end
end

function API:releaseUserCreation(x,y,button)
  local PlayerID = PlayerManager:getUserPlayerID()
  --FIXME New overlay system
  --if LEUI.overlayOn then return end
  if loveframes.util.GetHoverObject() then return end
  
  if button == "r" then
    if self.creating[PlayerID] and self.creating[PlayerID].creation and self.creating[PlayerID].creation.cancel then self.creating[PlayerID].creation:cancel() end
    SandboxMSB:UnCheckAll()
    self.creating[PlayerID] = nil
  end
  
  local cx, cy = self.cam:mousepos()
  if self.snap then
    cx = math.floor(cx/self.snap)*self.snap+self.snap
    cy = math.floor(cy/self.snap)*self.snap+self.snap
  end
  
  if button ~= "l" then return end
  if self.creating[PlayerID] and self.creating[PlayerID].creation and self.creating[PlayerID].creation.mousereleased then
    self.creating[PlayerID].creation:mousereleased(cx,cy,button)
  end
end

return API