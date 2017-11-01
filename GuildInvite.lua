Debug = false
GuildInvite_database = GuildInvite_database or {}
InvMessage = "inv me to guild"
WaitingForWhoUpdate = false
WhoUpdateInterval = 60*5 -- 5 minutes

function msg(msg)
    if( msg == nil ) then
        msg = " NIL "
    end
    ChatFrame1:AddMessage("GuildInvite: "..msg, 1.0, 1.0, 0.5)
end
-- clear old db rows
function housekeeper()
    for index, value in pairs(GuildInvite_database) do
        -- 30 days = 60*60*24*30
        if difftime(time(),value) > 60*60*24*30 then
            GuildInvite_database[index] = nil
            if Debug == true then msg("GuildInvite_database will be removes: "..index) end
        end
    end
end
function whoupdateloop(self, sinceLastUpdate, ...)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate
    if ( self.sinceLastUpdate > WhoUpdateInterval ) then
        if Debug == true then msg("Updating Who list...") end
        SendWho('g-""')
        WaitingForWhoUpdate = true
        self.sinceLastUpdate = 0
    end
end

local frame = CreateFrame("FRAME")
local frame2 = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("WHO_LIST_UPDATE")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")
local function eventHandler(self, event, ...)
    if event == "WHO_LIST_UPDATE" and WaitingForWhoUpdate then
        SetCVar("Sound_EnableSFX",0) -- disable Hide() sound
        FriendsFrame:Hide()
        SetCVar("Sound_EnableSFX",1) -- enable Hide() sound
        local numWhos, totalCount = GetNumWhoResults();
        for i = 1,numWhos do
            local name, guild = GetWhoInfo(i)
            -- send msg only to guys not in blacklist and with no guild
            if not GuildInvite_database[name] and guild == '' then
                SendChatMessage(string.format("Hey, %s. We are pleased to invite you to <%s>", name, GetGuildInfo("player")), "WHISPER", nil, name)
                SendChatMessage(string.format("You will receive guild invite if you whisper me this message: '%s'", InvMessage), "WHISPER", nil, name)
                -- msg(string.format("Hey, %s\nI want to invite you to our guild %s\nYou can autojoin by whisper me with this message:\n%s", name,GetGuildInfo("player"),InvMessage))
                GuildInvite_database[name] = time()
            end
        end
        WaitingForWhoUpdate = false
    elseif event == "CHAT_MSG_WHISPER" then
        local name,MsgContent = arg2,arg1
        if MsgContent == InvMessage and CanGuildInvite() then
            if Debug == true then msg("Sending guild invitation to "..name) end
            GuildInvite(name)
        elseif not CanGuildInvite() then
            if Debug == true then msg("You cannot invite players to guild") end
        end
    elseif event == "ADDON_LOADED" then
        housekeeper()
    end
    -- COMMENT: set guildmates to blacklist
    -- elseif event == "GUILD_ROSTER_UPDATE" then
    --     local NumGuildMembers = GetNumGuildMembers()
    --     for i = 1,NumGuildMembers do
    --         local name = GetGuildRosterInfo(i)
    --         GuildInvite_database[name] = 999999999999
    --         if Debug == true then msg("adding "..name.." to ignore list") end
    --     end
    -- end
end
frame:SetScript("OnEvent", eventHandler)
frame2:SetScript("OnUpdate", whoupdateloop)
