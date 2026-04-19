
local NoPortraitCombatText = CreateFrame("Frame")

local function OnWorldEnter()
    -- Disable combat feedback on PlayerFrame
    if PlayerFrame and PlayerFrame.UnregisterEvent then
        PlayerFrame:UnregisterEvent("UNIT_COMBAT")
    end

    -- Disable combat feedback on TargetFrame
    if TargetFrame and TargetFrame.UnregisterEvent then
        TargetFrame:UnregisterEvent("UNIT_COMBAT")
    end

    -- Disable combat feedback on FocusFrame
    if FocusFrame and FocusFrame.UnregisterEvent then
        FocusFrame:UnregisterEvent("UNIT_COMBAT")
    end

    -- Disable combat feedback on Party Frames
    for i = 1, 4 do
        local partyFrame = _G["PartyMemberFrame"..i]
        if partyFrame and partyFrame.UnregisterEvent then
            partyFrame:UnregisterEvent("UNIT_COMBAT")
        end
    end
end

NoPortraitCombatText:RegisterEvent("PLAYER_ENTERING_WORLD")
NoPortraitCombatText:SetScript("OnEvent", OnWorldEnter)
