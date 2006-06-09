﻿BigWigsOnyxia = AceAddon:new({
	name          = "BigWigsOnyxia",
	cmd           = AceChatCmd:new({}, {}),

	zonename = "Onyxia",
	enabletrigger = GetLocale() == "koKR" and "오닉시아" 
		or GetLocale() == "zhCN" and "奥妮克希亚"
		or "Onyxia"	,

	loc = GetLocale() == "deDE" and 
	{ 
		bossname = "Onyxia",
		disabletrigger = "Onyxia stirbt.",

		trigger1 = "atmet tief ein...",
		trigger2 = "von oben",
		trigger3 = "Es sieht so aus",

		warn1 = "Onyxia Tiefer Atem kommt, rennt zu den Seiten!",
		warn2 = "Onyxia Phase 2 kommt!",
		warn3 = "Onyxia Phase 3 kommt!",
		bosskill = "Onyxia wurde besiegt!",
	} 
		or GetLocale() == "koKR" and 
	{ 
		bossname = "오닉시아",
		disabletrigger = "오닉시아|1이;가; 죽었습니다.",

		trigger1 = "깊은 숨을 들이쉽니다...",
		trigger2 = "머리 위에서 모조리",
		trigger3 = "혼이 더 나야 정신을 차리겠구나!",

		warn1 = "경고 : 오닉시아 딥 브레스, 구석으로 피하십시오!",
		warn2 = "오닉시아 2단계 시작!",
		warn3 = "오닉시아 3단계 시작!",
		bosskill = "오닉시아를 물리쳤습니다!",
	} 
		or GetLocale() == "zhCN" and
	{ 
		bossname = "奥妮克希亚",
		disabletrigger = "奥妮克希亚死亡了。",

		trigger1 = "深深地吸了一口气……",
		trigger2 = "从上空",
		trigger3 = "看起来需要再给你一次教训",

		warn1 = "奥妮克希亚深呼吸即将出现，向边缘散开！",
		warn2 = "奥妮克希亚进入第二阶段！",
		warn3 = "奥妮克希亚进入第三阶段！",
		bosskill = "奥妮克希亚被击败了！",
	}	
		or 
	{ 
		bossname = "Onyxia",
		disabletrigger = "Onyxia dies.",

		trigger1 = "takes in a deep breath...",
		trigger2 = "from above",
		trigger3 = "It seems you'll need another lesson",

		warn1 = "Onyxia Deep Breath AoE incoming, move to sides!",
		warn2 = "Onyxia phase 2 incoming!",
		warn3 = "Onyxia phase 3 incoming!",
		bosskill = "Onyxia has been defeated!",
	}
})

function BigWigsOnyxia:Initialize()
	self.disabled = true
	BigWigs:RegisterModule(self)
end

function BigWigsOnyxia:Enable()
	self.disabled = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function BigWigsOnyxia:Disable()
	self.disabled = true
	self:UnregisterAllEvents()
end

function BigWigsOnyxia:CHAT_MSG_COMBAT_HOSTILE_DEATH()
	if (arg1 == self.loc.disabletrigger) then
		self:TriggerEvent("BIGWIGS_MESSAGE", self.loc.bosskill, "Green")
		self:Disable()
	end
end

function BigWigsOnyxia:CHAT_MSG_MONSTER_EMOTE()
	if (arg1 == self.loc.trigger1) then
		self:TriggerEvent("BIGWIGS_MESSAGE", self.loc.warn1, "Red")
	end
end

function BigWigsOnyxia:CHAT_MSG_MONSTER_YELL()
	if (string.find(arg1, self.loc.trigger2)) then
		self:TriggerEvent("BIGWIGS_MESSAGE", self.loc.warn2, "White")
	elseif (string.find(arg1, self.loc.trigger3)) then
		self:TriggerEvent("BIGWIGS_MESSAGE", self.loc.warn3, "White")
	end
end
--------------------------------
--      Load this bitch!      --
--------------------------------
BigWigsOnyxia:RegisterForLoad()