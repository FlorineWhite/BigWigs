﻿----------------------------------
--      Module Declaration      --
----------------------------------

local boss = BB["Razorscale"]
local commander = BB["Expedition Commander"]
local mod = BigWigs:New(boss, "$Revision$")
if not mod then return end
mod.zonename = BZ["Ulduar"]
mod.enabletrigger = {commander, boss}
mod.guid = 33186
mod.toggleoptions = {"phase", -1, "breath", "flame", "harpoon", "berserk", "bosskill"}

------------------------------
--      Are you local?      --
------------------------------

local db = nil
local p2 = nil
local pName = UnitName("player")
local started = nil
local count = 1
local totalHarpoons = 5
local phase = nil

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

L:RegisterTranslations("enUS", function() return {
	cmd = "Razorscale",

	phase = "Phases",
	phase_desc = "Warn when Razorscale switches between phases.",
	ground_trigger = "Move quickly! She won't remain grounded for long!",
	ground_message = "Razorscale Chained up!",
	air_trigger = "Give us a moment to prepare to build the turrets.",
	air_message = "Takeoff!",
	phase2_trigger = "%s grounded permanently!",
	phase2_message = "Phase 2!",
	phase2_warning = "Phase 2 Soon!",
	stun_bar = "Stun",

	breath = "Flame Breath",
	breath_desc = "Flame Breath warnings.",
	breath_trigger = "%s takes a deep breath...",
	breath_message = "Flame Breath!",
	breath_bar = "~Breath Cooldown",

	flame = "Devouring Flame",
	flame_desc = "Warn when you are in a Devouring Flame.",
	flame_message = "Flame on YOU!",

	harpoon = "Harpoon Turret",
	harpoon_desc = "Harpoon Turret announce.",
	harpoon_message = "Harpoon %d ready!",
	harpoon_trigger = "Harpoon Turret is ready for use!",
	harpoon_nextbar = "Harpoon %d",
} end )

L:RegisterTranslations("ruRU", function() return {
	phase = "Фазы",
	phase_desc = "Сообщать когда Острокрылая меняет фазы.",
	ground_trigger = "Быстрее! Сейчас она снова взлетит!",
	ground_message = "Острокрылая на привязи!",
	air_trigger = "Дайте время подготовить пушки.",
	air_message = "Взлет!",
	phase2_trigger = "Острокрылая обессилела и больше не может летать!",
	phase2_message = "Вторая фаза!",
	phase2_warning = "Скоро вторая фаза!",
	stun_bar = "Оглушение",

	breath = "Огненное дыхание",
	breath_desc = "Сообщать об Огненном дыхании.",
	breath_trigger = "%s делает глубокий вдох…",
	breath_message = "Огненное дыхание!",
	breath_bar = "~перезарядка дыхания",

	flame = "Лавовая бомба на Вас",
	flame_desc = "Сообщать когда вы поподаете под воздействие Лавовой бомбы.",
	flame_message = "ВЫ в Лавовой БОМБЕ!",

	harpoon = "Гарпунная Пушка",
	harpoon_desc = "Объявлять Гарпунные Пушки.",
	harpoon_message = "Гарпунная Пушка (%d)",
	harpoon_trigger = "Гарпунная пушка готова!",
	harpoon_nextbar = "Следующий Гарпун (%d)",
} end )

L:RegisterTranslations("koKR", function() return {
	phase = "단계",
	phase_desc = "칼날비늘의 단계 변경을 알립니다.",
	ground_trigger = "움직이세요! 오래 붙잡아둘 수는 없을 겁니다!",	--check
	ground_message = "칼날비늘 묶임!",
	--air_trigger = "Give us a moment to prepare to build the turrets.",	--check
	air_message = "이륙!",
	--phase2_trigger = "Razorscale lands permanently!",	--check
	phase2_message = "2 단계!",
	phase2_warning = "곧 2 단계!",
	stun_bar = "기절",

	breath = "화염 숨결",
	breath_desc = "화염 숨결을 알립니다.",
	breath_trigger = "%s|1이;가; 숨을 깊게 들이마십니다...",
	breath_message = "화염 숨결!",
	breath_bar = "~숨결 대기시간",

	flame = "자신의 파멸의 불길",
	flame_desc = "자신이 파멸의 불길에 걸렸을 때 알립니다.",
	flame_message = "당신은 파멸의 불길!",

	harpoon = "작살 포탑",
	harpoon_desc = "작살 포탑의 준비를 알립니다.",
	harpoon_message = "작살 포탑 (%d)",
	--harpoon_trigger = "Harpoon Turret is ready for use!",
	harpoon_nextbar = "다음 작살 (%d)",
} end )

