WZDM = {
    FUNC = {},
    CONFIG = {}
}

WZDM.TEMP = WZDM.TEMP or {}

WZDM.Currencies = {
    ["DarkRP"] = {
        Format = function( val )
            return DarkRP.formatMoney( val )
        end,
        Get = function( ply )
            return ply:getDarkRPVar( "money" )
        end,
        Add = function( ply, amount )
            ply:addMoney( amount )
        end,
        Take = function( ply, amount )
            ply:addMoney( -amount )
        end
    },
    ["nMoney2"] = {
        Format = function( val )
            return "$" .. string.Comma( val )
        end,
        Get = function( ply )
            return tonumber( ply:GetNWString( "WalletMoney" ) ) or 0
        end,
        Add = function( ply, amount )
            ply:SetNWString( "WalletMoney", tonumber( ply:GetNWString( "WalletMoney" ) )+amount )
        end,
        Take = function( ply, amount )
            ply:SetNWString( "WalletMoney", tonumber( ply:GetNWString( "WalletMoney" ) )-amount )
        end
    }
}

function WZDM.FUNC.GetCurrency()
    if( DarkRP ) then return WZDM.Currencies["DarkRP"] end
    if( NMONEY2_MAXVALUE ) then return WZDM.Currencies["nMoney2"] end
end

AddCSLuaFile( "wdm_config.lua" )
include( "wdm_config.lua" )

AddCSLuaFile( "wdm_client.lua" )

if( CLIENT ) then
    include( "wdm_client.lua" )
elseif( SERVER ) then
    include( "wdm_server.lua" )
end