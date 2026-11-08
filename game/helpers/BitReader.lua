local bit = require("bit")

local function byte(bit1, bit2, bit3, bit4)
	return bit.bor(
		bit1,
		bit.lshift(bit2, 8),
		bit.lshift(bit3, 16),
		bit.lshift(bit4, 24)
	)
end