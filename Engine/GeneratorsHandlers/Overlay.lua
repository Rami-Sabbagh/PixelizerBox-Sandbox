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

local OL = Class{}

function OL:init(GeneratorClass,GeneratorArgs,DimName,Snap,GUIData)
  self.guiData = GUIData
  self.genClass = GeneratorClass
  self.genArgs = GeneratorArgs
  self.genDim = DimName
  self.generator = self.genClass(self.genDim,Snap,self.guiData,unpack(self.genArgs or {}))
  self.snap = Snap
end

function OL:instantCreate(data)
  self.generator = self.genClass(self.genDim,self.snap,data.gui or {},unpack(self.genArgs or {}))
  self.generator.snap = data.snap
  local success = self.gen:create(data.x,data.y)
  local dim = DimensionManager:getDimension(self.genDim)
  dim:registerObject(self.gen,self)
  self.done, self.data = true, data
end

function OL:draw(mx,my)
  if self.generator and self.generator.draw then self.generator:draw(mx,my) end
end

function OL:drawBack()
  if self.generator and self.generator.drawBack then self.generator:drawBack() end
end

function OL:update(dt,mx,my)
  if self.generator and self.generator.update then self.generator:update(dt) end
  
  return self.done, self.data
end

function OL:mousereleased(x,y,button)
  if not button=="l" or self.done then return end
  local success = self.generator:create(x,y)
  if success then
    local dim = DimensionManager:getDimension(self.genDim)
    dim:registerObject(self.generator,self)
  end
  
  self.done, self.data = true, {x=x,y=y,snap=self.snap,args=self.genArgs,gui=self.guiData}
end

function OL:cancel()
  self.done = true
end

function OL:invokePoint(x,y)
  if self.generator.invokePoint then return self.generator:invokePoint(x,y) end
end

function OL:getData()
  return self.data
end

function OL:destroy()
  if self.generator.destroy then self.generator:destroy() end
end

return OL