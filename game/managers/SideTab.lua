SideTab = {
	Added = false,
	Opened = false,
	Ease = 0,
	Selection = 0,
	Selections = {
		{
			name = "Hi vro",
			callback = function()
				if CurrentState == MenuState then return end
				MenuState:Initalize()
			end
		},
		{
			name = "Hi vro 2",
			callback = function()
				if CurrentState == MultiplayerState then return end
				MultiplayerState:Initalize()
			end
		}
	}
}

-- the sidetabs "hitbox" when closed
local SIDETAB_CLOSED_WIDTH = 32

-- the sidetabs "hitbox" when opened
local SIDETAB_OPENED_WIDTH = 128

-- the size of the selection of each entry
local SIDETAB_SELECTION_HEIGHT = 32

-- this is the thing you can put your mouse to the side and see
-- contains different states you can swap to

--- the side tab becomes available to hover over
function SideTab:Initalize()
	self.Added = true
	self.Tick = love.audio.newSource(GameAssets.srb2.Sounds.SRB2.DSMENU1, "static")
	self.Confirm = love.audio.newSource(GameAssets.srb2.Sounds.SRB2.DSSTRPST, "static")
end

--- the side tab gets removed
function SideTab:Remove()
	self.Added = false
end

function SideTab:GetWidth()
	if self.Opened then
		return SIDETAB_OPENED_WIDTH
	end

	return SIDETAB_CLOSED_WIDTH
end

--- the side tab gets drawn
--- idea: when the sidetab is hovered over, it tweens in and the background of it slightly fades
function SideTab:Draw()
	local r, g, b, a = love.graphics.getColor()

	local x = self:GetWidth()
	local textX = self:GetWidth() - SIDETAB_OPENED_WIDTH / 2

	love.graphics.setColor(0, 0, 1, 1)
		love.graphics.rectangle("fill", 0, 0, x, love.graphics.getHeight())
	love.graphics.setColor(r, g, b, a)

	for i, entry in ipairs(self.Selections) do
		if i == self.Selection then
			love.graphics.setColor(1, 1, 0, 1)
		end

		Video:DrawString(entry.name, "tiny",
			textX,
			(SIDETAB_SELECTION_HEIGHT/2) + (SIDETAB_SELECTION_HEIGHT * (i-1)),
			0,
			2, 2,
			0, 0,
			0, 0,
			0.5, 0.5
		)
		love.graphics.setColor(r, g, b, a)
	end
end

function SideTab:ChooseSelectionBasedOnMouse(y)
	for i, _ in ipairs(self.Selections) do
		if  y >= SIDETAB_SELECTION_HEIGHT * (i - 1)
		and y <  SIDETAB_SELECTION_HEIGHT *  i      then
			if i == self.Selection then
				return i
			end

			self.Selection = i
			-- manage effects
			local clone = self.Tick:clone()
			clone:play()
			
			return i
		end
	end

	self.Selection = 0
	return 0
end

function SideTab:Open(x, y)
	self.Opened = true
	self.Ease = 0
	self:ChooseSelectionBasedOnMouse(y)
end

function SideTab:Close()
	self.Opened = false
	self.Ease = 0
	self.Selection = 0
end

--- so we can detect if the mouse is over the threshold for it
function SideTab:MouseMoved(x, y)
	local width = self:GetWidth()

	if x <= width and not self.Opened then
		self:Open(x, y)
	end

	if x > width and self.Opened then
		self:Close()
	end

	if self.Opened then
		self:ChooseSelectionBasedOnMouse(y)
	end
end

function SideTab:MousePressed(x, y)
	if self.Selection == 0 then
		-- nothings selected
		return
	end

	self.Confirm:stop()
	self.Confirm:play()

	self.Selections[self.Selection].callback()
end