-- YaHT - Yet another Hunter Timer by Aviana
if select(2,UnitClass("player")) ~= "HUNTER" then return end

YaHT = select(2, ...)

local L = YaHT.L
local ACR = LibStub("AceConfigRegistry-3.0", true)
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
YaHT.version = 2120

local SWING_TIME = 0.65
local AimedDelay = 1
local movementDelay = 0

local AimedShot = GetSpellInfo(19434)
local MultiShot = GetSpellInfo(2643)
local backdrop = {insets = {}}
local mediaRequired
local defaultMedia = {
	[SML.MediaType.STATUSBAR] = "Interface\\AddOns\\YaHT\\media\\Bar",
	[SML.MediaType.BACKGROUND] = "Interface\\ChatFrame\\ChatFrameBackground",
	[SML.MediaType.BORDER] = "Interface\\None",
}

local function OnUpdate(self, elapsed)
	local config = YaHT.db.profile
	if not config.lock then
		self.mockTime = self.mockTime + elapsed
		if self.mockTime > self.swingtime then
			self.texture:SetVertexColor(config.drawcolor.r,config.drawcolor.g,config.drawcolor.b)
			self.texture:SetWidth(self:GetWidth() * (1-(self.mockTime2/SWING_TIME)))
			self.mockTime2 = self.mockTime2 + elapsed
			if self.mockTime2 > SWING_TIME then
				self.mockTime = 0
			end
		else
			self.mockTime2 = 0
			self.texture:SetVertexColor(config.timercolor.r,config.timercolor.g,config.timercolor.b)
			self.texture:SetWidth(self:GetWidth() * self.mockTime/self.swingtime)
		end
		return
	end
	local curTime = GetTime()
	if not self.SwingStart and (curTime - self.lastshot) >= self.swingtime then
		--Start Swing timer
		if self.shooting and not self.casting then
			YaHT.mainFrame.texture:SetVertexColor(config.drawcolor.r,config.drawcolor.g,config.drawcolor.b)
			self:SetAlpha(config.alpha)
			self.SwingStart = curTime
		else
			if not self.shooting then
				self:Hide()
			end
		end
	elseif self.SwingStart then
		if IsPlayerMoving() or IsFalling() then
			self.SwingStart = curTime
			self.texture:SetWidth(0.01)
			self:SetAlpha(config.malpha)
			local timeSinceReadyToFire = curTime - self.lastshot + self.swingtime
			if timeSinceReadyToFire > 0 then
				while timeSinceReadyToFire > 0.5 do
					timeSinceReadyToFire = timeSinceReadyToFire - 0.5
				end
				movementDelay = 0.5 - timeSinceReadyToFire
			end
		else
			self.texture:SetWidth(config.width * math.min(((curTime - self.SwingStart) / (SWING_TIME + movementDelay)),1))
			self:SetAlpha(config.alpha)
		end
	else
		self.texture:SetWidth(config.width * (1 - math.min(((curTime - self.lastshot) / self.swingtime),1)))
		self:SetAlpha(config.alpha)
	end
end

