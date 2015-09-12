--This code was taken from concerned joe with permission--
--[[
 * Copyright (c) 2012-2014 Those Awesome Guys (TAG)
 *
 * You may NOT use this software for any commercial 
 * purpose, nor can you alter and redistribute it as your own.
 * Any credit must be attributed to Those Awesome Guys (TAG)
 * 
 * You are allowed and even encouraged to mod(ify) the game 
 * but all alterations must be specificed as a mod of the game
 * Concerned Joe, and not claim that Concerned Joe itself is a game
 * of your creation.
 *
 *  This notice may not be removed or altered from any source distribution.
 --]]

local channel = love.thread.getChannel("Loader");
local num = channel:demand();
local subchannel = love.thread.getChannel("Loader" .. num);
local infoChannel = love.thread.getChannel("LoaderInformation" .. num)
local resultsChannel = love.thread.getChannel("LoaderResults")

require("love.filesystem")
require("love.image");
require("love.audio");
require("love.font");
require("love.sound")


while true do 
	local Type = subchannel:demand();
	local FilePath = subchannel:demand();

	local q = infoChannel:pop();
	if(q ~= nil)then _TEXTUREQUALITY = q end

	local resource;

	if(Type == "Image")then 
		-- local func = function()love.image.newImageData(FilePath) end
		-- local okay = pcall(func)
		-- if(okay == false)then error("Cannot decode " .. FilePath) end

		local finalName;
		local chosenQuality = _TEXTUREQUALITY;
		---If the texture quality is high, get the normal asset
		--if not, get either the _M or _L if they exist
		if(_TEXTUREQUALITY == "High")then 
			finalName = FilePath
		else
			local lastBracket = FilePath:find("/[^/]*$")
			local name = FilePath:sub(lastBracket+1)
			if(_TEXTUREQUALITY == "Medium")then 
				name = "Cache/" .. name:gsub(".png","_M.png");
			elseif(_TEXTUREQUALITY == "Low")then 
				name = "Cache/" .. name:gsub(".png","_L.png");
			end
			if(not love.filesystem.exists(name))then 
				finalName = FilePath 
				chosenQuality = "High"
			else 
				finalName = name;
			end

		end 

		resultsChannel:push(chosenQuality)
		resource = love.image.newImageData(finalName);

	elseif(Type == "Json" or Type == "Ini")then
		resource = love.filesystem.read(FilePath);
	elseif(Type == "Font")then 
    --resource = Font(FilePath);
	end

	subchannel:supply("done")
	subchannel:supply(Type);
	subchannel:supply(resource);
	collectgarbage()
end