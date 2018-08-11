include("shared.lua")

function ENT:Initialize()
  self:Setup({
    viewdistance = 950,
    viewheight = 200,
    cockpit = {
      path = "models/awing/new_awing_cockpit.mdl"
    },
    enginesound = "vehicles/rz2_engine_loop.wav"
  })

  self:SetupDefaults()

  -- Adding engine effects
  self:AddEngine(Vector(-105, 42, 40), {
    startsize = 18,
    endsize = 10,
    lifetime = 2.7,
    color = Color(255, 204, 102),
    sprite = "sprites/orangecore1"
  })

  self:AddEngine(Vector(-105, -42, 40), {
    startsize = 18,
    endsize = 10,
    lifetime = 2.7,
    color = Color(255, 204, 102),
    sprite = "sprites/orangecore1"
  })

  self:AddEvent("OnCritical", function()
    if LocalPlayer():GetNWEntity("Ship") ~= self then return end
    surface.PlaySound("atat/atat_shoot.wav")
  end)

  -- Initialize the base, do not remove.
  self.BaseClass.Initialize(self)
end
