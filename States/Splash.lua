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

--Type : Class/State--
local Splash = {}

--Requirements--
local UI = require("Engine.UI")
local JSON = require("Helpers.json")
local Gamestate = require("Helpers.hump.gamestate")
local Timer = require("Helpers.hump.timer")
local Tweens = require("Helpers.tween")
local Loading = require("States.Loading")

function Splash:init()
  self.LOGO = love.graphics.newImage("Libs/Misc/RL4G_LOGO.png")
  self.fadingTime = 0.5
  self.showTime = 1
  print("Splash Initialized") --DEBUG
end

function Splash:enter()
  print("Splash Entered") --DEBUG
  self.alpha = {255}
  self.tween = Tweens.new(self.fadingTime,self.alpha,{0})
  Timer.add(self.fadingTime+self.showTime,function() self.tween = Tweens.new(self.fadingTime,self.alpha,{255}) end)
  Timer.add((self.fadingTime*2)+self.showTime,function() Gamestate.switch(Loading) end)
  
  love.graphics.setBackgroundColor(255,255,255,255)
end

function Splash:draw()
  love.graphics.setColor(255,255,255,255)
  UI:Draw(self.LOGO,_Width/2,_Height/2,self.LOGO:getWidth()*1.5,self.LOGO:getHeight()*1.5,nil,true)
  
  love.graphics.setColor(0,0,0,self.alpha[1])
  love.graphics.rectangle("fill",0,0,_Width,_Height)
end

function Splash:update(dt)
  self.tween:update(dt)
  Timer.update(dt)
end

function Splash:leave()
  print("Splash Leaved") --DEBUG
  Timer.clear()
end

function Splash:keyreleased()
  love.graphics.setColor(255,255,255,255)
  print("Splash Skipped") --DEBUG
  Gamestate.switch(Loading)
end

return Splash