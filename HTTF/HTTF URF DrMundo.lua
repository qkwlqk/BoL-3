local Version = "1.001"
local AutoUpdate = true

if myHero.charName ~= "DrMundo" then
  return
end

require 'HPrediction'

function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>HTTF URF DrMundo:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

---------------------------------------------------------------------------------

local Host = "raw.github.com"

local ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

local ScriptPath = "/BolHTTF/BoL/master/HTTF/HTTF URF DrMundo.lua".."?rand="..math.random(1,10000)
local UpdateURL = "https://"..Host..ScriptPath

local VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HTTF URF DrMundo.version".."?rand="..math.random(1,10000)
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
  DrMundoMenu()
  DelayAction(Orbwalk, 1)
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Variables()

  HPred = HPrediction()
  
  CanW = true
  LastW = os.clock()
  
  Spell_Q.collisionM['DrMundo'] = true
  Spell_Q.collisionH['DrMundo'] = false
  Spell_Q.delay['DrMundo'] = 0.25
  Spell_Q.range['DrMundo'] = 1050
  Spell_Q.speed['DrMundo'] = 2000
  Spell_Q.type['DrMundo'] = "DelayLine"
  Spell_Q.width['DrMundo'] = 120
  
  IsRecall = false
  RebornLoaded, RevampedLoaded, MMALoaded, SxOrbLoaded, SOWLoaded = false, false, false, false, false
  
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
  
  Q = {range = 1000, width = 120, ready}
  W = {radius = 325, ready}
  E = {ready}
  R = {ready}
  I = {range = 600, ready}
  S = {range = 760, ready}
  
  AutoQEWQ = {1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3}
  
  AddRange = GetDistance(myHero.minBBox)/2
  TrueRange = myHero.range+AddRange
  
  QTargetRange = Q.range+100
  
  QMinionRange = Q.range+100
  QJunglemobRange = Q.range+100
  
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
  STS = TargetSelector(TARGET_LOW_HP, S.range)
  
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, QMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, QJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  
end

---------------------------------------------------------------------------------

