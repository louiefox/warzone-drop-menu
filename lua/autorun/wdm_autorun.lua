WZDM = {
    FUNC = {},
    CONFIG = {}
}

WZDM.TEMP = WZDM.TEMP or {}

AddCSLuaFile( "wdm_config.lua" )
include( "wdm_config.lua" )

AddCSLuaFile( "wdm_client.lua" )

if( CLIENT ) then
    include( "wdm_client.lua" )
elseif( SERVER ) then
    include( "wdm_server.lua" )
end