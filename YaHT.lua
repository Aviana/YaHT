local _, playerClass = UnitClass("player")
if playerClass ~= "HUNTER" then return end

YaHT = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "FuBarPlugin-2.0")
YaHT:RegisterDB("YaHTdb")

-- Assets ----------------------------------------------------------------------------------
YaHT.ScanTip = CreateFrame("GameTooltip", "YaHTScanTip", nil, "GameTooltipTemplate")
YaHT.ScanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
local SWING_TIME = 0.65
--------------------------------------------------------------------------------------------

-- Localization Stuff ----------------------------------------------------------------------
YaHT.L = AceLibrary("AceLocale-2.2"):new("YaHT")
local L = YaHT.L
--------------------------------------------------------------------------------------------

-- FUBAR Stuff -----------------------------------------------------------------------------
YaHT.name = "YaHT"
YaHT.hasNoColor = true
YaHT.hasIcon = "Interface\\Icons\\Ability_UpgradeMoonglaive"
YaHT.defaultMinimapPosition = 180
YaHT.cannotDetachTooltip = true
YaHT.hideWithoutStandby = true

function YaHT:OnClick()
	self:ToggleLock()
end
--------------------------------------------------------------------------------------------

--Upon Loading
function YaHT:OnInitialize()
	self.cmdtable = {
		type = "group",
		args =
		{
			lock = {
				name = L["Lock"],
				desc = L["Lock Timer and Castbar into position"],
				type = "toggle",
				get = function() return YaHT.db.profile.locked end,
				set = function() YaHT:ToggleLock() end,
				order = 1,
			},
			aimed = {
				name = L["Aimed Shot in castbar"],
				desc = L["Show 'Aimed Shot' in the castbar"],
				type = "toggle",
				get = function() return YaHT.db.profile.aimed end,
				set = function() YaHT.db.profile.aimed = not YaHT.db.profile.aimed end,
				order = 2,
			},
			multi = {
				name = L["Multi-Shot in castbar"],
				desc = L["Show 'Multi-Shot' in the castbar"],
				type = "toggle",
				get = function() return YaHT.db.profile.multi end,
				set = function() YaHT.db.profile.multi = not YaHT.db.profile.multi end,
				order = 3,
			},
			timer = {
				type = "group",
				name = L["Timer options"],
				desc = L["Timer options"],
				args = {
					height = {
						type = "range",
						name = L["Height"],
						desc = L["Height"],
						min = 5,
						max = 80,
						step = 1,
						get = function() return YaHT.db.profile.height end,
						set = function(v) YaHT.db.profile.height = v; YaHT:OnProfileEnable() end,
						order = 1,
					},
					width = {
						type = "range",
						name = L["Width"],
						desc = L["Width"],
						min = 20,
						max = 800,
						step = 10,
						get = function() return YaHT.db.profile.width end,
						set = function(v) YaHT.db.profile.width = v; YaHT:OnProfileEnable() end,
						order = 2,
					},
					timercolor = {
						type = 'color',
						name = L["Timer Color"],
						desc = L["Set the color of the timer between shots"],
						get = function() return YaHT.db.profile.colors.timercolor.r, YaHT.db.profile.colors.timercolor.g, YaHT.db.profile.colors.timercolor.b end,
						set = function(r, g, b) YaHT.db.profile.colors.timercolor.r = r; YaHT.db.profile.colors.timercolor.g = g; YaHT.db.profile.colors.timercolor.b = b; YaHT:OnProfileEnable() end,
						order = 3,
					},
					drawcolor = {
						type = 'color',
						name = L["Draw Color"],
						desc = L["Set the color of the bar while the weapon charges"],
						get = function() return YaHT.db.profile.colors.drawcolor.r, YaHT.db.profile.colors.drawcolor.g, YaHT.db.profile.colors.drawcolor.b end,
						set = function(r, g, b) YaHT.db.profile.colors.drawcolor.r = r; YaHT.db.profile.colors.drawcolor.g = g; YaHT.db.profile.colors.drawcolor.b = b; YaHT:OnProfileEnable() end,
						order = 4,
					},
					border = {
						type = "range",
						name = L["Border Thickness"],
						desc = L["Border Thickness"],
						min = 0,
						max = 10,
						step = 0.1,
						get = function() return YaHT.db.profile.border end,
						set = function(v) YaHT.db.profile.border = v; YaHT:OnProfileEnable() end,
						order = 5,
					},
					bordercolor = {
						type = 'color',
						name = L["Border Color"],
						desc = L["Set the color of the border"],
						get = function() return YaHT.db.profile.colors.bordercolor.r, YaHT.db.profile.colors.bordercolor.g, YaHT.db.profile.colors.bordercolor.b end,
						set = function(r, g, b) YaHT.db.profile.colors.bordercolor.r = r; YaHT.db.profile.colors.bordercolor.g = g; YaHT.db.profile.colors.bordercolor.b = b; YaHT:OnProfileEnable() end,
						order = 6,
					},
					alpha = {
						type = "range",
						name = L["Alpha"],
						desc = L["Alpha"],
						min = 0,
						max = 1,
						step = 0.01,
						get = function() return YaHT.db.profile.alpha end,
						set = function(v) YaHT.db.profile.alpha = v; YaHT:OnProfileEnable() end,
						order = 7,
					},
					malpha = {
						type = "range",
						name = L["Movement Alpha"],
						desc = L["Alpha during player movent"],
						min = 0,
						max = 1,
						step = 0.01,
						get = function() return YaHT.db.profile.malpha end,
						set = function(v) YaHT.db.profile.malpha = v; YaHT:OnProfileEnable() end,
						order = 8,
					},
					texture = {
						type = "text",
						name = L["Bar Texture"],
						desc = L["Bar Texture"],
						usage = L["<texturename>"],
						get = function() return YaHT.db.profile.timertexture end,
						set = function(v) YaHT.db.profile.timertexture = v; YaHT:OnProfileEnable() end,
						order = 9,
					},
				},
				order = 4,
			},
			tranqoptions = {
				type = "group",
				name = L["Tranq options"],
				desc = L["Tranq options"],
				args = {
					enable = {
						type = "toggle",
						name = L["Tranq announce"],
						desc = L["Enable Tranquilizing Shot announce"],
						get = function() return YaHT.db.profile.tranq end,
						set = function() YaHT.db.profile.tranq = not YaHT.db.profile.tranq end,
						order = 1,
					},
					fail = {
						type = "toggle",
						name = L["Tranq fail announce"],
						desc = L["Enable failed Tranquilizing Shot announce"],
						get = function() return YaHT.db.profile.tranqfailed end,
						set = function() YaHT.db.profile.tranqfailed = not YaHT.db.profile.tranqfailed end,
						order = 2,
					},
					channel = {
						type = "text",
						name = L["Channel"],
						desc = L["Channel in which to announce"],
						usage = L["<channelname>"],
						get = function() return YaHT.db.profile.channel end,
						set = function(v) YaHT.db.profile.channel = v end,
						order = 3,
					},
					tranqmsg = {
						type = "text",
						name = L["Tranq Message"],
						desc = L["What to send to the channel"],
						usage = L["Use plain text and substitute the targets name with %t"],
						get = function() return YaHT.db.profile.tranqmsg end,
						set = function(v) YaHT.db.profile.tranqmsg = v end,
						order = 4,
					},
					tranqfailmsg = {
						type = "text",
						name = L["Tranq fail Message"],
						desc = L["What to send to the channel when tranq failed"],
						usage = L["<Message>"],
						get = function() return YaHT.db.profile.tranqfailmsg end,
						set = function(v) YaHT.db.profile.tranqfailmsg = v end,
						order = 5,
					},
				},
				order = 5,
			},
			header = {
				type = "header",
				order = 6,
			},
			reset = {
				type = "execute",
				name = L["Reset Settings"],
				desc = L["Reset Settings"],
				func = function() StaticPopup_Show("RESET_YAHT_PROFILE") end,
				order = 7,
			}
		}
	}
	self.OnMenuRequest = self.cmdtable
	self:RegisterChatCommand({"/yaht", "/yetanotherhuntertimer"}, self.cmdtable)
	----------------------------------------------------------------------------------------
	
	self:RegisterDefaults("profile", self.defaults.profile)
	
	self.x, self.y = GetPlayerMapPosition("player")
	self:ScheduleRepeatingEvent("UPDATE_PLAYER_POSITION", self.UPDATE_PLAYER_POSITION, 0.1, self)
	
	self.lastshot = GetTime()
	self.berserkValue = 0
	self.ShotSpells = {
		[L["Aimed Shot"]] = true,
		[L["Multi-Shot"]] = true,
		[L["Arcane Shot"]] = true,
		[L["Concussive Shot"]] = true,
		[L["Distracting Shot"]] = true,
		[L["Scatter Shot"]] = true,
		[L["Scorpid Sting"]] = true,
		[L["Serpent Sting"]] = true,
		[L["Viper Sting"]] = true,
		[L["Tranquilizing Shot"]] = true,
	}
	self.ChatTypes = {
		["SAY"] = true,
		["EMOTE"] = true,
		["YELL"] = true,
		["PARTY"] = true,
		["GUILD"] = true,
		["OFFICER"] = true,
		["RAID"] = true,
		["RAID_WARNING"] = true,
	}
	
	self:Init()

	local _, playerRace = UnitRace("player")
	if playerRace == "Troll" then
		self:RegisterEvent("UNIT_AURA")
	end
	
	self:RegisterEvent("SPELLCAST_FAILED", "SPELLCAST_STOP")
	self:RegisterEvent("SPELLCAST_INTERRUPTED", "SPELLCAST_STOP")
	self:RegisterEvent("SPELLCAST_FAILED")
	self:RegisterEvent("SPELLCAST_DELAYED")
	self:RegisterEvent("START_AUTOREPEAT_SPELL")
	self:RegisterEvent("STOP_AUTOREPEAT_SPELL")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("UNIT_RANGEDDAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
	self:Hook("CastSpell")
	self:Hook("CastSpellByName")
	self:Hook("UseAction")
	
	self:SystemMessage(L["Loaded. The hunt begins!"])
end

function YaHT:Init()
	-- Create Frames

	self.Bar = CreateFrame("Frame", "YaHTFrame", UIParent)
	self.Bar:SetFrameStrata("MEDIUM")
	self.Bar:RegisterForDrag("LeftButton")
	self.Bar:SetClampedToScreen(true)

	self.Bar.Texture = self.Bar:CreateTexture("YaHTFrameTexture","OVERLAY")
	self.Bar.Texture:SetPoint("CENTER",self.Bar,"CENTER")

	self.Bar.Background = self.Bar:CreateTexture(nil,"ARTWORK")
	self.Bar.Background:SetTexture(15/100, 15/100, 15/100, 1)
	self.Bar.Background:SetAllPoints(self.Bar)
	
	self.Bar.Border = self.Bar:CreateTexture(nil,"BORDER")
	self.Bar.Border:SetPoint("CENTER",self.Bar,"CENTER")
	self.Bar.Border:SetTexture(0,0,0)
	
	self.Bar.BorderBackground = self.Bar:CreateTexture(nil,"BACKGROUND")
	self.Bar.BorderBackground:SetPoint("CENTER",self.Bar,"CENTER")
	self.Bar.BorderBackground:SetTexture(1,1,1)
	
	self:OnProfileEnable()
end

function YaHT:ToggleLock(init)
	if not init then
		YaHT.db.profile.locked = not YaHT.db.profile.locked
	end
	local Bar = self.Bar
	if YaHT.db.profile.locked then
		Bar:EnableMouse(nil)
		Bar:SetMovable(nil)
		Bar:SetScript("OnDragStart", nil)
		Bar:SetScript("OnDragStop", nil)
	else
		Bar:EnableMouse(1)
		Bar:SetMovable(1)
		Bar:SetScript("OnDragStart", function() this:StartMoving() end)
		Bar:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()
			local _, _, _, x, y = this:GetPoint()
			YaHT.db.profile.x = x
			YaHT.db.profile.y = y
		end)
	end
	if not self.shooting and YaHT.db.profile.locked then
		Bar:SetAlpha(0)
	elseif self.moving then
		Bar:SetAlpha(YaHT.db.profile.malpha)
	else
		Bar:SetAlpha(YaHT.db.profile.alpha)
	end
