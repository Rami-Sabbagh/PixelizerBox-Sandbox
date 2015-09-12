local Writer = {};

--[[
Example use:

local writer = require("Writer");
writer:WriteFile("Lib/Any/Dir/You/Want/textFile.txt","This is a test");

And it will create the text file, and all directories and subdirectories automatically if they do not exist
]]--

function split(str, pat)----a useful string splitting function
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

local directories = {};
function Writer:CreateDirectory(path)
    ---check that I can create a directory here
    ---by creating a temporary file
    local file = io.open(path .. "/temp.checker","w");
    local lastBracket = path:find("/[^/]*$")

    if(file == nil)then
        --Go up and try to create a directory
        local subDir = "";
        if(lastBracket ~= nil)then subDir = path:sub(1,lastBracket-1) end--unless we've reached the root
        table.insert(directories,path)
        self:CreateDirectory(subDir)
    else 
        file:close()
        os.remove(path .. "/temp.checker");
        while(#directories > 0)do
            local dirName = directories[#directories]
            local lastSlash = dirName:find("/[^/]*$")
            local isRoot = false;
            if(lastSlash == nil)then lastSlash = 0; isRoot = true end

            local folderName = dirName:sub(lastSlash+1)
            if(not isRoot)then dirName = dirName:sub(1,lastSlash-1) else dirName = "" end
            local command = "cd " .. dirName .. " && mkdir " .. folderName
                      
            os.execute(command)
            table.remove(directories,#directories)
        end
    end

end

function Writer:WriteFile(path,data)
    local file,e = io.open(path,"wb");
    if(file == nil)then ---if directory isn't created
        local lastBracket = path:find("/[^/]*$")
        local subDir = path:sub(1,lastBracket-1)
        self:CreateDirectory(subDir)
        file = io.open(path,"wb")
    end
    file:write(data)
    file:close()
end

return Writer;