local Class = require("Helpers.hump.class") --Require the Hump class.
---
-- The edge generator.
-- Note: This generator is only for use with the HoldCreate handler, See this file Engine.GeneratorsHandlers.HoldCreate.
-- @module Edge
-- @return #Edge

--- @type Edge
local Edge = Class{} --Create the edge generator class.

local MathUtils = require("Engine.MathUtils") --Require the MathUtils for checking if a point is on the edge
local DimensionManager = require("Engine.DimensionManager") --Require the DimesionManager for getting the physics world.
local B2Edge = require("Engine.B2Object.Edge") --Require the Box2D edge creator.

---
-- Called when the user selects this generator and presses the mouse.
-- Note: Do not use love.mouse.getPosition because there is a camera !
-- 
-- @callof Edge#Edge
-- @param self The edge generator instance.
-- @param #number x The x position to start creating from.
-- @param #number y The y position to start creating from.
-- @param #string dimName The dimension name to create the object at.
-- @param #number Snap The snap amount.
-- @param #table GUIData The data of the created elements in the generator GUI file (See Mods/ExtraObject/Edge.gui).
-- @return #Edge The edge instance after initialization.
function Edge:init(x,y,dimName,snap,GUIData)
  self.world = DimensionManager:getDimension(dimName):getWorld() --Get the physics world
  self.snap = snap --Storing the snap
  self.guiData = GUIData --Storing the snap
  
  self.startX, self.startY  = x,y --The start point
  self.endX, self.endY = x,y --The end point
end

---
-- Called when the user finishs creating the object and releases.
-- 
-- @function [parent=#Edge] create
-- @param #number x The x position to end creating at.
-- @param #number y The y position to end creating at.
-- @return #boolean Did the generator create correctly.
function Edge:create(x,y)
  self.endX, self.endY = x,y --The end point
  
  self.object = B2Edge(self.world:getWorld(),self.startX,self.startY,self.endX,self.endY,true) --Create the box2d edge object
  
  if not self.object.failed then
    self.object.fixture:setFriction(self.guiData["Friction"] or 1) --Set the friction from the GUIData
    self.object.fixture:setRestitution(self.guiData["Restitution"] or 0) --Set the restitution from the GUIData
    return true
  else
    self.object = nil
    return false
  end
end

---
-- Called when drawing this object (Layer 2).
-- Note: Do not use love.mouse.getPosition because there is a camera !
-- 
-- @function [parent=#Edge] draw
-- @param self The edge generator instance.
-- @param #number mx The mouse x possition.
-- @param #number my The mouse y possition.
function Edge:draw(mx,my)
  if self.dead then return end --Prevent drawing if destroyed
  if self.object and not self.object.body:isActive() then return end
  
  love.graphics.setColor(150,150,150,255)
  love.graphics.setLineWidth(5)
  love.graphics.line(self.startX,self.startY,mx or self.endX,my or self.endY)
end

---
-- Called when drawing this object (Layer 1).
-- Note: Do not use love.mouse.getPosition because there is a camera !
-- 
-- @function [parent=#Edge] drawBack
function Edge:drawBack()
  if self.dead then return end --Prevent drawing if destroyed
  if self.object and not self.object.body:isActive() then return end
  love.graphics.setColor(100,100,100,255)
  love.graphics.setLineWidth(11)
  love.graphics.line(self.startX,self.startY,self.endX,self.endY)
end

---
-- Called when the user is trying to delete objects.
-- Return if the point is inside or on the object.
-- 
-- @function [parent=#Edge] invokePoint
-- @param #number x The point x position
-- @param #number y The point y position
-- @return #boolean Is the point is inside or on the object.
function Edge:invokePoint(x,y)
  if not self.object or self.dead then return end
  return MathUtils.isOnLine(self.startX,self.startY,self.endX,self.endY,x,y,5)
end

---
-- Called when destroying this generator.
-- Delete your box2d object if it exists.
-- Remember to stop drawing and updating the generator.
-- 
-- @function [parent=#Edge] destroy
function Edge:destroy()
  if self.object then self.object:destroy() end
  self.dead = true --To prevent drawing
end

return {HoldCreate=Edge} --Return the generator class.