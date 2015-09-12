--This code was taken from concerned joe with permission--
--[[
 * Copyright (c) 2012-2014 Those Awesome Guys (TAG)
 *
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

local Loader = {};

local imageHolder = {};
local soundHolder = {};
local fontHolder = {};
local imgDataHolder = {};
local rawJDataHolder = {};
local rawINIHolder = {};

local stuffToLoad = {};
local currentlyLoading = false;
local totalNum = 0;
local totalFonts = 0;
local fontsToLoad = {};
local soundsToLoad = {};
local totalSounds = 0;
local numThreads = 10;
local threadArray = {}
local resultsChannel = love.thread.getChannel("LoaderResults")

local Font = require("Engine.Font") --Custom font cashing table

function Loader:init(Holders)
	--Must be done only once at the start of the game
	--Starts the thread and leaves it open forever

	local channel = love.thread.getChannel("Loader")
	for i=1,numThreads do 
		local thread = love.thread.newThread("Helpers/LoaderThread.lua");
		thread:start();
		channel:supply(i);
		threadArray[#threadArray+1] = thread;
	end

	self:updateQuality()

	imageHolder = Holders[1];
	soundHolder = Holders[2];
	fontHolder = Holders[3];
	imgDataHolder = Holders[4];
	rawJDataHolder = Holders[5];
	rawINIHolder = Holders[6];
end

function Loader:updateQuality()
	for i=1,numThreads do 
		local info = love.thread.getChannel("LoaderInformation" .. i);
		info:push(_TEXTUREQUALITY)
	end
end

function Loader:load(FilePath,Name,FontSize,SpecialRequest,Prefix)
	local ob = {};

	--Check if this file is found in the User/ directory, if not, get it from the normal game's directory
	--if(love.filesystem.exists(_USERDIRECTORY .. FilePath))then 
	--	FilePath = _USERDIRECTORY .. FilePath;
	--end

	--Get type through extension
	local Type = "";
	local i = string.find(FilePath,".",nil,true)---Last argument is to turn off "magic patterns" when searching for strings
	local e = string.sub(FilePath,i+1); --e for extension

	local imageTypes = {"png","jpg","jpeg","dds"};
	local soundTypes = {"ogg","mp3","wav"};
	local fontTypes = {"ttf","otf"};
	local jsonType = "json";
	local iniType = "ini"

	local exceptions = {"db","txt","mod","lua","gui",} ---to skip files, (used to be to be to skip json files)

	if(FontSize == nil)then FontSize = 12 end

	if(Name == nil)then 
		--find last backslash
		local index = string.find(FilePath,"/");
		while(string.find(FilePath,"/",index+1) ~= nil)do 
			index = string.find(FilePath,"/",index+1)
		end

		Name = string.gsub(FilePath,"." .. e,"");
		Name = string.sub(Name,index+1);
		if(Prefix)then Name = Prefix .. Name end
	end

	if(_DXT == false and e == "dds")then--replace all dds with png if dxt isnt supported 
		FilePath = FilePath:gsub("dds","png")
	end

	for i=1,#imageTypes do 	if(e == imageTypes[i])then Type = "Image" end end
	for i=1,#soundTypes do if(e == soundTypes[i])then Type = "Sound" end end
	for i=1,#fontTypes do if(e == fontTypes[i])then Type = "Font" end end
	if(e == jsonType)then Type = "Json" end
	if(e == iniType)then Type = "Ini" end
	for i=1,#exceptions do if(e == exceptions[i])then Type = "NoGo" end end

	--if(Type == "")then error("Error, type '" .. e .. "' is unknown.") end

	ob.type = Type;
	ob.filePath = FilePath;
	ob.specialRequest = SpecialRequest; ---for loading an imageData instead of Image for example
	ob.name = Name;

	---make a special exception not to mipmap UI
	if(Type == "Image")then 
		--if(FilePath:find("Lib/UI") == 1)then _IsUI[Name] = true end
	end

	

	if(Type ~= "NoGo")then --for skipping files

		if(Type ~= "Font" and Type ~= "Sound")then 
			stuffToLoad[#stuffToLoad+1] = ob;
			totalNum = totalNum + 1;
		elseif(Type == "Font")then
			ob.fontsize = FontSize;

			totalFonts = totalFonts + 1;
			fontsToLoad[#fontsToLoad+1] = ob;
		elseif(Type == "Sound")then
			totalSounds = totalSounds+1;
			soundsToLoad[#soundsToLoad+1] = ob;
		end

	end --end skipping json files
end

function Loader:LoadFolder(FolderPath,Prefix,Exceptions)
	local files = love.filesystem.getDirectoryItems(FolderPath);
	if(Exceptions == nil)then Exceptions = {} end

	--Add the files from the user directory in case there is anything there that isn't in this folder
	--local extrafiles = love.filesystem.getDirectoryItems(_USERDIRECTORY .. FolderPath);
	if(extrafiles ~= nil)then --if it exists
		local hashes = {};
		for i=1,#files do hashes[files[i]] = true end
		for i=1,#extrafiles do 
			if(not hashes[extrafiles[i]])then 
				files[#files+1] = extrafiles[i]
			end
		end
	end

	for i=1,#files do 
		local dontLoad = false;
		for j=1,#Exceptions do if(files[i] == Exceptions[j])then dontLoad = true end end
		if(dontLoad == false and string.find(FolderPath .. files[i],".",nil,true) ~= nil)then --check if not folder
			self:load(FolderPath .. files[i],nil,nil,nil,Prefix);
		end
	end
end


function Loader:LoadDirectory(FolderPath,exceptions)
	local files = love.filesystem.getDirectoryItems(FolderPath);

	if(exceptions ~= nil)then 
		for i=1,#exceptions do 
			for j=1,#files do 
				if(files[j] == exceptions[i])then table.remove(files,j); break end
			end
		end
	end

	for i=1,#files do 
		if(string.find(FolderPath .. files[i],".",nil,true) ~= nil)then --check if not folder
			self:load(FolderPath .. files[i]);
		else 
			self:LoadFolder(FolderPath .. files[i] .. "/")
		end
	end
end

function Loader:getProgress()
	if(totalNum == 0 and totalFonts == 0 and totalSounds == 0)then return 1 end
	return 1 - ((#stuffToLoad + #fontsToLoad+1 + #soundsToLoad) / (totalNum+totalFonts+totalSounds));
end

local CheckForErrors = function(thread)
	local errorMessage = thread:getError()
    assert(not errorMessage, errorMessage)
end

local debugCheck = function(holder,n)--Debug check. Can be removed in the final version
	--if(holder[n] ~= nil)then print("Error, two instances of the asset '" .. n .. "' found in project. Cannot have two instances with the same name") end
end

local GetResourceIfDone = function(channel)
	--Check if done, and if so get it from thread, set currentLoadingSomething to false
	local done = channel:peek()

	if(done == "done")then --if done
		local d = channel:pop()--remove the done
		local loadedType = channel:demand();
		local loadedResource = channel:demand();
		local n = currentlyLoading.name;
    
    print("Loaded "..tostring(n).." ["..tostring(loadedType).."]") --DEBUG
    
		if(loadedType == "Image")then 
			--local console = require("Engine/Console")
			--console.SetLastLoaded(n)--to be able to print loaded images
			if(currentlyLoading.specialRequest == nil)then 
				imageHolder[n] = love.graphics.newImage(loadedResource)
			end
			if(currentlyLoading.specialRequest == "GetImageData")then 
				debugCheck(imageDataHolder,n);
				imgDataHolder[n] = loadedResource 
			end
			_ImageQualities[n] = resultsChannel:pop();
		end
		if(loadedType == "Sound")then debugCheck(soundHolder,n); soundHolder[n] = loadedResource; end
		if(loadedType == "Json")then debugCheck(rawJDataHolder,n); rawJDataHolder[n] = loadedResource; end
		if(loadedType == "Ini")then debugCheck(rawINIHolder,n); rawINIHolder[n] = loadedResource end
    --if(loadedType == "Font")then debugCheck(fontHolder,n); fontHolder[n] = loadedResource; print("Font loaded, "..n) end
		currentlyLoading = false;
	end--end if done
end

local PushNewResource = function(channel)
	--get something new to load, give it to the thread, set currenltLoadingSomething to true or something
	channel:push(stuffToLoad[1].type)
	channel:push(stuffToLoad[1].filePath)
	currentlyLoading = stuffToLoad[1];
	table.remove(stuffToLoad,1);
end

local ResetLoading = function()
	totalNum = 0;
end

local LoadFonts = function()
	--Load 10 at a time per frame for fasterness
	for i=1,10 do 
		if(#fontsToLoad > 0)then
			local ob = fontsToLoad[1];
			fontHolder[ob.name] = Font(ob.filePath);
			table.remove(fontsToLoad,1);
		else totalFonts = 0 end
	end
end

local LoadSounds = function()
	for i=1,10 do
		if(#soundsToLoad > 0)then 
			local ob = soundsToLoad[1];
			soundHolder[ob.name] = ob.filePath;
			table.remove(soundsToLoad,1);
		else totalSounds = 0 end
	end
end

function Loader:Update()

	for i=1,numThreads do 
		local thread = threadArray[i];
		local subchannel = love.thread.getChannel("Loader" .. i);

		--check for errors:
		for i=1,numThreads do 
			CheckForErrors(thread);
		end

		if (currentlyLoading)then 
			GetResourceIfDone(subchannel)
		elseif(#stuffToLoad > 0)then --if there is nothing being loaded, and there is still stuff to load
			PushNewResource(subchannel)
		elseif(#stuffToLoad == 0)then --if no more stuff to load, and finished loading everything
			--Done!
			ResetLoading();
		end 
	end

	LoadFonts();
	LoadSounds()	

end


return Loader;