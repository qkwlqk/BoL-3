local Version = "1.004"
local AutoUpdate = true

function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>HTTF Smite:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

class "HTTF_Smite"

---------------------------------------------------------------------------------

local Host = "raw.github.com"

local ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

local ScriptPath = "/BolHTTF/BoL/master/HTTF/HTTF Smite.lua".."?rand="..math.random(1,10000)
local UpdateURL = "https://"..Host..ScriptPath

local VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HTTF Smite.version".."?rand="..math.random(1,10000)
local VersionData = tonumber(GetWebResult(Host, VersionPath))

if AutoUpdate then

  if VersionData then
  
    ServerVersion = type(VersionData) == "number" and VersionData or nil
    
    if ServerVersion then
    
      if tonumber(Version) < ServerVersion then
        ScriptMsg("New version available: v"..VersionData)
        ScriptMsg("Updating, please don't press F9.")
        DelayAction(function() DownloadFile(UpdateURL, ScriptFilePath, function () ScriptMsg("Successfully updated.: v"..Version.." => v"..VersionData..", Press F9 twice to load the updated version.") end) end, 3)
      else
        ScriptMsg("You've got the latest version: v"..Version)
      end
      
    end
    
  else
    ScriptMsg("Error downloading version info.")
  end
  
else
  ScriptMsg("AutoUpdate: false")
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnLoad()

  HTTF_Smite = HTTF_Smite()
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HTTF_Smite:__init()

  self:Variables()
  self:SmiteMenu()
  AddTickCallback(function() self:Tick() end)
  AddDrawCallback(function() self:Draw() end)
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HTTF_Smite:Variables()

  if myHero:GetSpellData(SUMMONER_1).name:find("smite") then
    self.Smite = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("smite") then
    self.Smite = SUMMONER_2
  end
  
  self.S = {range = 760, ready}
  
  self.Items =
  {
  ["Stalker"] = {id=3706, slot = nil, ready},
  ["StalkerW"] = {id=3707, slot = nil},
  ["StalkerM"] = {id=3708, slot = nil},
  ["StalkerJ"] = {id=3709, slot = nil},
  ["StalkerD"] = {id=3710, slot = nil}
  }
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then
    S5SR = true
  elseif GetGame().map.index == 4 then
    TT = true
  end
  
  if S5SR then
    self.FocusJungleNames =
    {
    "SRU_Baron12.1.1",
    "SRU_Blue1.1.1",
    "SRU_Blue7.1.1",
    "Sru_Crab15.1.1",
    "Sru_Crab16.1.1",
    "SRU_Dragon6.1.1",
    "SRU_Gromp13.1.1",
    "SRU_Gromp14.1.1",
    "SRU_Krug5.1.2",
    "SRU_Krug11.1.2",
    "SRU_Murkwolf2.1.1",
    "SRU_Murkwolf8.1.1",
    "SRU_Razorbeak3.1.1",
    "SRU_Razorbeak9.1.1",
    "SRU_Red4.1.1",
    "SRU_Red10.1.1"
    }
    self.JungleMobNames =
    {
    "SRU_BlueMini1.1.2",
    "SRU_BlueMini7.1.2",
    "SRU_BlueMini21.1.3",
    "SRU_BlueMini27.1.3",
    "SRU_KrugMini5.1.1",
    "SRU_KrugMini11.1.1",
    "SRU_MurkwolfMini2.1.2",
    "SRU_MurkwolfMini2.1.3",
    "SRU_MurkwolfMini8.1.2",
    "SRU_MurkwolfMini8.1.3",
    "SRU_RazorbeakMini3.1.2",
    "SRU_RazorbeakMini3.1.3",
    "SRU_RazorbeakMini3.1.4",
    "SRU_RazorbeakMini9.1.2",
    "SRU_RazorbeakMini9.1.3",
    "SRU_RazorbeakMini9.1.4",
    "SRU_RedMini4.1.2",
    "SRU_RedMini4.1.3",
    "SRU_RedMini10.1.2",
    "SRU_RedMini10.1.3"
    }
  elseif TT then
    self.FocusJungleNames =
    {
    "TT_NWraith1.1.1",
    "TT_NGolem2.1.1",
    "TT_NWolf3.1.1",
    "TT_NWraith4.1.1",
    "TT_NGolem5.1.1",
    "TT_NWolf6.1.1",
    "TT_Spiderboss8.1.1"
    }   
    self.JungleMobNames =
    {
    "TT_NWraith21.1.2",
    "TT_NWraith21.1.3",
    "TT_NGolem22.1.2",
    "TT_NWolf23.1.2",
    "TT_NWolf23.1.3",
    "TT_NWraith24.1.2",
    "TT_NWraith24.1.3",
    "TT_NGolem25.1.1",
    "TT_NWolf26.1.2",
    "TT_NWolf26.1.3"
    }
  else
    self.FocusJungleNames =
    {
    }   
    self.JungleMobNames =
    {
    }
  end
  
  self.EnemyHeroes = GetEnemyHeroes()
  self.JungleMobs = minionManager(MINION_JUNGLE, self.S.range, myHero, MINION_SORT_MAXHEALTH_DEC)
  
end

---------------------------------------------------------------------------------

