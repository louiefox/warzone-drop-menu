include('shared.lua')

function ENT:Draw()
	local type, typeInfo = self:GetType(), self:GetTypeInfo()
	if( not type or not typeInfo ) then return end

	if( not IsValid( self.clientsideModel ) ) then
		local model = ((self:GetClientModel() != "" and self:GetClientModel()) or "models/props/cs_assault/Money.mdl")
		if( type == "ammo" ) then
			model = WZDM.CONFIG.AmmoModels[typeInfo] or "models/Items/BoxMRounds.mdl"
		end

		self.clientsideModel = ClientsideModel( model )
		return
	end

	self.clientsideModel:SetPos( self:GetPos()+Vector( 0, 0, 10 ) )
	self.clientsideModel:SetAngles( Angle( 0, CurTime()*50, 0 ) )
end

function ENT:Initialize()
	WZDM.TEMP.EntTooltips[self] = true
end

function ENT:OnRemove()
	WZDM.TEMP.EntTooltips[self] = nil

	if( IsValid( self.clientsideModel ) ) then
		self.clientsideModel:Remove()
	end
end

local gradientMatU, gradientMatD = Material("gui/gradient_up"), Material("gui/gradient_down")

local cashAccent = Color( 71, 188, 255 )
local ammoAccent = Color( 175, 175, 175 )

local textOutline = Color( 0, 0, 0 )

local dollarMat = Material( "wzdm/dollar.png" )
local defaultAmmoMat = Material( "wzdm/ammo_default.png" )
local weaponMat = Material( "wzdm/weapon.png" )

local function GetClosestEnt()
	local eyeTrace = LocalPlayer():GetEyeTraceNoCursor()
	if( eyeTrace and eyeTrace.HitPos ) then
		local hitPos = eyeTrace.HitPos

		if( LocalPlayer():GetPos():DistToSqr( hitPos ) > 20000 ) then return end

		local entTable = {}
		for k, v in pairs( ents.FindInSphere( hitPos, 35 ) ) do
			if( IsValid( v ) and WZDM.TEMP.EntTooltips and WZDM.TEMP.EntTooltips[v] ) then
				table.insert( entTable, { hitPos:DistToSqr( v:GetPos() ), v } )
			end
		end

		table.sort( entTable, function(a, b) return a[1] < b[1] end )

		return (entTable[1] or {})[2]
	end
end

WZDM.TEMP.EntTooltips = WZDM.TEMP.EntTooltips or {}
hook.Add( "HUDPaint", "WZDM.Hooks.HUDPaint", function()
	local ent = GetClosestEnt()
	local clientModel = IsValid( ent ) and ent.clientsideModel

	if( IsValid( ent ) and IsValid( clientModel ) ) then
		local type = ent:GetType()
		local typeInfo = ent:GetTypeInfo()

		local pos = Vector( clientModel:GetPos().x, clientModel:GetPos().y, clientModel:GetPos().z+10 )
		local pos2d = pos:ToScreen()

		local x, y = pos2d.x, pos2d.y
		local w, h = 500, 150
		
		local topH = 35
		local mainH = h-topH

		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( x-(w/2), y-h, w, h )

		local accentBorderH = 2

		local accent = (type == "cash" and cashAccent) or ammoAccent

		surface.SetDrawColor( accent )
		surface.DrawRect( x-(w/2), y-mainH, w, accentBorderH )

		surface.SetDrawColor( accent )
		surface.DrawRect( x-(w/2), y-accentBorderH, w, accentBorderH )

		surface.SetDrawColor( accent.r, accent.g, accent.b, 50 )
		surface.SetMaterial( gradientMatD )
		surface.DrawTexturedRect( x-(w/2), y-mainH, w, mainH/2 )
		surface.SetMaterial( gradientMatU )
		surface.DrawTexturedRect( x-(w/2), y-(mainH/2), w, mainH/2 )

		local iconMat, topText, bottomText
		if( type == "cash" ) then
			iconMat = dollarMat
			topText = DarkRP.formatMoney( ent:GetAmount() )
			bottomText = "Cash"
		elseif( type == "ammo" ) then
			iconMat = WZDM.CONFIG.AmmoIcons[typeInfo] or defaultAmmoMat
			topText = WZDM.CONFIG.AmmoNames[typeInfo] or typeInfo
			bottomText = "Ammo"
		elseif( type == "weapon" ) then
			iconMat = weaponMat
			topText = (weapons.GetStored( typeInfo ) or {}).PrintName or typeInfo
			bottomText = "Weapon"
		else
			return
		end

		local iconSize = 64
		surface.SetMaterial( iconMat )
		local iconX, iconY = x-(w/2)+(mainH/2)-(iconSize/2), y-(mainH/2)-(iconSize/2)

		surface.SetDrawColor( 0, 0, 0 )
		surface.DrawTexturedRect( iconX+1, iconY, iconSize, iconSize )
		surface.DrawTexturedRect( iconX-1, iconY, iconSize, iconSize )
		surface.DrawTexturedRect( iconX, iconY+1, iconSize, iconSize )
		surface.DrawTexturedRect( iconX, iconY-1, iconSize, iconSize )

		surface.SetDrawColor( 200, 200, 200 )
		surface.DrawTexturedRect( iconX, iconY, iconSize, iconSize )

		draw.SimpleTextOutlined( topText, "WZDM_FontTooltipTop", x-(w/2)+mainH, y-(mainH/2), Color( 255, 255, 255 ), 0, TEXT_ALIGN_BOTTOM, 1, textOutline )
		draw.SimpleTextOutlined( bottomText, "WZDM_FontTooltipBottom", x-(w/2)+mainH, y-(mainH/2), Color( 200, 200, 200 ), 0, 0, 1, textOutline )

		if( type == "ammo" ) then
			draw.SimpleTextOutlined( "x" .. string.Comma( ent:GetAmount() ), "WZDM_FontTooltipBigTxt", x+(w/2)-(mainH/2), y-(mainH/2), Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, textOutline )
		end

		-- Top Bar --
		local keyH = topH-12
		draw.RoundedBox( 8, x-(w/2)+10, y-h+(topH/2)-(keyH/2), keyH, keyH, Color( 255, 255, 255 ) )

		draw.SimpleText( string.upper( input.LookupBinding( "+use" ) ), "WZDM_FontTooltipKey", x-(w/2)+10+(keyH/2)-1, y-h+(topH/2), Color( 0, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleTextOutlined( "Take", "WZDM_FontTooltipKeyTxt", x-(w/2)+10+keyH+10, y-h+(topH/2), Color( 200, 200, 200 ), 0, TEXT_ALIGN_CENTER, 1, textOutline )
	end
end )

hook.Add( "KeyPress", "WZDM.Hooks.KeyPress", function( ply, key )
	if( key == IN_USE ) then
		local ent = GetClosestEnt()
		if( not IsValid( ent ) ) then return end

		if( CurTime() < (WZDM_PICKUP_COOLDOWN or 0) ) then return end
		WZDM_PICKUP_COOLDOWN = CurTime()+0.2

		net.Start( "WZDM.Net.RequestPickup" )
			net.WriteEntity( ent )
		net.SendToServer()
	end
end )