end

function YaHT:DELAY_SHOT()
	self.casting = true
end

function YaHT:StartCast(spellName, rank)
	local _,_, latency = GetNetStats()
	local castbar
	if spellName == L["Aimed Shot"] then
		castbar = YaHT.db.profile.aimed
		self.casttime = 3
		for i=1,32 do
			if UnitBuff("player",i) == "Interface\\Icons\\Ability_Warrior_InnerRage" then
				self.casttime = self.casttime/1.3
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Ability_Hunter_RunningShot" then
				self.casttime = self.casttime/1.4
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" then
				self.casttime = self.casttime/ (1 + self.berserkValue)
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Inv_Trinket_Naxxramas04" then
				self.casttime = self.casttime/1.2
			end
			if UnitDebuff("player",i) == "Interface\\Icons\\Spell_Shadow_CurseOfTounges" then
				self.casttime = self.casttime/0.5
			end
		end
	elseif spellName == L["Multi-Shot"] then
		castbar = YaHT.db.profile.multi
		self.casttime = 0.5
	elseif spellName == L["Tranquilizing Shot"] and YaHT.db.profile.tranq then
		self:ScheduleEvent("YaHT_TRANQ", self.Announce, 0.2, self, string.gsub(YaHT.db.profile.tranqmsg,"%%t",UnitName("target")))
	end
	if not self.casttime then
		self.casting = true
		return
	end
	self.castblock = true
	self.casttime = self.casttime + (latency/1000)
	if not oCB and not eCastingBar and castbar then
		CastingBarFrameStatusBar:SetStatusBarColor(1.0, 0.7, 0.0)
		CastingBarSpark:Show()
		CastingBarFrame.startTime = GetTime()
		CastingBarFrame.maxValue = CastingBarFrame.startTime + self.casttime
		CastingBarFrameStatusBar:SetMinMaxValues(CastingBarFrame.startTime, CastingBarFrame.maxValue)
		CastingBarFrameStatusBar:SetValue(CastingBarFrame.startTime)
		CastingBarText:SetText(spellName)
		CastingBarFrame:SetAlpha(1.0)
		CastingBarFrame.holdTime = 0
		CastingBarFrame.casting = 1
		CastingBarFrame.fadeOut = nil
		CastingBarFrame:Show()
		CastingBarFrame.mode = "casting"
	end
	if oCB and castbar then
		oCB:SpellStart(spellName, self.casttime, true)
	end
	if eCastingBar and castbar then
		eCastingBar_SpellcastStart("", spellName, self.casttime * 1000)
	end
	self:ScheduleEvent("DELAY_SHOT", self.DELAY_SHOT, 0.2, self)
