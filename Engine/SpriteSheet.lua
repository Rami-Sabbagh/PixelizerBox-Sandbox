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

local JSON = require("Helpers.json")

local SS = Class{}

function SS:init(SheetName,sheetImage,sheetJSON)
  self.SheetName = SheetName
  self.SheetImage = sheetImage or _Images[SheetName] 
  self.SheetJSON = sheetJSON or _rawJData[SheetName]
  self.SheetArray = JSON:decode(self.SheetJSON)
  self.SheetWidth = self.SheetArray.meta.size.w
  self.SheetHeight = self.SheetArray.meta.size.h
  self.SheetFrames = self.SheetArray.frames
  self.SheetQuads = {}
  
  for k,v in ipairs(self.SheetFrames) do
    self.SheetQuads[v.filename] = love.graphics.newQuad(v.frame.x,v.frame.y,v.frame.w,v.frame.h,self.SheetWidth,self.SheetHeight)
  end
  
end

function SS:draw(partname,...)
  local args = {...}
  love.graphics.draw(self.SheetImage,self.SheetQuads[partname],unpack(args))
end

return SS