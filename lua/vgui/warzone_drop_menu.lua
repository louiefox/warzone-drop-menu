local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled( true )

    self:DockPadding( 0, 0, 0, 0 )
    self:ShowCloseButton( false )
    self:SetTitle( "" )
    
    self.slotH = ScrH()*0.1

    surface.SetFont( "WZDM_FontBottom" )
    self.slotBottomH = select( 2, surface.GetTextSize( "$1,000" ) )+10

    self.slotW = self.slotH-self.slotBottomH-5
    self.slotSpacing = 10

    self.topInfo = vgui.Create( "DPanel", self )
    self.topInfo:Dock( TOP )
    self.topInfo:SetTall( 50 )
    local leftMat, rightMat = Material( "wzdm/mouse_left.png" ), Material( "wzdm/mouse_right.png" )
    local leftW, rightW = 0, 0
    self.topInfo.DrawHint = function( mat, text, x, y ) 
        local iconSize = 24

        surface.SetFont( "WZDM_FontBottom" )
        local textX = surface.GetTextSize( text )

        local contentW = textX+iconSize+5

        surface.SetMaterial( mat )

        surface.SetDrawColor( 0, 0, 0 )
        surface.DrawTexturedRect( x-(contentW/2)+1, y-(iconSize/2), iconSize, iconSize )
        surface.DrawTexturedRect( x-(contentW/2)-1, y-(iconSize/2), iconSize, iconSize )
        surface.DrawTexturedRect( x-(contentW/2), y-(iconSize/2)+1, iconSize, iconSize )
        surface.DrawTexturedRect( x-(contentW/2), y-(iconSize/2)-1, iconSize, iconSize )

        surface.SetDrawColor( 255, 255, 255 )
        surface.DrawTexturedRect( x-(contentW/2), y-(iconSize/2), iconSize, iconSize )

        draw.SimpleTextOutlined( text, "WZDM_FontBottom", x+(contentW/2), y, WZDM.CONFIG.Themes.SlotTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, WZDM.CONFIG.Themes.SlotTextOutlineColor )

        return contentW
    end
    self.topInfo.Paint = function( self2, w, h ) 
        if( self2.rightClickTxt ) then
            local drawOverMid = (w/2.5)+(leftW/2) > w/2
            leftW = self2.DrawHint( leftMat, self2.leftClickTxt or "", (drawOverMid and (w/2)-10-(leftW/2)) or w/2.5, h/2 )
            rightW = self2.DrawHint( rightMat, self2.rightClickTxt, (drawOverMid and (w/2)+10+(rightW/2)) or w-(w/2.5), h/2 )
        else
            self2.DrawHint( leftMat, self2.leftClickTxt or "", w/2, h/2 )
        end
    end

    self.slotRow = vgui.Create( "DPanel", self )
    self.slotRow:Dock( TOP )
    self.slotRow:SetTall( self.slotH )
    self.slotRow.Paint = function( self2, w, h ) end

    self.botttomInfo = vgui.Create( "DPanel", self )
    self.botttomInfo:Dock( BOTTOM )
    self.botttomInfo:SetTall( 35 )
    self.botttomInfo.Paint = function( self2, w, h ) 
        surface.SetDrawColor( 50, 50, 50, 250 )
        surface.DrawRect( 0, 0, w, h )

        draw.SimpleTextOutlined( self2.displayText or "", "WZDM_FontBottomL", w/2, h/2, WZDM.CONFIG.Themes.SlotTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, WZDM.CONFIG.Themes.SlotTextOutlineColor )
    end

    self.slotPanels = {}
    self:SetSize( 0, self.topInfo:GetTall()+self.slotRow:GetTall()+10+self.botttomInfo:GetTall() )

    self:AddSlot( "Money", Material( "wzdm/dollar.png" ), "Drop " .. DarkRP.formatMoney( WZDM.CONFIG.MoneyDropAmount ), "Drop " .. DarkRP.formatMoney( WZDM.CONFIG.MoneyDropAllAmount ), function( rightClick )
        net.Start( "WZDM.Net.RequestDropMoney" )
            net.WriteBool( rightClick )
        net.SendToServer()
    end, function()
        return DarkRP.formatMoney( LocalPlayer():getDarkRPVar( "money" ) )
    end )

    local defaultAmmoMat = Material( "wzdm/ammo_default.png" )
    for k, v in pairs( LocalPlayer():GetAmmo() ) do
        local name = game.GetAmmoName( k )
        self:AddSlot( (WZDM.CONFIG.AmmoNames[name] or name) .. " Ammo", WZDM.CONFIG.AmmoIcons[name] or defaultAmmoMat, "Drop Ammo", "Drop All Ammo", function( rightClick )
            net.Start( "WZDM.Net.RequestDropAmmo" )
                net.WriteString( name )
                net.WriteBool( rightClick )
            net.SendToServer()
        end, function()
            return LocalPlayer():GetAmmoCount( k )
        end )
    end

    local weaponSlot = self:AddSlot( function() 
        return LocalPlayer():GetActiveWeapon():GetPrintName()
    end, false, "Drop Weapon", false, function()
        net.Start( "WZDM.Net.RequestDropWeapon" )
        net.SendToServer()
    end, false, true, self.slotW*2 )

    weaponSlot.model = vgui.Create( "DModelPanel", weaponSlot )
    weaponSlot.model:Dock( FILL )
    function weaponSlot.model:LayoutEntity( Entity ) return end
    weaponSlot.model.UpdateModel = function( self2 )
        local weapon = LocalPlayer():GetActiveWeapon()
        if( not IsValid( weapon ) ) then return end

        self2.activeClass = weapon:GetClass()

        self2:SetModel( weapon:GetModel() )

        local modelEnt = self2.Entity
        if( not IsValid( modelEnt ) ) then return end

        local mn, mx = modelEnt:GetRenderBounds()
        local size = 0
        size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
        size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
        size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

        self2:SetFOV( 50 )
        self2:SetCamPos( Vector( size, size, size ) )
        self2:SetLookAt( (mn + mx) * 0.5 )
    end
    weaponSlot.model:UpdateModel()
    weaponSlot.model.DoClick = weaponSlot.DoClick
    weaponSlot.model.OnCursorEntered = weaponSlot.OnCursorEntered
    weaponSlot.model.Think = function( self2 )
        local weapon = LocalPlayer():GetActiveWeapon()
        if( not IsValid( weapon ) ) then return end

        if( self2.activeClass == weapon:GetClass() ) then return end 
        self2:UpdateModel() 
        self:DisplaySlot( weaponSlot.slotKey )
    end

    self:SetPos( (ScrW()/2)-(self:GetWide()/2), (ScrH()*0.8)-(self:GetTall()/2) )
