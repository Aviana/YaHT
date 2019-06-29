if select(2,UnitClass("player")) ~= "HUNTER" then return end

function YaHT:LoadDefaults()
	self.defaults = {
		profile = {
			lock = false,
			scale = 1,
			width = 300,
			height = 5,
			statusbar = "YaHT Bar",
			border = "None",
			font = "Myriad Condensed Web",
			alpha = 1,
			malpha = 0.2,
			showmulti = true,
			showaimed = true,
			enablebackground = true,
			background = "Chat Frame",
			border = "Blizzard Dialog",
			fill = true,
			announcetype = "SAY",
			announcemsg = YaHT.L["announcemsg"],
			announcefailmsg = YaHT.L["announcefailmsg"],
			bordercolor = {
				r = 1,
				g = 1,
				b = 1,
			},
			timercolor = {
				r = 1,
				g = 1,
				b = 1,
			},
			drawcolor = {
				r = 1,
				g = 0,
				b = 0,
			},
			backgroundcolor = {
				r = 0,
				g = 0,
				b = 0,
				a = 0.8,
			},
		},
	}
end