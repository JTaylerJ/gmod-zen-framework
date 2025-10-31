module("zen")

do -- Clipboard from text
    nt.SimpleChannel("SetClipboardText", {"string"}, function (ply, clipboard_text)
        if CLIENT then SetClipboardText(clipboard_text) end
    end)

    ---@param ply nt.target
    ---@param clipboard_text string
    function util.SetPlayerClipboard(ply, clipboard_text)
        if CLIENT then
            SetClipboardText(clipboard_text)
        end

        if SERVER then
            nt.SendToChannel("SetClipboardText", nil, clipboard_text)
        end
    end
end