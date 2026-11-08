require("helpers.String")
require("helpers.BitReader")

require("managers.Video")
require("managers.Palette")

require("objects.Patch")

require("states.LoadState")
require("states.MenuState")

function love.load()
	GameAssets = {}

	LoadState:Initalize()
end

function love.update(dt)
	CurrentState:Update(dt)
end

function love.draw()
	CurrentState:Draw()
end