function YaHT:OnInitialize()
	
	self:LoadDefaults()
	
	-- Initialize DB
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("YaHTdb", self.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfilesChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfilesChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileReset")
	SML.RegisterCallback(self, "LibSharedMedia_Registered", "MediaRegistered")
	SML:Register(SML.MediaType.STATUSBAR, "YaHT Bar", "Interface\\AddOns\\YaHT\\media\\Bar")

	self:Load()
	self:CreateConfig()
end

function YaHT:ProfilesChanged()
	if( resetTimer ) then resetTimer:Hide() end
	
	self.db:RegisterDefaults(self.defaults)
	
	-- No active layout, register the default one
	if( not self.db.profile.loadedLayout ) then
		self:LoadDefaults()
	end
	self:ApplySettings()
end

local resetTimer
function YaHT:ProfileReset()
	if( not resetTimer ) then
		resetTimer = CreateFrame("Frame")
		resetTimer:SetScript("OnUpdate", function(self)
			YaHT:ProfilesChanged()
			self:Hide()
		end)
	end
	
	resetTimer:Show()
end

-- We might not have had a media we required at initial load, wait for it to load and then update everything when it does
function YaHT:MediaRegistered(event, mediaType, key)
	if( mediaRequired and mediaRequired[mediaType] and mediaRequired[mediaType] == key ) then
		mediaRequired[mediaType] = nil
		
		self:ApplySettings()
	end
end

function YaHT:GetMedia(type, mediaName)
	local media = SML:Fetch(type, mediaName, true)
	if not media then
		mediaRequired = mediaRequired or {}
		mediaRequired[type] = mediaName
		return defaultMedia[type]
	end
	return media
end

function YaHT:ApplySettings()
	local config = YaHT.db.profile
	self.mainFrame:SetWidth(config.width)
	self.mainFrame:SetHeight(config.height)
	self.mainFrame:SetScale(config.scale)
	self.mainFrame:ClearAllPoints()
	if config.point then
		self.mainFrame:SetPoint(config.point, UIParent, config.relativePoint, config.x, config.y)
	else
		self.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -350)
	end
	self.mainFrame:EnableMouse(not config.lock)
	self.mainFrame:SetMovable(not config.lock)
	
	backdrop.edgeFile = config.enableborder and self:GetMedia(SML.MediaType.BORDER, config.border)
	backdrop.tile = true
	backdrop.edgeSize = 10
	backdrop.tileSize = 1
	backdrop.insets.left = 3
	backdrop.insets.right = 3
	backdrop.insets.top = 3
	backdrop.insets.bottom = 3
	
	self.mainFrame.border:SetBackdrop(backdrop)
	self.mainFrame.border:SetHeight(config.height + 6)
	self.mainFrame.border:SetWidth(config.width + 6)
	self.mainFrame.border:GetBackdropBorderColor(config.bordercolor.r, config.bordercolor.g, config.bordercolor.b)
	
	if config.enablebackground then
		self.mainFrame.background:Show()
	else
		self.mainFrame.background:Hide()
	end
	self.mainFrame.background:SetVertexColor(config.backgroundcolor.r, config.backgroundcolor.g, config.backgroundcolor.b, config.backgroundcolor.a)
	self.mainFrame.background:SetTexture(self:GetMedia(SML.MediaType.BACKGROUND, config.background))
	
	self.mainFrame.texture:ClearAllPoints()
	if config.fill then
		self.mainFrame.texture:SetPoint("CENTER", self.mainFrame, "CENTER")
	else
		self.mainFrame.texture:SetPoint("LEFT", self.mainFrame, "LEFT")
	end
	
	if YaHT.db.profile.lock and not self.mainFrame.shooting then
		self.mainFrame:Hide()
	else
		self.mainFrame:Show()
		self.mainFrame:SetAlpha(YaHT.db.profile.alpha)
		if self.mainFrame.SwingStart then
			self.mainFrame.texture:SetVertexColor(config.drawcolor.r,config.drawcolor.g,config.drawcolor.b)
		else
			self.mainFrame.texture:SetVertexColor(config.timercolor.r, config.timercolor.g,config.timercolor.b)
		end
	end
	
	self.mainFrame.texture:SetTexture(self:GetMedia(SML.MediaType.STATUSBAR, config.statusbar))
	self.mainFrame.texture:SetHeight(config.height)
end

function YaHT:Load()
	self.mainFrame = CreateFrame("Frame", "YaHTMainFrame", UIParent)
	self.mainFrame:SetFrameStrata("MEDIUM")
	self.mainFrame:RegisterForDrag("LeftButton")
	self.mainFrame:SetClampedToScreen(true)
	self.mainFrame:SetScript("OnDragStart", function() YaHT.mainFrame:StartMoving() end)
	self.mainFrame:SetScript("OnDragStop", function()
		local config, meh = YaHT.db.profile
		YaHT.mainFrame:StopMovingOrSizing()
		config.point, meh , config.relativePoint, config.x, config.y = YaHT.mainFrame:GetPoint()
	end)
	self.mainFrame.mockTime = 0
	self.mainFrame.time = 0
	self.mainFrame.lastshot = GetTime()
	self.mainFrame.swingtime = UnitRangedDamage("player") - SWING_TIME
	self.mainFrame:SetScript("OnUpdate", OnUpdate)
	
	self.mainFrame.background = self.mainFrame:CreateTexture("YaHTMainFrameBackground", "BACKGROUND")
	self.mainFrame.background:SetAllPoints(self.mainFrame)
	self.mainFrame.background:SetHorizTile(true)
	self.mainFrame.background:SetVertTile(true)
	
	self.mainFrame.texture = self.mainFrame:CreateTexture("YaHTMainFrameBar", "ARTWORK")
	
	self.mainFrame.border = CreateFrame("Frame", "YaHTMainFrameBorder", self.mainFrame)
	self.mainFrame.border:SetPoint("CENTER", self.mainFrame, "CENTER")
	
	self:ApplySettings()
