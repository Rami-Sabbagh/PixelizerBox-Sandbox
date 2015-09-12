local Signal = require("Helpers.hump.signal")
local Class = require("Helpers.hump.class")

local GWeapon = Class{}

function GWeapon:init(GeneratorClass,Args,DimName,Snap,GUIData)
  self.genClass = GeneratorClass
  self.args = Args and Args[1]
  self.genArgs = Args and Args[2] or {}
  self.genDim = DimName
  self.snap = Snap
  self.guiData = GUIData
  
  self.generator = self.genClass(self.genDim,Snap,self.guiData,unpack(self.genArgs))
end

function GWeapon:instantCreate(data)
  self:destroy() --The GWeapon must not be saved !
end

function GWeapon:draw(mx,my)
  if self.generator and self.generator.draw then self.generator:draw(mx,my) end
end

function GWeapon:drawBack()
  if self.generator and self.generator.drawBack then self.generator:drawBack() end
end

function GWeapon:update(dt,mx,my)
  if self.generator and self.generator.update then self.generator:update(dt,mx,my) end
  
  return false, nil --The GWeapon must not be saved !
end

function GWeapon:mousepressed(x,y,button)
   if self.generator and self.generator.mousepressed then self.generator:mousepressed(x,y,button) end
end

function GWeapon:mousereleased(x,y,button)
  if self.generator and self.generator.mousereleased then self.generator:mousereleased(x,y,button) end
end

function GWeapon:cancel()
  if self.generator and self.generator.destroy then self.generator:destroy() end
end

function GWeapon:invokePoint(x,y)
  
end

function GWeapon:getData()
  return nil --The GWeapon must not be saved !
end

function GWeapon:destroy()
  if self.generator and self.generator.destroy then self.generator:destroy() end
end

return GWeapon