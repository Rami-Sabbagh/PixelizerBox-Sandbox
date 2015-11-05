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

--Type : Class/Engine--
local SetupGame = {}

require("Engine.ErrorScreen")

local Font = require("Engine.Font")

function SetupGame:CopyDir(from,to)
  love.filesystem.createDirectory(to)
  for k, name in ipairs(love.filesystem.getDirectoryItems(from)) do
    if love.filesystem.isDirectory(from.."/"..name) then
      self:CopyDir(from.."/"..name,to.."/"..name)
    elseif love.filesystem.isFile(from.."/"..name) then
      local file = love.filesystem.read(from.."/"..name)
      love.filesystem.write(to.."/"..name,file)
      file = nil
    end
  end
end

function SetupGame:init()
  _DevelopmentMode = false
  _PixelFont = Font("Libs/Fonts/Pixel.ttf")

  _Width, _Height = love.graphics.getDimensions()
  _SystemOS = love.system.getOS()
  
  if _SystemOS == "Android" or (arg and arg[2] == "-android") then _Android = true end
  
  love.graphics.setDefaultFilter("nearest","nearest")
  
  --Loader Variables--
  _Images,_Sounds,_Fonts,_ImageDatas,_rawJData,_rawINIData,_ImageQualities,_TEXTUREQUALITY = {},{},{},{},{},{},{},"High"
  
  --_Cursor = love.mouse.newCursor(love.graphics.newImage("/Libs/Misc/SSHCursor.png"):getData())
  --love.mouse.setCursor(_Cursor)
  
  _EnterSandbox = true
  
  _Light = false
  
  if _Light then
    require("Helpers.LightVsShadow.light")
  end
  
  if not love.filesystem.exists("/Mods") or _DevelopmentMode then self:CopyDir("/InstallMods","/Mods") end
  if not love.filesystem.exists("/UserSaves") then love.filesystem.createDirectory("/UserSaves") end
  if not love.filesystem.exists("/Screenshots") then love.filesystem.createDirectory("/Screenshots") end
end

return SetupGame