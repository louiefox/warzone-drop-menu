function WZDM.FUNC.CreateMenu( parent )
    if( IsValid( WARZONE_DROP_MENU ) )  then
        WARZONE_DROP_MENU:Remove()
    end

    WARZONE_DROP_MENU = (parent and parent:Add( "warzone_drop_menu" )) or vgui.Create( "warzone_drop_menu" )
end

function WZDM.FUNC.HideMenu()
    if( IsValid( WARZONE_DROP_MENU ) )  then
        WARZONE_DROP_MENU:Remove()
    end
end

-- hook.Add( "ScoreboardShow", "WZDM.Hooks.ScoreboardShow", WZDM.FUNC.CreateMenu )
-- hook.Add( "ScoreboardHide", "WZDM.Hooks.ScoreboardHide", WZDM.FUNC.HideMenu )

hook.Add( "OnContextMenuOpen", "WZDM.Hooks.OnContextMenuOpen", function() WZDM.FUNC.CreateMenu( g_ContextMenu ) end )
hook.Add( "OnContextMenuClose", "WZDM.Hooks.OnContextMenuClose", WZDM.FUNC.HideMenu )

local gradientMatR, gradientMatU, gradientMatD = Material("gui/gradient"), Material("gui/gradient_up"), Material("gui/gradient_down")
function WZDM.FUNC.DrawTexturedGradientBox(x, y, w, h, direction, ...)
	local colors = {...}
	local horizontal = direction != 1
	local secSize = math.ceil( ((horizontal and w) or h)/math.ceil( #colors/2 ) )
	
	local previousPos = (horizontal and x or y)-secSize
	for k, v in pairs( colors ) do
		if( k % 2 != 0 ) then
			previousPos = previousPos+secSize
			surface.SetDrawColor( v )
			surface.DrawRect( (horizontal and previousPos or x), (horizontal and y or previousPos), (horizontal and secSize or w), (horizontal and h or secSize) )
		end
	end

	local previousGradPos = (horizontal and x or y)-secSize
	for k, v in pairs( colors ) do
		if( k % 2 == 0 ) then
			previousGradPos = previousGradPos+secSize
			surface.SetDrawColor( v )
			surface.SetMaterial( horizontal and gradientMatR or gradientMatU )
			if( horizontal ) then
				surface.DrawTexturedRectUV( (horizontal and previousGradPos or x), (horizontal and y or previousGradPos), (horizontal and secSize or w), (horizontal and h or secSize), 1, 0, 0, 1)
			else
				surface.DrawTexturedRect( (horizontal and previousGradPos or x), (horizontal and y or previousGradPos), (horizontal and secSize or w), (horizontal and h or secSize))
			end

			if( colors[k+1] ) then
				surface.SetDrawColor( v )
				surface.SetMaterial( horizontal and gradientMatR or gradientMatD )
				surface.DrawTexturedRect((horizontal and previousGradPos+secSize or x), (horizontal and y or previousGradPos+secSize), (horizontal and secSize or w), (horizontal and h or secSize))
			end
		end
	end
end

surface.CreateFont( "WZDM_FontBottom", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 5 ),
    weight = 500,
    outline = false,
} )

surface.CreateFont( "WZDM_FontBottomL", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 7 ),
    weight = 500,
    outline = false,
} )

surface.CreateFont( "WZDM_FontTooltipTop", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 10 ),
    weight = 500,
    outline = false,
} )

surface.CreateFont( "WZDM_FontTooltipBottom", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 8 ),
    weight = 500,
    outline = false,
} )

surface.CreateFont( "WZDM_FontTooltipKey", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 6 ),
    weight = 500,
    outline = false,
} )

surface.CreateFont( "WZDM_FontTooltipKeyTxt", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 7 ),
    weight = 500,
    outline = false,
} )

surface.CreateFont( "WZDM_FontTooltipBigTxt", {
    font = "Roboto",
    extended = false,
    size = ScreenScale( 13 ),
    weight = 5000,
    outline = false,
} )

net.Receive( "WZDM.Net.SendPickup", function()
    local type = net.ReadString()
    local typeInfo = net.ReadString()
    local amount = net.ReadUInt( 32 )

    if( type == "cash" ) then
        notification.AddLegacy( "You picked up " .. DarkRP.formatMoney( amount ) .. " from the ground!", 0, 3 )
    elseif( type == "ammo" ) then
        notification.AddLegacy( "You picked up x" .. string.Comma( amount ) .. " " .. (WZDM.CONFIG.AmmoNames[typeInfo] or typeInfo) .. " from the ground!", 0, 3 )
    end

    surface.PlaySound( "ui/buttonclick.wav" )
end )

net.Receive( "WZDM.Net.SendCantDropWeapon", function()
    notification.AddLegacy( "You cannot drop this weapon!", 1, 3 )
    surface.PlaySound( "ui/buttonclick.wav" )
end )