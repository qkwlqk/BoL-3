local Version = "1.104"
local AutoUpdate = true

if myHero.charName ~= "Orianna" then
  return
end

require 'HPrediction'

function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>HTTF Orianna:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

---------------------------------------------------------------------------------

local Host = "raw.github.com"

local ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

local ScriptPath = "/BolHTTF/BoL/master/HTTF/HTTF Orianna.lua".."?rand="..math.random(1,10000)
local UpdateURL = "https://"..Host..ScriptPath

local VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HTTF Orianna.version".."?rand="..math.random(1,10000)
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
  OriannaMenu()
  
end

function Variables()

  HPred = HPrediction()
  
  Ball = myHero
  
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
  
  Q = {range = 825, radius = 175, speed = 1200, ready}
  W = {range = 1250, radius = 225, ready}
  E = {range = 1250, speed = 1800, width = 80, ready}
  R = {range = 1250, radius = 410, ready} --delay = .5
  I = {range = 600, ready}
  S = {range = 760, ready}
  
  AddRange = GetDistance(myHero.minBBox)/2
  TrueRange = myHero.range+AddRange
  
  QTargetRange = Q.range+Q.radius+100
  WTargetRange = W.range+W.radius+100
  ETargetRange = E.range+100
  RTargetRange = R.range+R.radius+100
  
  QMinionRange = Q.range+Q.radius+100
  QJunglemobRange = Q.range+Q.radius+100
  WMinionRange = W.range+W.radius+100
  WJunglemobRange = W.range+W.radius+100
  
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
  WTS = TargetSelector(TARGET_LESS_CAST, WTargetRange, DAMAGE_MAGIC, false)
  ETS = TargetSelector(TARGET_LESS_CAST, ETargetRange, DAMAGE_MAGIC, false)
  RTS = TargetSelector(TARGET_LESS_CAST, RTargetRange, DAMAGE_MAGIC, false)
  STS = TargetSelector(TARGET_LOW_HP, S.range)
  
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, QMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, QJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  
end

---------------------------------------------------------------------------------