L:RegisterTranslations("frFR", function() return {
	phase = "Phases",
	phase_desc = "Prévient quand la rencontre entre dans une nouvelle phase.",
	ground_trigger = "Faites vite ! Elle va pas rester au sol très longtemps !",
	ground_message = "Tranchécaille enchaînée !",
	air_trigger = "Laissez un instant pour préparer la construction des tourelles.",
	air_message = "Décollage !",
	phase2_trigger = "Tranchécaille bloquée au sol !",
	phase2_message = "Phases 2 !",
	phase2_warning = "Phase 2 imminente !",
	stun_bar = "Étourdie",

	breath = "Souffle de flammes",
	breath_desc = "Prévient de l'arrivée des Souffles de flammes.",
	breath_trigger = "%s inspire profondément…",
	breath_message = "Souffle de flammes !",
	breath_bar = "~Recharge Souffle",

	flame = "Flamme dévorante sur vous",
	flame_desc = "Prévient quand vous vous trouvez dans une Flamme dévorante.",
	flame_message = "Flamme dévorante sur VOUS !",

	harpoon = "Tourelle à harpon",
	harpoon_desc = "Prévient quand une tourelle à harpon est prête.",
	harpoon_message = "Tourelle à harpon (%d)",
	harpoon_trigger = "Tourelle à harpon prête à l'action !",
	harpoon_nextbar = "Prochaine Tourelle (%d)",
} end )

L:RegisterTranslations("deDE", function() return {
	phase = "Phasen",
	phase_desc = "Warnt bei Phasenwechsel.",
	ground_trigger = "Beeilt Euch! Sie wird nicht lange am Boden bleiben!",
	ground_message = "Angekettet!",
	air_trigger = "Gebt uns einen Moment, damit wir uns auf den Bau der Geschütze vorbereiten können.",
	air_message = "Hebt ab!",
	phase2_trigger = "%s dauerhaft an den Boden gebunden!",
	phase2_message = "Phase 2!",
	phase2_warning = "Phase 2 bald!",
	stun_bar = "Betäubt",

	breath = "Flammenatem",
	breath_desc = "Warnt vor Flammenatem.",
	breath_trigger = "%s holt tief Luft...",
	breath_message = "Flammenatem!",
	breath_bar = "~Flammenatem",

	flame = "Verschlingende Flamme",
	flame_desc = "Warnt, wenn du von Verschlingende Flamme getroffen wirst.",
	flame_message = "Verschlingende Flamme auf DIR!",

	harpoon = "Harpunengeschütze",
	harpoon_desc = "Warnungen und Timer für die Harpunengeschütze.",
	harpoon_message = "Harpunengeschütz (%d) bereit!",
	harpoon_trigger = "Harpunengeschütz ist einsatzbereit!",
	harpoon_nextbar = "Geschütz (%d)",
} end )

