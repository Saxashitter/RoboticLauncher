require("helpers.String")
require("helpers.BitReader")

require("managers.Video")
require("managers.Palette")
require("managers.SideTab")
require("managers.SRB2")

require("objects.Patch")

require("states.LoadState")
require("states.MenuState")
require("states.MultiplayerState")

-- @todo Maybe every single require here isn't necessary?
-- It helps with compiling literally everything yes,
-- but I'm not sure if it's like cool to do this or not

love2d_main_directory = love.filesystem.getRealDirectory("main.lua");
gameicons_directory = (love2d_main_directory .. "/" .. "gameicons");

resource_hacker =  (love2d_main_directory .. "/" .. "libraries/resource_hacker/");
resource_hacker_program =  (resource_hacker .. "ResourceHacker.exe");

-- Convert to Windows file standards
-- @note probably not necessary but still :p
if (love.system.getOS() == "Windows") then
	love2d_main_directory = love2d_main_directory:gsub("/", "\\");
	gameicons_directory = gameicons_directory:gsub("/", "\\");
	resource_hacker = resource_hacker:gsub("/", "\\");
	resource_hacker_program = resource_hacker_program:gsub("/", "\\");
else
	love2d_main_directory = love2d_main_directory:gsub("\\", "/");
	gameicons_directory = gameicons_directory:gsub("\\", "/");
	resource_hacker = resource_hacker:gsub("\\", "/");
	resource_hacker_program = resource_hacker_program:gsub("\\", "/");
end

-- @todo Above might need to be moved too? Eh...

local function RemoveFull(item)
	if (love.filesystem.getInfo(item, "directory")) then
		for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
			RemoveFull(item .. (love.system.getOS() == "Windows" and "\\" or '/') .. child);
			love.filesystem.remove(item .. (love.system.getOS() == "Windows" and "\\" or '/') .. child);
		end
	end
	love.filesystem.remove(item);
end

local function RemoveGameIconsDirectory()
	--if (love.filesystem.exists(gameicons_directory)) then
		RemoveFull(gameicons_directory);
	--end
end

function love.load()
	GameAssets = {}

	print("\n") -- newline cause i hate how it doesn't make one for you already
	RemoveGameIconsDirectory()
	LoadState:Initalize()
end

function love.update(dt)
	CurrentState:Update(dt)

	if SideTab.Added then
		-- SideTab:Update(dt)
	end
end

function love.draw()
	CurrentState:Draw()

	if SideTab.Added then
		SideTab:Draw()
	end
end

function love.mousemoved(x, y, dx, dy, touchscreen)
	if SideTab.Added then
		SideTab:MouseMoved(x, y)
	end
end

function love.mousepressed(x, y, button, touchscreen, presses)
	-- sidetab should have priority
	if SideTab.Added and SideTab.Opened then
		if button == 2 then return end

		SideTab:MousePressed(x, y)
		return
	end

	if CurrentState.MousePressed then
		CurrentState:MousePressed(x, y, button)
	end
end

function love.quit()
	RemoveGameIconsDirectory();
	return false;
end
