﻿------------------------------
--      Are you local?      --
------------------------------

local boss = BB["Malygos"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local pName = UnitName("player")
local UnitName = UnitName
local db = nil
local started = nil
local phase = nil
local p2 = nil
local fmt = string.format

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Malygos",
	
	sparks = "Power Spark",
	sparks_desc = "Warns on Power Spark spawns.",
	sparks_message = "Power Spark spawns!",
	sparks_warning = "Power Spark in ~5sec!",
	
	vortex = "Vortex",
	vortex_desc = "Warn for vortex and show a bar.",
	vortex_message = "Vortex!",
	vortex_warning = "Possible Vortex in ~5sec!",
	vortex_next = "Vortex Cooldown",	
	
	breath = "Deep Breath",
	breath_desc = "Deep Breath warnings.",
	breath_message = "Deep Breath!",
	breath_warning = "Deep Breath in ~5sec!",
	
	surge = "Surge of Power",
	surge_desc = "Warn who has Surge of Power.",
	surge_message = "Surge of Power: %s",
	surge_you = "Surge of Power on YOU!",
	
	icon = "Raid Target Icon",
	icon_desc = "Place a Raid Target Icon on the player that Surge of Power is being cast on(requires promoted or higher)",
	
	phase = "Phases",
	phase_desc = "Warn for phase changes.",
	phase2_warning = "Phase 2 soon!",
	phase2_trigger = "I had hoped to end your lives quickly",
	phase2_message = "Phase 2 - Nexus Lord & Scion of Eternity!",
	phase2_end_trigger = "ENOUGH! If you intend to reclaim Azeroth's magic",
	phase3_warning = "Phase 3 soon!",
	phase3_trigger = "Now your benefactors make their",
	phase3_message = "Phase 3!",
	
	log = "|cffff0000"..boss.."|r:\n This boss needs data, please consider turning on your /combatlog or transcriptor and submit the logs.",
} end )

