properties.Add("allegiance", {
  MenuLabel = "Allegiance",
  Order = 999,
  MenuIcon = "icon16/flag_blue.png",
  Filter = function(self, ent, ply)
    if (not IsValid(ent)) then return false end
    if (ent:IsPlayer()) then return false end
    if (not ent.IsSWVRVehicle) then return false end
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then return false end

    return ent.IsSWVRVehicle
  end,
  MenuOpen = function(self, option, ent, tr)
    local submenu = option:AddSubMenu()

    for _, faction in pairs(SWVR.Sides) do
      for __, allegiance in pairs(faction) do
        local opt = submenu:AddOption(allegiance, function()
          self:SetAllegiance(ent, allegiance)
        end)

        if (ent:GetAllegiance() == allegiance) then
          opt:SetChecked(true)
        end
      end
    end
  end,
  Action = function(self, ent) end,
  SetAllegiance = function(self, ent, allegiance)
    self:MsgStart()
    net.WriteEntity(ent)
    net.WriteString(allegiance)
    self:MsgEnd()
  end,
  Receive = function(self, length, player)
    local ent = net.ReadEntity()
    local allegiance = net.ReadString()
    if (not self:Filter(ent, player)) then return end
    ent:SetAllegiance(allegiance)
  end
})

properties.Add("bang", {
  MenuLabel = "Destroy",
  Order = 999,
  MenuIcon = "icon16/bomb.png",
  Filter = function(self, ent, ply)
    if (not IsValid(ent)) then return false end
    if (ent:IsPlayer()) then return false end
    if (not ent.IsSWVRVehicle) then return false end
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then return false end

    return ent.IsSWVRVehicle
  end,
  Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
  Receive = function(self, length, player)
    local ent = net.ReadEntity()
    if (not self:Filter(ent, player)) then return end
    ent:Bang()
  end
})

properties.Add("repair", {
  MenuLabel = "Repair",
  Order = 999,
  MenuIcon = "icon16/bullet_wrench.png",
  Filter = function(self, ent, ply)
    if (not IsValid(ent)) then return false end
    if (ent:IsPlayer()) then return false end
    if (not ent.IsSWVRVehicle) then return false end
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then return false end

    return ent.IsSWVRVehicle
  end,
  Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
  Receive = function(self, length, player)
    local ent = net.ReadEntity()
    if (not self:Filter(ent, player)) then return end
    ent:SetCurHealth(ent:GetStartHealth())
    ent:SetShieldHealth(ent:GetStartShieldHealth())
  end
})

cleanup.Register("swvehicles")

