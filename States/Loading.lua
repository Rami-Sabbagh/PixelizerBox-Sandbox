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

local Loading = {} --(LibLoader) Shortcut--

--Requirements--
local loveframes = require("Helpers.loveframes")
local Gamestate = require("Helpers.hump.gamestate")
local Timer = require("Helpers.hump.timer")
local Tweens = require("Helpers.tween")
local Loader = require("Helpers.Loader")

local Menu = require("States.Menu")
local Sandbox = require("States.Sandbox")

local SpriteSheet = require("Engine.SpriteSheet")

function Loading:init()
  Loader:init({_Images,_Sounds,_Fonts,_ImageDatas,_rawJData,_rawINIData})
  self.fadingTime = 0.5
  
  self.sheetImage = love.graphics.newImage("Libs/Sheets/RobotSheet.png");
  self.sheetJSON = love.filesystem.read("Libs/Sheets/RobotSheet.json");
  
  self.sheet = SpriteSheet("RobotSheet",self.sheetImage,self.sheetJSON); 
  
  self:LibFolder("/Libs/");
  self:LibFolder("/Mods/");
  
  print("Loading Initialized") --DEBUG
end

function Loading:enter()
  print("Loading Entered") --DEBUG
  self.alpha = {255}
  self.tween = Tweens.new(self.fadingTime,self.alpha,{0})
  
  love.graphics.setBackgroundColor(255,255,255,255)
end

function Loading:update(dt)
  self.tween:update(dt)
  Timer.update(dt)
  Loader:Update()
  
  if math.floor(Loader:getProgress()*100) == 100 and not _Loaded then
    _Loaded = true
    print("Loading Done") --DEBUG
  end
end

function Loading:draw()
  love.graphics.setColor(255,255,255,255)
  self.sheet:draw("RobotOutline",_Width/4,_Height/2,0,25,25,11,11)
  
  local height = math.floor(Loader:getProgress()*23*25)
  
  love.graphics.setStencil(function() love.graphics.rectangle("fill",_Width/4-10*25,(_Height/2+11*25)-height,25*20,height) end)
  self.sheet:draw("Robot_Normal",_Width/4,_Height/2,0,25,25,10,10)
  love.graphics.setStencil()
  
  love.graphics.setFont(_PixelFont[36])
  love.graphics.setColor(75,75,75,255)
  
  local text = "PixelizerBox V".._Version.."\n".._State.."\n"
  for i=0,text:len()-14 do text = text.."-" end
  if not _Loaded then
    text = text.."\n Loading "..math.floor(Loader:getProgress()*100).."%"
  else
    text = text.."\n\nPress any key to continue"
  end
  
  love.graphics.printf(text,_Width/2,_Height/4-75,_Width/2,"center")
  
  love.graphics.setColor(200,0,0,255)
  
  love.graphics.printf("Important ! This game development have been stopped because of schools start,The development will restart at the end of them.\n\nThe game is licensed under apache license v2.0 so do what you want with it. ",_Width/2,_Height/2-50,_Width/2,"center")
  
  --Fade--
  love.graphics.setColor(0,0,0,self.alpha[1])
  love.graphics.rectangle("fill",0,0,_Width,_Height)
end

function Loading:leave()
  print("Loading Leaved") --DEBUG
  loveframes.SetState("none")
end

function Loading:LibFolder(dir)
  Loader:LoadFolder(dir)
  local files = love.filesystem.getDirectoryItems(dir)
  for k,file in pairs(files) do
    if love.filesystem.isDirectory(dir..file) then
      self:LibFolder(dir..file.."/")
    end
  end
end

function Loading:keypressed()
  if not _Loaded or self.exiting then return end
  self.tween = Tweens.new(self.fadingTime,self.alpha,{255})
  Timer.add(self.fadingTime,function() if _EnterSandbox then Gamestate.switch(Sandbox) else Gamestate.switch(Menu) end end)
  self.exiting = true
end

return Loading