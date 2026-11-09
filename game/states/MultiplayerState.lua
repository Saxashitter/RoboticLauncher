MultiplayerState = {}

local time = 0
function MultiplayerState:Initalize()
	CurrentState = self
	time = 0
end


function MultiplayerState:Update(dt)
	time = time + dt
end

function MultiplayerState:Draw()
	-- love.graphics.circle("fill", 24, 12, 12)
	local angle = math.rad(20 * math.cos(time*4))

	local width, height = love.graphics.getDimensions()
	local scaleX = 3 -- * math.abs(math.cos(time))
	local scaleY = 3 -- * math.abs(math.sin(time/2))
	local wave = 1 * math.cos(time * 3)

	Video:DrawString("dis is Multi", "default", width/2, height/2, 0, scaleX, scaleY, 0, 0, wave, 0, 0.5, 0.5)
end