function DrMundoMenu()

  Menu = scriptConfig("HTTF DrMundo URF", "HTTF DrMundo URF")
  
  Menu:addSubMenu("HitChance Settings", "HitChance")
  
    Menu.HitChance:addSubMenu("Combo", "Combo")
      Menu.HitChance.Combo:addParam("Q", "Q HitChacne (Default value = 1.02)", SCRIPT_PARAM_SLICE, 1.02, 1, 3, 2)
      
    Menu.HitChance:addSubMenu("Harass", "Harass")
      Menu.HitChance.Harass:addParam("Q", "Q HitChacne (Default value = 1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 3, 2)
      
  Menu:addSubMenu("Combo Settings", "Combo")
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    
  Menu:addSubMenu("Clear Settings", "Clear")
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
      
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
      
  Menu:addSubMenu("Harass Settings", "Harass")
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
    Menu.Harass:addParam("On2", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey('T'))
    
  Menu:addSubMenu("LastHit Settings", "LastHit")
    Menu.LastHit:addParam("On", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    
  Menu:addSubMenu("Jungle Steal Settings", "JSteal")
    Menu.JSteal:addParam("On", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.JSteal:addParam("On2", "Jungle Steal Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("Flee Settings", "Flee")
    Menu.Flee:addParam("On", "Flee (Only Use KillSteal)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
    
  Menu:addSubMenu("Misc Settings", "Misc")
    if VIP_USER then
    Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, true)
    end
    --Menu.Misc:addParam("AutoLevel", "Auto Level Spells", SCRIPT_PARAM_ONOFF, false)
    --Menu.Misc:addParam("ALOpt", "Skill order : ", SCRIPT_PARAM_LIST, 1, {"R>Q>W>E (QEWQ)"})
    
  Menu:addSubMenu("Draw Settings", "Draw")
  
    Menu.Draw:addSubMenu("Draw Target", "Target")
      Menu.Draw.Target:addParam("Q", "Draw Q Target", SCRIPT_PARAM_ONOFF, true)
      
    Menu.Draw:addSubMenu("Draw Predicted Position", "PP")
      Menu.Draw.PP:addParam("Q", "Draw Q Pos", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw.PP:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Draw.PP:addParam("Line", "Draw Line to Pos", SCRIPT_PARAM_ONOFF, true)
      
    Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
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

function Orbwalk()

  if _G.AutoCarry then
  
    if _G.Reborn_Initialised then
      RebornLoaded = true
      ScriptMsg("Found SAC: Reborn.")
    else
      RevampedLoaded = true
      ScriptMsg("Found SAC: Revamped.")
    end
    
  elseif _G.Reborn_Loaded then
    DelayAction(Orbwalk, 1)
  elseif _G.MMA_Loaded then
    MMALoaded = true
    ScriptMsg("Found MMA.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
  
    require 'SxOrbWalk'
    
    SxOrbMenu = scriptConfig("SxOrb Settings", "SxOrb")
    
    SxOrb = SxOrbWalk()
    SxOrb:LoadToMenu(SxOrbMenu)
    
    SxOrbLoaded = true
    ScriptMsg("Found SxOrb.")
  elseif FileExist(LIB_PATH .. "SOW.lua") then
  
    require 'SOW'
    require 'VPrediction'
    
    VP = VPrediction()
    SOWVP = SOW(VP)
    
    Menu:addSubMenu("Orbwalk Settings (SOW)", "Orbwalk")
      Menu.Orbwalk:addParam("Info", "SOW settings", SCRIPT_PARAM_INFO, "")
      Menu.Orbwalk:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      SOWVP:LoadToMenu(Menu.Orbwalk)
      
    SOWLoaded = true
    ScriptMsg("Found SOW.")
  else
    ScriptMsg("Orbwalk not founded.")
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnTick()

  if myHero.dead then
    return
  end
  
  Checks()
  Targets()
  
  local WTarget = nil
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    if ValidTarget(enemy, W.radius) then
      WTarget = enemy
      break
    end
    
  end
  
  if W.ready then
  
    if WTarget ~= nil and CanW and not IsRecall and HealthPercent() >= 10 then
      CastW()
    end
    
  end
  
  if R.ready and not IsRecall and HealthPercent() < 100 then
    CastR()
  end
  
  if Menu.Combo.On then
    Combo()
  end
  
  if Menu.Clear.Farm.On then
    Farm()
  end
  
  if Menu.Clear.JFarm.On then
    JFarm()
  end
  
  if Menu.Harass.On or (Menu.Harass.On2 and not IsRecall) then
    Harass()
  end
  
  if Menu.LastHit.On then
    LastHit()
  end
  
  if Menu.JSteal.On or Menu.JSteal.On2 then
    JSteal()
  end
  
  if Menu.JSteal.Always then
    JstealAlways()
  end
  
  if Menu.KillSteal.On then
    KillSteal()
  end
  
  if Menu.Flee.On then
    Flee()
  end
  
  if Menu.Misc.AutoLevel then
    AutoLevel()
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
  
  AddRange = GetDistance(myHero.minBBox, myHero)/2
  TrueRange = myHero.range+AddRange
end

---------------------------------------------------------------------------------

function Targets()

  --[[AATarget = nil
  
  if RebornLoaded then
    --Target = _G.AutoCarry.Crosshair.Attack_Crosshair.target
    --Target = _G.AutoCarry.Crosshair._Skills_Crosshair.target
    Target = _G.AutoCarry.Crosshair:GetTarget()
  elseif RevampedLoaded then
    Target = _G.AutoCarry.Orbwalker.target
  elseif MMALoaded then
    Target = _G.MMA_Target
  elseif SxOrbLoaded then
    Target = SxOrb:GetTarget()
  elseif SOWLoaded then
    Target = SOWVP:GetTarget()
  end
  
  if Target and Target.type == myHero.type and ValidTarget(Target, TrueRange) then
    AATarget = Target
  end]]
  
  QTS:update()
  STS:update()
  QTarget = QTS.target
  STarget = STS.target
end

--[[function OrbReset()

  if RebornLoaded then
    _G.AutoCarry.Orbwalker:ResetAttackTimer
  elseif RevampedLoaded then
  elseif MMALoaded then
    _G.MMA_ResetAutoAttack()
  elseif SxOrbLoaded then
    SxOrb:ResetAA()
  elseif SOWLoaded then
    SOWVP:resetAA()
    --SOW:resetAA()
  end
  
end]]

---------------------------------------------------------------------------------

function Combo()

  local WTarget = nil
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    if ValidTarget(enemy, W.radius) then
      WTarget = enemy
      break
    end
    
  end
  
  if W.ready then
  
    if (WTarget == nil or HealthPercent() < 10) and not CanW then
      CastW()
    end
    
  end
  
  if QTarget ~= nil then
  
    if Q.ready and ValidTarget(QTarget, Q.range+100) then
      CastQ(QTarget, "Combo")
    end
    
    if QHitChance ~= nil and QHitChance >= 0 and QHitChance < 1 then
    
      for i, enemy in ipairs(EnemyHeroes) do
        
        if ValidTarget(enemy, Q.range+100) then
          CastQ(enemy, "Combo")
        end
        
      end
      
    end
    
    if E.ready and ValidTarget(QTarget, HTTF_TrueRange(QTarget)) then
      CastE()
    end
    
  end
  
  if STarget ~= nil then
  
    local ComboBRK = 40
    local BCSTargetDmg = GetDmg("BC", STarget)
    local BRKSTargetDmg = GetDmg("BRK", STarget)
    
    if Items["Stalker"].ready and ValidTarget(STarget, S.range) then
      CastS(STarget)
    end
    
    if ComboBRK >= HealthPercent() then
    
      if Items["BC"].ready and ValidTarget(STarget, Items["BC"].range) then
        CastBC(STarget)
      elseif Items["BRK"].ready and ValidTarget(STarget, Items["BRK"].range) then
        CastBRK(STarget)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Farm()

  if Q.ready then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local AAMinionDmg = GetDmg("AA", minion)
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg+--[[2.5*]]AAMinionDmg <= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JFarm()

  if Q.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= Q.range and ValidTarget(LargeJunglemob, Q.range+100) then
        CastQ(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, Q.range+100) then
        CastQ(junglemob)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Harass()

  local WTarget = nil
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    if ValidTarget(enemy, W.radius) then
      WTarget = enemy
      break
    end
    
  end
  
  if W.ready then
  
    if (WTarget == nil or HealthPercent() < 10) and not CanW then
      CastW()
    end
    
  end
  
  if QTarget ~= nil then
  
    if Q.ready and ValidTarget(QTarget, Q.range+100) then
      CastQ(QTarget, "Harass")
    end
    
    if QHitChance ~= nil and QHitChance >= 0 and QHitChance < 1 then
    
      for i, enemy in ipairs(EnemyHeroes) do
      
        if ValidTarget(enemy, Q.range+100) then
          CastQ(enemy, "Harass")
        end
        
      end
      
    end
    
    if E.ready and ValidTarget(QTarget, HTTF_TrueRange(QTarget)) then
      CastE()
    end
    
  end
  
end

---------------------------------------------------------------------------------

function LastHit()

  if Q.ready then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion, "LastHit")
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JSteal()

  if S.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local SJunglemobDmg = GetDmg("SMITE", junglemob)
      
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
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+100) then
          CastQ(junglemob, "JSteal")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JstealAlways()
  
  if S.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local SJunglemobDmg = GetDmg("SMITE", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and SJunglemobDmg >= junglemob.health and ValidTarget(junglemob, S.range) then
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
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+100) then
          CastQ(junglemob, "JSteal")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function KillSteal()

  for i, enemy in ipairs(EnemyHeroes) do
  
    local QTargetDmg = GetDmg("Q", enemy)
    local ITargetDmg = GetDmg("IGNITE", enemy)
    local SBTargetDmg = GetDmg("STALKER", enemy)
    
    if I.ready and ITargetDmg >= enemy.health and ValidTarget(enemy, I.range) then
      CastI(enemy)
    end
    
    if Items["Stalker"].ready and SBTargetDmg >= enemy.health and ValidTarget(enemy, S.range) then
      CastS(enemy)
      return
    end
    
    if Q.ready and QTargetDmg >= enemy.health and ValidTarget(enemy, Q.range+100) then
      CastQ(enemy, "KillSteal")
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Flee()

  FleePos = myHero+(Vector(mousePos)-myHero):normalized()*300
  
  MoveToMouse()
  
end

---------------------------------------------------------------------------------

function AutoLevel()

  if Menu.Misc.ALOpt == 1 then
  
    if Q.level+W.level+E.level+R.level < myHero.level then
    
      local spell = {SPELL_1, SPELL_2, SPELL_3, SPELL_4}
      local level = {0, 0, 0, 0}
      
      for i = 1, myHero.level do
        level[AutoQEWQ[i]] = level[AutoQEWQ[i]]+1
      end
      
      for i, j in ipairs({Q.level, W.level, E.level, R.level}) do
      
        if j < level[i] then
          LevelSpell(spell[i])
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function HTTF_AddRange(enemy)
  return GetDistance(enemy.minBBox, enemy--[[enemy.maxBBox]])/2
end

---------------------------------------------------------------------------------

function HTTF_TrueRange(enemy)
  return myHero.range+HTTF_AddRange(myHero)+HTTF_AddRange(enemy)
end

---------------------------------------------------------------------------------

function HealthPercent()
  return (myHero.health/myHero.maxHealth)*100
end

---------------------------------------------------------------------------------

function OrbwalkCanMove()

  if RebornLoaded then
    return _G.AutoCarry.CanMove
  elseif RevampedLoaded then
  elseif MMALoaded then
    return _G.MMA_AbleToMove
  elseif SxOrbLoaded then
    return SxOrb:CanMove()
  elseif SOWLoaded then
    return SOWVP:CanMove()
    --return SOW:CanMove()
  end
  
end

---------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  if enemy == nil then
    return 0
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
  
    if Q.level >= 1 and Q.level <= 3 then
      APDmg = math.max(30+50*Q.level, EnemyHealth*(12+3*Q.level)/100)
    elseif Q.level >= 4 then
      APDmg = math.max(30+50*Q.level, EnemyHealth*(15+2*Q.level)/100)
    else
      APDmg = 0
    end
    
    if enemy.type ~= myHero.type then
      APDmg = math.min(APDmg, 200+100*Q.level)
    end
    
  elseif spell == "W" then
    APDmg = 0
  elseif spell == "E" then
    APDmg = 0
  elseif spell == "R" then
    APDmg = 0
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQ(unit, mode)

  if unit.dead or mode ~= "LastHit" and mode ~= "JSteal" and mode ~= "KillSteal" and not OrbwalkCanMove() then
    return
  end
  
  QPos, QHitChance = HPred:GetPredict("Q", unit, myHero)
  
  if mode == "Combo" and QHitChance >= Menu.HitChance.Combo.Q or mode == "Harass" and QHitChance >= Menu.HitChance.Harass.Q or (mode == "LastHit" or mode == "JSteal" or mode == "KillSteal" or mode == nil) and QHitChance >= 1 then
  
    if VIP_USER and Menu.Misc.UsePacket then
      Packet("S_CAST", {spellId = _Q, toX = QPos.x, toY = QPos.z, fromX = QPos.x, fromY = QPos.z}):send()
    else
      CastSpell(_Q, QPos.x, QPos.z)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function CastW()

  if os.clock()-LastW <= 0.2 then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _W}):send()
  else
    CastSpell(_W)
  end
  
  LastW = os.clock()
end

---------------------------------------------------------------------------------

function CastE()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E}):send()
  else
    CastSpell(_E)
  end
  
