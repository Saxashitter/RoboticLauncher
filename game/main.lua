require("helpers.String")
require("helpers.BitReader")

require("managers.Video")
require("managers.Palette")
require("managers.SideTab")

require("objects.Patch")

require("states.LoadState")
require("states.MenuState")

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