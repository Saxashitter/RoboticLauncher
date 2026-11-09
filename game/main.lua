require("helpers.String")
require("helpers.BitReader")

require("managers.Video")
require("managers.Palette")
require("managers.SideTab")

require("objects.Patch")

require("states.LoadState")
require("states.MenuState")
require("states.MultiplayerState")

function love.load()
	GameAssets = {}

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