end

local gradientMat = Material( "wzdm/gradient_box.png" )
function PANEL:AddSlot( displayText, icon, leftClickTxt, rightClickTxt, clickFunc, getTextFunc, isActive, widthOverride )
    local slotKey = #self.slotPanels+1

    local slotPanel = vgui.Create( "DButton", self.slotRow )
    slotPanel:Dock( LEFT )
    slotPanel:DockMargin( 0, 0, self.slotSpacing, 0 )
    slotPanel:SetWide( widthOverride or self.slotW )
    slotPanel:SetText( "" )
    slotPanel.leftClickTxt = leftClickTxt
    slotPanel.rightClickTxt = rightClickTxt
    slotPanel.slotKey = slotKey
    slotPanel.Paint = function( self2, w, h )
        local topH = (getTextFunc and h-self.slotBottomH-5) or h

        surface.SetDrawColor( 0, 0, 0, 250 )
        surface.DrawRect( 0, 0, w, topH )

        surface.SetDrawColor( 125, 125, 125, 150 )
        surface.SetMaterial( gradientMat )
        surface.DrawTexturedRect( 0, 0, w, topH )

        surface.SetDrawColor( 150, 150, 150 )
        surface.DrawRect( 0, 0, w, 2 )
        surface.DrawRect( 0, topH-2, w, 2 )

        if( self.displayedSlot == slotKey or self2:IsHovered() or (IsValid( self2.model ) and self2.model:IsHovered()) ) then
            local hoverC = WZDM.CONFIG.Themes.HoverColor

            surface.SetDrawColor( hoverC.r, hoverC.g, hoverC.b, 100 )
            surface.SetMaterial( gradientMat )
            surface.DrawTexturedRect( 0, 0, w, topH )
    
            surface.SetDrawColor( hoverC )
            surface.DrawRect( 0, 0, w, 2 )
            surface.DrawRect( 0, topH-2, w, 2 )
        end

        if( icon ) then
            surface.SetDrawColor( 200, 200, 200 )
            surface.SetMaterial( icon )
            local iconSize = 64
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (topH/2)-(iconSize/2), iconSize, iconSize )
        end

        if( not getTextFunc ) then return end

        surface.SetDrawColor( 0, 0, 0, 250 )
        surface.DrawRect( 0, h-self.slotBottomH, w, self.slotBottomH )

        surface.SetDrawColor( 125, 125, 125, 150 )
        surface.SetMaterial( gradientMat )
        surface.DrawTexturedRect( 0, h-self.slotBottomH, w, self.slotBottomH )

        draw.SimpleTextOutlined( getTextFunc(), "WZDM_FontBottom", w/2, h-(self.slotBottomH/2), WZDM.CONFIG.Themes.SlotTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, WZDM.CONFIG.Themes.SlotTextOutlineColor )
    end
    slotPanel.GetDisplayText = function()
        return (isfunction( displayText ) and displayText()) or displayText
    end
    slotPanel.OnCursorEntered = function()
        if( self.displayedSlot == slotKey ) then return end
        self:DisplaySlot( slotKey )
    end
    slotPanel.DoClick = function()
        surface.PlaySound( "ui/buttonclick.wav" )
        clickFunc( false )
    end
    slotPanel.DoRightClick = function()
        surface.PlaySound( "ui/buttonclick.wav" )
        clickFunc( true )
    end

    self.slotPanels[slotKey] = slotPanel

    if( not self.displayedSlot ) then
        self:DisplaySlot( slotKey )
    end

    self:SetWide( self:GetWide()+((self:GetWide() > 0 and self.slotSpacing) or 0)+slotPanel:GetWide() )

    return slotPanel
end

function PANEL:DisplaySlot( slotKey )
    self.displayedSlot = slotKey

    local slotPanel = self.slotPanels[slotKey]

    self.topInfo.leftClickTxt = slotPanel.leftClickTxt
    self.topInfo.rightClickTxt = slotPanel.rightClickTxt
    self.botttomInfo.displayText = slotPanel:GetDisplayText()
end

function PANEL:Paint( w, h )

end

vgui.Register( "warzone_drop_menu", PANEL, "DFrame" )