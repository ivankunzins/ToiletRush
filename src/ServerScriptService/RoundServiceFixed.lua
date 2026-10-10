local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService=require(game.ServerScriptService:WaitForChild("RoundStatsService"))
local RoundService={State="INTERMISSION",EndAt=0,PhaseEndAt=0,RoundNumber=0}
function RoundService:GetTimeLeft()if self.State~="ROUND"then return 0 end;return math.max(0,math.ceil(self.EndAt-os.clock()))end
function RoundService:GetQueuedPlayers()local q={};for _,p in Players:GetPlayers()do if p:GetAttribute("Queued")==true then table.insert(q,p)end end;return q end
local function hasActiveRoundPlayers()
 for _,player in ipairs(Players:GetPlayers()) do
  if player:GetAttribute("RoundActive")==true then return true end
 end
 return false
end
local function fireRoundClients(stateRemote,event,...)
 for _,player in ipairs(Players:GetPlayers()) do
  if player:GetAttribute("RoundActive")==true then stateRemote:FireClient(player,event,...) end
 end
end
local function fireRoundFeedback(event,...)
 local remotes=ReplicatedStorage:FindFirstChild("Remotes")
 local feedback=remotes and remotes:FindFirstChild("Feedback")
 if not feedback then return end
 for _,player in ipairs(Players:GetPlayers()) do
  if player:GetAttribute("RoundActive")==true then feedback:FireClient(player,event,...) end
 end
end
function RoundService:SyncPlayer(player,stateRemote)
 if not player.Parent then return end
 if self.State=="INTERMISSION" then
  stateRemote:FireClient(player,"INTERMISSION",math.max(0,math.ceil(self.PhaseEndAt-os.clock())))
 elseif player:GetAttribute("RoundActive")==true and self.State=="ROUND" then
  stateRemote:FireClient(player,"ROUND_START",Config.Round.Duration,self.RoundNumber)
  stateRemote:FireClient(player,"TICK",self:GetTimeLeft())
 elseif player:GetAttribute("RoundActive")==true and self.State=="BOSS" then
  stateRemote:FireClient(player,"BOSS_START",Config.Boss.Health)
 end
