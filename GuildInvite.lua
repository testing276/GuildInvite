debug = false
GuildInvite_database = GuildInvite_database or {}
InvMessage = "inv to guild"

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
            if debug == true then msg("GuildInvite_database will be removes: "..index) end
        end
    end
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("WHO_LIST_UPDATE")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")
local function eventHandler(self, event, ...)
    if event == "WHO_LIST_UPDATE" then
        local numWhos, totalCount = GetNumWhoResults();
        for i = 1,numWhos do
            local name, guild = GetWhoInfo(i)
            -- send msg only to guys not in blacklist and with no guild
            if not GuildInvite_database[name] and guild == '' then
                SendChatMessage(string.format("Hey, %s. I want to invite you to our guild <%s>", name, GetGuildInfo("player")), "WHISPER", nil, name)
                SendChatMessage("You can autojoin by whisper me this message:", "WHISPER", nil, name)
                SendChatMessage(InvMessage, "WHISPER", nil, name)
                -- msg(string.format("Hey, %s\nI want to invite you to our guild %s\nYou can autojoin by whisper me with this message:\n%s", name,GetGuildInfo("player"),InvMessage))
                GuildInvite_database[name] = time()
            end
        end
    elseif event == "CHAT_MSG_WHISPER" then
        local name,msg = arg2,arg1
        if msg == InvMessage and CanGuildInvite() then
            if debug == true then msg("Sending guild invitation to "..name) end
            GuildInvite(name)
        elseif not CanGuildInvite() then
            if debug == true then msg("You cannot invite players to guild") end
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
    --         if debug == true then msg("adding "..name.." to ignore list") end
    --     end
    -- end
end
frame:SetScript("OnEvent", eventHandler)
