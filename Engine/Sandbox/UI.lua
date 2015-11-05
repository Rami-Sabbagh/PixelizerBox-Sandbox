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

local UI = {mainState="Sandbox"}

local SetupGame = require("Engine.SetupGame")
local MSB = require("Engine.Sandbox.MainSideBar")
local YNF = require("Engine.Menu.YesNoFrame")
local INF = require("Engine.Menu.InfoFrame")

function UI:build()
  MSB:build(self.mainState)
  self:checkInstallModsUpdate()
end

function UI:checkInstallModsUpdate()
  local IV = 0 if love.filesystem.exists("/Mods/.version") then IV = tonumber(love.filesystem.read("/Mods/.version"),10) end
  if IV < _InstallModsVersion then
    local UserRequest = YNF(self.mainState,"Built-In Mods Update", "There's a new version of the built-in mods ready to install, Proccess ?", "Current Version: "..IV..", New Version: ".._InstallModsVersion,"Install","Ignore",true)
    UserRequest.yes.click = function()
      SetupGame:InstallMods()
      local UserInfo = INF(self.mainState,"Built-In Mods Updated","The built-in mods have been updated, Please restart the game after clicking exit.","Exit")
      UserInfo.ignore.click = love.event.quit
    end
  end
end

return UI