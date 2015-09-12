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

local Class = require("Helpers.hump.class") --Require the class library.
local Base = Class{} --Create the object class.

--The initialize function, The first argumnet should be ALWAYS the world.
function Base:init(world)
  self.world = world --You should ALWAYS store the world in the variable.
  
  self.type = "Base" --You should ALWAYS the object type in this variable.
end

--The drawing function, Doesn't call automaticaly, You have to register it in the world or handle it yourself.
function Base:draw()
  
end

--The drawing function, Doesn't call automaticaly, You have to register it in the world or handle it yourself.
function Base:update(dt)
  
end

--The destroy function, Called when destroying the world (If this object is registered).
function Base:destroy()
  
end

return Base --Return the base.