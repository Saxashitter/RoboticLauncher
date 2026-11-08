--- @return number
function stringByteAtPosition(self, ...)
	local num = 0

	for i = 1, select("#", ...) do
		local position = select(i, ...)
		-- num = num + (self:sub(position, position)):byte()

		local byte = (self:sub(position, position)):byte()
		local shift = (i-1) * 8

		if shift > 0 then
			byte = bit.lshift(byte, shift)
		end

		num = bit.bor(byte, num)
	end

	return num
end