end

function YaHT:COMBAT_LOG_EVENT_UNFILTERED()
	 local _, event, _, casterID, _, _, _, targetID, targetName, _, _, spellID, name, _, extra_spell_id, _, _, resisted, blocked, absorbed = CombatLogGetCurrentEventInfo()
	local _, rank, icon, castTime = GetSpellInfo(spellID)
	local icon, castTime = select(3, GetSpellInfo(spellID))
	if event == "SWING_DAMAGE" or event == "ENVIRONMENTAL_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" then
		if resisted or blocked or absorbed then return end
		if targetID == UnitGUID("player") then
			local maxValue
			maxValue = 0
			if not CastingBarFrame.maxValue == nil then
				maxValue = CastingBarFrame.maxValue
			end
			CastingBarFrame.maxValue = maxValue + math.min(CastingBarFrame:GetValue(),AimedDelay)
			CastingBarFrame:SetMinMaxValues(0, CastingBarFrame.maxValue)
			if AimedDelay > 0.2 then
				AimedDelay = AimedDelay - 0.2
			end
		end
		return
	elseif event == "SPELL_CAST_SUCCESS" and spellID == 19801 and casterID == UnitGUID("player") then
		if YaHT.db.profile.tranqannounce then
			local num
			if YaHT.db.profile.announcetype == "CHANNEL" then
				num = GetChannelName(YaHT.db.profile.targetchannel)
			end
			SendChatMessage(string.format(YaHT.db.profile.announcemsg,targetName), YaHT.db.profile.announcetype, nil, num or YaHT.db.profile.targetchannel)
		end
	elseif event == "SPELL_MISSED" and spellID == 19801 and casterID == UnitGUID("player") then
		if YaHT.db.profile.tranqannouncefail then
			local num
			if YaHT.db.profile.announcetype == "CHANNEL" then
				num = GetChannelName(YaHT.db.profile.targetchannel)
			end
			SendChatMessage(string.format(YaHT.db.profile.announcefailmsg,targetName), YaHT.db.profile.announcetype, nil, num or YaHT.db.profile.targetchannel)
		end
	end
	if (name ~= AimedShot and name ~= MultiShot) or (not YaHT.db.profile.showaimed and name == AimedShot) or (not YaHT.db.profile.showmulti and name == MultiShot) then return end
	if event == "SPELL_CAST_START" and casterID == UnitGUID("player") then
		self.mainFrame.casting = true
		
		if name == AimedShot then
			AimedDelay = 1
			castTime = 3000
		else
			castTime = 500
		end
		
		CastingBarFrame.Spark:Show()
		local startColor = CastingBarFrame_GetEffectiveStartColor(CastingBarFrame, false, false)
		CastingBarFrame:SetStatusBarColor(startColor:GetRGB())
		if CastingBarFrame.flashColorSameAsStart then
			CastingBarFrame.Flash:SetVertexColor(startColor:GetRGB())
		else
			CastingBarFrame.Flash:SetVertexColor(1, 1, 1)
		end
		CastingBarFrame.value = 0
		CastingBarFrame.maxValue = castTime / 1000
		CastingBarFrame:SetMinMaxValues(0, CastingBarFrame.maxValue)
		CastingBarFrame:SetValue(CastingBarFrame.value)
		if ( CastingBarFrame.Text ) then
			CastingBarFrame.Text:SetText(name)
		end
		if ( CastingBarFrame.Icon ) then
			CastingBarFrame.Icon:SetTexture(icon)
			if ( CastingBarFrame.iconWhenNoninterruptible ) then
				CastingBarFrame.Icon:SetShown(true)
			end
		end
		CastingBarFrame_ApplyAlpha(CastingBarFrame, 1.0)
		CastingBarFrame.holdTime = 0
		CastingBarFrame.casting = true
		CastingBarFrame.castID = nil
		CastingBarFrame.channeling = nil
		CastingBarFrame.fadeOut = nil
		CastingBarFrame:Show()
	end