function OriannaMenu()

  Menu = scriptConfig("HTTF Orianna", "HTTF Orianna")
  
  Menu:addSubMenu("HitChance Settings", "HitChance")
  
    Menu.HitChance:addSubMenu("Combo", "Combo")
      Menu.HitChance.Combo:addParam("Q", "Q HitChacne (Default value = 1.6)", SCRIPT_PARAM_SLICE, 1.6, 1, 3, 2)
      Menu.HitChance.Combo:addParam("W", "W HitChacne (Default value = 2)", SCRIPT_PARAM_SLICE, 2, 1, 3, 2)
      Menu.HitChance.Combo:addParam("R", "R HitChacne (Default value = 2)", SCRIPT_PARAM_SLICE, 2, 1, 3, 2)
      
    Menu.HitChance:addSubMenu("Harass", "Harass")
      Menu.HitChance.Harass:addParam("Q", "Q HitChacne (Default value = 2)", SCRIPT_PARAM_SLICE, 2, 1, 3, 2)
      Menu.HitChance.Harass:addParam("W", "W HitChacne (Default value = 3)", SCRIPT_PARAM_SLICE, 3, 1, 3, 2)
      
  Menu:addSubMenu("Combo Settings", "Combo")
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Info", "Use Q if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Info", "Use W if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Info", "Use E if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E2", "Default value = 20", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Info", "Use R if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R3", "Use R Min Count (Default = 3)", SCRIPT_PARAM_SLICE, 3, 2, 5, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Item", "Use Items", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("BRK", "Use BRK if my own HP < x%", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
    
  Menu:addSubMenu("Clear Settings", "Clear")
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Clear.Farm:addParam("Info", "Use Q if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Q2", "Default value = 70", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Clear.Farm:addParam("Info", "Use W if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("W2", "Default value = 70", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Clear.Farm:addParam("Info", "Use E if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("E2", "Default value = 80", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
        
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Clear.JFarm:addParam("Info", "Use Q if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("Q2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Clear.JFarm:addParam("Info", "Use W if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("W2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Clear.JFarm:addParam("Info", "Use E if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("E2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
      
  Menu:addSubMenu("Harass Settings", "Harass")
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("Info", "Use Q if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Q2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("Info", "Use W if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("W2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("Info", "Use E if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("E2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
    
  Menu:addSubMenu("LastHit Settings", "LastHit")
    Menu.LastHit:addParam("On", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.LastHit:addParam("Info", "Use Q if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Q2", "Default value = 80", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
    Menu.LastHit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.LastHit:addParam("Info", "Use W if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("W2", "Default value = 80", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
    Menu.LastHit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.LastHit:addParam("Info", "Use E if Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("E2", "Default value = 90", SCRIPT_PARAM_SLICE, 90, 0, 100, 0)
    
  Menu:addSubMenu("Jungle Steal Settings", "JSteal")
    Menu.JSteal:addParam("On", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.JSteal:addParam("On2", "Jungle Steal Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    if Smite ~= nil then
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("S", "Use Smite", SCRIPT_PARAM_ONOFF, true)
    end
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Always", "Always Use Q, W, E and Smite\n(Baron & Dragon)", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    if Ignite ~= nil then
      Menu.KillSteal:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("I", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
    end
    if Smite ~= nil then
      Menu.KillSteal:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("S", "Use Stalker's Blade", SCRIPT_PARAM_ONOFF, true)
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
      Menu.Draw.Target:addParam("W", "Draw W Target", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.Target:addParam("E", "Draw E Target", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.Target:addParam("R", "Draw R Target", SCRIPT_PARAM_ONOFF, false)
      
    Menu.Draw:addSubMenu("Draw Predicted Position", "PP")
      Menu.Draw.PP:addParam("Q", "Draw Q Pos", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw.PP:addParam("W", "Draw W Pos", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.PP:addParam("E", "Draw E Line", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.PP:addParam("R", "Draw R Pos", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw.PP:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Draw.PP:addParam("Line", "Draw Line to Pos", SCRIPT_PARAM_ONOFF, true)
      
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Ball", "Draw Ball", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, false)
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
    
  Menu.Combo.On = false
  Menu.Clear.Farm.On = false
  Menu.Clear.JFarm.On = false
  Menu.Harass.On = false
  Menu.LastHit.On = false
  Menu.JSteal.On = false
  Menu.Flee.On = false
  
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
  
  AddRange = GetDistance(myHero.minBBox)/2
  TrueRange = myHero.range+AddRange
  
end

---------------------------------------------------------------------------------

function Targets()

  QTS:update()
  WTS:update()
  ETS:update()
  RTS:update()
  STS:update()
  
  QTarget = QTS.target
  WTarget = WTS.target
  ETarget = ETS.target
  RTarget = RTS.target
  STarget = STS.target
  
end

---------------------------------------------------------------------------------

function Combo()

  if QTarget ~= nil then
  
    local ComboQ = Menu.Combo.Q
    local ComboQ2 = Menu.Combo.Q2
    local ComboE = Menu.Combo.E
    local ComboE2 = Menu.Combo.E2
    
    if Q.ready and ComboQ and ComboQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+Q.radius+100) then
      CastQ(QTarget, "Combo")
    end
    
    if Ball ~= nil and QPos ~= nil and Q.ready and E.ready and ComboQ and ComboE and ComboQ2+ComboE2 <= ManaPercent() and GetDistance(QPos, Ball)/1200 > GetDistance(myHero, Ball)/1800+GetDistance(QPos, myHero)/1200 then
      CastEMe()
    end
    
  end
  
  if WTarget ~= nil then
  
    local ComboW = Menu.Combo.W
    local ComboW2 = Menu.Combo.W2
    
    if W.ready and ComboW and ComboW2 <= ManaPercent() and ValidTarget(WTarget, W.range+W.radius+100) then
      CastW(WTarget, "Combo")
    end
    
  end
  
  if ETarget ~= nil then
  
    local ComboE = Menu.Combo.E
    local ComboE2 = Menu.Combo.E2
    
    if E.ready and ComboE and ComboE2 <= ManaPercent() and ValidTarget(ETarget, E.range+100) then
      CastE(ETarget)
    end
    
  end
  
  if RTarget ~= nil then
  
    local ComboR = Menu.Combo.R
    local ComboR2 = Menu.Combo.R2
  
    if R.ready and ComboR and ComboR2 <= ManaPercent() and ValidTarget(RTarget, R.range+R.radius+100) then
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

  local FarmQ = Menu.Clear.Farm.Q
  local FarmQ2 = Menu.Clear.Farm.Q2
  local FarmW = Menu.Clear.Farm.W
  local FarmW2 = Menu.Clear.Farm.W2
  local FarmE = Menu.Clear.Farm.E
  local FarmE2 = Menu.Clear.Farm.E2
  
  if Q.ready and FarmQ and FarmQ2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local QMinionDmg = .7*GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQ(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local AAMinionDmg = GetDmg("AA", minion)
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQ(minion)
      end
      
    end
    
  end
  
  if W.ready and FarmW and FarmW2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local WMinionDmg = GetDmg("W", minion)
      
      if WMinionDmg >= minion.health and ValidTarget(minion, W.range+W.radius+100) then
        CastW(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local AAMinionDmg = GetDmg("AA", minion)
      local WMinionDmg = GetDmg("W", minion)
      
      if WMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, W.range+W.radius+100) then
        CastW(minion)
      end
      
    end
    
  end
  
  if E.ready and FarmE and FarmE2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local EMinionDmg = GetDmg("E", minion)
      
      if EMinionDmg >= minion.health and ValidTarget(minion, E.range+100) then
        CastE(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local AAMinionDmg = GetDmg("AA", minion)
      local EMinionDmg = GetDmg("E", minion)
      
      if EMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, E.range+100) then
        CastE(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JFarm()

  local JFarmQ = Menu.Clear.JFarm.Q
  local JFarmQ2 = Menu.Clear.JFarm.Q2
  local JFarmW = Menu.Clear.JFarm.W
  local JFarmW2 = Menu.Clear.JFarm.W2
  local JFarmE = Menu.Clear.JFarm.E
  local JFarmE2 = Menu.Clear.JFarm.E2
  
  if Q.ready and JFarmQ and JFarmQ2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= Q.range+Q.radius and ValidTarget(LargeJunglemob, Q.range+Q.radius+100) then
        CastQ(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      if ValidTarget(junglemob, Q.range+Q.radius+100) then
        CastQ(junglemob)
      end
      
    end
    
  end
  
  if W.ready and JFarmW and JFarmW2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= W.range+W.radius and ValidTarget(LargeJunglemob, W.range+W.radius+100) then
        CastW(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      if ValidTarget(junglemob, W.range+W.radius+100) then
        CastW(junglemob)
      end
      
    end
    
  end
  
  if E.ready and JFarmE and JFarmE2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= E.range and ValidTarget(LargeJunglemob, E.range+100) then
        CastE(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      if ValidTarget(junglemob, E.range+100) then
        CastE(junglemob)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Harass()

  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    local HarassE = Menu.Harass.E
    local HarassE2 = Menu.Harass.E2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+Q.radius+100) then
      CastQ(QTarget, "Harass")
    end
    
    if Ball ~= nil and QPos ~= nil and QHitChance ~= nil and QHitChance >= Menu.HitChance.Harass.Q and Q.ready and E.ready and HarassQ and HarassE and HarassQ2+HarassE2 <= ManaPercent() and GetDistance(QPos, Ball)/1200 > GetDistance(myHero, Ball)/1800+GetDistance(QPos, myHero)/1200 then
      CastEMe()
    end
    
  end
  
  if WTarget ~= nil then
  
    local HarassW = Menu.Harass.W
    local HarassW2 = Menu.Harass.W2
    
    if W.ready and HarassW and HarassW2 <= ManaPercent() and ValidTarget(WTarget, W.range+W.radius+100) then
      CastW(WTarget, "Harass")
    end
    
  end
  
  if ETarget ~= nil then
  
    local HarassE = Menu.Harass.E
    local HarassE2 = Menu.Harass.E2
    
    if E.ready and HarassE and HarassE2 <= ManaPercent() and ValidTarget(ETarget, E.range+100) then
      CastE(ETarget)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function LastHit()

  local LastHitQ = Menu.LastHit.Q
  local LastHitQ2 = Menu.LastHit.Q2
  local LastHitW = Menu.LastHit.W
  local LastHitW2 = Menu.LastHit.W2
  local LastHitE = Menu.LastHit.E
  local LastHitE2 = Menu.LastHit.E2
  
  if Q.ready and LastHitQ and LastHitQ2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local QMinionDmg = .7*GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQ(minion)
      end
      
    end
    
  end
  
  if W.ready and LastHitW and LastHitW2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local WMinionDmg = GetDmg("W", minion)
      
      if WMinionDmg >= minion.health and ValidTarget(minion, W.range+W.radius+100) then
        CastW(minion)
      end
      
    end
    
  end
  
  if E.ready and LastHitE and LastHitE2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      if minion == nil then
        return
      end
      
      local EMinionDmg = GetDmg("E", minion)
      
      if EMinionDmg >= minion.health and ValidTarget(minion, E.range+100) then
        CastE(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function JSteal()

  local JStealQ = Menu.JSteal.Q
  local JStealW = Menu.JSteal.W
  local JStealE = Menu.JSteal.E
  local JStealS = Menu.JSteal.S
  
  if S.ready and JStealS then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local SJunglemobDmg = GetDmg("SMITE", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and SJunglemobDmg >= junglemob.health and ValidTarget(junglemob, S.range) then
          CastS(junglemob)
          return
        end
        
      end
      
    end
    
  end
  
  if Q.ready and JStealQ then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local QJunglemobDmg = .8*GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+100) then
          CastQ(junglemob)
        end
        
      end
      
    end
    
  end
  
  if W.ready and JStealW then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local WJunglemobDmg = GetDmg("W", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and WJunglemobDmg >= junglemob.health and ValidTarget(junglemob, W.range+W.radius+100) then
          CastW(junglemob)
        end
        
      end
      
    end
    
  end
  
  if E.ready and JStealE then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local EJunglemobDmg = GetDmg("E", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and EJunglemobDmg >= junglemob.health and ValidTarget(junglemob, E.range+100) then
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
    
      if junglemob == nil then
        return
      end
      
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
    
      if junglemob == nil then
        return
      end
      
      local QJunglemobDmg = GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+100) then
          CastQ(junglemob)
        end
        
      end
      
    end
    
  end
  
  if W.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local WJunglemobDmg = GetDmg("W", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and WJunglemobDmg >= junglemob.health and ValidTarget(junglemob, W.range+W.radius+100) then
          CastW(junglemob)
        end
        
      end
      
    end
    
  end
  
  if E.ready then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if junglemob == nil then
        return
      end
      
      local EJunglemobDmg = GetDmg("E", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if (junglemob.name == "SRU_Baron12.1.1" or junglemob.name == "SRU_Dragon6.1.1") and EJunglemobDmg >= junglemob.health and ValidTarget(junglemob, E.range+100) then
          CastE(junglemob)
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------

function KillSteal()

  local KillStealQ = Menu.KillSteal.Q
  local KillStealW = Menu.KillSteal.W
  local KillStealE = Menu.KillSteal.E
  local KillStealR = Menu.KillSteal.R
  local KillStealI = Menu.KillSteal.I
  local KillStealS = Menu.KillSteal.S
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    if enemy == nil then
       return
    end
    
    local QTargetDmg = .7*GetDmg("Q", enemy)
    local WTargetDmg = GetDmg("W", enemy)
    local ETargetDmg = GetDmg("E", enemy)
    local RTargetDmg = GetDmg("R", enemy)
    local ITargetDmg = GetDmg("IGNITE", enemy)
    local SBTargetDmg = GetDmg("STALKER", enemy)
    
    if I.ready and KillStealI and ITargetDmg >= enemy.health and ValidTarget(enemy, I.range) then
      CastI(enemy)
    end
    
    if Items["Stalker"].ready and KillStealS and SBTargetDmg >= enemy.health and ValidTarget(enemy, S.range) then
      CastS(enemy)
      return
    end
    
    if Q.ready and KillStealQ and QTargetDmg >= enemy.health and ValidTarget(enemy, Q.range+Q.radius+100) then
      CastQ(enemy)
    end
    
    if W.ready and KillStealW and WTargetDmg >= enemy.health and ValidTarget(enemy, W.range+W.radius+100) then
      CastW(enemy)
    end
    
    if E.ready and KillStealE and ETargetDmg >= enemy.health and ValidTarget(enemy, E.range+100) then
      CastE(enemy)
    end
    
    if R.ready and KillStealR and RTargetDmg >= enemy.health and ValidTarget(enemy, R.range+R.radius+100) then
      CastR(enemy)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function Flee()

  MoveToMouse()
  
  if W.ready and Ball == myHero then
    CastSpell(_W)
  end
  
end

---------------------------------------------------------------------------------

function HealthPercent(unit)
  return (unit.health/unit.maxHealth)*100
end

function ManaPercent()
  return (myHero.mana/myHero.maxMana)*100
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
  
    if Q.ready then
      APDmg = 30*Q.level+30+.5*AP
    end
    
  elseif spell == "W" then
  
    if W.ready then
      APDmg = 45*W.level+25+.7*AP
    end
    
  elseif spell == "E" then
  
    if E.ready then
      ADDmg = 30*E.level+30+.3*AP
    end
    
  elseif spell == "R" then
  
    if R.ready then
      APDmg = 75*R.level+75+.7*AP
    end
    
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQ(unit, mode)

  if Ball == nil then
    return
  end
  
  QPos, QHitChance = HPred:GetPredict("Q", unit, Ball)
  
  if mode == "Combo" and QHitChance >= Menu.HitChance.Combo.Q or mode == "Harass" and QHitChance >= Menu.HitChance.Harass.Q or mode == nil and QHitChance >= 1 then
  
    if VIP_USER and Menu.Misc.UsePacket then
      Packet("S_CAST", {spellId = _Q, toX = QPos.x, toY = QPos.z, fromX = QPos.x, fromY = QPos.z}):send()
    else
      CastSpell(_Q, QPos.x, QPos.z)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function CastW(unit, mode)

  if Ball == nil then
    return
  end
  
  WPos, WHitChance = HPred:GetPredict("W", unit, Ball)
  
  if mode == "Combo" and WHitChance >= Menu.HitChance.Combo.W or mode == "Harass" and WHitChance >= Menu.HitChance.Harass.W or mode == nil and WHitChance >= 2 then
  
    if VIP_USER and Menu.Misc.UsePacket then
      Packet("S_CAST", {spellId = _W}):send()
    else
      CastSpell(_W)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function CastE(unit)

  if Ball == nil or Ball == myHero then
    return
  end
  
  EHit = HPred:SpellCollision("E", unit, Ball, myHero)
  
  if EHit then
  
    if VIP_USER and Menu.Misc.UsePacket then
      Packet("S_CAST", {spellId = _E, targetNetworkId = myHero.networkID}):send()
    else
      CastSpell(_E, myHero)
    end
    
  end
  
end

---------------------------------------------------------------------------------

function CastEMe()

  if Ball == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E, targetNetworkId = myHero.networkID}):send()
  else
    CastSpell(_E, myHero)
  end
  
end

---------------------------------------------------------------------------------

function CastR(unit, mode)

  if Ball == nil then
    return
  end
  
  RPos, RHitChance, RNoH = HPred:GetPredict("R", unit, Ball, true)
  
  if mode == "Combo" and (RHitChance >= Menu.HitChance.Combo.R and (Q.ready and GetDmg("Q", unit) or 0)+(W.ready and GetDmg("W", unit) or 0)+GetDmg("R", unit) >= unit.health or RNoH >= Menu.Combo.R3) or mode == nil and RHitChance >= 2 then
  
    if VIP_USER and Menu.Misc.UsePacket then
      Packet("S_CAST", {spellId = _R}):send()
    else
      CastSpell(_R)
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
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.Target.W and WTarget ~= nil then
    DrawCircle(WTarget.x, WTarget.y, WTarget.z, W.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.Target.E and ETarget ~= nil then
    DrawCircle(ETarget.x, ETarget.y, ETarget.z, E.width/2, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.Target.R and RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if QHitChance ~= nil then
  
    if QHitChance == 0 then
      Qcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif QHitChance == 3 then
      Qcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif QHitChance >= 2 then
      Qcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif QHitChance >= 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  
  if WHitChance ~= nil then
  
    if WHitChance == 0 then
      Wcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif WHitChance == 3 then
      Wcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif WHitChance >= 2 then
      Wcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif WHitChance >= 1 then
      Wcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  
  if EHit ~= nil then
  
    if EHit then
      Ecolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    else
      Ecolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    end
    
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
  
  if Ball ~= nil then
  
    if Menu.Draw.PP.Q and QPos ~= nil then
    
      DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, Qcolor)
      
      if Menu.Draw.PP.Line then
        DrawLine3D(Ball.x, Ball.y, Ball.z, QPos.x, QPos.y, QPos.z, 2, Qcolor)
      end
      
      QPos = nil
    end
    
    if Menu.Draw.PP.W and WPos ~= nil then
    
      DrawCircle(WPos.x, WPos.y, WPos.z, W.radius, Wcolor)
      
      if Menu.Draw.PP.Line then
        DrawLine3D(Ball.x, Ball.y, Ball.z, WPos.x, WPos.y, WPos.z, 2, Wcolor)
      end
      
      WPos = nil
    end
    
    if Menu.Draw.PP.E and EHit ~= nil then
      DrawLine3D(Ball.x, Ball.y, Ball.z, myHero.x, myHero.y, myHero.z, 2, Ecolor)
    end
    
    if Menu.Draw.PP.R and RPos ~= nil then
    
      DrawCircle(RPos.x, RPos.y, RPos.z, R.radius, Rcolor)
      
      if Menu.Draw.PP.Line then
        DrawLine3D(Ball.x, Ball.y, Ball.z, RPos.x, RPos.y, RPos.z, 2, Rcolor)
      end
      
      RPos = nil
    end
    
  end
  
  if Menu.Draw.Hitchance then
  
    if QHitChance ~= nil then
      DrawText("Q HitChance: "..QHitChance, 20, 1250, 550, Qcolor)
      QHitChance = nil
    end
  
    if WHitChance ~= nil then
      DrawText("W HitChance: "..WHitChance, 20, 1250, 600, Wcolor)
      WHitChance = nil
    end
  
    if EHit ~= nil then
      DrawText("E Hit: "..tostring(EHit), 20, 1250, 650, Ecolor)
    end
    
    if RHitChance ~= nil then
      DrawText("R HitChance: "..RHitChance, 20, 1250, 700, Rcolor)
      RHitChance = nil
      
      if RNoH ~= nil then
        DrawText("R NoH: "..RNoH, 20, 1050, 550, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
        RNoH = nil
      end
      
    end
    
  end
  
  EHit = nil
  
  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, TrueRange, ARGB(0xFF, 0, 0xFF, 0))
  end
  
  if Menu.Draw.Q then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.W and W.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, W.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.E and E.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, E.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.R and R.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, R.range, ARGB(0xFF, 0x00, 0x00, 0xFF))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, ARGB(0xFF, 0xFF, 0x24, 0x24))
  end
  
  if Menu.Draw.S and S.ready and (Menu.JSteal.On or Menu.JSteal.On2) and Menu.JSteal.S then
    DrawCircle(myHero.x, myHero.y, myHero.z, S.range, ARGB(0xFF, 0xFF, 0x14, 0x93))
  end
  
  if Menu.Draw.Ball and Ball ~= nil then
    DrawCircle(Ball.x, Ball.y, Ball.z, Q.radius, ARGB(0xFF, 0xFF, 0x5E, 0x00))
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
  
  if animation == "Prop" then
    Ball = unit
  end
  
end

---------------------------------------------------------------------------------

function OnCreateObj(object)

  if object.team ~= myHero.team then
    return
  end
  
  if object.name == "TheDoomBall" and object.team == myHero.team then
    Ball = object
  end
  
end

---------------------------------------------------------------------------------

function OnProcessSpell(unit, spell)

  if not unit.isMe then
    return
  end
  
  if spell.name == "OrianaIzunaCommand" then
    Ball = nil
  end
  
  if spell.name == "OrianaRedactCommand" then
    Ball = spell.target
  end
  
end