end

function YaHT:GCDcheck()
	local _,_,offset,numSpells = GetSpellTabInfo(GetNumSpellTabs())
	local numAllSpell = offset + numSpells;
	local gcd
	for i=1,numAllSpell do
		local name = GetSpellName(i,"BOOKTYPE_SPELL");
		if ( name == L["Serpent Sting"] ) then
			_,gcd = GetSpellCooldown(i,"BOOKTYPE_SPELL")
			break
		end
	end
	return (gcd == 1.5)
end

--System Message Output --------------------------------------------------------------------
function YaHT:SystemMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFAAD372YaHT|cFFFFFFFF: "..msg)
end
--------------------------------------------------------------------------------------------

--On Profile changed------------------------------------------------------------------------
function YaHT:OnProfileEnable()
	-- Apply settings here
	
	local x = YaHT.db.profile.x
	local y = YaHT.db.profile.y
	local height = YaHT.db.profile.height
	local width = YaHT.db.profile.width
	
	self.Bar:SetAlpha(YaHT.db.profile.alpha)
	self.Bar:SetWidth(width)
	self.Bar:SetHeight(height)
	self.Bar:ClearAllPoints()
	
	if x then
		self.Bar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
	else
		self.Bar:SetPoint("CENTER", UIParent, "CENTER", 0, -350)
	end
	
	self.Bar.Texture:SetHeight(height)
	self.Bar.Texture:SetWidth(width)
	self.Bar.Texture:SetTexture("Interface\\AddOns\\YaHT\\media\\"..YaHT.db.profile.timertexture)
	if self.SwingStart then
		self.Bar.Texture:SetVertexColor(YaHT.db.profile.colors.drawcolor.r,YaHT.db.profile.colors.drawcolor.g,YaHT.db.profile.colors.drawcolor.b)
	else
		self.Bar.Texture:SetVertexColor(YaHT.db.profile.colors.timercolor.r,YaHT.db.profile.colors.timercolor.g,YaHT.db.profile.colors.timercolor.b)
	end
	
	self.Bar.Border:SetWidth(width +3)
	self.Bar.Border:SetHeight(height +3)
	
	self.Bar.BorderBackground:SetWidth(width +(YaHT.db.profile.border * 2))
	self.Bar.BorderBackground:SetHeight(height +(YaHT.db.profile.border * 2))
	self.Bar.BorderBackground:SetVertexColor(YaHT.db.profile.colors.bordercolor.r,YaHT.db.profile.colors.bordercolor.g,YaHT.db.profile.colors.bordercolor.b)

	self:ToggleLock(true)
