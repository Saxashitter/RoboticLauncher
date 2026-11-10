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
	local string

	if (SRB2:Running()) then
		string = "SRB2 is running!";
	else
		string = "click to start srb2 lol";
	end

	Video:DrawString(string, "default", width/2, height/2, 0, scaleX, scaleY, 0, 0, 0, 0, 0.5, 0.5)
	if (SRB2.icon ~= nil) then
		local bounce = math.cos(time * 2);
		SRB2.icon:Draw(250, 100, 0, 1, bounce, 0, 0, 0, 0);
	end
end

function MultiplayerState:MousePressed(x, y)
	if (SRB2:Running()) then
		-- @todo TODO make this better lmfao
		-- maybe like the sounds get stored in an array and then we have a function just do this for us?
		-- @note like the Icons and Font stuff?
		-- would help get rid of having to call the sidetab library lol...
		SideTab.Error:stop();
		SideTab.Error:play();
		print("Game already running!");
		return;
	end
	if not (LoadState:ValidGamePath(Game.Path, Game.EXEName, Game.EXEType)) then
		print("Game exectuable not found, not launching.");
		return;
	end

	SRB2:Launch();
end
