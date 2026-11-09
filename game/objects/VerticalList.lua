-- TODO: this will require a major refactoring of already existing code
-- Patch should be able to use x and y coordinates in a similar vein to keep the codebase in line

VerticalList = {}
VerticalList.__index = VerticalList

VerticalList.x = 0
VerticalList.y = 0
VerticalList.width = 16
VerticalList.height = 16
VerticalList.color = {r = 1, g = 1, b = 1, a = 1}

VerticalList.entryHeight = 4 -- if the height is too large, it automatically shortens to height / #entries
VerticalList.entryPadding = 0

VerticalList.entries = {}

-- class to make lists of buttons and whatnot, allows for adding backgrounds and stuff too

function VerticalList:New()
	local new = setmetatable({}, self)
	return new
end

function VerticalList:Extend()
	local new = setmetatable({}, self)
	new.__index = new
	return new
end