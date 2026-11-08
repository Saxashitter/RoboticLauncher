Patch = {}
Patch.__index = Patch

local byte = stringByteAtPosition

-- loads graphics and takes account of its offsets and whatnot
--- @param file love.File
function Patch.Initalize(file)
	local data, err = file:read()
	local new = setmetatable({}, Patch)

	new.width = byte(data, 0x01, 0x02)
	new.height = byte(data, 0x03, 0x04)
	new.leftoffset = byte(data, 0x05, 0x06)
	new.topoffset = byte(data, 0x07, 0x08)

	new.imageData = love.image.newImageData(new.width, new.height, "rgba8")

	-- im pretty sure this is so the numbers can become negative
	if new.leftoffset >= (1 << 15) then
		new.leftoffset = new.leftoffset - (1 << 16)
	end
	if new.topoffset >= (1 << 15) then
		new.topoffset = new.topoffset - (1 << 16)
	end

	local columns = {}
	local previousTopDelta = 0
	for column = 1, new.width do
		local offsettedByte = 0x09 + bit.lshift(column - 1, 2)
		local columnOffset = byte(data,
			offsettedByte,
			offsettedByte + 1,
			offsettedByte + 2,
			offsettedByte + 3
		)

		local posts = {}
		local position = columnOffset + 1
		local previousTopDelta = 0
		while true do
			local topDelta = byte(data, position)
			if topDelta == 0xFF then
				-- thats the end of this post
				break
			end
			
			if topDelta <= previousTopDelta then
				topDelta = topDelta + previousTopDelta
			end
			previousTopDelta = topDelta
			
			local pixelsStart = position + 3
			local length = byte(data, position + 1)
	
			for i = 1, length do
				local pixel = byte(data, pixelsStart + i - 1)
				local color = Palette.Colors[pixel+1]

				new.imageData:setPixel(
					column-1,
					(i-1) + topDelta,
					color.r,
					color.g,
					color.b,
					1
				)
			end

			position = pixelsStart + length + 1
		end
	end

	new.image = love.graphics.newImage(new.imageData)

	return new
end

function Patch:Draw(x, y, r, sx, sy, ox, oy, kx, ky)
	x = x or 0
	y = y or 0
	r = r or 0
	sx = sx or 1
	sy = sy or 1
	ox = (ox or 0) + self.leftoffset
	oy = (oy or 0) + self.topoffset
	kx = kx or 0
	ky = ky or 0

	love.graphics.draw(self.image, x, y, r, sx, sy, ox, oy, kx, ky)
end