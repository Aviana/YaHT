local _, playerClass = UnitClass("player")
if playerClass ~= "HUNTER" then return end

local L = YaHT.L

StaticPopupDialogs["RESET_YAHT_PROFILE"] = {
	text = L["Do you really want to reset to default for your current profile?"],
	button1 = L["OK"],
	button2 = L["Cancel"],
	OnAccept = function()
		YaHT:ResetDB("profile")
		--Need To Reset the options Window here if its open
		YaHT:OnProfileEnable()
		YaHT:SystemMessage(YaHT.L["Current profile has been reset."])
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

-- Default Settings ------------------------------------------------------------------------
YaHT.defaults = {
	profile = {
		aimed = true,
		multi = true,
		locked = false,
		colors = {
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
		},
		timertexture = "Bar",
		height = 5,
		width = 300,
		border = 3,
		alpha = 1,
		malpha = 0.2,
		tranqmsg = L["YaHT_TRANQMSG"],
		tranqfailmsg = L["YaHT_FAILEDMSG"],
	},
}
--------------------------------------------------------------------------------------------
