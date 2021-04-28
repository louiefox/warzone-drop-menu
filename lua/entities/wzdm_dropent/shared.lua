ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Money"
ENT.Category		= "Warzone Drop Menu"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Amount" )
    self:NetworkVar( "String", 0, "Type" )
    self:NetworkVar( "String", 1, "TypeInfo" )
    self:NetworkVar( "String", 2, "ClientModel" )
end