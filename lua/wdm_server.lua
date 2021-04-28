util.AddNetworkString( "WZDM.Net.SendPickup" )
util.AddNetworkString( "WZDM.Net.RequestPickup" )
net.Receive( "WZDM.Net.RequestPickup", function( len, ply )
    if( CurTime() < (ply.WZDM_PICKUP_COOLDOWN or 0) ) then return end
    ply.WZDM_PICKUP_COOLDOWN = CurTime()+0.2

    local ent = net.ReadEntity()
    if( not IsValid( ent ) or ent:GetClass() != "wzdm_dropent" ) then return end

	if( ply:GetPos():DistToSqr( ent:GetPos() ) > 20000 ) then return end

    local type, typeInfo, amount, ammo = ent:GetType(), ent:GetTypeInfo(), ent:GetAmount(), ent.ammo
    ent:Remove()

    if( type == "cash" ) then
        ply:addMoney( amount )
    elseif( type == "ammo" ) then
        ply:GiveAmmo( amount, typeInfo )
    elseif( type == "weapon" ) then
        local weapon = ply:Give( typeInfo, true )
        if( ammo ) then
            weapon:SetClip1( ammo )
        end
 
        ply:SelectWeapon( typeInfo )
    end

    net.Start( "WZDM.Net.SendPickup" )
        net.WriteString( type )
        net.WriteString( typeInfo )
        net.WriteUInt( amount, 32 )
    net.Send( ply )
end )

util.AddNetworkString( "WZDM.Net.RequestDropMoney" )
net.Receive( "WZDM.Net.RequestDropMoney", function( len, ply )
    if( CurTime() < (ply.WZDM_DROP_COOLDOWN or 0) ) then return end
    ply.WZDM_DROP_COOLDOWN = CurTime()+0.1

    local rightClick = net.ReadBool()

    local dropAmount = (rightClick and WZDM.CONFIG.MoneyDropAllAmount) or WZDM.CONFIG.MoneyDropAmount
    dropAmount = math.Clamp( dropAmount, 0, ply:getDarkRPVar( "money" ) )

    if( dropAmount <= 0 ) then return end

    ply:addMoney( -dropAmount )

    local ent = ents.Create( "wzdm_dropent" )
    ent:SetPos( ply:GetPos()+(ply:GetForward()*45) )
    ent:SetType( "cash" )
    ent:SetAmount( dropAmount )
    ent:Spawn()
end )

util.AddNetworkString( "WZDM.Net.RequestDropAmmo" )
net.Receive( "WZDM.Net.RequestDropAmmo", function( len, ply )
    if( CurTime() < (ply.WZDM_DROP_COOLDOWN or 0) ) then return end
    ply.WZDM_DROP_COOLDOWN = CurTime()+0.1

    local ammoType = net.ReadString()
    if( not ammoType ) then return end

    local ammoCount = ply:GetAmmoCount( ammoType )
    if( not ammoCount or ammoCount <= 0 ) then return end

    local rightClick = net.ReadBool()

    local dropAmount = (rightClick and ammoCount) or WZDM.CONFIG.AmmoDropAmount
    dropAmount = math.Clamp( dropAmount, 0, ammoCount )

    if( dropAmount <= 0 ) then return end

    ply:RemoveAmmo( dropAmount, ammoType )

    local ent = ents.Create( "wzdm_dropent" )
    ent:SetPos( ply:GetPos()+(ply:GetForward()*45) )
    ent:SetType( "ammo" )
    ent:SetTypeInfo( ammoType )
    ent:SetAmount( dropAmount )
    ent:Spawn()
end )

util.AddNetworkString( "WZDM.Net.SendCantDropWeapon" )
util.AddNetworkString( "WZDM.Net.RequestDropWeapon" )
net.Receive( "WZDM.Net.RequestDropWeapon", function( len, ply )
    if( CurTime() < (ply.WZDM_DROP_COOLDOWN or 0) ) then return end
    ply.WZDM_DROP_COOLDOWN = CurTime()+0.1

    local activeWeapon = ply:GetActiveWeapon()
    if( not IsValid( activeWeapon ) ) then return end

    local weaponClass, worldModel, clip1 = activeWeapon:GetClass(), activeWeapon:GetWeaponWorldModel(), activeWeapon:Clip1()
    if( worldModel == "" or not hook.Run( "canDropWeapon", ply, activeWeapon ) ) then
        net.Start( "WZDM.Net.SendCantDropWeapon" )
        net.Send( ply )
        return
    end

    ply:StripWeapon( weaponClass )

    local ent = ents.Create( "wzdm_dropent" )
    ent:SetPos( ply:GetPos()+(ply:GetForward()*45) )
    ent:SetType( "weapon" )
    ent:SetTypeInfo( weaponClass )
    ent:SetClientModel( worldModel )
    ent.ammo = clip1
    ent:Spawn()
end )