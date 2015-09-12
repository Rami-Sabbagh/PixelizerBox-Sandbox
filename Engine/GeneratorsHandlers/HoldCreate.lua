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
local Signal = require("Helpers.hump.signal")
local Class = require("Helpers.hump.class")

local DimensionManager = require("Engine.DimensionManager")

local HC = Class{}

function HC:init(GeneratorClass,GeneratorArgs,DimName,Snap,GUIData)
  self.genClass = GeneratorClass
  self.genArgs = GeneratorArgs
  self.genDim = DimName
  self.snap = Snap
  self.guiData = GUIData
end

function HC:instantCreate(data)
  self.generator = self.genClass(data.x1,data.y1,self.genDim,data.snap,data.gui or {},unpack(data.args or {}))
  local success = self.generator:create(data.x2,data.y2)
  if not success then self.done, self.data = true, data return end
  local dim = DimensionManager:getDimension(self.genDim)
  dim:registerObject(self.gen,self)
  self.done, self.data = true, data
end

function HC:draw(mx,my)
  if self.generator and self.generator.draw then self.generator:draw(mx,my) end
  if not self.done then
    if not love.mouse.isDown("l") and self.snap then mx = mx - self.snap my = my - self.snap end
    love.graphics.setColor(255,255,255,150)
    love.graphics.setLineWidth(3)
    love.graphics.line(mx-8,my,mx+8,my)
    love.graphics.line(mx,my-8,mx,my+8)
  end
end

function HC:drawBack()
  if self.generator and self.generator.drawBack then self.generator:drawBack() end
end

function HC:update(dt,mx,my)
  if self.generator and self.generator.update then self.generator:update(dt,mx,my) end
  
  return self.done, self.data
end

function HC:mousepressed(x,y,button)
  if not button=="l" or self.done then return end
  self.generator = self.genClass(x,y,self.genDim,self.snap,self.guiData,unpack(self.genArgs or {}))
  self.x1, self.y1 = x, y
end

function HC:mousereleased(x,y,button)
  if not button=="l" or self.done or not self.x1 or not self.y1 then return end
  local success = self.generator:create(x,y)
  if success then
    local dim = DimensionManager:getDimension(self.genDim)
    dim:registerObject(self.generator,self)
  end
  
  self.x2, self.y2 = x,y
  
  self.done, self.data = self.generator, {x1=self.x1,x2=self.x2,y1=self.y1,y2=self.y2,snap=self.snap,args=self.genArgs,gui=self.guiData}
end

function HC:cancel()
  self.done = true
end

function HC:invokePoint(x,y)
  if self.generator.invokePoint then return self.generator:invokePoint(x,y) end
end

function HC:getData()
  return self.data
end

function HC:destroy()
  if self.generator.destroy then self.generator:destroy() end
end

return HC