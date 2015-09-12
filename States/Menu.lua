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

local Menu = {}

local loveframes = require("Helpers.loveframes")
local Gamestate = require("Helpers.hump.gamestate")
local Timer = require("Helpers.hump.timer")
local Tweens = require("Helpers.tween")

local ButtonsPanel = require("Engine.Menu.ButtonsPanel")

local Sandbox = require("States.Sandbox")

function Menu:init()
  local fadingTime = 0.5
  self.fadingTime = fadingTime
  
  self.BP = ButtonsPanel("Menu",_Width/4,_Height/2,200,400,true)
  self.BP:newButton("Sandbox", function()
      loveframes.SetState("none")
      self.tween = Tweens.new(self.fadingTime,self.alpha,{255})
      Timer.add(self.fadingTime,function() Gamestate.switch(Sandbox) end)
    end)
  self.BP:newButton("Patches")
  self.BP:newButton("Options")
  self.BP:newButton("Exit", function()
      loveframes.SetState("none")
      self.tween = Tweens.new(self.fadingTime,self.alpha,{255})
      Timer.add(self.fadingTime,function() love.event.quit() end)
    end)
end

function Menu:enter()
  self.alpha = {255}
  self.tween = Tweens.new(self.fadingTime,self.alpha,{0})
  
  love.graphics.setBackgroundColor(50,50,50,255)
  
  loveframes.SetState("Menu")
end

function Menu:draw()
  love.graphics.setColor(255,255,255,255)
  love.graphics.draw( _Images["Background"], _Width, _Height, 0, 1, 1, _Images["Background"]:getWidth(), _Images["Background"]:getHeight() )
    
  loveframes.draw()
  
  --Fade--
  love.graphics.setColor(0,0,0,self.alpha[1])
  love.graphics.rectangle("fill",0,0,_Width,_Height)
end

function Menu:update(dt)
  Timer.update(dt)
  self.tween:update(dt)
end

function Menu:leave()
  loveframes.SetState("none")
end

return Menu