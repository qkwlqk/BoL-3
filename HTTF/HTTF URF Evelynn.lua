local Version = "1.0"
local AutoUpdate = true

if myHero.charName ~= "Evelynn" then
  return
end

require 'HPrediction'

function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>HTTF URF Evelynn:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

---------------------------------------------------------------------------------

local Host = "raw.github.com"

local ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

local ScriptPath = "/BolHTTF/BoL/master/HTTF/HTTF URF Evelynn.lua".."?rand="..math.random(1,10000)
local UpdateURL = "https://"..Host..ScriptPath

local VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HTTF URF Evelynn.version".."?rand="..math.random(1,10000)
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

  Variables()
  EvelynnMenu()
  
end

function Variables()

  HPred = HPrediction()
  
  Spell_R.addunitminBBox['Evelynn'] = false
  Spell_R.delay['Evelynn'] = 0.25
  Spell_R.radius['Evelynn'] = 500
  Spell_R.range['Evelynn'] = 900
  Spell_R.type['Evelynn'] = "PromptCircle"
  
  IsRecall = false
  
  if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
    Ignite = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
    Ignite = SUMMONER_2
  end
  
  if myHero:GetSpellData(SUMMONER_1).name:find("smite") then
    Smite = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("smite") then
    Smite = SUMMONER_2
  end
  
  Q = {range = 600, ready}
  W = {ready}
  E = {range = 450, ready}
  R = {range = 900, radius = 500, ready}
  I = {range = 600, ready}
  S = {range = 760, ready}
  
  TrueRange = myHero.range+GetDistance(myHero.minBBox, myHero)/2
  
  QTargetRange = Q.range
  ETargetRange = E.range
  RTargetRange = R.range+R.radius+100
  
  QMinionRange = Q.range
  QJunglemobRange = Q.range
  
  Items =
  {
  ["BC"] = {id=3144, range = 450, slot = nil, ready},
  ["BRK"] = {id=3153, range = 450, slot = nil, ready},
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
    FocusJungleNames =
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
  JungleMobNames =
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
    FocusJungleNames =
    {
    "TT_NWraith1.1.1",
    "TT_NGolem2.1.1",
    "TT_NWolf3.1.1",
    "TT_NWraith4.1.1",
    "TT_NGolem5.1.1",
    "TT_NWolf6.1.1",
    "TT_Spiderboss8.1.1"
    }   
    JungleMobNames =
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
    FocusJungleNames =
    {
    }   
    JungleMobNames =
    {
    }
  end
  
  QTS = TargetSelector(TARGET_LESS_CAST, QTargetRange, DAMAGE_MAGIC, false)
  ETS = TargetSelector(TARGET_LESS_CAST, ETargetRange, DAMAGE_PHYSICAL, false)
  RTS = TargetSelector(TARGET_LESS_CAST, RTargetRange, DAMAGE_MAGIC, false)
  STS = TargetSelector(TARGET_LOW_HP, S.range)
  
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, QMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, QJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  
end

---------------------------------------------------------------------------------

function EvelynnMenu()

  Menu = scriptConfig("HTTF URF Evelynn", "HTTF URF Evelynn")
  
  Menu:addSubMenu("HitChance Settings", "HitChance")
  
    Menu.HitChance:addSubMenu("Combo", "Combo")
      Menu.HitChance.Combo:addParam("R", "R HitChacne (Default value = 3)", SCRIPT_PARAM_SLICE, 3, 1, 3, 2)
      
  Menu:addSubMenu("Combo Settings", "Combo")
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R3", "Use R Min Count (Default = 3)", SCRIPT_PARAM_SLICE, 3, 2, 5, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Item", "Use Items", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("BRK", "Use BRK if my own HP < x%", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
      
  Menu:addSubMenu("Clear Settings", "Clear")
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
      
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
      
  Menu:addSubMenu("Harass Settings", "Harass")
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
    
  Menu:addSubMenu("LastHit Settings", "LastHit")
    Menu.LastHit:addParam("On", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    
  Menu:addSubMenu("Jungle Steal Settings", "JSteal")
    Menu.JSteal:addParam("On", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Always", "Always Use Q, E and Smite\n(Baron & Dragon)", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
    
  if Smite ~= nil then
  Menu:addSubMenu("AutoCast Settings", "Auto")
    Menu.Auto:addParam("On", "AutoCast", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoS", "Use Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
  end
  
  Menu:addSubMenu("Flee Settings", "Flee")
    Menu.Flee:addParam("On", "Flee (Only Use KillSteal)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
    
  if VIP_USER then
  Menu:addSubMenu("Misc Settings", "Misc")
    Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, true)
  end
  
  Menu:addSubMenu("Draw Settings", "Draw")
  
    Menu.Draw:addSubMenu("Draw Target", "Target")
      Menu.Draw.Target:addParam("Q", "Draw Q Target", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw.Target:addParam("E", "Draw E Target", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.Target:addParam("R", "Draw R Target", SCRIPT_PARAM_ONOFF, false)
      
    Menu.Draw:addSubMenu("Draw Predicted Position", "PP")
      Menu.Draw.PP:addParam("R", "Draw R Pos", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.PP:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Draw.PP:addParam("Line", "Draw Line to Pos", SCRIPT_PARAM_ONOFF, true)
      
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("R", "Draw R range", SCRIPT_PARAM_ONOFF, false)
    if Ignite ~= nil then
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("I", "Draw Ignite range", SCRIPT_PARAM_ONOFF, false)
    end
    if Smite ~= nil then
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("S", "Draw Smite range", SCRIPT_PARAM_ONOFF, true)
    end
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Path", "Draw Move Path", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Hitchance", "Draw Hitchance", SCRIPT_PARAM_ONOFF, true)
    
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnTick()

  if myHero.dead then
    return
  end
  
  Checks()
  Targets()
  
  if Menu.Combo.On then
    Combo()
  end
  
  if Menu.Clear.Farm.On then
    Farm()
  end
  
  if Menu.Clear.JFarm.On then
    JFarm()
  end
  
  if Menu.Harass.On then
    Harass()
  end
  
  if Menu.LastHit.On then
    LastHit()
  end
  
  if Menu.JSteal.Always then
    JstealAlways()
  elseif Menu.JSteal.On then
    JSteal()
  end
  
  if Menu.KillSteal.On then
    KillSteal()
  end
  
  if Menu.Flee.On then
    Flee()
  end
  
end

---------------------------------------------------------------------------------

function Checks()

  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  S.ready = Smite ~= nil and myHero:CanUseSpell(Smite) == READY
  
  for _, item in pairs(Items) do
    item.slot = GetInventorySlotItem(item.id)
  end
  
  Items["BC"].ready = Items["BC"].slot and myHero:CanUseSpell(Items["BC"].slot) == READY
  Items["BRK"].ready = Items["BRK"].slot and myHero:CanUseSpell(Items["BRK"].slot) == READY
  Items["Stalker"].ready = Smite ~= nil and (Items["Stalker"].slot or Items["StalkerW"].slot or Items["StalkerM"].slot or Items["StalkerJ"].slot or Items["StalkerD"].slot) and myHero:CanUseSpell(Smite) == READY
  
  Q.level = myHero:GetSpellData(_Q).level
  W.level = myHero:GetSpellData(_W).level
  E.level = myHero:GetSpellData(_E).level
  R.level = myHero:GetSpellData(_R).level
  
  EnemyMinions:update()
  JungleMobs:update()
  
end

---------------------------------------------------------------------------------

function Targets()

  QTS:update()
  ETS:update()
  RTS:update()
  STS:update()
  
  QTarget = QTS.target
  ETarget = ETS.target
  RTarget = RTS.target
  STarget = STS.target
  
end

---------------------------------------------------------------------------------

function Combo()

  if QTarget ~= nil then
  
    if Q.ready and ValidTarget(QTarget, Q.range) then
      CastQ()
    end
    
    if W.ready and ValidTarget(QTarget, Q.range) then
      CastW()
    end
    
  end
  
  if ETarget ~= nil then
  
    if E.ready and ValidTarget(ETarget, E.range) then
      CastE(ETarget)
    end
    
  end
  
  if RTarget ~= nil then
  
    if R.ready and ValidTarget(RTarget, R.range+R.radius+100) then
      CastR(RTarget, "Combo")
    end
    
  end
  
  if STarget ~= nil then
  
    local ComboItem = Menu.Combo.Item
    
    if ComboItem then
    
      local ComboBRK = Menu.Combo.BRK
      local BCSTargetDmg = GetDmg("BC", STarget)
      local BRKSTargetDmg = GetDmg("BRK", STarget)
      
      if Items["Stalker"].ready and ValidTarget(STarget, S.range) then
        CastS(STarget)
      end
      
      if ComboBRK >= HealthPercent(myHero) then
      
        if Items["BC"].ready and ValidTarget(STarget, Items["BC"].range) then
          CastBC(STarget)
        elseif Items["BRK"].ready and ValidTarget(STarget, Items["BRK"].range) then
          CastBRK(STarget)
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Farm()

  if Q.ready then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      if ValidTarget(minion, Q.range) then
        CastQ()
        
        if W.ready then
          CastW()
        end
        
      end
      
    end
    
  end
  
  if E.ready then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local EMinionDmg = GetDmg("E", minion)
      
      if EMinionDmg >= minion.health and ValidTarget(minion, E.range) then
        CastE(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if ValidTarget(minion, E.range) then
        CastE(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JFarm()

  if Q.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, Q.range) then
        CastQ()
        
        if W.ready then
          CastW()
        end
        
      end
      
    end
    
  end
  
  if E.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= E.range and ValidTarget(LargeJunglemob, E.range) then
        CastE(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, E.range) then
        CastE(junglemob)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Harass()

  if QTarget ~= nil then
  
    if Q.ready and ValidTarget(QTarget, Q.range) then
      CastQ()
    end
    
    if W.ready and ValidTarget(QTarget, Q.range) then
      CastW()
    end
    
  end
  
  if ETarget ~= nil then
  
    if E.ready and ValidTarget(ETarget, E.range) then
      CastE(ETarget)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function LastHit()

  if Q.ready then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range) then
        CastQ()
        
        if W.ready then
          CastW()
        end
        
      end
      
    end
    
  end
  
  if E.ready then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local EMinionDmg = GetDmg("E", minion)
      
      if EMinionDmg >= minion.health and ValidTarget(minion, E.range) then
        CastE(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JSteal()

  if S.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local SJunglemobDmg = GetDmg("Smite", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and SJunglemobDmg >= junglemob.health and ValidTarget(junglemob, S.range) then
          CastS(junglemob)
          return
        end
        
      end
      
    end
    
  end
  
  if Q.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range) then
          CastQ()
        end
        
      end
      
    end
    
  end
  
  if E.ready and JStealE then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local EJunglemobDmg = GetDmg("E", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and EJunglemobDmg >= junglemob.health and ValidTarget(junglemob, E.range) then
          CastE(junglemob)
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JstealAlways()

  if S.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local SJunglemobDmg = GetDmg("Smite", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1" and SJunglemobDmg >= junglemob.health and ValidTarget(junglemob, S.range) then
          CastS(junglemob)
          return
        end
        
      end
      
    end
    
  end
  
  if Q.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range) then
          CastQ()
        end
        
      end
      
    end
    
  end
  
  if E.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local EJunglemobDmg = GetDmg("E", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and EJunglemobDmg >= junglemob.health and ValidTarget(junglemob, E.range) then
          CastE(junglemob)
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function KillSteal()

  for i, enemy in ipairs(EnemyHeroes) do
  
    local QTargetDmg = GetDmg("Q", enemy)
    local ETargetDmg = GetDmg("E", enemy)
    local RTargetDmg = GetDmg("R", enemy)
    local ITargetDmg = GetDmg("IGNITE", enemy)
    local SBTargetDmg = GetDmg("STALKER", enemy)
    
    if I.ready and ITargetDmg >= enemy.health and ValidTarget(enemy, I.range) then
      CastI(enemy)
    end
    
    if Items["Stalker"].ready and SBTargetDmg >= enemy.health and ValidTarget(enemy, S.range) then
      CastS(enemy)
      return
    end
    
    if Q.ready and QTargetDmg >= enemy.health and ValidTarget(enemy, Q.range) then
      CastQ()
    end
    
    if E.ready and ETargetDmg >= enemy.health and ValidTarget(enemy, E.range) then
      CastE(enemy)
    end
    
    if R.ready and RTargetDmg >= enemy.health and ValidTarget(enemy, R.range+R.radius+100) then
      CastR(enemy)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Flee()

  MoveToMouse()
  
  if W.ready then
    CastW()
  end
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    if Q.ready and GetDistance(enemy, myHero) <= Q.range then
      CastQ()
    end
    
    if E.ready and GetDistance(enemy, myHero) <= E.range then
      CastE(enemy)
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HealthPercent(unit)
  return (unit.health/unit.maxHealth)*100
end

function ManaPercent()
  return (myHero.mana/myHero.maxMana)*100
end

---------------------------------------------------------------------------------

function AddRange(enemy)
  return GetDistance(enemy.minBBox, enemy--[[enemy.maxBBox]])/2
end

---------------------------------------------------------------------------------

function TrueRange(enemy)
  return myHero.range+AddRange(myHero)+AddRange(enemy)
end

---------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  if enemy == nil then
    return
  end
  
  local ADDmg = 0
  local APDmg = 0
  
  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local AP = myHero.ap
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  local EnemyHealth = enemy.health
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
  
  if spell == "IGNITE" then
  
    local TrueDmg = 50+20*Level
    
    return TrueDmg
  elseif spell == "SMITE" then
  
    if Level <= 4 then
    
      local TrueDmg = 370+20*Level
      
      return TrueDmg
    elseif Level <= 9 then
    
      local TrueDmg = 330+30*Level
      
      return TrueDmg
    elseif Level <= 14 then
    
      local TrueDmg = 240+40*Level
      
      return TrueDmg
    else
    
      local TrueDmg = 100+50*Level
      
      return TrueDmg
    end
    
  elseif spell == "STALKER" then
  
    local TrueDmg = 20+8*Level
    
    return TrueDmg
  elseif spell == "BC" then
    APDmg = 100
  elseif spell == "BRK" then
    ADDmg = math.max(100, .1*enemy.maxHealth)
  elseif spell == "AA" then
    ADDmg = TotalDmg
  elseif spell == "Q" then
    APDmg = 25+15*Q.level+(30+5*Q.level)/100*AP+(45+5*Q.level)/100*AddDmg
  elseif spell == "E" then
    ADDmg = 30+40*E.level+AP+AddDmg
  elseif spell == "R" then
    APDmg = (10+5*R.level+AP/100)/100*EnemyHealth
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQ()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _Q}):send()
  else
    CastSpell(_Q)
  end
  
end

---------------------------------------------------------------------------------

function CastW()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _W}):send()
  else
    CastSpell(_W)
  end
  
end

---------------------------------------------------------------------------------

function CastE(unit)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
  else
    CastSpell(_E, unit)
  end
  
end

---------------------------------------------------------------------------------

function CastR(unit, mode)

  RPos, RHitChance, RNoH = HPred:GetPredict("R", unit, myHero, true)
  
  if mode == "Combo" and (RHitChance >= Menu.HitChance.Combo.R and (Q.ready and GetDmg("Q", unit) or 0)+(E.ready and GetDmg("E", unit) or 0)+GetDmg("R", unit) >= unit.health or RNoH >= Menu.Combo.R3) or mode == nil and RHitChance >= 3 then
  
    if VIP_USER and Menu.Misc.UsePacket then
      Packet("S_CAST", {spellId = _R, toX = RPos.x, toY = RPos.z, fromX = RPos.x, fromY = RPos.z}):send()
    else
      CastSpell(_R, RPos.x, RPos.z)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function CastI(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Ignite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Ignite, enemy)
  end
  
end

---------------------------------------------------------------------------------

function CastS(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Smite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Smite, enemy)
  end
  
end

---------------------------------------------------------------------------------

function CastBC(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["BC"].slot, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Items["BC"].slot, enemy)
  end
  
end

---------------------------------------------------------------------------------

function CastBRK(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["BRK"].slot, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Items["BRK"].slot, enemy)
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function MoveToMouse()

  if mousePos and GetDistance(mousePos) <= 100 then
    MousePos = myHero+(Vector(mousePos)-myHero):normalized()*300
  else
    MousePos = mousePos
  end
  
  myHero:MoveTo(MousePos.x, MousePos.z)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnDraw()

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.Target.Q and QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, AddRange(QTarget), ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.Target.E and ETarget ~= nil then
    DrawCircle(ETarget.x, ETarget.y, ETarget.z, AddRange(ETarget), ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.Target.R and RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if RHitChance ~= nil then
  
    if RHitChance == 0 then
      Rcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif RHitChance == 3 then
      Rcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif RHitChance >= 2 then
      Rcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif RHitChance >= 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  
  if Menu.Draw.PP.R and RPos ~= nil then
  
    DrawCircle(RPos.x, RPos.y, RPos.z, R.radius, Rcolor)
    
    if Menu.Draw.PP.Line then
      DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, Rcolor)
    end
    
    RPos = nil
  end
  
  if Menu.Draw.Hitchance then
  
    if RHitChance ~= nil then
      DrawText("R HitChance: "..RHitChance, 20, 1250, 700, Rcolor)
      RHitChance = nil
      
      if RNoH ~= nil then
        DrawText("R NoH: "..RNoH, 20, 1050, 550, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
        RNoH = nil
      end
      
    end
    
  end
  
  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, TrueRange, ARGB(0xFF, 0, 0xFF, 0))
  end
  
  if Menu.Draw.Q then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.E then
    DrawCircle(myHero.x, myHero.y, myHero.z, E.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.R and R.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, R.range, ARGB(0xFF, 0x00, 0x00, 0xFF))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, ARGB(0xFF, 0xFF, 0x24, 0x24))
  end
  
  if Menu.Draw.S and S.ready and (Menu.Auto.On and Menu.Auto.AutoS or Menu.JSteal.On) then
    DrawCircle(myHero.x, myHero.y, myHero.z, S.range, ARGB(0xFF, 0xFF, 0x14, 0x93))
  end
  
  if Menu.Draw.Path then
  
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
    
    for i, enemy in ipairs(EnemyHeroes) do
    
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

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnAnimation(unit, animation)

  if not unit.isMe then
    return
  end
  
  if animation == "recall" then
    IsRecall = true
  elseif animation == "recall_winddown" or animation == "Run" or animation == "Spell1" or animation == "Spell2" or animation == "Spell3" or animation == "Spell4" then
    IsRecall = false
  end
  
end
