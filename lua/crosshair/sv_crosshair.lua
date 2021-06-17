hook.Add("PlayerSay", "CrosshairMenu", function(ply, text)
    text = string.lower(text)

    if text == "!cross" or text == "!crosshair" then
        ply:ConCommand("crosshair_menu")
    end
end)

util.AddNetworkString("RefreshCrosshair")

net.Receive("RefreshCrosshair", function(len, ply)
    ply:SetNWInt("XHairThickness", net.ReadInt(8))
    ply:SetNWInt("XHairGap", net.ReadInt(8))
    ply:SetNWInt("XHairSize", net.ReadInt(8))
    ply:SetNWString("XHairColor", net.ReadString())
    ply:SetNWFloat("XHairOutline", net.ReadFloat())
end)