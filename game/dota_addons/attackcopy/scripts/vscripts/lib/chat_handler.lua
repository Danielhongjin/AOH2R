require("lib/cheats")



ChatHandler = ChatHandler or class({})


function ChatHandler:OnPlayerChat(keys)
    if Cheats:IsEnabled() then
        local brute_text = keys.text

        if string.sub(brute_text, 1, 1) == "-" then
            local text = string.sub(brute_text, 2)
            local playerId = keys.playerid
            local player = PlayerResource:GetPlayer(playerId)

            local args = {}
            for s in string.gmatch(text, "%S+") do
                table.insert(args, s)
            end

            local command = args[1]
            table.remove(args, 1)

            if Cheats[command] then
                Cheats[command](Cheats, player, args)
            end
        end
    end
end
