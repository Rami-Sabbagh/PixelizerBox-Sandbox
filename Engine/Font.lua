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

---
-- PixelizerBox font caching system.
-- 
-- @module Font
local font = {}

local fontmeta = {}

---
-- Creates a new cached font.
-- 
-- @callof Font#Font
-- @param #string filename The path to the font.
-- @return Font#CachedFont The new cached font.
fontmeta.__call = function(t,filename)
  
  ---
  -- The cached font.
  -- usage: font[size] -> The cached font with the given size.
  -- 
  -- @type CachedFont
  local newfont = {}
  local newfontmeta = {}
  
  newfontmeta.__index = function(t,k)
    t[k] = love.graphics.newFont(filename,k);
    return t[k]
  end
  
  setmetatable(newfont,newfontmeta) 
  
  return newfont
end

setmetatable(font,fontmeta)

return font