end
--------------------------------------------------------------------------------------------

--Event functions --------------------------------------------------------------------------
function YaHT:UPDATE_PLAYER_POSITION()
	local x, y = GetPlayerMapPosition("player")
	if x ~= self.x or y ~= self.y then
		self.moving = true
		self.x = x
		self.y = y
	else
		self.moving = nil
	end
end

local function isBuffed()
	for i=1, 32 do
		if UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" then
			return true
		end
	end
end

function YaHT:UNIT_AURA()
	local newBuffStatus = isBuffed()
	if not self.hasBerserk and newBuffStatus then
		self.hasBerserk = true
		if((UnitHealth("player")/UnitHealthMax("player")) >= 0.40) then
			self.berserkValue = (1.30 - (UnitHealth("player")/UnitHealthMax("player")))/3
		else
			self.berserkValue = 0.3
		end
	elseif self.hasBerserk and not newBuffStatus then
		self.berserkValue = 0
		self.hasBerserk = nil
	end
end

function YaHT:YAHT_ON_UPDATE()
	local curTime = GetTime()
	local tex = self.Bar.Texture
	local width = YaHT.db.profile.width
	if not self.SwingStart and (curTime - self.lastshot) >= self.swingtime then
		--Start Swing timer
		if self.shooting and not self.casting then
			tex:SetVertexColor(YaHT.db.profile.colors.drawcolor.r,YaHT.db.profile.colors.drawcolor.g,YaHT.db.profile.colors.drawcolor.b)
			self.Bar:SetAlpha(YaHT.db.profile.alpha)
			self.SwingStart = curTime
		else
			if not self.shooting then
				self:CancelScheduledEvent("YAHT_ON_UPDATE")
			end
			if YaHT.db.profile.locked then
				self.Bar:SetAlpha(0)
			end
		end
	elseif self.SwingStart then
		if self.moving then
			self.SwingStart = curTime
			tex:SetWidth(0.01)
			self.Bar:SetAlpha(YaHT.db.profile.malpha)
		else
			tex:SetWidth(width * math.min(((curTime - self.SwingStart) / SWING_TIME),1))
			self.Bar:SetAlpha(YaHT.db.profile.alpha)
		end
	else
		tex:SetWidth(width * (1 - math.min(((curTime - self.lastshot) / self.swingtime),1)))
	end
