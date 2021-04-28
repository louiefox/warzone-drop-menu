AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "" )
	self:DrawShadow( false )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if( self:GetAmount() <= 0 ) then
		self:SetAmount( WZDM.CONFIG.MoneyDropAmount )
	end

	local type, typeInfo = self:GetType(), self:GetTypeInfo()
	if( type == "weapon" ) then return end

	for k, v in ipairs( ents.FindInSphere( self:GetPos(), 15 ) ) do
		if( v:GetClass() != "wzdm_dropent" or v == self ) then continue end

		local partnerType = v:GetType()
		if( type != partnerType ) then continue end

		if( type == "ammo" and typeInfo != v:GetTypeInfo() ) then continue end

		v:SetAmount( v:GetAmount()+self:GetAmount() )
		self:Remove()
		break
	end
end