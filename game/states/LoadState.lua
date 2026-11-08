LoadState = {}

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

function LoadState:LoadFiles(path)
    if not path or path == "" then return end

    -- Normalize Windows separators for LÖVE's virtual filesystem.
    path = path:gsub("\\", "/")

	-- load files...
    local gamefilepaths = {
		"srb2.pk3",
		"music.pk3",
		"characters.pk3"
	}
	local folders = {}

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
		print("================")
		print(v)
		print("================")
		
		-- load everything in the folder recursively
		local folder = RecursiveEnumerate(mountpath)
		folders[path] = folder

		love.filesystem.unmount(mountpath)
	end

	-- setup palette
	Palette:Initalize(folders["srb2"]["PLAYPAL"])

	-- debugging
	-- Palette:FindClosestColor(1, 0, 0)
	Sonic = Patch.Initalize(folders.characters["1_Sonic"]["2_Sprites"].STNDA1)
	-- Patch.Initalize(folders.srb2.Graphics.Titlescreen.Alacroix["T4RIBB25"])

	GameAssets = folders
    MenuState:Initalize()
end

function LoadState:Update(dt)
end

function LoadState:Draw()
	love.graphics.print("hi", 0, 0)
end