if SERVER then
  CreateConVar("swvr_health_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Damage Enabled")
  CreateConVar("swvr_health_multiplier", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Health Multiplier")
  CreateConVar("swvr_shields_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Shields Enabled")
  CreateConVar("swvr_shields_multiplier", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Shield Multiplier")
  CreateConVar("swvr_weapons_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Weapons Enabled")
  CreateConVar("swvr_weapons_multiplier", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Weapon Multiplier")
  CreateConVar("swvr_collsions_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Collisions Enabled")
  CreateConVar("swvr_collisions_multiplier", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Collision Multiplier")
  CreateConVar("swvr_disable_use", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Disable players from entering ships.")
end

if CLIENT then
  CreateClientConVar("swvr_shields_draw", "1", true, false, "Draw shield effects.")
  CreateClientConVar("swvr_engines_draw", "1", true, false, "Draw engine effects.")

  language.Add("Cleanup_swvehicles", "Star Wars Vehicles")

  local SERVER_DEFAULTS = {
    swvr_disable_use = "0",
    swvr_health_enabled = "1",
    swvr_health_multiplier = "1.00",
    swvr_shields_enabled = "1",
    swvr_shields_multiplier = "1.00",
    swvr_weapons_enabled = "1",
    swvr_weapons_multiplier = "1.00",
    swvr_collsion_enabled = "1",
    swvr_collision_multiplier = "1.00"
  }

  local function BuildServerSettings(pnl)
    pnl:AddControl("ComboBox", {
      MenuButton = 1,
      Folder = "util_swvr_sv",
      Options = {
        ["#preset.default"] = SERVER_DEFAULTS
      },
      CVars = table.GetKeys(SERVER_DEFAULTS)
    })

    pnl:CheckBox("Damage Enabled", "swvr_health_enabled")
    pnl:NumSlider("Health Multiplier", "swvr_health_multiplier", "0.0", "10.0", 2)
    pnl:CheckBox("Shields Enabled", "swvr_shields_enabled")
    pnl:NumSlider("Shield Multiplier", "swvr_shields_multiplier", "0.0", "10.0", 2)
    pnl:CheckBox("Weapons Enabled", "swvr_weapons_enabled")
    pnl:NumSlider("Weapon Damage Multiplier", "swvr_weapons_multiplier", "0.0", "10.0", 2)
    pnl:CheckBox("Collisions Enabled", "swvr_collisions_enabled")
    pnl:NumSlider("Collision Multiplier", "swvr_collisions_multiplier", "0.0", "2.0", 2)
    pnl:CheckBox("Disable Entering Ships", "swvr_disable_use")

    return pnl
  end

  local CLIENT_DEFAULTS = {
    swvr_shields_draw = "1",
    swvr_engines_draw = "1"
  }

  local function BuildClientSettings(pnl)
    pnl:AddControl("ComboBox", {
      MenuButton = 1,
      Folder = "util_swvr_cl",
      Options = {
        ["#preset.default"] = CLIENT_DEFAULTS
      },
      CVars = table.GetKeys(CLIENT_DEFAULTS)
    })

    return pnl
  end

  hook.Add("PopulateToolMenu", "SWVR.PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "Star Wars Vehicles", "SWVRSVSettings", "Server Settings", "", "", BuildServerSettings)
    spawnmenu.AddToolMenuOption("Utilities", "Star Wars Vehicles", "SWVRCLSettings", "Client Settings", "", "", BuildClientSettings)
  end)

  hook.Add("AddToolMenuCategories", "SWVR.AddToolMenuCategories", function()
    spawnmenu.AddToolCategory("Utilities", "Star Wars Vehicles", "Star Wars Vehicles")
  end)

  spawnmenu.AddCreationTab("Star Wars Vehicles: Redux", function()
    local ctrl = vgui.Create("SpawnmenuContentPanel")
    ctrl:CallPopulateHook("SWVRVehiclesTab")

    return ctrl
  end, "icons16/other.png", 60)

  spawnmenu.AddContentType("swvrvehicle", function(container, obj)
    if (not obj.material) then return end
    if (not obj.nicename) then return end
    if (not obj.spawnname) then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("entity")
    icon:SetSpawnName(obj.spawnname)
    icon:SetName(obj.nicename)
    icon:SetMaterial(obj.material)
    icon:SetAdminOnly(obj.admin)
    icon:SetColor(Color(205, 92, 92, 255))

    icon.DoClick = function()
      RunConsoleCommand("gm_spawnsent", obj.spawnname)
      surface.PlaySound("ui/buttonclickrelease.wav")
    end

    icon.OpenMenu = function()
      local menu = DermaMenu()

      menu:AddOption("Copy to Clipboard", function()
        SetClipboardText(obj.spawnname)
      end)

      menu:AddOption("Spawn Using Toolgun", function()
        RunConsoleCommand("gmod_tool", "creator")
        RunConsoleCommand("creator_type", "0")
        RunConsoleCommand("creator_name", obj.spawnname)
      end)

      menu:Open()
    end

    if (IsValid(container)) then
      container:Add(icon)
    end

    return icon
  end)

  spawnmenu.AddContentType("swvrweapon", function(container, obj)
    if (not obj.material) then return end
    if (not obj.nicename) then return end
    if (not obj.spawnname) then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("weapon")
    icon:SetSpawnName(obj.spawnname)
    icon:SetName(obj.nicename)
    icon:SetMaterial(obj.material)
    icon:SetAdminOnly(obj.admin)
    icon:SetColor(Color(135, 206, 250, 255))

    icon.DoClick = function()
      RunConsoleCommand("gm_giveswep", obj.spawnname)
      surface.PlaySound("ui/buttonclickrelease.wav")
    end

    icon.DoMiddleClick = function()
      RunConsoleCommand("gm_spawnswep", obj.spawnname)
      surface.PlaySound("ui/buttonclickrelease.wav")
    end

    icon.OpenMenu = function()
      local menu = DermaMenu()

      menu:AddOption("Copy to Clipboard", function()
        SetClipboardText(obj.spawnname)
      end)

      menu:AddOption("Spawn Using Toolgun", function()
        RunConsoleCommand("gmod_tool", "creator")
        RunConsoleCommand("creator_type", "3")
        RunConsoleCommand("creator_name", obj.spawnname)
      end)

      menu:Open()
    end

    if (IsValid(container)) then
      container:Add(icon)
    end

    return icon
  end)

  hook.Add("SWVRVehiclesTab", "AddEntityContent", function(pnlContent, tree, node)
    local Categorised = { }
    local SpawnableEntities = table.Merge({ }, list.Get("SWVRVehicles.Weapons") or { }) --[[list.Get("SWVRVehicles") or ]]

    for k, v in pairs(scripted_ents.GetList()) do
      if v.t.Base == "swvr_base" then
        table.insert(SpawnableEntities, v.t)
      end
    end

    if (SpawnableEntities) then
      for k, v in pairs(SpawnableEntities) do
        v.SpawnName = k
        v.Category = v.Category or "Other"
        Categorised[v.Category] = Categorised[v.Category] or { }
        table.insert(Categorised[v.Category], v)
      end
    end

    for CategoryName, v in SortedPairs(Categorised) do
      local child = tree:AddNode(CategoryName, "icon16/" .. string.lower(CategoryName) .. ".png")
      if (child.PropPanel) then return end
      child.PropPanel = vgui.Create("ContentContainer", pnlContent)
      child.PropPanel:SetVisible(false)
      child.PropPanel:SetTriggerSpawnlistChange(false)
      local Types = { }

      for k, ent in pairs(v) do
        ent.Class = ent.Class or "Other"
        Types[ent.Class] = Types[ent.Class] or { }
        table.insert(Types[ent.Class], ent)
      end

      for Type, tbl in SortedPairs(Types) do
        local path = "icon16/" .. string.lower(CategoryName) .. "_" .. string.lower(Type) .. ".png"
        path = file.Exists("materials/" .. path, "GAME") and path or "icon16/" .. string.lower(CategoryName) .. ".png"
        local typeNode = child:AddNode(Type, path)
        local panel = vgui.Create("ContentContainer", pnlContent)
        panel:SetVisible(false)
        local header = vgui.Create("ContentHeader", child.PropPanel)
        header:SetText(Type)
        child.PropPanel:Add(header)

        for k, ent in SortedPairsByMemberValue(tbl, "PrintName") do
          local data = {
            nicename = ent.PrintName or ent.ClassName,
            spawnname = ent.ClassName,
            material = "entities/" .. ent.ClassName .. ".png",
            admin = ent.AdminOnly or false,
            author = ent.Author,
            info = ent.Instructions
          }

          spawnmenu.CreateContentIcon(ent.Category ~= "Weapons" and "swvrvehicle" or "swvrweapon", panel, data)
          spawnmenu.CreateContentIcon(ent.Category ~= "Weapons" and "swvrvehicle" or "swvrweapon", child.PropPanel, data)
        end

        typeNode.DoClick = function()
          pnlContent:SwitchPanel(panel)
        end
      end

      function child:DoClick()
        pnlContent:SwitchPanel(self.PropPanel)
      end

      child:SetExpanded(true)
    end

    local FirstNode = tree:Root():GetChildNode(0)

    if (IsValid(FirstNode)) then
      FirstNode:InternalDoClick()
    end
  end)
end