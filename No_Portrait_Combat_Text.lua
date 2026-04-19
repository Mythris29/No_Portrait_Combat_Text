local ADDON_NAME = "No_Portrait_Combat_Text"

-- SavedVariables (declared in .toc) are injected by WoW before ADDON_LOADED.
-- NoPortraitCombatText_Global = { HidePlayer, HidePet }
-- NoPortraitCombatText_Char   = { UseCharacterSettings, HidePlayer, HidePet }

local DEFAULTS = {
    HidePlayer = true,
    HidePet    = true,
}

local function EnsureSettingsTables()
    if NoPortraitCombatText_Global == nil then
        NoPortraitCombatText_Global = {
            HidePlayer = DEFAULTS.HidePlayer,
            HidePet    = DEFAULTS.HidePet,
        }
    else
        for k, v in pairs(DEFAULTS) do
            if NoPortraitCombatText_Global[k] == nil then
                NoPortraitCombatText_Global[k] = v
            end
        end
    end

    if NoPortraitCombatText_Char == nil then
        NoPortraitCombatText_Char = {
            UseCharacterSettings = false,
            HidePlayer = NoPortraitCombatText_Global.HidePlayer,
            HidePet    = NoPortraitCombatText_Global.HidePet,
        }
    else
        if NoPortraitCombatText_Char.UseCharacterSettings == nil then
            NoPortraitCombatText_Char.UseCharacterSettings = false
        end
        for k, v in pairs(DEFAULTS) do
            if NoPortraitCombatText_Char[k] == nil then
                NoPortraitCombatText_Char[k] = NoPortraitCombatText_Global[k]
            end
        end
    end
end

local function GetSetting(key)
    EnsureSettingsTables()
    if NoPortraitCombatText_Char.UseCharacterSettings then
        return NoPortraitCombatText_Char[key]
    end
    return NoPortraitCombatText_Global[key]
end

local function SetSetting(key, value)
    EnsureSettingsTables()
    if NoPortraitCombatText_Char.UseCharacterSettings then
        NoPortraitCombatText_Char[key] = value
    else
        NoPortraitCombatText_Global[key] = value
    end
end

local function SetUseCharacterSettings(enabled)
    EnsureSettingsTables()
    if enabled and not NoPortraitCombatText_Char.UseCharacterSettings then
        -- Seed character table from current global values so the toggle is seamless.
        for k in pairs(DEFAULTS) do
            NoPortraitCombatText_Char[k] = NoPortraitCombatText_Global[k]
        end
    end
    NoPortraitCombatText_Char.UseCharacterSettings = enabled
end

-- Apply one frame's UNIT_COMBAT registration based on whether we want to hide its combat text.
local function ApplyFrame(frame, hide)
    if not frame then return end
    if hide then
        if frame.UnregisterEvent then
            frame:UnregisterEvent("UNIT_COMBAT")
        end
    else
        if frame.RegisterEvent then
            frame:RegisterEvent("UNIT_COMBAT")
        end
    end
end

local function ApplyAllSettings()
    EnsureSettingsTables()
    ApplyFrame(PlayerFrame, GetSetting("HidePlayer"))
    ApplyFrame(PetFrame,    GetSetting("HidePet"))
end

-- Build the Blizzard Settings panel (AddOns tab).
local function BuildSettingsPanel()
    local category = Settings.RegisterVerticalLayoutCategory("No Portrait Combat Text")

    -- Checkbox: Use Character-Specific Settings
    local useCharVarTbl = { UseCharacterSettings = NoPortraitCombatText_Char.UseCharacterSettings or false }
    local useCharSetting = Settings.RegisterAddOnSetting(
        category,
        "NoPortraitCombatText_UseCharacterSettings",
        "UseCharacterSettings",
        useCharVarTbl,
        Settings.VarType.Boolean,
        "Use Character-Specific Settings",
        false
    )
    useCharSetting:SetValue(NoPortraitCombatText_Char.UseCharacterSettings or false)
    useCharSetting:SetValueChangedCallback(function(_, value)
        SetUseCharacterSettings(value)
        ApplyAllSettings()
    end)
    Settings.CreateCheckbox(
        category,
        useCharSetting,
        "If enabled, this character uses its own toggles; otherwise it follows the account-wide settings."
    )

    local function AddHideCheckbox(key, label, tooltip)
        local varTbl = { [key] = GetSetting(key) }
        if varTbl[key] == nil then varTbl[key] = DEFAULTS[key] end
        local setting = Settings.RegisterAddOnSetting(
            category,
            "NoPortraitCombatText_"..key,
            key,
            varTbl,
            Settings.VarType.Boolean,
            label,
            DEFAULTS[key]
        )
        local current = GetSetting(key)
        if current == nil then current = DEFAULTS[key] end
        setting:SetValue(current)
        setting:SetValueChangedCallback(function(_, value)
            SetSetting(key, value)
            ApplyAllSettings()
        end)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    AddHideCheckbox("HidePlayer", "Hide combat text on Player frame",
        "Suppress damage/heal text on your own portrait.")
    AddHideCheckbox("HidePet",    "Hide combat text on Pet frame",
        "Suppress damage/heal text on your pet's portrait.")

    Settings.RegisterAddOnCategory(category)
end

-- Event frame
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_PET")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        EnsureSettingsTables()
        BuildSettingsPanel()
        ApplyAllSettings()
        f:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        ApplyAllSettings()
    elseif event == "UNIT_PET" and arg1 == "player" then
        -- PetFrame can be (re)created when the player summons/dismisses a pet; re-apply.
        ApplyAllSettings()
    end
end)