end

---------------------------------------------------------------------------------

function CastR()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _R}):send()
  else
    CastSpell(_R)
  end
  
end

---------------------------------------------------------------------------------

function CastI(enemy)

  if enemy.dead then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Ignite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Ignite, enemy)
  end
  
end

---------------------------------------------------------------------------------

function CastS(enemy)

  if enemy.dead then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Smite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Smite, enemy)
  end
  
end

---------------------------------------------------------------------------------

function CastBC(enemy)

  if enemy.dead then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["BC"].slot, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Items["BC"].slot, enemy)
  end
  
end

---------------------------------------------------------------------------------

function CastBRK(enemy)

  if enemy.dead then
    return
  end
  
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
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.width/2, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if QHitChance ~= nil then
  
    if QHitChance == -1 then
      Qcolor = ARGB(0xFF, 0x00, 0x00, 0x00)
    elseif QHitChance < 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif QHitChance == 3 then
      Qcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif QHitChance >= 2 then
      Qcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif QHitChance >= 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  
  if Menu.Draw.PP.Q and QPos ~= nil then
  
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.width/2, Qcolor)
    
    if Menu.Draw.PP.Line then
      DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, Qcolor)
    end
    
    QPos = nil
  end
  
  if Menu.Draw.Hitchance then
  
    if QHitChance ~= nil then
      DrawText("Q HitChance: "..QHitChance, 20, 1250, 550, Qcolor)
      QHitChance = nil
    end
    
  end
  
  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, TrueRange, ARGB(0xFF, 0, 0xFF, 0))
  end
  
  if Menu.Draw.Q then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range+AddRange, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, ARGB(0xFF, 0xFF, 0x24, 0x24))
  end
  
  if Menu.Draw.S and S.ready and (Menu.JSteal.On or Menu.JSteal.On2) and Menu.JSteal.S then
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

function OnApplyBuff(source, unit, buff)

  if buff.name == "BurningAgony" then --
    CanW = false
  end
  
end

function OnRemoveBuff(unit, buff)

  if not unit.isMe then
    return
  end
  
  if buff.name == "BurningAgony" then 
    CanW = true
  end
  
end