end
local function teleportPlayer(player,index,arena)local character=player.Character;local humanoid=character and character:FindFirstChildOfClass("Humanoid");if not character or not humanoid or humanoid.Health<=0 then player:LoadCharacter();character=player.Character or player.CharacterAdded:Wait()end;local root=character:WaitForChild("HumanoidRootPart",8);local newHumanoid=character:FindFirstChildOfClass("Humanoid");local spawns=arena:WaitForChild("Spawns"):GetChildren();if root and #spawns>0 then local s=spawns[((index-1)%#spawns)+1];root.CFrame=s.CFrame+Vector3.new(0,4,0);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end;if newHumanoid then newHumanoid.Health=newHumanoid.MaxHealth;newHumanoid.AutoRotate=true end;return newHumanoid end
function RoundService:Run(arena,stateRemote,coinService,shopService,dataService,achievementService,bossService,minionService)
 while true do
  self.State="INTERMISSION";self.EndAt=0;self.PhaseEndAt=os.clock()+Config.Round.Intermission
  for remaining=Config.Round.Intermission,1,-1 do stateRemote:FireAllClients("INTERMISSION",remaining);task.wait(1)end;self.PhaseEndAt=0
  local players=self:GetQueuedPlayers();if #players<Config.Round.MinimumPlayers then stateRemote:FireAllClients("LOBBY_WAIT",#players,Config.Round.MinimumPlayers);task.wait(1);continue end
  self.RoundNumber+=1;shopService:Reset();RoundStatsService:Reset(players);local deathConnections={};local characterConnections={};local recovering={}
  local function disconnectDeath(player)local c=deathConnections[player];if c then c:Disconnect();deathConnections[player]=nil end end
  local function bindCharacter(player,index)local character=player.Character;local humanoid=character and character:FindFirstChildOfClass("Humanoid");if not humanoid then return end;disconnectDeath(player);deathConnections[player]=humanoid.Died:Connect(function()if player:GetAttribute("RoundActive")~=true or recovering[player] then return end;recovering[player]=true;task.delay(.7,function()recovering[player]=nil;if player.Parent and player:GetAttribute("RoundActive")==true and player:GetAttribute("Eliminated")~=true then teleportPlayer(player,index,arena)end end)end)end
  for i,player in ipairs(players)do player:SetAttribute("HasLifebuoy",false);player:SetAttribute("RoundActive",true);player:SetAttribute("FlushActive",false);player:SetAttribute("Eliminated",false);player:SetAttribute("ReachedTop",false);player:SetAttribute("LastRoundSurvived",false);player:SetAttribute("StoryStage",0);player:SetAttribute("LobbyStatus","IN_ROUND");teleportPlayer(player,i,arena);bindCharacter(player,i);characterConnections[player]=player.CharacterAdded:Connect(function()if player:GetAttribute("RoundActive")~=true then return end;task.defer(function()if player.Parent and player:GetAttribute("RoundActive")==true and player:GetAttribute("Eliminated")~=true then bindCharacter(player,i)end end)end)end
  coinService:Start(arena,dataService);self.State="ROUND";self.EndAt=os.clock()+Config.Round.Duration;self.PhaseEndAt=self.EndAt;fireRoundClients(stateRemote,"ROUND_START",Config.Round.Duration,self.RoundNumber)
  local feedbackRemote=ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Feedback")
  if feedbackRemote then
   for _,player in ipairs(players) do
    feedbackRemote:FireClient(player,"STORY_INTRO","🚽 АВАРИЙНЫЙ СМЫВ! Хранитель Ванной запечатал слив. Пройди пять испытаний и доберись до золотой лестницы за 180 секунд.")
   end
  end
  while self:GetTimeLeft()>0 do fireRoundClients(stateRemote,"TICK",self:GetTimeLeft());task.wait(1)end
  coinService:Stop()
  self.State="BOSS";self.EndAt=0;self.PhaseEndAt=0
  local remotes=ReplicatedStorage:FindFirstChild("Remotes")
  local feedback=remotes and remotes:FindFirstChild("Feedback")
  fireRoundFeedback("BOSS_WARNING","🚨 ВРЕМЯ ВЫШЛО! ХРАНИТЕЛЬ ВАННОЙ ПРОБУЖДАЕТСЯ!")
  task.wait(Config.Boss.WarningSeconds or 3)
  if not hasActiveRoundPlayers() then
   if minionService then minionService:Stop() end
   if bossService.Stop then bossService:Stop() end
   for _,connection in pairs(deathConnections) do connection:Disconnect() end
   for _,connection in pairs(characterConnections) do connection:Disconnect() end
   task.wait(1)
   continue
  end
  fireRoundClients(stateRemote,"BOSS_START",Config.Boss.Health)
  bossService:Start(arena)
  if minionService then minionService:Start(arena) end
  local bossDeadline=os.clock()+(Config.Boss.Duration or 180)
  while not bossService:IsDefeated() and os.clock()<bossDeadline and hasActiveRoundPlayers() do
   fireRoundClients(stateRemote,"BOSS_TICK",bossService:GetHealth(),Config.Boss.Health)
   task.wait(.5)
  end
  local bossDefeated=bossService:IsDefeated()
  local timedOut=not bossDefeated and hasActiveRoundPlayers() and os.clock()>=bossDeadline
  if minionService then minionService:Stop()end
  if bossService.Stop then bossService:Stop()end
  if timedOut then
   local remotes=ReplicatedStorage:FindFirstChild("Remotes")
   local feedback=remotes and remotes:FindFirstChild("Feedback")
   fireRoundFeedback("BOSS_TIMEOUT","⏰ Время вышло! Босс не побеждён.")
  end
  for _,player in ipairs(Players:GetPlayers())do
   if player:GetAttribute("RoundActive")~=true then continue end
   player:SetAttribute("LastRoundSurvived",bossDefeated)
   player:SetAttribute("RoundActive",false)
   player:SetAttribute("FlushActive",false)
   player:SetAttribute("ReachedTop",false)
   player:SetAttribute("LobbyStatus","QUEUED")
   local stats=RoundStatsService:Get(player)
   local participationCoins=Config.Economy.ParticipationReward or 0
   local participationXP=Config.Progression.ParticipationXP or 0
   if participationCoins>0 then dataService:AddCoins(player,participationCoins) end
   if participationXP>0 then dataService:AddXP(player,participationXP) end
   if bossDefeated then
    local survivalCoins=Config.Economy.SurvivalReward or 0
    local survivalXP=Config.Progression.SurvivalXP or 0
    if survivalCoins>0 then dataService:AddCoins(player,survivalCoins) end
    if survivalXP>0 then dataService:AddXP(player,survivalXP) end
   end
   dataService:MarkRound(player,bossDefeated)
   if achievementService then achievementService:EvaluateRound(player,stats,bossDefeated)end
   local feedbackRemote=ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Feedback")
   if feedbackRemote then
    local totalCoins=participationCoins+(bossDefeated and (Config.Economy.SurvivalReward or 0) or 0)
    local totalXP=participationXP+(bossDefeated and (Config.Progression.SurvivalXP or 0) or 0)
    feedbackRemote:FireClient(player,"ROUND_REWARD",("🎁 НАГРАДА: +%d МОНЕТ • +%d XP%s"):format(totalCoins,totalXP,bossDefeated and " • ПОБЕДА!" or ""))
   end
   stateRemote:FireClient(player,"ROUND_STATS",stats,bossDefeated)
  end
  for _,c in pairs(deathConnections)do c:Disconnect()end;for _,c in pairs(characterConnections)do c:Disconnect()end;task.wait(Config.Round.ResultsDuration)
 end
end
return RoundService