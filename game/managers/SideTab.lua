SideTab = {
	Added = false,
	Opened = false,
	Ease = 0
}

-- the sidetabs "hitbox" when closed
local SIDETAB_CLOSED_WIDTH = 32

-- the sidetabs "hitbox" when opened
local SIDETAB_OPENED_WIDTH = 64

-- the size of the selection of each entry
local SIDETAB_SELECTION_HEIGHT = 16

-- this is the thing you can put your mouse to the side and see
-- contains different states you can swap to

--- the side tab becomes available to hover over
function SideTab:Initalize()
	self.Added = true
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
	love.graphics.setColor(0, 0, 1, 1)
	love.graphics.rectangle("fill", 0, 0, self:GetWidth(), love.graphics.getHeight())
	love.graphics.setColor(r, g, b, a)
end

function SideTab:Open()
	self.Opened = true
	self.Ease = 0
end

function SideTab:Close()
	self.Opened = false
	self.Ease = 0
end

--- so we can detect if the mouse is over the threshold for it
function SideTab:MouseMoved(x, y)
	local width = self:GetWidth()

	if x <= width and not self.Opened then
		self:Open()
	end

	if x > width and self.Opened then
		-- close
		self:Close()
	end
end