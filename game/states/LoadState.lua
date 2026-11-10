LoadState = {}
LoadState.MainPath = ""

Game = {}
Game.EXEName = ""
Game.EXEType = ""
Game.Path = ""
Game.Format = ""

local function ReturnFileDirectory(string, fix_string)
	if (love.system.getOS() == "Windows") then
		string = string:gsub("/", "\\");
	else
		string = string:gsub("\\", "/");
	end
	if (string) then
		local directory_path_end = string:find("/[^/]*$");
		string = string:sub(1, directory_path_end-1);
	end
	return string;
end

local function ReturnFilename(string, no_extension)
	local filename = string:sub(string:find("/[^/]*$") + 1);
	if (no_extension) then
		filename = filename:sub(1, filename:match(".*()%.") - 1);
	end
	return filename;
end

local function ReturnFiletype(string)
	return string:sub(string:find(".[^.]*$") + 1);
end

function LoadState:Initalize()
	CurrentState = self

	-- when path-saving is in we can parse the saved filepath and load files immediately before transitioning to MenuState
	-- for now its just this

	---@diagnostic disable-next-line: undefined-field
	love.window.showFileDialog("openfolder", function(files, filtername, errorstring)
		if errorstring then
			error(errorstring)
		end
		
		self:LoadFiles(files[1])
	end)
end

-- This function will return a string filetree of all files
-- in the folder and files in all subfolders
function RecursiveEnumerate(folder, fileTree)
	local tree = {}
	local filesTable = love.filesystem.getDirectoryItems(folder)

	for i,v in ipairs(filesTable) do
		local file = folder.."/"..v
		local info = love.filesystem.getInfo(file)
		local short = v:match("([^/\\]+)%.[^%.]+$")
		if not short then
			short = v:match("([^/\\]+)$")
		end

		if info then
			if info.type == "file" then
---@diagnostic disable-next-line: undefined-field
				tree[short] = love.filesystem.openFile(file, "r")
			elseif info.type == "directory" then
				tree[short] = RecursiveEnumerate(file, fileTree)
			end
		end
	end

	return tree
end

function LoadState:ValidGamePath(path, exename, exetype)
	local lfile = love.filesystem;
	local OS = love.system.getOS();

	local filename = ("%s/%s.%s"):format(path, exename, exetype);
	if (OS == "Windows") then
		filename = filename:gsub("/", "\\");
	end

	if (lfile.openNativeFile and lfile.openNativeFile(filename, "r")) then
		-- Pretty sure this is a relatively new function, so...
		-- so I wanna make sure things stay compatible between LOVE2D versions
		return true;
	end	
	return (lfile.exists(filename) and lfile.isFile(filename));
end

-- @todo TODO: search directory automatically for executable :p
-- @note (preferably with love.filesystem.getDirectoryItems?)
function LoadState:SetGameJunk(path)
	local OS = love.system.getOS();
	local executable_name;
	local executable_type;

	if (OS ~= "Windows" and OS ~= "OS X" and OS ~= "iOS" and OS ~= "Linux" and OS ~= "Android") then
		print("Unknown OS, can't launch game!");
		return;
	end

	if (OS == "Windows") then
		executable_name = "srb2win";
		executable_type = "exe";
	elseif (OS == "OS X") then
		-- ngl i dunno how to launch this lol
		executable_name = "srb2";
		executable_type = "darwin";
	elseif (OS == "iOS") then
		executable_name = "srb2";
		executable_type = "ipa";
	elseif (OS == "Linux") then
		executable_name = "lsdl2srb2";
		executable_type = "";
	elseif (OS == "Android") then
		executable_name = "srb2-android";
		executable_type = "apk";
	end

	if not (LoadState:ValidGamePath(path, executable_name, executable_type)) then
		print(("Couldn't find executable (%s/%s.%s), please select it."):format(path, executable_name, executable_type));
		---@diagnostic disable-next-line: undefined-field
		love.window.showFileDialog("openfile", function(files, filtername, errorstring)
			if (errorstring) then
				error(errorstring);
				return;
			end
			if (files[1]) then
				local filename = files[1];
				filename = filename:gsub("\\", "/");
				Game.Path = ReturnFileDirectory(filename, true);
				Game.EXEName = ReturnFilename(filename, true);
				Game.EXEType = ReturnFiletype(filename);
				Game.Format = ('cd "%s" & "%s/%s.%s"');
				print(("Found executable! (%s/%s.%s)"):format(Game.Path, Game.EXEName, Game.EXEType));
				return true;
			else
				print("Game exectuable not found.");
				return false;
			end
		end)
	else
		if (OS == "Windows") then
			Game.Path = path:gsub("/", "\\");
		else
			Game.Path = path:gsub("\\", "/");
		end
		Game.EXEName = executable_name;
		Game.EXEType = executable_type;
		Game.Format = ('cd "%s" & "%s/%s.%s"');
	end
end

function LoadState:LoadFiles(path)
	path = path:gsub("\\", "/");
	if (LoadState.MainPath == "") then
		LoadState.MainPath = path;
		LoadState:SetGameJunk(path);
	end

	-- load files...
    local gamefilepaths = {
		"srb2.pk3",
		"music.pk3",
		"characters.pk3"
	}

	for k, v in ipairs(gamefilepaths) do
		local fullpath = path.."/"..v
---@diagnostic disable-next-line: undefined-field
		local file, errorstr = love.filesystem.openNativeFile(fullpath, "r")
		local path = v:sub(1, #v-4)
		local mountpath = "gamedata"..k

		if errorstr then
			error("somethings up with "..v)
		end

		-- convert love file to filedata for the thingy
		local bytes = file:read()
		file:close()
		if not bytes then
			error("uh oh")
		end
		local fileData = love.filesystem.newFileData(bytes, v)
	
		love.filesystem.mount(fileData, mountpath, mountpath)
		
		-- load everything in the folder recursively
		local folder = RecursiveEnumerate(mountpath)
		GameAssets[path] = folder

		love.filesystem.unmount(mountpath)
	end

	-- setup palette
	Palette:Initalize(GameAssets["srb2"]["PLAYPAL"])

	-- setup videolib
	Video:Initalize()

	-- debugging
	-- Palette:FindClosestColor(1, 0, 0)
	Sonic = Patch.Initalize(GameAssets.characters["1_Sonic"]["2_Sprites"].STNDA1)
	-- Patch.Initalize(folders.srb2.Graphics.Titlescreen.Alacroix["T4RIBB25"])

	-- menus
    MenuState:Initalize()
	SideTab:Initalize()
end

function LoadState:Update() end

function LoadState:Draw()
	love.graphics.print("hi", 0, 0)
end
