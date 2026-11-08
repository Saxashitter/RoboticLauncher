Palette = {
	Colors = {} -- rgb colors
}

-- manage the currently loaded palette

--- @param file love.File
function Palette:Initalize(file)
	self.Colors = {}

	local data = file:read()
	local i = 1

	for num = 1, 256 do
		local color = {}

		color.r = (data:sub(i, i)):byte() / 255
		color.g = (data:sub(i+1, i+1)):byte() / 255
		color.b = (data:sub(i+2, i+2)):byte() / 255
		color.a = 1

		self.Colors[num] = color
		i = i + 3
	end

	self.Colors[257] = {r = 1, g = 1, b = 1, a = 0} -- transparent index
end

function Palette:FindClosestColor(r, g, b)
	local closest_color = self.Colors[257]
	local closest_distortion = math.huge

	for i, color in ipairs(self.Colors) do
		local dr = r - color.r
		local dg = g - color.g
		local db = b - color.b
		local distortion = (dr*dr) + (dg*dg) + (db*db)

		if distortion < closest_distortion then
			closest_color = color
			closest_distortion = distortion
		end
	end

	print(("Closest color: %d, %d, %d"):format(closest_color.r, closest_color.g, closest_color.b))
	return closest_color
end