SRB2 = {};
SRB2.thread = nil;
SRB2.icon = nil;

-- @todo Make this more of a global library thing
-- Helps with compatibility and stuff, love2D 12 won't be necessary then :p
local function OpenFile(filename, mode)
	local lfile = love.filesystem;
	local file;

	if (lfile.openNativeFile) then
		-- Pretty sure this is a relatively new function, so...
		-- so I wanna make sure things stay compatible between LOVE2D versions
		file = lfile.openNativeFile(filename, mode);
		return file;
	end
	if (lfile.newFile) then
		file = lfile.newFile(filename);
		file:open(mode);
		return file;
	end

	error("ERROR: No way to open a file!");
	return nil;
end

function SRB2:GetGameIcon()
	local OS = love.system.getOS();
	local gamepath = ("%s/%s.%s"):format(Game.Path, Game.EXEName, Game.EXEType);

	if (OS == "Windows") then
		gamepath = gamepath:gsub("/", "\\");
	else
		gamepath = gamepath:gsub("\\", "/");
	end

	if (OS == "Windows") then
		os.execute(('"start %s -open %s -save %s -action extract -mask ICONGROUP,, -log CON"'):format(resource_hacker_program, gamepath, gameicons_directory));
		--SRB2.icon = Patch.Initalize(gameicons_directory .. (OS == "Windows" and "\\" or "/") .. "ICON106_1.ico");
		-- @todo Too late for me now, but eventually add another library to convert to png :p
	else
		print("No way for other platforms to get the icon yet!");
	end
end

function SRB2:Launch()
	local OS_newthread = [[
		local game_fullpath = ...;
		os.execute(game_fullpath);
	]];
	local OS_command = Game.Format:format(Game.Path, Game.Path, Game.EXEName, Game.EXEType);

	self.thread = love.thread.newThread(OS_newthread:format(Game.Path, Game.EXEName, Game.EXEType));
	self.thread:start(OS_command);
	self:GetGameIcon();
end

function SRB2:Running()
	return (self.thread and self.thread.isRunning);
end
