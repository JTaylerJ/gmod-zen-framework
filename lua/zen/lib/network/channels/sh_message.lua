module("zen", package.seeall)

do
    nt.RegisterChannel("message.simpleChatText", nil, {
        types = {"string"},
        OnRead = function(self, ply, hook_name, hook_args)
            if CLIENT then
                chat.AddText(string)
            end
        end,
    })


    ---Send message to chat for players
    ---@param target Player|"CRecipientFilter"| table<Player>
    ---@param message string
    function nt.PrintMessage(target, message)
        nt.SendToChannel(target, message)
    end
end