end

function YaHT:UNIT_SPELLCAST_INTERRUPTED(unit, castID, spellID)
	self.mainFrame.casting = nil
	
	if GetSpellInfo(spellID) == AimedShot or GetSpellInfo(spellID) == MultiShot then
		CastingBarFrame:SetValue(CastingBarFrame.maxValue)
		CastingBarFrame:SetStatusBarColor(CastingBarFrame.failedCastColor:GetRGB())
		if ( CastingBarFrame.Spark ) then
			CastingBarFrame.Spark:Hide()
		end
		if ( CastingBarFrame.Text ) then
			CastingBarFrame.Text:SetText(FAILED)
		end
		CastingBarFrame.casting = nil
		CastingBarFrame.channeling = nil
		CastingBarFrame.fadeOut = true
		CastingBarFrame.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
	end
end

function YaHT:START_AUTOREPEAT_SPELL()
	local config = YaHT.db.profile
	local curTime = GetTime()
	self.mainFrame.shooting = true
--	self.mainFrame.ignoregcd = self:GCDcheck()
	if curTime - self.mainFrame.lastshot < self.mainFrame.swingtime then
		self.mainFrame.texture:SetVertexColor(config.timercolor.r,config.timercolor.g,config.timercolor.b)
	else
		self.mainFrame.texture:SetVertexColor(config.drawcolor.r,config.drawcolor.g,config.drawcolor.b)
		self.mainFrame.SwingStart = curTime
		if IsPlayerMoving() then
			self.mainFrame.lastshot = curTime - self.mainFrame.swingtime
		end
	end
	self.mainFrame:SetAlpha(YaHT.db.profile.alpha)
	self.mainFrame:Show()
end

function YaHT:STOP_AUTOREPEAT_SPELL()
	self.mainFrame.shooting = nil
	if YaHT.db.profile.lock and (GetTime() - self.mainFrame.lastshot) >= self.mainFrame.swingtime then
		self.mainFrame:SetAlpha(0)
		self.mainFrame:Hide()
	end
end

function YaHT:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellID)
	local config = YaHT.db.profile
	if self.mainFrame.casting then
		self.mainFrame.casting = nil
		return
	end
	if spellID == 75 then
		if self.mainFrame.shooting then
			self.mainFrame.lastshot = GetTime()
			self.mainFrame.multishooting = nil
			self.mainFrame.SwingStart = nil
			self.mainFrame.ignoregcd = nil
			if self.mainFrame.newswingtime then
				self.mainFrame.swingtime = self.mainFrame.newswingtime
				self.mainFrame.newswingtime = nil
			end
			self.mainFrame.texture:SetVertexColor(config.timercolor.r,config.timercolor.g,config.timercolor.b)
			movementDelay = 0
		end
	end
end

function YaHT:UNIT_RANGEDDAMAGE()
	self.mainFrame.newswingtime = UnitRangedDamage("player") - SWING_TIME
end

function YaHT:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF2150C2YaHT|cFFFFFFFF: ".. msg)
end

SLASH_YAHT1 = "/yaht"
SLASH_YAHT2 = "/huntertimer"
SLASH_YAHT3 = "/yetanotherhuntertimer"
SlashCmdList["YAHT"] = function(msg)
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	AceConfigDialog:Open("YaHT")
end

local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("START_AUTOREPEAT_SPELL")
frame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
frame:RegisterEvent("UNIT_RANGEDDAMAGE")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event, ...)
	if( event == "PLAYER_LOGIN" ) then
		YaHT:OnInitialize()
		self:UnregisterEvent("PLAYER_LOGIN")
	else
		YaHT[event](YaHT, ...)
	end
end)
