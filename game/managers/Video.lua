Video = {}

-- patch cache
Video.Patches = {}
Video.Fonts = {}
Video.StringDimensions = {} -- for strings

function Video:Initalize()
	Video:MakeFont("default", GameAssets.srb2.Graphics.Fonts.STCFN, "STCFN%03d")
	Video:MakeFont("tiny", GameAssets.srb2.Graphics.Fonts.TNYFN, "TNYFN%03d")
end

function Video:MakeFont(fontName, fontDirectory, fontFormat, spacing)
	self.Fonts[fontName] = {
		directory = fontDirectory,
		format = fontFormat,
		spacing = 4 or 0,
		patches = {}
	}

	return self.Fonts[fontName]
end

function Video:GetStringDimensions(string, font)
	if self.StringDimensions[font] and self.StringDimensions[font][string] then
		return self.StringDimensions[font][string].x,
			self.StringDimensions[font][string].y
	end

	self.StringDimensions[font] = self.StringDimensions[font] or {}

	font = font or "STCFN"

	local width = 0
	local x = 0
	local y = 0

	local fontData = self.Fonts[font]
	local directory = fontData.directory

	for i = 1, #string do
		local str = string:sub(i, i)

		if str == " " then
			x = x + fontData.spacing
			goto continue
		end

		local filename = fontData.format:format(str:byte())
		local patch = fontData.patches[filename]

		if not patch then
			patch = Patch.Initalize(directory[filename])
			fontData.patches[filename] = patch
		end

		x = x + patch.width
		y = math.max(y, patch.height)

		::continue::
	end

	self.StringDimensions[font][string] = {x = x, y = y}
	return x, y
end


--- @param string string
--- @param font string|nil
--- @param x number|nil
--- @param y number|nil
--- @param r number|nil
--- @param sx number|nil
--- @param sy number|nil
--- @param ox number|nil
--- @param oy number|nil
--- @param kx number|nil
--- @param ky number|nil
--- @param ax number|nil
--- @param ay number|nil
function Video:DrawString(string, font, x, y, r, sx, sy, ox, oy, kx, ky, ax, ay)
	font = font or "STCFN"
	x = x or 0
	y = y or 0
	r = r or 0
	sx = sx or 1
	sy = sy or 1
	ox = ox or 0
	oy = oy or 0
	kx = kx or 0
	ky = ky or 0
	ax = ax or 0
	ay = ay or 0

	local fontData = self.Fonts[font]
	local directory = fontData.directory

	-- align
	local width, height = self:GetStringDimensions(string, font)
	ox = ox + width * ax
	oy = oy + height * ay

	local cos = math.cos(r)
	local sin = math.sin(r)

	for i = 1, #string do
		local str = string:sub(i, i)

		if str == " " then
			x = x + fontData.spacing * cos
			y = y + fontData.spacing * sin
			goto continue
		end

		local filename = fontData.format:format(str:byte())
		local patch = fontData.patches[filename]

		if not patch then
			patch = Patch.Initalize(directory[filename])
			fontData.patches[filename] = patch
		end

		patch:Draw(x, y, r, sx, sy, ox, oy, kx, ky)

		x = x + (patch.width * sx) * cos
		y = y + (patch.width * sx) * sin

		::continue::
	end
end