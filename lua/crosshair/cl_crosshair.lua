-- TODO: Make some things local

CH = {}
CH.SliderTextColor = Color(200, 200, 200)
CH.XHairThickness = CreateClientConVar("crosshair_thickness", 2, true, false)
CH.XHairGap = CreateClientConVar("crosshair_gap", 8, true, false)
CH.XHairSize = CreateClientConVar("crosshair_size", 8, true, false)
CH.XHairColor = CreateClientConVar("crosshair_color", string.FromColor(color_white), true, false)
CH.XHairOutline = CreateClientConVar("crosshair_outline", 0, true, false)
CH.SeeSpectatorCrosshair = CreateClientConVar("crosshair_spectator", "1", true, true)

function CH:OpenCrosshairCreator()
    local frame = vgui.Create("DFrame")
    frame:SetSize(640, 480)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Crosshair Creator")
    frame.backgroundColor = Color(40, 40, 40)

    function frame:Paint()
        surface.SetDrawColor(self.backgroundColor)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    end

    local panel = vgui.Create("DPanel", frame)
    panel:SetSize(frame:GetWide() - 8, frame:GetTall() - 44)
    panel:SetPos(4, 32)
    panel.Paint = self.Empty

    local crosshair = vgui.Create("DPanel", panel)
    crosshair:SetSize(panel:GetWide() / 2 - 2, panel:GetTall())
    crosshair:SetPos(0, 0)

    crosshair.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)

        self:DrawCrosshair(LocalPlayer(), w / 2, h / 2)
    end

    local controls = vgui.Create("DPanel", panel)
    controls:SetSize(panel:GetWide() / 2 - 2, panel:GetTall())
    controls:SetPos(panel:GetWide() - controls:GetWide(), 0)
    controls.color = Color(50, 50, 50)

    function controls:Paint(w, h)
        surface.SetDrawColor(self.color)
        surface.DrawRect(0, 0, w, h)
    end

    local scrollPanel = vgui.Create("DScrollPanel", controls)
    scrollPanel:SetSize(controls:GetWide() - 16, controls:GetTall() - 16)
    scrollPanel:SetPos(8, 8)
    local vbar = scrollPanel:GetVBar()
    vbar:SetWide(4)
    vbar.color = ColorAlpha(color_black, 100)

    function vbar:Paint(w, h)
        surface.SetDrawColor(self.color)
        surface.DrawRect(0, 0, w, h)
    end

    vbar.btnUp.Paint = self.Empty
    vbar.btnDown.Paint = self.Empty
    vbar.btnGrip.color = ColorAlpha(color_white, 200)

    function vbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(self.color)
        surface.DrawRect(0, 0, w, h)
    end

    local list = vgui.Create("DIconLayout", scrollPanel)
    list:SetSize(scrollPanel:GetSize())
    list:SetPos(0, 0)
    list:SetSpaceX(0)
    list:SetSpaceY(4)

    self:AddHeaderToList(list, "Dimensions")
    self:AddSliderConvarToList(list, "Thickness", 0, 16, "crosshair_thickness")
    self:AddSliderConvarToList(list, "Internal Gap", 0, 32, "crosshair_gap")
    self:AddSliderConvarToList(list, "Size", 0, 32, "crosshair_size")
    self:AddSliderConvarToList(list, "Outline", 0, 3, "crosshair_outline")

    self:AddHeaderToList(list, "Color")
    local colorChooser = vgui.Create("DColorCombo")
    colorChooser:SetWide(list:GetWide() - 8)
    colorChooser.OnValueChanged = function(s, color)
        RunConsoleCommand("crosshair_color", string.FromColor(color))
        self:Update()
    end
    list:Add(colorChooser)

    self:AddHeaderToList(list, "Configuration")
    local seeSpectatorCrosshairContainer = vgui.Create("EditablePanel")
    seeSpectatorCrosshairContainer:SetWide(list:GetWide() - 8)
    local seeSpectatorCrosshair = vgui.Create("DCheckBox", seeSpectatorCrosshairContainer)
    seeSpectatorCrosshair.OnChange = function(s, value)
        RunConsoleCommand("crosshair_spectator", value and "1" or "0")
    end
    local seeSpectatorCrosshairLabel = vgui.Create("DLabel", seeSpectatorCrosshairContainer)
    seeSpectatorCrosshairLabel:SetText("See other players crosshair when spectating")
    seeSpectatorCrosshairLabel:SetPos(24, 0)
    seeSpectatorCrosshairLabel:SetWide(list:GetWide() - 8 - 24)
    list:Add(seeSpectatorCrosshairContainer)
