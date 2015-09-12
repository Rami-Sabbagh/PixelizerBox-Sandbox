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

---
-- Used for some math tasks.
-- 
-- @module MathUtils
local MU = {}

---
-- Returns a random number between min and max.
-- 
-- @function [parent=#Mathutils] random
-- @param #number min The min value.
-- @param #number max The max value.
-- @return #number The random result.
function MU.random(min,max)
  math.randomseed(os.clock())
  math.randomseed(math.random(1000000000,9999999999))
  return math.random(min,max)
end

---
-- Returns a random id with the given length.
-- 
-- @function [parent=#MathUtils] randomID
-- @param #number digits The length of the ID.
-- @return #number The random ID.
function MU.randomID(digits)
  return MU.random(10^(digits-1),10^digits-1)
end

---
-- Returns if a point is on a line.
-- 
-- @function[parent=#MathUtils] isOnLine
-- @param #number stx The start x position of the line.
-- @param #number sty The start y position of the line.
-- @param #number edx The end x position of the line.
-- @param #number edy The end y position of the line.
-- @param #number cux The x position of the point.
-- @param #number cuy The y position of the point.
-- @param #number thick The thick of the line.
-- @return #boolean Is the point in the line ?
function MU.isOnLine(stx,sty,edx,edy,cux,cuy,thick)
  local thick = thick or 1
  local fullDist = MU.calcDistance(stx,sty,edx,edy)
  local realDist = MU.calcDistance(stx,sty,cux,cuy) +  MU.calcDistance(cux,cuy,edx,edy)
  if realDist >= fullDist and realDist <= fullDist + thick/4 then return true end
end

---
-- Returns if a point is inside a rectangle.
-- 
-- @function [parent=#MathUtils] isInRect
-- @param #number x The point x position.
-- @param #number y The point y position.
-- @param #number rx The top-left rectangle corner x position.
-- @param #number ry The top-left rectangle corner y position.
-- @param #number rw The rectangle width.
-- @param #number rh The rectangle height.
-- @return #boolean Is the point in the rectangle ?
function MU.isInRect(x,y,rx,ry,rw,rh)
  if rw < 0 then rw = math.abs(rw); rx = rx-rw end
  if rh < 0 then rh = math.abs(rh); ry = ry-rh end
  
  rw, rh = rx+rw, ry+rh
  if x >= rx and x <= rw and y >= ry and y <= rh then
    return true
  else
    return false
  end
end

---
-- Returns if a point is inside a circle.
-- 
-- @function [parent=#MathUtils] isInCircle
-- @param #number x The point x position.
-- @param #number y The point y position.
-- @param #number cx The circle center x position.
-- @param #number cy The circle center y position.
-- @param #number cr The circle radius.
-- @return #boolean Is the point in the circle ?
function MU.isInCircle(x,y,cx,cy,cr)
  local dist = MU.calcDistance(x,y,cx,cy)
  if dist <= cr then return true else return false end
end

function MU.calcDistance(x1,y1,x2,y2)
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

return MU