end

function YaHT:Announce(msg)
	if self.ChatTypes[strupper(YaHT.db.profile.channel)] then
		SendChatMessage(msg, strupper(YaHT.db.profile.channel))
	else
		local id = GetChannelName(YaHT.db.profile.channel)
		if id then
			SendChatMessage(msg, "CHANNEL", nil, id)
		end
	end
end

function YaHT:CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF()
	if string.find(arg1, L["YaHT_MISS"]) then
		self:Announce(YaHT.db.profile.tranqfailmsg)
	end
end

function YaHT:UNIT_RANGEDDAMAGE()
	self.newswingtime = UnitRangedDamage("player") - SWING_TIME
end

function YaHT:SPELLCAST_DELAYED()
	if self.casttime then
		self.casttime = self.casttime + (arg1/1000)
	end
end

function YaHT:SPELLCAST_FAILED()
	self.casting = nil
	self:CancelScheduledEvent("YaHT_TRANQ")
end

function YaHT:SPELLCAST_STOP()
	self.casting = nil
	self.castblock = nil
	if incTranq and YaHT.db.profile.channel and YaHT.db.profile.channel ~= "" then
		local msg = string.gsub(YaHT.db.profile.tranqmsg, "%%t", currTarget)
		self:Announce(msg)
	end