L:RegisterTranslations("koKR", function() return {
	sparks = "마력의 불꽃",
	sparks_desc = "마력의 불꽃 소환을 알립니다.",
	sparks_message = "마력의 불꽃 소환!",
	sparks_warning = "약 5초 후 마력의 불꽃!",
	
	vortex = "회오리",
	vortex_desc = "회오리에 대한 알림과 바를 표시합니다.",
	vortex_message = "회오리!",
	vortex_warning = "약 5초 후 회오리 사용가능!",
	vortex_next = "회오리 대기시간",
	
	breath = "깊은 숨결",
	breath_desc = "깊은 숨결을 알립니다.",
	breath_message = "깊은 숨결!",
	breath_warning = "약 5초 후 깊은 숨결!",
	
	surge = "마력의 쇄도",
	surge_desc = "마력의 쇄도의 대상을 알립니다.",
	surge_message = "마력의 쇄도: %s",
	surge_you = "당신에게 마력의 쇄도!",
	
	icon = "전술 표시",
	icon_desc = "마력의 쇄도의 시전 대상의 플레이어에게 전술 표시를 지정합니다. (승급자 이상 권한 요구)",
	
	phase = "단계",
	phase_desc = "단계 변화를 알립니다.",
	phase2_warning = "잠시 후 2 단계!",
	phase2_trigger = "되도록 빨리 끝내 주고 싶었다만",
	phase2_message = "2 단계 - 마력의 군주 & 영원의 후예!",
	phase2_end_trigger = "그만! 아제로스의 마력을 되찾고",
	phase3_warning = "잠시 후 3 단계!",
	phase3_trigger = "네놈들의 후원자가 나타났구나",
	phase3_message = "3 단계!",
	
	log = "|cffff0000"..boss.."|r:\n 해당 보스에 대한 대화 멘트, 전투로그등을 필요로 합니다. 섬게이트,인벤의 BigWigs Bossmods 안건에 /대화기록, /전투기록을 한 로그나 기타 스샷, 잘못된 타이머등 오류를 제보 부탁드립니다. 윈드러너 서버:백서향으로 바로 문의 주시면 조금 빠른 수정 업데이트가 됩니다 @_@;",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.zonename = BZ["The Eye of Eternity"]
mod.enabletrigger = boss
mod.guid = 28859
mod.toggleoptions = {"phase", -1, "sparks", "vortex", "breath", "surge", -1, "icon", "bosskill"}
mod.revision = tonumber(("$Revision$"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddCombatListener("SPELL_AURA_APPLIED", "Surge", 57407, 60936)
	self:AddCombatListener("SPELL_CAST_SUCCESS", "Vortex", 56105)
	self:AddCombatListener("UNIT_DIED", "BossDeath")

	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")

	BigWigs:Print(L["log"])
	started = nil
	db = self.db.profile
	phase = 0
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:Vortex(_, spellID)
	if db.vortex then
		self:Bar(L["vortex"], 10, 56105)
		self:IfMessage(L["vortex_message"], "Attention", spellID)
		self:Bar(L["vortex_next"], 59, 56105)
		self:ScheduleEvent("VortexWarn", "BigWigs_Message", 54, L["vortex_warning"], "Attention")
		if db.sparks then
			self:CancelScheduledEvent("SparkWarn")
			self:TriggerEvent("BigWigs_StopBar", self, L["sparks"])
			self:Bar(L["sparks"], 17, 44780)
			self:ScheduleEvent("SparkWarn", "BigWigs_Message", 12, L["sparks_warning"], "Attention")
		end
	end
end

local cachedId = nil

function mod:Surge()
	if db.surge then
		self:ScheduleRepeatingEvent("BWMalygosToTScan", self.SurgeCheck, 0.5, self)
	end
end

local last = 0
function mod:SurgeCheck()
	local target
	if UnitName("target") == boss then
		target = UnitName("targettarget")
	elseif UnitName("focus") == boss then
		target = UnitName("focustarget")
	else
		local num = GetNumRaidMembers()
		for i = 1, num do
			if UnitName(fmt("%s%d%s", "raid", i, "pet") or "") == boss then
				target = UnitName(fmt("%s%d%s", "raid", i, "targettarget"))
				break
			end
		end
	end
	if target then
		local time = GetTime()
		if (time - last) > 4 then
			last = time
			if UnitIsUnit(target, "player") then
				self:LocalMessage(L["surge_you"], "Personal", 31299, "Long")
			else
				self:IfMessage(fmt(L["surge_message"], target), "Important", 31299, "Alert")
			end
			if db.icon then
				self:Icon(target, "icon")
			end
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE()
	if unit == boss then
		if phase == 1 then
			if db.sparks then
			-- 44780, looks like a Power Spark :)
			self:CancelScheduledEvent("SparkWarn")
			self:TriggerEvent("BigWigs_StopBar", self, L["sparks"])
			self:Message(L["sparks_message"], "Important", 44780, "Alert")
			self:Bar(L["sparks"], 30, 44780)
			self:ScheduleEvent("SparkWarn", "BigWigs_Message", 25, L["sparks_warning"], "Attention")
			end
		elseif phase == 2 then
			if db.breath then
			--19879 Frost Wyrm, looks like a dragon breathing 'deep breath' :)
			self:Message(L["breath_message"], "Important", 43810, "Alert")
			self:Bar(L["breath"], 59, 43810)
			self:ScheduleEvent("BreathWarn", "BigWigs_Message", 54, L["breath_warning"], "Attention")
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:find(L["phase2_trigger"]) then
		phase = 2	
		self:CancelScheduledEvent("VortexWarn")
		self:CancelScheduledEvent("SparkWarn")
		self:TriggerEvent("BigWigs_StopBar", self, L["sparks"])
		self:TriggerEvent("BigWigs_StopBar", self, L["vortex_next"])
		self:Message(L["phase2_message"], "Attention")
		if db.breath then
				self:Bar(L["breath"], 92, 43810)
				self:DelayedMessage(87, L["breath_warning"], "Attention")
		end
	elseif msg:find(L["phase2_end_trigger"]) then
		self:CancelScheduledEvent("BreathWarn")
		self:TriggerEvent("BigWigs_StopBar", self, L["breath"])
		self:Message(L["phase3_warning"], "Attention")
	elseif msg:find(L["phase3_trigger"]) then
		phase = 3
		self:Message(L["phase3_message"], "Attention")
	end
end

function mod:UNIT_HEALTH(msg)
	if not db.phase then return end
	if UnitName(msg) == boss then
		local hp = UnitHealth(msg)
		if hp > 51 and hp <= 54 and not p2 then
			self:Message(L["phase2_warning"], "Attention")
			p2 = true
		elseif hp > 60 and p2 then
			p2 = false
		end
	end
end	

function mod:BigWigs_RecvSync(sync, rest, nick)
	if self:ValidateEngageSync(sync, rest) and not started then
		started = true
		wipe = true
		phase = 1
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if db.enrage then
			self:Enrage(600)
		end
	end
end

