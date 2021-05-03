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

hook.Add( "OnContextMenuOpen", "WZDM.Hooks.OnContextMenuOpen", function() 
    if( WZDM.CONFIG.MenuKey != "context" ) then return end
    WZDM.FUNC.CreateMenu( g_ContextMenu ) 
end )

hook.Add( "OnContextMenuClose", "WZDM.Hooks.OnContextMenuClose", function()
    if( WZDM.CONFIG.MenuKey != "context" ) then return end
    WZDM.FUNC.HideMenu()
end )

hook.Add( "PlayerButtonDown", "WZDM.Hooks.PlayerButtonDown", function( ply, button ) 
    if( WZDM.CONFIG.MenuKey != button or IsValid( WARZONE_DROP_MENU ) ) then return end
    WZDM.FUNC.CreateMenu() 
    gui.EnableScreenClicker( true )
end )

hook.Add( "PlayerButtonUp", "WZDM.Hooks.PlayerButtonUp", function( ply, button ) 
    if( WZDM.CONFIG.MenuKey != button or not IsValid( WARZONE_DROP_MENU ) ) then return end
    WZDM.FUNC.HideMenu()
    gui.EnableScreenClicker( false )
end )

local function CreateFonts()
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
end
CreateFonts()

hook.Add( "OnScreenSizeChanged", "WZDM.Hooks.OnScreenSizeChanged", CreateFonts )

net.Receive( "WZDM.Net.SendPickup", function()
    local type = net.ReadString()
    local typeInfo = net.ReadString()
    local amount = net.ReadUInt( 32 )

    if( type == "cash" and WZDM.FUNC.GetCurrency() ) then
        notification.AddLegacy( "You picked up " .. WZDM.FUNC.GetCurrency().Format( amount ) .. " from the ground!", 0, 3 )
    elseif( type == "ammo" ) then
        notification.AddLegacy( "You picked up x" .. string.Comma( amount ) .. " " .. (WZDM.CONFIG.AmmoNames[typeInfo] or typeInfo) .. " from the ground!", 0, 3 )
    end

    surface.PlaySound( "ui/buttonclick.wav" )
end )

net.Receive( "WZDM.Net.SendCantDropWeapon", function()
    notification.AddLegacy( "You cannot drop this weapon!", 1, 3 )
    surface.PlaySound( "ui/buttonclick.wav" )
end )

function WZDM.FUNC.ScreenScale( num )
    return (ScrW()/2560)*num
end