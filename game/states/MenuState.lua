MenuState = {}

function MenuState:Initalize()
	CurrentState = self
end

local time = 0

function MenuState:Update(dt)
	time = time + dt
end

function MenuState:Draw()
	-- love.graphics.circle("fill", 24, 12, 12)
	local bounce = math.cos(time * 2)

	Sonic:Draw(250, 100, 0, 1, bounce, 0, 0, 0, 0)
	Video:DrawString(10, 10, "Hello, I'm your neighbor!")
	Video:DrawString(10, 20, "Goodbye, and see you later!")
end