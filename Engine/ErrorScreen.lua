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

--This file is the error screen that shows when the game crashs !--
--Not documented due it's not a part of the main game, Only a error handler--
local loveframes = require("Helpers.loveframes")

local giantFont = love.graphics.newFont("/Helpers/loveframes/skins/Snap/font/RobotoCondensed-Bold.ttf", 24)
local bigFont = love.graphics.newFont("/Helpers/loveframes/skins/Snap/font/RobotoCondensed-Bold.ttf", 18)
local smallFont = love.graphics.newFont("/Helpers/loveframes/skins/Snap/font/Roboto-Light.ttf", 12)

local crashBot = love.graphics.newImage("/Libs/Misc/RobotCrash.png")

local function error_printer(msg, layer)
  print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
  msg = tostring(msg)
  
  error_printer(msg, 2)
  
  if not love.window or not love.graphics or not love.event then
    return
  end
  
  if not love.graphics.isCreated() or not love.window.isCreated() then
    if not pcall(love.window.setMode, 800, 600) then
      return
    end
  end
  
  -- Reset state.
  if love.mouse then
    love.mouse.setVisible(true)
    love.mouse.setGrabbed(false)
  end
  if love.joystick then
    for i,v in ipairs(love.joystick.getJoysticks()) do
      v:setVibration() -- Stop all joystick vibrations.
    end
  end
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.clear()
  love.graphics.origin()
  
  loveframes.util.RemoveAll()
  loveframes.SetState("none")
  
  local trace = debug.traceback()
  
  local err = {}
  
  table.insert(err, msg.."\n")
  
  
  for l in string.gmatch(trace, "(.-)\n") do
    if not string.match(l, "boot.lua") then
      l = string.gsub(l, "stack traceback:", "Traceback(OS: "..love.system.getOS().."):\n")
      table.insert(err, l)
    end
  end
  
  table.insert(err, "\nGlobal Variables:\n")
  
  local varsData={}
  
  for k,v in pairs(_G) do
    --table.insert(err, k.." ["..type(v).."]: "..tostring(v))
    if not varsData[type(v)] then varsData[type(v)] = {} end
    varsData[type(v)][k] = v
  end
  
  for tk,tv in pairs(varsData) do
    table.insert(err,"["..tk.."s]:")
    local fakeTable = {}
    for k,v in pairs(tv) do table.insert(fakeTable,k) end
    table.sort(fakeTable)
    for k,v in ipairs(fakeTable) do
      local value = tostring(tv[v])
      value = value:gsub("function%: ","")
      value = value:gsub("table%: ","")
      table.insert(err,"  "..v..": "..value)
    end
  end
  
  local ErrMSG = table.concat(err, "\n")
  
  ErrMSG = string.gsub(ErrMSG, "\t", "")
  ErrMSG = string.gsub(ErrMSG, "%[string \"(.-)\"%]", "%1")
  
  local hand = {}
  
  function hand.run()
    if love.math then
      love.math.setRandomSeed(os.time())
    end
    
    if love.event then
      love.event.pump()
    end
    
    if hand.load then hand.load(arg) end
    
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end
    
    local dt = 0
    
    -- Main loop time.
    while true do
      -- Process events.
      if love.event then
        love.event.pump()
        for e,a,b,c,d in love.event.poll() do
          if e == "quit" then
            if not love.quit or not love.quit() then
              if love.audio then
                love.audio.stop()
              end
              return
            end
          end
          if hand[e] then hand[e](a,b,c,d) end
        end
      end
      
      -- Update dt, as we'll be passing it to update
      if love.timer then
        love.timer.step()
        dt = love.timer.getDelta()
      end
      
      -- Call update and draw
      if hand.update then hand.update(dt) end -- will pass 0 if love.timer is disabled
      
      if love.window and love.graphics and love.window.isCreated() then
        love.graphics.clear()
        love.graphics.origin()
        if hand.draw then hand.draw() end
        love.graphics.present()
      end
      
      if love.timer then love.timer.sleep(0.001) end
    end
  end
  
  function hand.load()
    love.window.setTitle("PixelizerBox V".._Version.." [".._State.."] [Crashed]")
    
    love.graphics.setBackgroundColor(50,50,50,255)
    
    local Title = loveframes.Create("text")
    Title:SetPos(120,50):SetFont(giantFont):SetDefaultColor(255,255,255,255)
    Title:SetText("Why did I crash Q-Q, Plz report me at the bug tracker.")
    
    local Note = loveframes.Create("text")
    Note:SetPos(130,80):SetFont(bigFont):SetDefaultColor(175,175,175,255)
    Note:SetText("That's why I'm in the early access :P")
    
    local ErrorList = loveframes.Create("list")
    ErrorList:SetPos(70,140):SetSize(love.graphics.getWidth()-140,love.graphics.getHeight()-260)
    ErrorList:SetPadding(5):SetPadding(5)
    
    local ErrorText = loveframes.Create("text")
    ErrorText:SetFont(bigFont):SetText(ErrMSG)
    ErrorList:AddItem(ErrorText)
    
    local CopyError = loveframes.Create("button")
    CopyError:SetPos(70,love.graphics.getHeight()-100):SetSize(love.graphics.getWidth()/2-70,50)
    CopyError:SetText("Copy crash report to clipboard (Do this before submitting)")
    CopyError.OnClick = function() love.system.setClipboardText(ErrMSG) end
    
    local PasteError = loveframes.Create("button")
    PasteError:SetPos(20+love.graphics.getWidth()/2,love.graphics.getHeight()-100)
    PasteError:SetSize(love.graphics.getWidth()/2-90,50)
    PasteError:SetText("Submit crash report (Do this after copying it)")
    PasteError.OnClick = function() love.system.openURL("https://bitbucket.org/RamiLego4Game/pixelizerbox/issues/new") end
  end
  
  function hand.update(dt)
    loveframes.update(dt)
  end
  
  function hand.draw()
    loveframes.draw()
  end
  
  function hand.mousepressed(x,y,button)
    loveframes.mousepressed(x,y,button)
  end
  
  function hand.mousereleased(x,y,button)
    loveframes.mousereleased(x,y,button)
  end
  
  function hand.keypressed(key,isrepeat)
    if key == "escape" then love.event.quit() end
    loveframes.keypressed(key,isrepeat)
  end
  
  function hand.keyreleased(key)
    loveframes.keyreleased(key)
  end
  
  function hand.textinput(text)
    loveframes.textinput(text)
  end
  
  hand.run()
end