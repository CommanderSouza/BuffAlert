local events = CreateFrame("Frame", nil, UIParent)
local greaterdemon = CreateFrame("Frame", "GreaterDemonFrame", UIParent)
local spelltracker = CreateFrame("Frame", "SpellTrackerFrame", UIParent)

events:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
events:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
events:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
events:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
events:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
events:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
events:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
events:RegisterEvent("CHAT_MSG_SPELL_PET_BUFF")
events:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")
events:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
events:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS")
events:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS")
events:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
events:RegisterEvent("CHAT_MSG_COMBAT_LOG")
events:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
events:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
events:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF")
events:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE")
events:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF")
events:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
events:RegisterEvent("CHAT_MSG_COMBAT_MISC_INFO")
events:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
events:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS")
events:RegisterEvent("CHAT_MSG_COMBAT_PARTY_HITS")
events:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")

-- Create texture functions
local function CreateTexture()
	local demontexture = greaterdemon:CreateTexture(nil, "OVERLAY")
	demontexture:SetWidth(256) -- Width of the icon
	demontexture:SetHeight(128) -- Height of the icon
	demontexture:SetPoint("CENTER", UIParent, "CENTER", 0, 75) -- Offset on X-axis
	demontexture:SetAlpha(0) -- Start invisible

	demontexture:Hide() -- Hidden initially
	return demontexture
end

local Texture = CreateTexture()

-- Show texture function
local function ShowTextures(texturePath)
    Texture:Hide()
    Texture:SetTexture(texturePath)
	Texture:Show()
end

-- Hide texture function
local function HideTextures()
	Texture:Hide()
end

-- Timer variables
local timerRunning = false
local timerDuration = 0
local timerEndTime = 0

-- Create a FontString to display the timer
local timerText = greaterdemon:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
timerText:SetPoint("TOP", Texture, "BOTTOM", 0, 0) -- Position below the texture
timerText:SetText("") -- Initially empty
timerText:Hide() -- Hide initially

-- Set custom font
local customFontPath = "Interface\\AddOns\\BuffAlert\\DieDieDie.ttf" -- Relative path to your font
local fontSize = 20 -- Adjust size as needed
local outline = "OUTLINE" -- Optional: use "OUTLINE", "THICKOUTLINE", or nil for no outline

timerText:SetFont(customFontPath, fontSize, outline)
timerText:SetTextColor(1, 0, 0) -- Set text color to red

-- Function to start the timer
local function start_timer(duration)
    if timerRunning then
        return
    end
    timerDuration = duration
    timerEndTime = GetTime() + duration
    timerRunning = true
    timerText:Show() -- Show the timer display
    timerText:SetText(string.format("%.1f", duration)) -- Set initial timer text
end

local function stop_timer()
    if not timerRunning then
        return
    end
    timerRunning = false
    timerDuration = 0
    timerEndTime = 0
    timerText:Hide() -- Hide the timer display
    timerText:SetText("") -- Clear the timer text
end



-- Pulse Animation Variables
local demonpulseAlpha = 0.3
local demonpulseDirection = 0.01 -- Fade in speed
local demonminScale = 0.8 -- Minimum scale multiplier
local demonmaxScale = 1.0 -- Maximum scale multiplier
local demonbaseWidth = 256 -- Base width of the texture
local demonbaseHeight = 128 -- Base height of the texture

-- OnUpdate script to create pulsing effect (opacity + manual scaling)
greaterdemon:SetScript("OnUpdate", function(self, elapsed)
    -- Update alpha for pulse
    demonpulseAlpha = demonpulseAlpha + demonpulseDirection

    -- Reverse direction at boundaries
    if demonpulseAlpha <= 0.3 then
        demonpulseDirection = 0.01 -- Fade in
    elseif demonpulseAlpha >= 0.8 then
        demonpulseDirection = -0.01 -- Fade out
    end

    -- Calculate scale based on alpha
    local demonscale = demonminScale + (demonpulseAlpha - 0.3) / 0.5 * (demonmaxScale - demonminScale) -- Linear interpolation

    -- Apply alpha and scale to both textures
    if Texture:IsShown() then
        Texture:SetAlpha(demonpulseAlpha)

        local demonscaledWidth = demonbaseWidth * demonscale
        local demonscaledHeight = demonbaseHeight * demonscale
        Texture:SetWidth(demonscaledWidth)
        Texture:SetHeight(demonscaledHeight)
    end

    -- Timer logic
    if timerRunning then
        local remaining = timerEndTime - GetTime()
        if remaining <= 0 then
            stop_timer() -- Stop the timer if it expires
            HideTextures()
        else
            -- Display remaining time (you can customize this further)
            timerText:SetText(string.format("%.1f", remaining))
        end
    end
end)

