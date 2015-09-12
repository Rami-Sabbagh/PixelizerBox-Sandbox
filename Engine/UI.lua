--Warning !!: This is a desperated file, It may be deleted/removed at any update--
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
local UI = {}

function UI:init()
  self.unkown = love.graphics.newImage("Libs/Misc/Messing.png")
end

--If the pass variable is not number it will return nil, else it return the same variable
function UI:forceNum(var)
  if type(var) ~= "number" then var = nil end
  return var
end

--If the pass variable is not boolean it will return nil, else it return the same variable
function UI:forceBol(var)
  if type(var) ~= "boolean" then var = nil end
  return var
end

--If the pass variable is not table it will return nil, else it return the same variable
function UI:forceTable(var)
  if type(var) ~= "table" then var = nil end
  return var
end

function UI:Draw(Image,X,Y,Width,Height,Rotation,Center,Flip)
  if _Loaded then
    if type(Image) ~= "userdata" and type(Image) ~= "string" then
      Image = "Messing"
    elseif type(Image) ~= "userdata" then
      Image = _Images[Image]
    end
  else
    if type(Image) ~= "userdata" then
      Image = self.unkown
    end
  end
  
  X = self:forceNum(X) or 0
  Y = self:forceNum(Y) or 0
  Width = self:forceNum(Width) or Image:getWidth()
  Height = self:forceNum(Height) or Image:getHeight()
  Rotation = self:forceNum(Rotation) or 0
  Center = self:forceBol(Center) or false
  Flip = self:forceBol(Flip) or false
  if Center then OrginX,OrginY = Image:getWidth()/2,Image:getHeight()/2 end
  OrginX = OrginX or 0
  OrginY = OrginY or 0
  Width = Width/Image:getWidth()
  Height = Height/Image:getHeight()
  Rotation = math.rad(Rotation)
  
  if Flip then
    love.graphics.draw(Image,X,Y,Rotation,-Width,Height,OrginX,OrginY)
  else
    love.graphics.draw(Image,X,Y,Rotation,Width,Height,OrginX,OrginY)
  end
  
  Image,X,Y,Width,Height,Rotation,Center,OrginX,OrginY,Flip = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
end

return UI