function HTTF_Smite:SmiteMenu()

  if self.Smite == nil then
    DelayAction(function() print("\n\n\n\n")
    ScriptMsg("You don't have Smite\n\n\n") end, 2)
    return
  end
  
  self.Menu = scriptConfig("HTTF Smite", "HTTF Smite")
  
  self.Menu:addSubMenu("Jungle Steal Settings", "JSteal")
    self.Menu.JSteal:addParam("On", "Use Smite", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    self.Menu.JSteal:addParam("On2", "Use Smite Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    
  self.Menu:addSubMenu("KillSteal Settings", "KillSteal")
    self.Menu.KillSteal:addParam("On", "Use Stalker's Blade for KillSteal", SCRIPT_PARAM_ONOFF, true)
    
  if VIP_USER then
  self.Menu:addSubMenu("Misc Settings", "Misc")
    self.Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, true)
  end
  
  self.Menu:addSubMenu("Draw Settings", "Draw")
  
    self.Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      self.Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    self.Menu.Draw:addParam("S", "Draw Smite range", SCRIPT_PARAM_ONOFF, true)
      self.Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    self.Menu.Draw:addParam("Path", "Draw Move Path", SCRIPT_PARAM_ONOFF, false)
    
  self.Menu.JSteal.On = false
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HTTF_Smite:Tick()

  if myHero.dead or self.Smite == nil then
    return
  end
  
  self:Checks()
  
  if not self.S.ready then
    return
  end
  
  if self.Menu.JSteal.On or self.Menu.JSteal.On2 then
    self:JSteal()
  end
  
  self:JstealAlways()
  
  if self.Menu.KillSteal.On then
    self:KillSteal()
  end
  
end

---------------------------------------------------------------------------------

function HTTF_Smite:Checks()

  self.S.ready = myHero:CanUseSpell(self.Smite) == READY
  
  for _, item in pairs(self.Items) do
    item.slot = GetInventorySlotItem(item.id)
  end
  
  self.Items["Stalker"].ready = (self.Items["Stalker"].slot or self.Items["StalkerW"].slot or self.Items["StalkerM"].slot or self.Items["StalkerJ"].slot or self.Items["StalkerD"].slot) and myHero:CanUseSpell(self.Smite) == READY
  
  self.JungleMobs:update()
  
end

---------------------------------------------------------------------------------

function HTTF_Smite:JSteal()

  if self.S.ready then
  
    for i, junglemob in pairs(self.JungleMobs.objects) do
    
      local SJunglemobDmg = self:GetDmg("SMITE", junglemob)
      
      for j = 1, #self.FocusJungleNames do
      
        if junglemob.name == self.FocusJungleNames[j] and SJunglemobDmg >= junglemob.health and ValidTarget(junglemob, self.S.range) then
          self:CastS(junglemob)
          return
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function HTTF_Smite:JstealAlways()

  if self.S.ready then
  
    for i, junglemob in pairs(self.JungleMobs.objects) do
    
      local SJunglemobDmg = self:GetDmg("SMITE", junglemob)
      
      for j = 1, #self.FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and SJunglemobDmg >= junglemob.health and ValidTarget(junglemob, self.S.range) then
          self:CastS(junglemob)
          return
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function HTTF_Smite:KillSteal()

  for i, enemy in ipairs(self.EnemyHeroes) do
  
    local SBTargetDmg = self:GetDmg("STALKER", enemy)
    
    if self.Items["Stalker"].ready and SBTargetDmg >= enemy.health and ValidTarget(enemy, self.S.range) then
      self:CastS(enemy)
      return
    end
    
  end
  
end

---------------------------------------------------------------------------------

function HTTF_Smite:GetDmg(spell, enemy)

  self.TrueDmg = 0
  
  if enemy == nil then
    return self.TrueDmg
  end
  
  local Level = myHero.level
  
  if spell == "SMITE" then
  
    if Level <= 4 then
    
      self.TrueDmg = 370+20*Level
      
      return self.TrueDmg
    elseif Level <= 9 then
    
      self.TrueDmg = 330+30*Level
      
      return self.TrueDmg
    elseif Level <= 14 then
    
      self.TrueDmg = 240+40*Level
      
      return self.TrueDmg
    else
    
      self.TrueDmg = 100+50*Level
      
      return self.TrueDmg
    end
    
  elseif spell == "STALKER" then
  
    self.TrueDmg = 20+8*Level
    
    return self.TrueDmg
  end
  
  return self.TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HTTF_Smite:CastS(enemy)

  if VIP_USER and self.Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = self.Smite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(self.Smite, enemy)
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HTTF_Smite:Draw()

  if self.Smite == nil then
    return
  end
  
  if not self.Menu.Draw.On or myHero.dead then
    return
  end
  
  if self.Menu.Draw.S and self.S.ready and (self.Menu.JSteal.On or self.Menu.JSteal.On2) then
    DrawCircle(myHero.x, myHero.y, myHero.z, self.S.range, ARGB(0xFF, 0xFF, 0x14, 0x93))
  end
  
  if self.Menu.Draw.Path then
  
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
      end
      
    end
    
    for i, enemy in ipairs(self.EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
        end
        
      end
      
    end
    
  end
  
end
