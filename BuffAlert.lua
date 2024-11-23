local events = CreateFrame("Frame", nil, UIParent)
events:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
events:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
events:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

local buffSounds = {
    ["You gain Shadow Trance"] = "Interface\\Sounds\\ShadowTrance-Fr.mp3",
    --["You gain Nightfall"] = "Interface\\Sounds\\Nightfall-Fr.mp3",
}

events:SetScript("OnEvent", function()	
	for msg, soundFile in pairs(buffSounds) do
        if (string.find(arg1, msg)) then
            PlaySoundFile(soundFile)
        end
    end
end)