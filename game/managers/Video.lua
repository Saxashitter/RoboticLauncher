Video = {}

-- patch cache
Video.Patches = {}

--- @param x number
--- @param y number
--- @param string string
function Video:DrawString(x, y, string)
	local font = "STCFN"
	local textwidth = 8
	local directory = GameAssets.srb2.Graphics.Fonts.STCFN

	for i = 1, #string do
		local str = string:sub(i, i)

		if str == " " then
			x = x + 2
			goto continue
		end
		local filename = (font.."%03d"):format(str:byte())
		local patch = self.Patches[filename]

		if not patch then
			patch = Patch.Initalize(directory[filename])
			self.Patches[filename] = patch
		end

		patch:Draw(x + textwidth * (i-1), y)
		::continue::
	end
end