L:RegisterTranslations("zhCN", function() return {
	phase = "阶段",
	phase_desc = "当锋鳞转换不同阶段时发出警报。",
--	ground_trigger = "Move quickly! She won't remain grounded for long!",
	ground_message = "锋鳞被锁住了！",
--	air_trigger = "Give us a moment to prepare to build the turrets.",
	air_message = "起飞！",
--	phase2_trigger = "Razorscale lands permanently!",
	phase2_message = "第二阶段！",
	phase2_warning = "即将 第二阶段！",
	stun_bar = "<昏迷>",

	breath = "烈焰喷射",
	breath_desc = "当烈焰喷射时发出警报。",
--	breath_trigger = "%s takes a deep breath...",
	breath_message = "烈焰喷射！",
	breath_bar = "~Breath Cooldown",

	flame = "自身Devouring Flame",
	flame_desc = "当你中了Devouring Flame时发出警报。",
	flame_message = ">你< Devouring Flame！",

	harpoon = "魚叉炮台",
	harpoon_desc = "当魚叉炮台可用时发出警报。",
	harpoon_message = "魚叉炮台：>%d<可用！",
--	harpoon_trigger = "Harpoon Turret is ready for use!",
	harpoon_nextbar = "<魚叉炮台：%d>",
} end )

L:RegisterTranslations("zhTW", function() return {
	phase = "階段",
	phase_desc = "當銳鱗轉換不同階段發出警報。",
--	ground_trigger = "Move quickly! She won't remain grounded for long!",
	ground_message = "銳鱗被鎖住了！",
--	air_trigger = "Give us a moment to prepare to build the turrets.",
	air_message = "起飛！",
--	phase2_trigger = "Razorscale lands permanently!",
	phase2_message = "第二階段！",
	phase2_warning = "即將 第二階段！",
	stun_bar = "<擊昏>",

	breath = "火息術",
	breath_desc = "當火息術時發出警報。",
--	breath_trigger = "%s takes a deep breath...",
	breath_message = "火息術！",
	breath_bar = "~Breath Cooldown",

	flame = "自身吞噬烈焰",
	flame_desc = "當你中了吞噬烈焰時發出警報。",
	flame_message = ">你< 吞噬烈焰！",

	harpoon = "魚叉炮塔",
	harpoon_desc = "當魚叉炮塔可用時發出警報。",
	harpoon_message = "魚叉炮塔：>%d<可用！",
--	harpoon_trigger = "Harpoon Turret is ready for use!",
	harpoon_nextbar = "<魚叉炮塔：%d>",
} end )

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddCombatListener("SPELL_DAMAGE", "Flame", 64704, 64733)
	self:AddCombatListener("UNIT_DIED", "BossDeath")

	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	totalHarpoons = GetCurrentDungeonDifficulty() == 1 and 2 or 4
	db = self.db.profile
	started = nil
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:Flame(player)
	if player == pName and db.flame then
		self:LocalMessage(L["flame_message"], "Personal", 64733, "Alarm")
	end
end

function mod:UNIT_HEALTH(msg)
	if not db.phase then return end
	if UnitName(msg) == boss then
		local hp = UnitHealth(msg)
		if hp > 51 and hp <= 55 and not p2 then
			self:Message(L["phase2_warning"], "Positive")
			p2 = true
		elseif hp > 70 and p2 then
			p2 = nil
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L["phase2_trigger"] and db.phase then
		phase = 2
		self:IfMessage(L["phase2_message"], "Attention")
	elseif msg == L["breath_trigger"] and db.breath then
		self:IfMessage(L["breath_message"], "Attention", 64021)
		if phase == 2 then
			self:Bar(L["breath_bar"], 21, 64021)
		end
	elseif msg == L["harpoon_trigger"] and db.harpoon then
		self:IfMessage(L["harpoon_message"]:format(count), "Attention", "INV_Spear_06")
		count = count + 1
		if count < totalHarpoons then
			self:Bar(L["harpoon_nextbar"]:format(count), 18, "INV_Spear_06")
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["ground_trigger"] and db.phase then
		self:Message(L["ground_message"], "Attention", nil, "Long")
		self:Bar(L["stun_bar"], 38, 20170) --20170, looks like a stun :p
	elseif msg == L["air_trigger"] then
		p2 = nil
		count = 1
		self:Bar(L["harpoon_nextbar"]:format(count), 55, "INV_Spear_06")
		if not started then
			if db.berserk then
				self:Enrage(600, true)
			end
			started = true
			phase = 1
		else
			self:TriggerEvent("BigWigs_StopBar", self, L["stun_bar"])
			self:Message(L["air_message"], "Attention", nil, "Info")
		end
	end
end

