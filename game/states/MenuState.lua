MenuState = {}

function MenuState:Initalize()
	CurrentState = self
	SideTab:Initalize()
end

local time = 0

function MenuState:Update(dt)
	time = time + dt
end

function MenuState:Draw()
	-- love.graphics.circle("fill", 24, 12, 12)
	local bounce = math.cos(time * 2)
	local angle = math.rad(20 * math.cos(time*4))

	local width, height = love.graphics.getDimensions()
	local scaleX = 3 -- * math.abs(math.cos(time))
	local scaleY = 3 -- * math.abs(math.sin(time/2))
	local wave = 1 * math.cos(time * 3)

	Sonic:Draw(250, 100, 0, 1, bounce, 0, 0, 0, 0)
	Video:DrawString("Hello, I'm your neighbor!", "tiny", width/2, height/2, 0, scaleX, scaleY, 0, 0, wave, 0, 0.5, 0.5)
end