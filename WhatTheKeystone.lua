WhatTheKeystone = {}
WhatTheKeystone.state = {}
WhatTheKeystone.state.keystone = nil

local function prettyPrint(string)
    print("|cFF34E0FFWhatTheKeystone:|r " .. string)
end

local function formatInfo(fullName, difficulty)
    return ("|cFFF9D65D%s +%s|r"):format(fullName, tostring(difficulty or "?"))
end

local function handleSlashCommand()
    if WhatTheKeystone.state.keystone == nil then
        prettyPrint("Join an LFG party to remember the key.")
        return nil
    end
    prettyPrint(WhatTheKeystone.state.keystone)
end

SLASH_WHATTHEKEYSTONE1 = "/whatthekeystone"
SLASH_WHATTHEKEYSTONE2 = "/wtk"
SlashCmdList["WHATTHEKEYSTONE"] = function()
    handleSlashCommand()
end

local function handleGroupJoin(groupName)
    if not groupName then
        return nil
    end

    local info = C_LFGList.GetSearchResultInfo(groupName)
    if not info then
        prettyPrint("|cFFFF0000 Error finding group|r")
        return nil
    end

    if #info.activityIDs <= 0 then
        prettyPrint("|cFFFF0000 Group has no activityIDs|r")
        return nil
    end

    local activityID = info.activityIDs[1]
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

    if not activityInfo then
        prettyPrint("|cFFFF0000 Error getting activity info|r")
        return nil
    end

    local message = formatInfo(activityInfo.fullName, activityInfo.difficultyID)
    WhatTheKeystone.state.keystone = message

    prettyPrint(message)
end

local function handleGroupLeft()
    WhatTheKeystone.state.keystone = nil
end

local eventListenerFrame = CreateFrame("Frame", "WhatTheKeystoneEventListenerFrame", UIParent)
local function handleEvent(self, event, ...)
    if event == "LFG_LIST_JOINED_GROUP" then
        handleGroupJoin(...)
    end
    if event == "GROUP_LEFT" then
        handleGroupLeft()
    end
end

eventListenerFrame:SetScript("OnEvent", handleEvent)
eventListenerFrame:RegisterEvent("LFG_LIST_JOINED_GROUP")
eventListenerFrame:RegisterEvent("GROUP_LEFT")