end

function YaHT:START_AUTOREPEAT_SPELL()
	local curTime = GetTime()
	self.swingtime = UnitRangedDamage("player") - SWING_TIME
	self.shooting = true
	self.ignoregcd = self:GCDcheck()
	if curTime - self.lastshot < self.swingtime then
		self.Bar.Texture:SetVertexColor(YaHT.db.profile.colors.timercolor.r,YaHT.db.profile.colors.timercolor.g,YaHT.db.profile.colors.timercolor.b)
	else
		self.Bar.Texture:SetVertexColor(YaHT.db.profile.colors.drawcolor.r,YaHT.db.profile.colors.drawcolor.g,YaHT.db.profile.colors.drawcolor.b)
		self.SwingStart = curTime
	end
	self.Bar:SetAlpha(YaHT.db.profile.alpha)
	if not self:IsEventScheduled("YAHT_ON_UPDATE") then
		self:ScheduleRepeatingEvent("YAHT_ON_UPDATE", self.YAHT_ON_UPDATE, 0, self)
	end
end

function YaHT:STOP_AUTOREPEAT_SPELL()
	self.shooting = nil
	if YaHT.db.profile.locked and (GetTime() - self.lastshot) >= self.swingtime then
		self.Bar:SetAlpha(0)
		self:CancelScheduledEvent("YAHT_ON_UPDATE")
	end
end

function YaHT:ITEM_LOCK_CHANGED()
	if self.casting then
		self.casting = nil
		self.casttime = nil
		self.castblock = nil
		return
	end
	if self.shooting then
		self.lastshot = GetTime()
		self.multishooting = nil
		self.SwingStart = nil
		self.ignoregcd = nil
		if self.newswingtime then
			self.swingtime = self.newswingtime
			self.newswingtime = nil
		end
		self.Bar.Texture:SetVertexColor(YaHT.db.profile.colors.timercolor.r,YaHT.db.profile.colors.timercolor.g,YaHT.db.profile.colors.timercolor.b)
	end
end
--------------------------------------------------------------------------------------------

--Hooks ------------------------------------------------------------------------------------

function YaHT:CastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	self.hooks.CastSpell(spellId, spellbookTabNum)
	local _,cd = GetSpellCooldown(spellId,spellbookTabNum)
	if self.casting == true or cd == 6 then
		return
	end
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	if self.ShotSpells[spellName] and not self.castblock then
		self:StartCast(spellName, rank)
	end
end

function YaHT:CastSpellByName(spellName, onSelf)
	-- Call the original function
	self.hooks.CastSpellByName(spellName, onSelf)
	
	for i=1,120 do
		if IsCurrentAction(i) then
			break
		end
		if i == 120 then return end
	end
	
	local _,_,rank = string.find(spellName,"(%d+)")
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	if not rank then
		local i = 1
		while GetSpellName(i, BOOKTYPE_SPELL) do
			local s, r = GetSpellName(i, BOOKTYPE_SPELL)
			if s == spellName then
				rank = r
			end
			i = i+1
		end
		if rank then
			_,_,rank = string.find(rank,"(%d+)")
		end
	end
	if self.ShotSpells[spellName] and not self.castblock then
		self:StartCast(spellName, rank)
	end
end

function YaHT:UseAction(slot, checkCursor, onSelf)
	-- Call the original function
	self.hooks.UseAction(slot, checkCursor, onSelf)
	
	if GetActionText(slot) or not IsCurrentAction(slot) then return end
	
	self.ScanTip:ClearLines()
	self.ScanTip:SetAction(slot)
	local spellName = YaHTScanTipTextLeft1:GetText()
	local rank = YaHTScanTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	if not rank then
		rank = 1
	end
	
	if self.ShotSpells[spellName] and not self.castblock then
		self:StartCast(spellName, rank)
	end
end
--------------------------------------------------------------------------------------------