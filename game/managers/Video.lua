Video = {}

-- patch cache
Video.Patches = {}
Video.Fonts = {}
Video.Icons = {}
Video.StringDimensions = {} -- for strings

-- string flags
StringFlags = {};
StringFlags.V_STRINGDANCE = 1<<1;

-- misc
local FRACUNIT = 2;

function Video:Initalize()
	Video:MakeFont("default", GameAssets.srb2.Graphics.Fonts.STCFN, "STCFN%03d")
	Video:MakeFont("tiny", GameAssets.srb2.Graphics.Fonts.TNYFN, "TNYFN%03d")
	Video:MakeIcon("settings", GameAssets.characters["4_Amy"]["2_Sprites"], "TPOSA1")
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

function Video:MakeIcon(iconName, iconDirectory, iconFileName)
	self.Icons[iconName] = {
		directory = iconDirectory,
		filename = iconFileName,
		patch = nil
	};
	return self.Icons[iconName];
end

function Video:GetStringDimensions(string, font)
	font = font or "STCFN"

	if self.StringDimensions[font] and self.StringDimensions[font][string] then
		return self.StringDimensions[font][string].x,
			self.StringDimensions[font][string].y
	end
	self.StringDimensions[font] = self.StringDimensions[font] or {}

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

local function V_DanceYOffset(counter)
	local duration = 16;
	local step = (love.timer.getTime() + counter) % duration;
	return math.abs(step - (duration / 2)) - (duration / 4);
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
--- @param flags number|nil
function Video:DrawString(string, font, x, y, r, sx, sy, ox, oy, kx, ky, ax, ay, flags)
	if (string == nil) then
		error("Video:DrawString - Did you forget to specify a string?");
		return;
	end
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
	flags = flags or 0

	local fontData = self.Fonts[font]
	local directory = fontData.directory

	-- offset
	local cyoff = 0;

	-- align
	local width, height = self:GetStringDimensions(string, font)
	ox = ox + width * ax
	oy = oy + height * ay

	-- misc
	local cos = math.cos(r)
	local sin = math.sin(r)

	-- loop
	local i = 1;
	local dancecounter = 0;

	while (i <= #string) do
		local str = string:sub(i, i)
		local icon = "";

		cyoff = 0;

		if (str == "<") then
			while (i <= #string) do
				local icon_str = string:sub(i, i);
				i = i+1;
				if (icon_str ~= "<" and icon_str ~= ">") then
					icon = icon..icon_str;
				end
				if (icon_str == ">") then
					break;
				end
			end
			if (i > #string) then
				error("Video:DrawString - Fix your string! (missing end of icon parser '>')");
				return;
			end

			if (false) then
				print("================")
				print(icon)
				print("================")
			end

			local iconData = self.Icons[icon];
			local icon_directory = iconData.directory;
			local filename = iconData.filename:format(icon:byte());
			local patch = iconData.patch;

			if not patch then
				patch = Patch.Initalize(icon_directory[filename]);
				iconData.patch = patch;
			end

			if (flags == StringFlags.V_STRINGDANCE) then
				cyoff = V_DanceYOffset(dancecounter) * FRACUNIT;
			end
			patch:Draw(x, y+cyoff, r, sx, sy, ox, oy, kx, ky);

			x = x + patch.width * cos;
			y = y + patch.width * sin;

			dancecounter = dancecounter+1;
			goto continue
		end

		if str == " " then
			x = x + fontData.spacing * cos
			y = y + fontData.spacing * sin
			i = i+1;
			dancecounter = dancecounter+1;
			goto continue
		end

		local filename = fontData.format:format(str:byte())
		local patch = fontData.patches[filename]

		if not patch then
			patch = Patch.Initalize(directory[filename])
			fontData.patches[filename] = patch
		end

		if (flags == StringFlags.V_STRINGDANCE) then
			cyoff = V_DanceYOffset(dancecounter) * FRACUNIT;
		end
		patch:Draw(x, y+cyoff, r, sx, sy, ox, oy, kx, ky)

		x = x + (patch.width * sx) * cos
		y = y + (patch.width * sx) * sin

		i = i+1;
		dancecounter = dancecounter+1;
		::continue::
	end
end