local function CreateSideTexture(xOffset, mirrored)
    local texture = spelltracker:CreateTexture(nil, "OVERLAY")
    texture:SetWidth(128) -- Width of the icon
    texture:SetHeight(256) -- Height of the icon
    texture:SetPoint("CENTER", UIParent, "CENTER", xOffset, 0) -- Offset on X-axis
    texture:SetAlpha(0) -- Start invisible

    -- Flip texture horizontally if mirrored
    if mirrored then
        texture:SetTexCoord(1, 0, 0, 1) -- Reverses the image horizontally
    end

    texture:Hide() -- Hidden initially
    return texture
end

local leftTexture = CreateSideTexture(-200, false) -- Left side, normal orientation
local rightTexture = CreateSideTexture(200, true)  -- Right side, flipped horizontally

-- Pulse Animation Variables
local pulseAlpha = 0.3
local pulseDirection = 0.01 -- Fade in speed
local minScale = 0.8 -- Minimum scale multiplier
local maxScale = 1.0 -- Maximum scale multiplier
local baseWidth = 128 -- Base width of the texture
local baseHeight = 256 -- Base height of the texture

-- Function to hide textures
local function HideSideTextures()
    leftTexture:Hide()
    rightTexture:Hide()
end

-- Function to show textures with the given texture path
local function ShowSideTextures(texturePath)
    leftTexture:SetTexture(texturePath)
    rightTexture:SetTexture(texturePath)
    leftTexture:Show()
    rightTexture:Show()
end

-- OnUpdate script to create pulsing effect (opacity + manual scaling)
spelltracker:SetScript("OnUpdate", function(self, elapsed)
    -- Update alpha for pulse
    pulseAlpha = pulseAlpha + pulseDirection

    -- Reverse direction at boundaries
    if pulseAlpha <= 0.3 then
        pulseDirection = 0.01 -- Fade in
    elseif pulseAlpha >= 0.8 then
        pulseDirection = -0.01 -- Fade out
    end

    -- Calculate scale based on alpha
    local scale = minScale + (pulseAlpha - 0.3) / 0.5 * (maxScale - minScale) -- Linear interpolation

    -- Apply alpha and scale to both textures
    if leftTexture:IsShown() and rightTexture:IsShown() then
        leftTexture:SetAlpha(pulseAlpha)
        rightTexture:SetAlpha(pulseAlpha)

        -- Adjust width and height for scaling effect
        local scaledWidth = baseWidth * scale
        local scaledHeight = baseHeight * scale
        leftTexture:SetWidth(scaledWidth)
        leftTexture:SetHeight(scaledHeight)
        rightTexture:SetWidth(scaledWidth)
        rightTexture:SetHeight(scaledHeight)
    end
end)

-- Define handlers for specific messages or events
local eventHandlers = {
    ["You gain Shadow Trance"] = function()
        PlaySoundFile("Interface\\Sounds\\ShadowTrance-Fr.mp3")
        DEFAULT_CHAT_FRAME:AddMessage('|cff9482c9' .. 'SHADOW TRANCE' .. '|r')
    end,
    ["You cast Inferno"] = function()
        HideTextures()
        stop_timer()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon.mp3")
        ShowTextures("Interface\\AddOns\\BuffAlert\\demon_breaking.tga")
        start_timer(180)
    end,
    ["You cast Demon Gate"] = function()
        HideTextures()
        stop_timer()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon.mp3")
        ShowTextures("Interface\\AddOns\\BuffAlert\\demon_breaking.tga")
        start_timer(186)
    end,
    ["Enslave Demon fades from Infernal"] = function()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon-voice.mp3")
        HideTextures()
        stop_timer()
    end,
    ["Enslave Demon fades from Felguard"] = function()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon-voice.mp3")
        HideTextures()
        stop_timer()
    end,
    ["Felguard dies"] = function()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon-voice.mp3")
        HideTextures()
        stop_timer()
    end,
    ["Infernal dies"] = function()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon-voice.mp3")
        HideTextures()
        stop_timer()
    end,
    ["You have slain Felguard"] = function()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon-voice.mp3")
        HideTextures()
        stop_timer()
    end,
    ["You have slain Infernal"] = function()
        PlaySoundFile("Interface\\AddOns\\BuffAlert\\demon-voice.mp3")
        HideTextures()
        stop_timer()
    end,
    ["Physical damage from your Power Overwhelming"] = function()
        ShowSideTextures("Interface\\AddOns\\BuffAlert\\po.tga")
    end,
    ["Power Overwhelming fades from"] = function()
        HideSideTextures()
    end,
    ["You die"] = function()
        HideSideTextures()
        HideTextures()
        stop_timer()
    end,
}

-- Set up the OnEvent script
events:SetScript("OnEvent", function()
    if not arg1 then return end

    for msg, handler in pairs(eventHandlers) do
        if string.find(arg1, msg) then
            handler()
            break
        end
    end
end)