end

function CH:AddSliderConvarToList(list, text, min, max, convar)
    local slider = vgui.Create("DNumSlider")
    slider:SetText(text)
    slider:SetMinMax(min, max)
    slider:SetWide(list:GetWide())
    slider:SetConVar(convar)
    slider:SetDark(false)

    slider.OnValueChanged = function(s, value)
        self:Update()
    end

    list:Add(slider)
end

function CH:AddHeaderToList(list, text)
    local space = vgui.Create("DPanel")
    space:SetWide(list:GetWide())
    space:SetTall(12)
    space.Paint = self.Empty
    list:Add(space)

    local label = vgui.Create("DLabel")
    label:SetFont("DermaLarge")
    label:SetTextColor(color_white)
    label:SetText(text)
    label:SizeToContents()
    label:SetWide(list:GetWide())
    list:Add(label)
end

function CH:Empty()
end

function CH:Update()
    net.Start("RefreshCrosshair")
        net.WriteInt(self.XHairThickness:GetInt(), 8)
        net.WriteInt(self.XHairGap:GetInt(), 8)
        net.WriteInt(self.XHairSize:GetInt(), 8)
        net.WriteString(self.XHairColor:GetString())
        net.WriteFloat(self.XHairOutline:GetFloat())
    net.SendToServer()
end

function CH:DrawTicks(ply, x, y, tickness, size, gap, color)
    surface.SetDrawColor(color)
    surface.DrawRect(x - (tickness / 2), y - (size + gap / 2), tickness, size)
    surface.DrawRect(x - (tickness / 2), y + (gap / 2), tickness, size)
    surface.DrawRect(x + (gap / 2), y - (tickness / 2), size, tickness)
    surface.DrawRect(x - (size + gap / 2), y - (tickness / 2), size, tickness)
end

function CH:DrawCrosshair(ply, x, y)
    x = x or ScrW() / 2
    y = y or ScrH() / 2

    local xtickness = ply:GetNWInt("XHairThickness", self.XHairThickness:GetInt())
    local gap = ply:GetNWInt("XHairGap", self.XHairGap:GetInt())
    local size = ply:GetNWInt("XHairSize", self.XHairSize:GetInt())
    local color = string.ToColor(ply:GetNWString("XHairColor", self.XHairColor:GetString()))
    local outline = ply:GetNWFloat("XHairOutline", self.XHairOutline:GetFloat())

    if outline > 0.1 then
        local tickness = xtickness + outline
        self:DrawTicks(ply, x, y, tickness, size + tickness, gap - tickness, color_black)
    end

    self:DrawTicks(ply, x, y, xtickness, size, gap, color)
end

hook.Add("HUDPaint", "DrawCustomCrosshair", function()
    local client = LocalPlayer()
    local ply = client

    if CH.SeeSpectatorCrosshair:GetBool() and not client:Alive() then
        local observer = client:GetObserverTarget()

        if IsValid(observer) then
            ply = observer
        end
    end

    -- Is able to draw crosshair
    if IsValid(ply) and ply:IsPlayer() and ply:Alive() and not client:KeyDown(IN_ATTACK2) then
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon.DrawCrosshair ~= false then
            CH:DrawCrosshair(ply)
        end
    end
end)

hook.Add("InitPostEntity", "UpdateServerHud", function()
    CH:Update()
end)

hook.Add("HUDShouldDraw", "HideHUD", function(name)
    -- Never return true here unless you have a reason
    if name == "CHudCrosshair" then return false end
end)

concommand.Add("crosshair_menu", function()
    CH:OpenCrosshairCreator()
end)