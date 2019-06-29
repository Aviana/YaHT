if select(2,UnitClass("player")) ~= "HUNTER" then return end
local Addon = select(1, ...)

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local SML = SML or LibStub:GetLibrary("LibSharedMedia-3.0")

local L = YaHT.L

function YaHT:CreateConfig()

	local function get(info)
		return YaHT.db.profile[info[#info]]
	end

	local function set(info, value)
		YaHT.db.profile[info[#info]] = value
		YaHT:ApplySettings()
	end

	local function getColor(info)
		local db = YaHT.db.profile[info[#info]]
		return db.r, db.g ,db.b, db.a
	end
	
	local function setColor(info, r, g, b, a)
		local db = YaHT.db.profile[info[#info]]
		db.r = r
		db.g = g
		db.b = b
		db.a = a
		YaHT:ApplySettings()
	end

	local MediaList = {}
	local function getMediaData(info)
		local mediaType = info[#(info)]

		MediaList[mediaType] = MediaList[mediaType] or {}

		for k in pairs(MediaList[mediaType]) do MediaList[mediaType][k] = nil end
		for _, name in pairs(SML:List(mediaType) or {}) do
			MediaList[mediaType][name] = name
		end
		
		return MediaList[mediaType]
	end

	local aceoptions = {
		name = "Yet another Hunter Timer",
		type = "group",
		get = get,
		set = set,
		icon = "",
		args = {
			general = {
				name = L["Overview"],
				type = "group",
				order = 1,
				args = {
					descriptiontext = {
						name = "Yet another Hunter Timer by Aviana\nDonate: paypal.me/LunaUnitFrames\n".."Version: "..YaHT.version,
						type = "description",
						width = "full",
						order = 1,
					},
					optionsheader = {
						name = L["Options"],
						type = "header",
						order = 2,
					},
					lock = {
						name = L["Lock"],
						desc = L["Lock / Unlock the timer bar for drag."],
						type = "toggle",
						order = 3,
					},
					width = {
						name = L["Width"],
						desc = L["Set the width."],
						width = "full",
						type = "range",
						order = 4,
						min = 10,
						max = 600,
						step = 1,
					},
					height = {
						name = L["Height"],
						desc = L["Set the height."],
						width = "full",
						type = "range",
						order = 5,
						min = 5,
						max = 50,
						step = 1,
					},
					scale = {
						name = L["Scale"],
						desc = L["Set the scale."],
						type = "range",
						order = 6,
						isPercent = true,
						min = 0.1,
						max = 3,
						step = 0.1,
					},
					alpha = {
						name = L["Alpha"],
						desc = L["Set the alpha."],
						type = "range",
						order = 6.1,
						isPercent = true,
						min = 0.1,
						max = 1,
						step = 0.1,
					},
					malpha = {
						name = L["Movement alpha"],
						desc = L["Set the alpha while moving."],
						type = "range",
						order = 6.2,
						isPercent = true,
						min = 0.1,
						max = 1,
						step = 0.1,
					},
					barheader = {
						name = L["Bar options"],
						type = "header",
						order = 7,
					},
					statusbar = {
						order = 8,
						type = "select",
						name = L["Bar texture"],
						dialogControl = "LSM30_Statusbar",
						values = getMediaData,
					},
					timercolor = {
						name = L["Timer Color"],
						type = "color",
						order = 9,
						get = getColor,
						set = setColor,
					},
					drawcolor = {
						name = L["Draw Color"],
						type = "color",
						order = 10,
						get = getColor,
						set = setColor,
					},
					fill = {
						name = L["Fill from middle"],
						desc = L["Extend the bar from the middle outwards."],
						type = "toggle",
						order = 11,
					},
					backgroundheader = {
						name = L["Background options"],
						type = "header",
						order = 12,
					},
					enablebackground = {
						name = L["Background"],
						desc = L["Show a background."],
						type = "toggle",
						order = 13,
					},
					background = {
						order = 14,
						type = "select",
						name = L["Background texture"],
						dialogControl = "LSM30_Background",
						values = getMediaData,
					},
					backgroundcolor = {
						name = L["Background Color"],
						type = "color",
						order = 15,
						hasAlpha = true,
						get = getColor,
						set = setColor,
					},
					borderheader = {
						name = L["Border options"],
						type = "header",
						order = 16,
					},
					enableborder = {
						name = L["Border"],
						desc = L["Show a border."],
						type = "toggle",
						order = 17,
					},
					border = {
						order = 18,
						type = "select",
						name = L["Border texture"],
						dialogControl = "LSM30_Border",
						values = getMediaData,
					},
					bordercolor = {
						name = L["Border Color"],
						type = "color",
						order = 19,
						get = getColor,
						set = setColor,
					},
					castbarheader = {
						name = L["Castbar options"],
						type = "header",
						order = 20,
					},
					showaimed = {
						name = GetSpellInfo(19434),
						desc = L["Show this on the default castbar."],
						type = "toggle",
						order = 21,
					},
					showmulti = {
						name = GetSpellInfo(2643),
						desc = L["Show this on the default castbar."],
						type = "toggle",
						order = 22,
					},
					announceheader = {
						name = L["Announce options"],
						type = "header",
						order = 23,
					},
					tranqannounce = {
						name = string.format(L["Announce %s"],GetSpellInfo(19801)),
						desc = L["Enable / disable the announcement."],
						type = "toggle",
						order = 24,
						width = "double",
					},
					tranqannouncefail = {
						name = string.format(L["Announce failed %s"],GetSpellInfo(19801)),
						desc = L["Enable / disable the announcement."],
						type = "toggle",
						order = 25,
						width = "double",
					},
					announcetype = {
						name = L["Announce in"],
						desc = L["The channel in which to announce."],
						type = "select",
						order = 26,
						values = {["WHISPER"] = L["Whisper"], ["CHANNEL"] = L["Channel"], ["RAID_WARNING"] = L["Raid Warning"], ["SAY"] = L["Say"], ["YELL"] = L["Yell"], ["PARTY"] = L["Party"], ["RAID"] = L["Raid"]},
						set = function(info, value) set(info,value) LibStub("AceConfigRegistry-3.0", true):NotifyChange("YaHT") end
					},
					targetchannel = {
						name = L["Channel/Playername"],
						desc = L["Set the channel or player for whisper."],
						type = "input",
						order = 27,
						hidden = function() return not (YaHT.db.profile.announcetype == "WHISPER" or YaHT.db.profile.announcetype == "CHANNEL") end,
					},
					announcemsg = {
						name = L["Announce Message"],
						desc = L["Set the message to be broadcasted."],
						type = "input",
						order = 28,
						width = "full",
					},
					announcefailmsg = {
						name = L["Announce Fail Message"],
						desc = L["Set the message to be broadcasted."],
						type = "input",
						order = 29,
						width = "full",
					},
				}
			}
		}
	}

	AceConfigRegistry:RegisterOptionsTable(Addon, aceoptions, true)
	aceoptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	
	AceConfigDialog:AddToBlizOptions(Addon, nil, nil, "general")
	AceConfigDialog:AddToBlizOptions(Addon, L["Profiles"], Addon, "profile")
	
	AceConfigDialog:SetDefaultSize(Addon, 895, 570)
end