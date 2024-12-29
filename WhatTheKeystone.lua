WhatTheKeystone = {}
WhatTheKeystone.state = {}
WhatTheKeystone.state.keystone = nil

local function prettyPrint(string)
    print("|cFFFFFF00WhatTheKeystone:|r " .. string)
end

local function formatInfo(keystone)
    local shortName = keystone:gsub("%s%([äöüÄÖÜa-zA-Z ]*%)", "")
    return ("%s"):format(tostring(shortName or ""))
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

    local message = formatInfo(activityInfo.fullName)
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
