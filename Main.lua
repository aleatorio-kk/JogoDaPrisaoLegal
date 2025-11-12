--[[
Todos os direitos reservados. ©aleatoriokk - GitHub do Proprietário Original: github.com/aleatorio-kk
Não é permitido a republicação do mesmo.
Sinta-se livre para utilizar ou pegar partes do código source original, mas NÃO republique o source como se ele fosse de sua autoria ou domínio.

All rights reserved. ©aleatoriokk - Official Owner GitHub: github.com/aleatorio-kk
No repost allowed.
Feel free to take some parts from the source, but DON'T repost by impersonating this script is yours.
]]

-- Completamente Open Source
-- Si divirta muitu

--[[

Agradecimentos / Creditos:
*https://github.com/EdgeIY/infiniteyield ou *https://github.com/EdgeIY:
 - Maior parte das ideias de comando e algumas funções foram diretamente retiradas do source de lá.
 - O funcionamento da maior parte dos comandos foi retirado a ideia de lá também (findcmd, addcmd, execcmd, etc)
 - É um Universal Admin incrível, você deveria usar :)

*Tiger Admin e Prizzlife:
 - Infelizmente não tenho ideia de onde esses dois vieram originalmente, mas creio que sejam os dois melhores admins já criados pra Prison Life. :P
 - A ideia de criar meu próprio sistema de script de adm pra essa bomba de jogo foi por causa que eu gostaria de criar algo novo, e também já era muito fã de criar script pra PL. (kill aura, tp, kill, etc)
 - Esses dois foram o chute inicial pra ideia que eu precisava no início pra realmente começar a querer criar um admin pra isso.

Special Thanks / Credits:
*https://github.com/EdgeIY/infiniteyield or *https://github.com/EdgeIY:
 - Most of commands ideas and some functions has been got directly from the source from IY.
 - The commands ideas and ways to execute and create commands has been gotten from it too! (findcmd, addcmd, execcmd, etc)
 - A pretty nice Universal Admin. (you should try too)

*Tiger Admin & Prizzlife:
 - Sadly, i don't know the official page or loadstring or GitHub from both, but i know these both are one of the bests already created admins for Prison Life :P
 - The idea about create my own Admin Panel for that i had due i was thinking about create something new, and i already was a big fan from create some scripts for PL. (kill aura, to, kill, etc)
 - These two admins got in my mind the first real kick for startup this project and share it with people.

]]--

-- [[ Aleatoriokk Hub ]] --
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CurrentVersion = "1.0.0"

local VersionBlitz = false

local parentupvr = game:FindFirstChildOfClass("CoreGui")

task.spawn(function()
	local success, latestVersionInfo = pcall(function() 
		local versionJson = game:HttpGet("https://raw.githubusercontent.com/aleatorio-kk/JogoDaPrisaoLegal/refs/heads/main/Version")
		return HttpService:JSONDecode(versionJson)
	end)

	if success and latestVersionInfo and latestVersionInfo.Version then
		local latestVersion = latestVersionInfo.Version
		if CurrentVersion ~= latestVersion then
			VersionBlitz = true
		elseif CurrentVersion == latestVersion then
			VersionBlitz = false
		end
	end
end)

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local mouse = plr:GetMouse()
local camera = workspace.CurrentCamera
local IsOnMobile

if UserInputService.TouchEnabled then
	IsOnMobile = true
else
	IsOnMobile = false
end

local Prefix = ";"
local CloseBind = Enum.KeyCode.RightShift

local KASize = 20
local showaurastatus = false

local WhitelistedPlayers = {}

local isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService

local function AddWhitelist(player)
	if player and player:IsA("Player") then
		WhitelistedPlayers[player.UserId] = true
	end
end

local function RemoveWhitelist(player)
	if player and player:IsA("Player") then
		WhitelistedPlayers[player.UserId] = nil
	end
end

local function IsWhitelisted(player)
	return player and WhitelistedPlayers[player.UserId] == true
end

local Commands = {}

local function AddCommand(name, aliases, func)
	Commands[name] = {
		Name = name,
		Aliases = aliases or {},
		Func = func,
	}
end

local function GetCommand(str)
	local lowerStr = str:lower()
	local cmd = Commands[lowerStr]
	if cmd then return cmd end
	for _, c in pairs(Commands) do
		for _, alias in ipairs(c.Aliases) do
			if alias:lower() == lowerStr then
				return c
			end
		end
	end
	return nil
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(mouse.X, mouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
}

local Cmds = {
	{Name = "cmds", Description = "Displays a list of available commands."},
	{Name = "cmdbar", Description = "Enables the Command Bar UI."},
	{Name = "getscript", Description = "Copies the script link to your clipboard."},
	{Name = "hub", Description = "Makes the hub visible or not."},
	{Name = "console", Description = "Opens the Developer Console."},
	{Name = "dex", Description = "Opens the DEX (By Moon)."},
	{Name = "remotespy", Description = "Opens Simple Spy V3."},
	{Name = "audiologger", Description = "Opens Edges audio logger."},
	{Name = "refresh", Description = "Refreshes your character."},
	{Name = "whitelist", Description = "Adds a player to the whitelist. (Ignores multiple players commands. it only applies to 'kill all' or 'killaura', etc.)"},
	{Name = "unwhitelist", Description = "Removes a player from the whitelist."},
	{Name = "killaura", Description = "Creates a aura that kills anyone touchs or get near."},
	{Name = "unkillaura", Description = "Disables Kill Aura"},
	{Name = "aurareload", Description = "Reloads the Kill Aura"},
	{Name = "showaura", Description = "Shows the radius size from the aura."},
	{Name = "killaurasize", Description = "Changes the Kill Aura Size. (Min. Size:1 - Max. Size:20)"},
	{Name = "fly", Description = "Makes you fly."},
	{Name = "unfly", Description = "Disables the fly."},
	{Name = "flyspeed", Description = "Changes the fly speed."},
	{Name = "vfly", Description = "Makes you fly inside a vehicle. (vehicle fly too if you are the driver)"},
	{Name = "unvfly", Description = "Disables the vfly."},
	{Name = "vflyspeed", Description = "Changes the fly speed of the vfly."},
	{Name = "cfly", Description = "Makes you fly, but only at your vision. (Like Client-Only visual exploits)"},
	{Name = "uncfly", Description = "Disables the cfly. (for other people, it should be like a teleport if you are not at your last position)"},
	{Name = "cflyspeed", Description = "Changes the cfly speed."},
	{Name = "float", Description = "Makes you float and plane walk through air."},
	{Name = "unfloat", Description = "Disables the float."},
	{Name = "noclip", Description = "Ables you to walk through solid objects."},
	{Name = "unnoclip", Description = "Disables the noclip."},
	{Name = "goto", Description = "Teleports you to a player."},
	{Name = "breakvelocity", Description = "Sets your Characters Velocity to 0."},
	{Name = "spin", Description = "Do your Character to spin."},
	{Name = "unspin", Description = "Stops spin."},
	{Name = "speed", Description = "Changes your walk speed."},
	{Name = "jump", Description = "Changes your jump power."},
	{Name = "antibring", Description = "Disables you to sit and don't be killed by exploiters with Cars."},
	{Name = "unantibring", Description = "Enables you to sit normally."},
	{Name = "sit", Description = "Makes your Character sit."},
	{Name = "savepos", Description = "Saves your current position."},
	{Name = "loadpos", Description = "Loads the saved position. (Should save before load)"},
}

local function ExecuteCommand(commandStr, player, args)
	local cmd = GetCommand(commandStr)
	if not cmd then return end

	cmd.Func(player, args)
end

function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

local function SendSystemChatMessage(text)
	TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(text)
end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

local PrisonLife = Instance.new("ScreenGui")
local Holder = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UITitleUIPadding = Instance.new("UIPadding")
local Close = Instance.new("TextButton")
local CloseButtonUIStroke = Instance.new("UIStroke")
local Min = Instance.new("TextButton")
local MinButtonUIStroke = Instance.new("UIStroke")
local HolderFrameUIStroke = Instance.new("UIStroke")
local Main = Instance.new("Frame")
local MainUIFrameUIStroke = Instance.new("UIStroke")
local Tabs = Instance.new("Frame")
local TabsFrameUIStroke = Instance.new("UIStroke")
local TabsFrameUIListLayout = Instance.new("UIListLayout")
local TabButtonMain = Instance.new("TextButton")
local TabButtonMainStroke = Instance.new("UIStroke")
local TabsFrameUIPadding = Instance.new("UIPadding")
local TabButtonLP = Instance.new("TextButton")
local TabButtonLPStroke = Instance.new("UIStroke")
local TabButtonSettings = Instance.new("TextButton")
local TabButtonSettingsStroke = Instance.new("UIStroke")
local TabsFrameHolder = Instance.new("Frame")
local MainTab = Instance.new("Frame")
local CmdBarButtonOpen = Instance.new("TextButton")
local UIStroke = Instance.new("UIStroke")
local CommandsButton = Instance.new("TextButton")
local UIStroke_2 = Instance.new("UIStroke")
local PlayersButton = Instance.new("TextButton")
local UIStroke_3 = Instance.new("UIStroke")
local DisclaimerText = Instance.new("TextLabel")
local UIStroke_4 = Instance.new("UIStroke")
local Playerslolidk = Instance.new("TextLabel")
local LPTab = Instance.new("Frame")
local RefreshCharButton = Instance.new("TextButton")
local UIStroke_5 = Instance.new("UIStroke")
local JumpPowerInputFrame = Instance.new("Frame")
local UIStroke_6 = Instance.new("UIStroke")
local JumpPowerInputText = Instance.new("TextBox")
local ChangeJumpButton = Instance.new("TextButton")
local UIStroke_7 = Instance.new("UIStroke")
local WalkSpeedInputFrame = Instance.new("Frame")
local UIStroke_8 = Instance.new("UIStroke")
local WalkspeedInputText = Instance.new("TextBox")
local ChangeSpeedButton = Instance.new("TextButton")
local UIStroke_9 = Instance.new("UIStroke")
local CriminalButton = Instance.new("TextButton")
local UIStroke_10 = Instance.new("UIStroke")
local GuardButton = Instance.new("TextButton")
local UIStroke_11 = Instance.new("UIStroke")
local InmateButton = Instance.new("TextButton")
local UIStroke_12 = Instance.new("UIStroke")
local SettingsTab = Instance.new("Frame")
local SettingsScrouller = Instance.new("ScrollingFrame")
local ExampleSettingsButton = Instance.new("TextButton")
local ExampleUIStrokeeeeerr = Instance.new("UIStroke")
local SettingsScroullerUIListLayout = Instance.new("UIListLayout")
local SettingsScroullerUIPadding = Instance.new("UIPadding")

local CommandListHolder = Instance.new("Frame")
local Title_2 = Instance.new("TextLabel")
local UITitleUIPadding_2 = Instance.new("UIPadding")
local Close_2 = Instance.new("TextButton")
local CloseButtonUIStroke_2 = Instance.new("UIStroke")
local Min_2 = Instance.new("TextButton")
local MinButtonUIStroke_2 = Instance.new("UIStroke")
local CmdMain = Instance.new("Frame")
local CmdMainUIStroke = Instance.new("UIStroke")
local Scrollinnnnnng = Instance.new("ScrollingFrame")
local ScrollinnnnnngUIListLayout = Instance.new("UIListLayout")
local ScrollinnnnnngUIPadding = Instance.new("UIPadding")
local CommandTemplate = Instance.new("TextLabel")
local CommandListHolderUIStroke = Instance.new("UIStroke")
local CommandTip = Instance.new("Frame")
local BeautifuTipUIStroke = Instance.new("UIStroke")
local TipTextLabel = Instance.new("TextLabel")
local BeautifuTipNameUIStroke = Instance.new("UIStroke")
local TipDescLabel = Instance.new("TextLabel")
local BeautifuTipDescUIStroke = Instance.new("UIStroke")
local TipAliasLabel = Instance.new("TextLabel")
local BeautifuTipAliasUIStroke = Instance.new("UIStroke")


local CommandBarHolder = Instance.new("Frame")
local Title_3 = Instance.new("TextLabel")
local UITitleUIPadding_3 = Instance.new("UIPadding")
local Close_3 = Instance.new("TextButton")
local CloseButtonUIStroke_3 = Instance.new("UIStroke")
local Min_3 = Instance.new("TextButton")
local MinButtonUIStroke_3 = Instance.new("UIStroke")
local CmdBarMain = Instance.new("Frame")
local CmdBarMainUIStroke = Instance.new("UIStroke")
local CommandBar = Instance.new("TextBox")
local CommandBarUIStroke = Instance.new("UIStroke")
local CommandBarHolderUIStroke = Instance.new("UIStroke")


local NotifyHolder = Instance.new("Frame")
local NotifyTemplate = Instance.new("Frame")
local NotifyContentText = Instance.new("TextLabel")
local NotUIStroke = Instance.new("UIStroke")
local NHolderUIListLayout = Instance.new("UIListLayout")

PrisonLife.Name = "Aleatoriokk | Prison Life"
PrisonLife.Parent = parentupvr
PrisonLife.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
PrisonLife.DisplayOrder = 999
PrisonLife.ResetOnSpawn = false

Holder.Name = "Holder"
Holder.Parent = PrisonLife
Holder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(0.285203725, 0, 0.326767087, 0)
if IsOnMobile then
	Holder.Size = UDim2.new(0.3, 0, 0.065, 0)
else
	Holder.Size = UDim2.new(0.235109717, 0, 0.0405561998, 0)
end

Title.Name = "Title"
Title.Parent = Holder
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(0.788888872, 0, 1, 0)
Title.Font = Enum.Font.Nunito
Title.RichText = true
Title.Text = "Aleatoriokk Hub | <font color='rgb(0, 0, 155)'>P</font><font color='rgb(255, 155, 0)'>L</font> Admin Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextSize = 14.000
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

UITitleUIPadding.Name = "UITitleUIPadding"
UITitleUIPadding.Parent = Title
UITitleUIPadding.PaddingLeft = UDim.new(0, 8)

Close.Name = "Close"
Close.Parent = Holder
Close.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.895555556, 0, 0, 0)
Close.Size = UDim2.new(0.104444444, 0, 1, 0)
Close.Font = Enum.Font.SourceSans
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextScaled = true
Close.TextSize = 14.000
Close.TextWrapped = true

CloseButtonUIStroke.Name = "CloseButtonUIStroke"
CloseButtonUIStroke.Parent = Close
CloseButtonUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CloseButtonUIStroke.Color = Color3.fromRGB(255, 255, 255)

Min.Name = "Min"
Min.Parent = Holder
Min.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
Min.BorderSizePixel = 0
Min.Position = UDim2.new(0.788315594, 0, 0, 0)
Min.Size = UDim2.new(0.104444444, 0, 1, 0)
Min.Font = Enum.Font.SourceSans
Min.Text = "-"
Min.TextColor3 = Color3.fromRGB(255, 255, 255)
Min.TextScaled = true
Min.TextSize = 14.000
Min.TextWrapped = true

MinButtonUIStroke.Name = "MinButtonUIStroke"
MinButtonUIStroke.Parent = Min
MinButtonUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MinButtonUIStroke.Color = Color3.fromRGB(255, 255, 255)

HolderFrameUIStroke.Name = "HolderFrameUIStroke"
HolderFrameUIStroke.Parent = Holder
HolderFrameUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
HolderFrameUIStroke.Color = Color3.fromRGB(255, 255, 255)

Main.Name = "Main"
Main.Parent = Holder
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 0, 1, 0)
Main.Size = UDim2.new(1, 0, 11.4285717, 0)

MainUIFrameUIStroke.Name = "MainUIFrameUIStroke"
MainUIFrameUIStroke.Parent = Main
MainUIFrameUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainUIFrameUIStroke.Color = Color3.fromRGB(255, 255, 255)

Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tabs.BackgroundTransparency = 1.000
Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
Tabs.BorderSizePixel = 0
Tabs.Size = UDim2.new(1, 0, 0.150000006, 0)

TabsFrameUIStroke.Name = "TabsFrameUIStroke"
TabsFrameUIStroke.Parent = Tabs
TabsFrameUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TabsFrameUIStroke.Color = Color3.fromRGB(255, 255, 255)

TabsFrameUIListLayout.Name = "TabsFrameUIListLayout"
TabsFrameUIListLayout.Parent = Tabs
TabsFrameUIListLayout.FillDirection = Enum.FillDirection.Horizontal
TabsFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsFrameUIListLayout.Padding = UDim.new(0, 5)

TabButtonMain.Name = "TabButtonMain"
TabButtonMain.Parent = Tabs
TabButtonMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TabButtonMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
TabButtonMain.BorderSizePixel = 0
TabButtonMain.Position = UDim2.new(0, 0, 0.0833333284, 0)
TabButtonMain.Size = UDim2.new(0.321999997, 0, 0.833000004, 0)
TabButtonMain.AutoButtonColor = false
TabButtonMain.Font = Enum.Font.Nunito
TabButtonMain.Text = "Main"
TabButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtonMain.TextScaled = true
TabButtonMain.TextSize = 14.000
TabButtonMain.TextWrapped = true

TabButtonMainStroke.Name = "TabButtonMainStroke"
TabButtonMainStroke.Parent = TabButtonMain
TabButtonMainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TabButtonMainStroke.Color = Color3.fromRGB(255, 255, 255)

TabsFrameUIPadding.Name = "TabsFrameUIPadding"
TabsFrameUIPadding.Parent = Tabs
TabsFrameUIPadding.PaddingLeft = UDim.new(0, 15)
TabsFrameUIPadding.PaddingRight = UDim.new(0, 15)

TabButtonLP.Name = "TabButtonLP"
TabButtonLP.Parent = Tabs
TabButtonLP.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TabButtonLP.BorderColor3 = Color3.fromRGB(0, 0, 0)
TabButtonLP.BorderSizePixel = 0
TabButtonLP.LayoutOrder = 1
TabButtonLP.Position = UDim2.new(0, 0, 0.0833333284, 0)
TabButtonLP.Size = UDim2.new(0.321999997, 0, 0.833000004, 0)
TabButtonLP.AutoButtonColor = false
TabButtonLP.Font = Enum.Font.Nunito
TabButtonLP.Text = "Local Player"
TabButtonLP.TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtonLP.TextScaled = true
TabButtonLP.TextSize = 14.000
TabButtonLP.TextWrapped = true

TabButtonLPStroke.Name = "TabButtonLPStroke"
TabButtonLPStroke.Parent = TabButtonLP
TabButtonLPStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TabButtonLPStroke.Color = Color3.fromRGB(255, 255, 255)

TabButtonSettings.Name = "TabButtonSettings"
TabButtonSettings.Parent = Tabs
TabButtonSettings.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TabButtonSettings.BorderColor3 = Color3.fromRGB(0, 0, 0)
TabButtonSettings.BorderSizePixel = 0
TabButtonSettings.LayoutOrder = 2
TabButtonSettings.Position = UDim2.new(0, 0, 0.0833333284, 0)
TabButtonSettings.Size = UDim2.new(0.321999997, 0, 0.833000004, 0)
TabButtonSettings.AutoButtonColor = false
TabButtonSettings.Font = Enum.Font.Nunito
TabButtonSettings.Text = "Settings"
TabButtonSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtonSettings.TextScaled = true
TabButtonSettings.TextSize = 14.000
TabButtonSettings.TextWrapped = true

TabButtonSettingsStroke.Name = "TabButtonSettingsStroke"
TabButtonSettingsStroke.Parent = TabButtonSettings
TabButtonSettingsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TabButtonSettingsStroke.Color = Color3.fromRGB(255, 255, 255)

TabsFrameHolder.Name = "TabsFrameHolder"
TabsFrameHolder.Parent = Main
TabsFrameHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabsFrameHolder.BackgroundTransparency = 1.000
TabsFrameHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
TabsFrameHolder.BorderSizePixel = 0
TabsFrameHolder.Position = UDim2.new(0, 0, 0.155000001, 0)
TabsFrameHolder.Size = UDim2.new(1, 0, 0.845000029, 0)

MainTab.Name = "MainTab"
MainTab.Parent = TabsFrameHolder
MainTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainTab.BackgroundTransparency = 1.000
MainTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainTab.BorderSizePixel = 0
MainTab.Size = UDim2.new(1, 0, 1, 0)
MainTab.Visible = true

CmdBarButtonOpen.Name = "CmdBarButtonOpen"
CmdBarButtonOpen.Parent = MainTab
CmdBarButtonOpen.AnchorPoint = Vector2.new(0.5, 0.5)
CmdBarButtonOpen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdBarButtonOpen.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdBarButtonOpen.BorderSizePixel = 0
CmdBarButtonOpen.Position = UDim2.new(0.5, 0, 0.120999999, 0)
CmdBarButtonOpen.Size = UDim2.new(0.733333349, 0, 0.147928998, 0)
CmdBarButtonOpen.Font = Enum.Font.Nunito
CmdBarButtonOpen.Text = "Command Bar"
CmdBarButtonOpen.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdBarButtonOpen.TextScaled = true
CmdBarButtonOpen.TextSize = 14.000
CmdBarButtonOpen.TextWrapped = true
CmdBarButtonOpen.AutoButtonColor = false

UIStroke.Parent = CmdBarButtonOpen
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(255, 255, 255)

CommandsButton.Name = "CommandsButton"
CommandsButton.Parent = MainTab
CommandsButton.AnchorPoint = Vector2.new(0.5, 0.5)
CommandsButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CommandsButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
CommandsButton.BorderSizePixel = 0
CommandsButton.Position = UDim2.new(0.5, 0, 0.659461558, 0)
CommandsButton.Size = UDim2.new(0.733333349, 0, 0.147928998, 0)
CommandsButton.Font = Enum.Font.Nunito
CommandsButton.Text = "Command List"
CommandsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandsButton.TextScaled = true
CommandsButton.TextSize = 14.000
CommandsButton.TextWrapped = true
CommandsButton.AutoButtonColor = false

UIStroke_2.Parent = CommandsButton
UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_2.Color = Color3.fromRGB(255, 255, 255)

PlayersButton.Name = "PlayersButton"
PlayersButton.Parent = MainTab
PlayersButton.AnchorPoint = Vector2.new(0.5, 0.5)
PlayersButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayersButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
PlayersButton.BorderSizePixel = 0
PlayersButton.Position = UDim2.new(0.5, 0, 0.842893541, 0)
PlayersButton.Size = UDim2.new(0.733333349, 0, 0.147928998, 0)
PlayersButton.Font = Enum.Font.Nunito
PlayersButton.Text = "Players List"
PlayersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayersButton.TextScaled = true
PlayersButton.TextSize = 14.000
PlayersButton.TextWrapped = true
PlayersButton.AutoButtonColor = false

UIStroke_3.Parent = PlayersButton
UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_3.Color = Color3.fromRGB(255, 255, 255)

DisclaimerText.Name = "DisclaimerText"
DisclaimerText.Parent = MainTab
DisclaimerText.AnchorPoint = Vector2.new(0.5, 0.5)
DisclaimerText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DisclaimerText.BackgroundTransparency = 1.000
DisclaimerText.BorderColor3 = Color3.fromRGB(0, 0, 0)
DisclaimerText.BorderSizePixel = 0
DisclaimerText.Position = UDim2.new(0.5, 0, 0.375999987, 0)
DisclaimerText.Size = UDim2.new(0.888888896, 0, 0.266272157, 0)
DisclaimerText.Font = Enum.Font.Nunito
DisclaimerText.RichText = true
DisclaimerText.Text = "<font color='rgb(255,0,0)'>Disclaimer:</font> This Admin Panel is currently in W.I.P.(Working In Progress), things are supposed to change or be removed in some update."
DisclaimerText.TextColor3 = Color3.fromRGB(255, 255, 255)
DisclaimerText.TextScaled = true
DisclaimerText.TextSize = 14.000
DisclaimerText.TextWrapped = true

UIStroke_4.Parent = DisclaimerText
UIStroke_4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_4.Color = Color3.fromRGB(255, 255, 255)

Playerslolidk.Name = "Playerslolidk"
Playerslolidk.Parent = MainTab
Playerslolidk.AnchorPoint = Vector2.new(0.5, 0.5)
Playerslolidk.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Playerslolidk.BackgroundTransparency = 1.000
Playerslolidk.BorderColor3 = Color3.fromRGB(0, 0, 0)
Playerslolidk.BorderSizePixel = 0
Playerslolidk.Position = UDim2.new(0.5, 0, 0.957000017, 0)
Playerslolidk.Size = UDim2.new(0.888888896, 0, 0.0855384246, 0)
Playerslolidk.Font = Enum.Font.Nunito
Playerslolidk.Text = "Manage current in-server Players and do it without write any commands :)"
Playerslolidk.TextColor3 = Color3.fromRGB(255, 255, 255)
Playerslolidk.TextScaled = true
Playerslolidk.TextSize = 14.000
Playerslolidk.TextWrapped = true

LPTab.Name = "LPTab"
LPTab.Parent = TabsFrameHolder
LPTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LPTab.BackgroundTransparency = 1.000
LPTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
LPTab.BorderSizePixel = 0
LPTab.Size = UDim2.new(1, 0, 1, 0)
LPTab.Visible = false

RefreshCharButton.Name = "RefreshCharButton"
RefreshCharButton.Parent = LPTab
RefreshCharButton.AnchorPoint = Vector2.new(0.5, 0.5)
RefreshCharButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RefreshCharButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
RefreshCharButton.BorderSizePixel = 0
RefreshCharButton.Position = UDim2.new(0.5, 0, 0.120999999, 0)
RefreshCharButton.Size = UDim2.new(0.733333349, 0, 0.147928998, 0)
RefreshCharButton.Font = Enum.Font.Nunito
RefreshCharButton.Text = "Refresh Character"
RefreshCharButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshCharButton.TextScaled = true
RefreshCharButton.TextSize = 14.000
RefreshCharButton.TextWrapped = true
RefreshCharButton.AutoButtonColor = false

UIStroke_5.Parent = RefreshCharButton
UIStroke_5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_5.Color = Color3.fromRGB(255, 255, 255)

JumpPowerInputFrame.Name = "JumpPowerInputFrame"
JumpPowerInputFrame.Parent = LPTab
JumpPowerInputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
JumpPowerInputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerInputFrame.BackgroundTransparency = 1.000
JumpPowerInputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
JumpPowerInputFrame.BorderSizePixel = 0
JumpPowerInputFrame.Position = UDim2.new(0.5, 0, 0.610000014, 0)
JumpPowerInputFrame.Size = UDim2.new(0.73299998, 0, 0.170000002, 0)

UIStroke_6.Parent = JumpPowerInputFrame
UIStroke_6.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_6.Color = Color3.fromRGB(255, 255, 255)

JumpPowerInputText.Name = "JumpPowerInputText"
JumpPowerInputText.Parent = JumpPowerInputFrame
JumpPowerInputText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerInputText.BackgroundTransparency = 1.000
JumpPowerInputText.BorderColor3 = Color3.fromRGB(0, 0, 0)
JumpPowerInputText.BorderSizePixel = 0
JumpPowerInputText.Size = UDim2.new(0.99999994, 0, 0.600191832, 0)
JumpPowerInputText.Font = Enum.Font.Nunito
JumpPowerInputText.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
JumpPowerInputText.PlaceholderText = "Jump Input"
JumpPowerInputText.Text = ""
JumpPowerInputText.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerInputText.TextScaled = true
JumpPowerInputText.TextSize = 14.000
JumpPowerInputText.TextWrapped = true

ChangeJumpButton.Name = "ChangeJumpButton"
ChangeJumpButton.Parent = JumpPowerInputFrame
ChangeJumpButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ChangeJumpButton.BackgroundTransparency = 1.000
ChangeJumpButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ChangeJumpButton.BorderSizePixel = 0
ChangeJumpButton.Position = UDim2.new(0, 0, 0.600000024, 0)
ChangeJumpButton.Size = UDim2.new(1, 0, 0.400000006, 0)
ChangeJumpButton.Font = Enum.Font.Nunito
ChangeJumpButton.Text = "Change JumpPower"
ChangeJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ChangeJumpButton.TextScaled = true
ChangeJumpButton.TextSize = 14.000
ChangeJumpButton.TextWrapped = true
ChangeJumpButton.AutoButtonColor = false

UIStroke_7.Parent = ChangeJumpButton
UIStroke_7.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_7.Color = Color3.fromRGB(255, 255, 255)

WalkSpeedInputFrame.Name = "JumpPowerInputFrame"
WalkSpeedInputFrame.Parent = LPTab
WalkSpeedInputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
WalkSpeedInputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedInputFrame.BackgroundTransparency = 1.000
WalkSpeedInputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
WalkSpeedInputFrame.BorderSizePixel = 0
WalkSpeedInputFrame.Position = UDim2.new(0.5, 0, 0.379999995, 0)
WalkSpeedInputFrame.Size = UDim2.new(0.73299998, 0, 0.170000002, 0)

UIStroke_8.Parent = WalkSpeedInputFrame
UIStroke_8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_8.Color = Color3.fromRGB(255, 255, 255)

WalkspeedInputText.Name = "WalkspeedInputText"
WalkspeedInputText.Parent = WalkSpeedInputFrame
WalkspeedInputText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WalkspeedInputText.BackgroundTransparency = 1.000
WalkspeedInputText.BorderColor3 = Color3.fromRGB(0, 0, 0)
WalkspeedInputText.BorderSizePixel = 0
WalkspeedInputText.Size = UDim2.new(0.99999994, 0, 0.600191832, 0)
WalkspeedInputText.Font = Enum.Font.Nunito
WalkspeedInputText.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
WalkspeedInputText.PlaceholderText = "Speed Input"
WalkspeedInputText.Text = ""
WalkspeedInputText.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkspeedInputText.TextScaled = true
WalkspeedInputText.TextSize = 14.000
WalkspeedInputText.TextWrapped = true

ChangeSpeedButton.Name = "ChangeSpeedButton"
ChangeSpeedButton.Parent = WalkSpeedInputFrame
ChangeSpeedButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ChangeSpeedButton.BackgroundTransparency = 1.000
ChangeSpeedButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ChangeSpeedButton.BorderSizePixel = 0
ChangeSpeedButton.Position = UDim2.new(0, 0, 0.600000024, 0)
ChangeSpeedButton.Size = UDim2.new(1, 0, 0.400000006, 0)
ChangeSpeedButton.Font = Enum.Font.Nunito
ChangeSpeedButton.Text = "Change WalkSpeed"
ChangeSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ChangeSpeedButton.TextScaled = true
ChangeSpeedButton.TextSize = 14.000
ChangeSpeedButton.TextWrapped = true
ChangeSpeedButton.AutoButtonColor = false

UIStroke_9.Parent = ChangeSpeedButton
UIStroke_9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_9.Color = Color3.fromRGB(255, 255, 255)

CriminalButton.Name = "CriminalButton"
CriminalButton.Parent = LPTab
CriminalButton.AnchorPoint = Vector2.new(0.5, 0.5)
CriminalButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CriminalButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
CriminalButton.BorderSizePixel = 0
CriminalButton.Position = UDim2.new(0.308463126, 0, 0.807390571, 0)
CriminalButton.Size = UDim2.new(0.350259751, 0, 0.0887574032, 0)
CriminalButton.Font = Enum.Font.Nunito
CriminalButton.Text = "Criminal Team"
CriminalButton.TextColor3 = Color3.fromRGB(255, 0, 0)
CriminalButton.TextScaled = true
CriminalButton.TextSize = 14.000
CriminalButton.TextWrapped = true
CriminalButton.AutoButtonColor = false

UIStroke_10.Parent = CriminalButton
UIStroke_10.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_10.Color = Color3.fromRGB(255, 0, 0)

GuardButton.Name = "GuardButton"
GuardButton.Parent = LPTab
GuardButton.AnchorPoint = Vector2.new(0.5, 0.5)
GuardButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
GuardButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
GuardButton.BorderSizePixel = 0
GuardButton.Position = UDim2.new(0.49999994, 0, 0.928692341, 0)
GuardButton.Size = UDim2.new(0.350259751, 0, 0.0887574032, 0)
GuardButton.Font = Enum.Font.Nunito
GuardButton.Text = "Guard Team"
GuardButton.TextColor3 = Color3.fromRGB(0, 100, 255)
GuardButton.TextScaled = true
GuardButton.TextSize = 14.000
GuardButton.TextWrapped = true
GuardButton.AutoButtonColor = false

UIStroke_11.Parent = GuardButton
UIStroke_11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_11.Color = Color3.fromRGB(0, 100, 255)

InmateButton.Name = "InmateButton"
InmateButton.Parent = LPTab
InmateButton.AnchorPoint = Vector2.new(0.5, 0.5)
InmateButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InmateButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
InmateButton.BorderSizePixel = 0
InmateButton.Position = UDim2.new(0.691536784, 0, 0.807390571, 0)
InmateButton.Size = UDim2.new(0.350259751, 0, 0.0887573957, 0)
InmateButton.Font = Enum.Font.Nunito
InmateButton.Text = "Inmate Team"
InmateButton.TextColor3 = Color3.fromRGB(255, 100, 0)
InmateButton.TextScaled = true
InmateButton.TextSize = 14.000
InmateButton.TextWrapped = true
InmateButton.AutoButtonColor = false

UIStroke_12.Parent = InmateButton
UIStroke_12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_12.Color = Color3.fromRGB(255, 100, 0)

SettingsTab.Name = "SettingsTab"
SettingsTab.Parent = TabsFrameHolder
SettingsTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SettingsTab.BackgroundTransparency = 1.000
SettingsTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
SettingsTab.BorderSizePixel = 0
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.Visible = false

SettingsScrouller.Name = "SettingsScrouller"
SettingsScrouller.Parent = SettingsTab
SettingsScrouller.Active = true
SettingsScrouller.AnchorPoint = Vector2.new(0.5, 0.5)
SettingsScrouller.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SettingsScrouller.BackgroundTransparency = 1.000
SettingsScrouller.BorderColor3 = Color3.fromRGB(0, 0, 0)
SettingsScrouller.BorderSizePixel = 0
SettingsScrouller.Position = UDim2.new(0.5, 0, 0.5, 0)
SettingsScrouller.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
SettingsScrouller.ScrollBarThickness = 4
SettingsScrouller.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsScrouller.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"

ExampleSettingsButton.Name = "ExampleSettingsButton"
ExampleSettingsButton.Parent = SettingsScrouller
ExampleSettingsButton.AnchorPoint = Vector2.new(0.5, 0.5)
ExampleSettingsButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ExampleSettingsButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ExampleSettingsButton.BorderSizePixel = 0
ExampleSettingsButton.Position = UDim2.new(0.49999994, 0, 0.0657462254, 0)
ExampleSettingsButton.Size = UDim2.new(0.899999976, 0, 0, 40)
ExampleSettingsButton.Visible = false
ExampleSettingsButton.AutoButtonColor = false
ExampleSettingsButton.Font = Enum.Font.Nunito
ExampleSettingsButton.Text = "Command List"
ExampleSettingsButton.TextColor3 = Color3.fromRGB(0, 255, 0)
ExampleSettingsButton.TextScaled = true
ExampleSettingsButton.TextSize = 14.000
ExampleSettingsButton.TextWrapped = true

ExampleUIStrokeeeeerr.Name = "ExampleUIStrokeeeeerr"
ExampleUIStrokeeeeerr.Parent = ExampleSettingsButton
ExampleUIStrokeeeeerr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ExampleUIStrokeeeeerr.Color = Color3.fromRGB(0, 255, 0)

SettingsScroullerUIListLayout.Name = "SettingsScroullerUIListLayout"
SettingsScroullerUIListLayout.Parent = SettingsScrouller
SettingsScroullerUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SettingsScroullerUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsScroullerUIListLayout.Padding = UDim.new(0, 5)

SettingsScroullerUIPadding.Name = "SettingsScroullerUIPadding"
SettingsScroullerUIPadding.Parent = SettingsScrouller
SettingsScroullerUIPadding.PaddingBottom = UDim.new(0, 5)
SettingsScroullerUIPadding.PaddingTop = UDim.new(0, 5)


CommandListHolder.Name = "CommandListHolder"
CommandListHolder.Parent = PrisonLife
CommandListHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CommandListHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
CommandListHolder.BorderSizePixel = 0
CommandListHolder.Position = UDim2.new(0.600000024, 0, 0.326999992, 0)
CommandListHolder.Visible = false

if IsOnMobile then
	CommandListHolder.Size = UDim2.new(0.3, 0, 0.066, 0)
else
	CommandListHolder.Size = UDim2.new(0.235109717, 0, 0.0405561998, 0)
end

Title_2.Name = "Title"
Title_2.Parent = CommandListHolder
Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_2.BackgroundTransparency = 1.000
Title_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title_2.BorderSizePixel = 0
Title_2.Size = UDim2.new(0.788888872, 0, 1, 0)
Title_2.Font = Enum.Font.Nunito
Title_2.Text = "Command List"
Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_2.TextScaled = true
Title_2.TextSize = 14.000
Title_2.TextWrapped = true
Title_2.TextXAlignment = Enum.TextXAlignment.Left

UITitleUIPadding_2.Name = "UITitleUIPadding"
UITitleUIPadding_2.Parent = Title_2
UITitleUIPadding_2.PaddingLeft = UDim.new(0, 8)

Close_2.Name = "Close"
Close_2.Parent = CommandListHolder
Close_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Close_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close_2.BorderSizePixel = 0
Close_2.Position = UDim2.new(0.895555556, 0, 0, 0)
Close_2.Size = UDim2.new(0.104444444, 0, 1, 0)
Close_2.Font = Enum.Font.SourceSans
Close_2.Text = "X"
Close_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Close_2.TextScaled = true
Close_2.TextSize = 14.000
Close_2.TextWrapped = true

CloseButtonUIStroke_2.Name = "CloseButtonUIStroke"
CloseButtonUIStroke_2.Parent = Close_2
CloseButtonUIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CloseButtonUIStroke_2.Color = Color3.fromRGB(255, 255, 255)

Min_2.Name = "Min"
Min_2.Parent = CommandListHolder
Min_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Min_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Min_2.BorderSizePixel = 0
Min_2.Position = UDim2.new(0.788315594, 0, 0, 0)
Min_2.Size = UDim2.new(0.104444444, 0, 1, 0)
Min_2.Font = Enum.Font.SourceSans
Min_2.Text = "-"
Min_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Min_2.TextScaled = true
Min_2.TextSize = 14.000
Min_2.TextWrapped = true

MinButtonUIStroke_2.Name = "MinButtonUIStroke"
MinButtonUIStroke_2.Parent = Min_2
MinButtonUIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MinButtonUIStroke_2.Color = Color3.fromRGB(255, 255, 255)

CmdMain.Name = "CmdMain"
CmdMain.Parent = CommandListHolder
CmdMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdMain.BorderSizePixel = 0
CmdMain.Position = UDim2.new(0, 0, 1, 0)
CmdMain.Size = UDim2.new(1.00000012, 0, 13.7142868, 0)

CmdMainUIStroke.Name = "CmdMainUIStroke"
CmdMainUIStroke.Parent = CmdMain
CmdMainUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CmdMainUIStroke.Color = Color3.fromRGB(255, 255, 255)

Scrollinnnnnng.Name = "Scrollinnnnnng"
Scrollinnnnnng.Parent = CmdMain
Scrollinnnnnng.Active = true
Scrollinnnnnng.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Scrollinnnnnng.BackgroundTransparency = 1.000
Scrollinnnnnng.BorderColor3 = Color3.fromRGB(0, 0, 0)
Scrollinnnnnng.BorderSizePixel = 0
Scrollinnnnnng.Size = UDim2.new(1, 0, 1, 0)
Scrollinnnnnng.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Scrollinnnnnng.CanvasSize = UDim2.new(0, 0, 10, 0)
Scrollinnnnnng.ScrollBarThickness = 9
Scrollinnnnnng.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"

ScrollinnnnnngUIListLayout.Name = "ScrollinnnnnngUIListLayout"
ScrollinnnnnngUIListLayout.Parent = Scrollinnnnnng
ScrollinnnnnngUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ScrollinnnnnngUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollinnnnnngUIListLayout.Padding = UDim.new(0, 5)

ScrollinnnnnngUIPadding.Name = "ScrollinnnnnngUIPadding"
ScrollinnnnnngUIPadding.Parent = Scrollinnnnnng
ScrollinnnnnngUIPadding.PaddingBottom = UDim.new(0, 15)
ScrollinnnnnngUIPadding.PaddingTop = UDim.new(0, 15)

CommandTemplate.Name = "CommandTemplate"
CommandTemplate.Parent = Scrollinnnnnng
CommandTemplate.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CommandTemplate.BorderColor3 = Color3.fromRGB(0, 0, 0)
CommandTemplate.BorderSizePixel = 0
CommandTemplate.Position = UDim2.new(0.0439670198, 0, 0, 0)
CommandTemplate.Size = UDim2.new(0.912, 0, 0, 45)
CommandTemplate.Font = Enum.Font.Nunito
CommandTemplate.Text = "This is a command template!"
CommandTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandTemplate.TextScaled = true
CommandTemplate.TextSize = 14.000
CommandTemplate.TextWrapped = true
CommandTemplate.Visible = false

CommandListHolderUIStroke.Name = "CommandListHolderUIStroke"
CommandListHolderUIStroke.Parent = CommandListHolder
CommandListHolderUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CommandListHolderUIStroke.Color = Color3.fromRGB(255, 255, 255)

CommandTip.Name = "CommandTip"
CommandTip.Parent = PrisonLife
CommandTip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CommandTip.BackgroundTransparency = 0.200
CommandTip.BorderColor3 = Color3.fromRGB(0, 0, 0)
CommandTip.BorderSizePixel = 0
CommandTip.Position = UDim2.new(0.56277746, 0, 0.125144839, 0)
CommandTip.Visible = false

if IsOnMobile then
	CommandTip.Size = UDim2.new(0.26, 0, 0.26, 0)
else
	CommandTip.Size = UDim2.new(0.19, 0, 0.19, 0)
end

BeautifuTipUIStroke.Name = "BeautifuTipUIStroke"
BeautifuTipUIStroke.Parent = CommandTip
BeautifuTipUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BeautifuTipUIStroke.Color = Color3.fromRGB(255, 255, 255)

TipTextLabel.Name = "TipTextLabel"
TipTextLabel.Parent = CommandTip
TipTextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TipTextLabel.BackgroundTransparency = 1.000
TipTextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TipTextLabel.BorderSizePixel = 0
TipTextLabel.Size = UDim2.new(1, 0, 0.200000003, 0)
TipTextLabel.Font = Enum.Font.Nunito
TipTextLabel.Text = "Command Name"
TipTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TipTextLabel.TextScaled = true
TipTextLabel.TextSize = 14.000
TipTextLabel.TextWrapped = true

BeautifuTipNameUIStroke.Name = "BeautifuTipNameUIStroke"
BeautifuTipNameUIStroke.Parent = TipTextLabel
BeautifuTipNameUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BeautifuTipNameUIStroke.Color = Color3.fromRGB(255, 255, 255)

TipDescLabel.Name = "TipDescLabel"
TipDescLabel.Parent = CommandTip
TipDescLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TipDescLabel.BackgroundTransparency = 1.000
TipDescLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TipDescLabel.BorderSizePixel = 0
TipDescLabel.Position = UDim2.new(0, 0, 0.400000006, 0)
TipDescLabel.Size = UDim2.new(1, 0, 0.600000024, 0)
TipDescLabel.Font = Enum.Font.Nunito
TipDescLabel.Text = "What a beautiful description, aren't it, uh?"
TipDescLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TipDescLabel.TextScaled = true
TipDescLabel.TextSize = 14.000
TipDescLabel.TextWrapped = true

BeautifuTipDescUIStroke.Name = "BeautifuTipDescUIStroke"
BeautifuTipDescUIStroke.Parent = TipDescLabel
BeautifuTipDescUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BeautifuTipDescUIStroke.Color = Color3.fromRGB(255, 255, 255)

TipAliasLabel.Name = "TipAliasLabel"
TipAliasLabel.Parent = CommandTip
TipAliasLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TipAliasLabel.BackgroundTransparency = 1.000
TipAliasLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TipAliasLabel.BorderSizePixel = 0
TipAliasLabel.Position = UDim2.new(0, 0, 0.200000003, 0)
TipAliasLabel.Size = UDim2.new(1.00000012, 0, 0.200000003, 0)
TipAliasLabel.Font = Enum.Font.Nunito
TipAliasLabel.Text = "cmd, cmdname, help, beauiful, command, here"
TipAliasLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TipAliasLabel.TextScaled = true
TipAliasLabel.TextSize = 14.000
TipAliasLabel.TextWrapped = true

BeautifuTipAliasUIStroke.Name = "BeautifuTipAliasUIStroke"
BeautifuTipAliasUIStroke.Parent = TipAliasLabel
BeautifuTipAliasUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BeautifuTipAliasUIStroke.Color = Color3.fromRGB(255, 255, 255)


CommandBarHolder.Name = "CommandBarHolder"
CommandBarHolder.Parent = PrisonLife
CommandBarHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CommandBarHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
CommandBarHolder.BorderSizePixel = 0
CommandBarHolder.Position = UDim2.new(0.436683059, 0, 0.0990730003, 0)
CommandBarHolder.Visible = false

if IsOnMobile then
	CommandBarHolder.Size = UDim2.new(0.25, 0, 0.066, 0)
else
	CommandBarHolder.Size = UDim2.new(0.177638456, 0, 0.0405561998, 0)
end

Title_3.Name = "Title"
Title_3.Parent = CommandBarHolder
Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_3.BackgroundTransparency = 1.000
Title_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title_3.BorderSizePixel = 0
Title_3.Position = UDim2.new(-0.0029889904, 0, 0, 0)
Title_3.Size = UDim2.new(0.788888872, 0, 1, 0)
Title_3.Font = Enum.Font.Nunito
Title_3.Text = "Command Bar"
Title_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_3.TextScaled = true
Title_3.TextSize = 14.000
Title_3.TextWrapped = true
Title_3.TextXAlignment = Enum.TextXAlignment.Left

UITitleUIPadding_3.Name = "UITitleUIPadding"
UITitleUIPadding_3.Parent = Title_3
UITitleUIPadding_3.PaddingLeft = UDim.new(0, 8)

Close_3.Name = "Close"
Close_3.Parent = CommandBarHolder
Close_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Close_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close_3.BorderSizePixel = 0
Close_3.Position = UDim2.new(0.895555556, 0, 0, 0)
Close_3.Size = UDim2.new(0.104444444, 0, 1, 0)
Close_3.Font = Enum.Font.SourceSans
Close_3.Text = "X"
Close_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Close_3.TextScaled = true
Close_3.TextSize = 14.000
Close_3.TextWrapped = true

CloseButtonUIStroke_3.Name = "CloseButtonUIStroke"
CloseButtonUIStroke_3.Parent = Close_3
CloseButtonUIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CloseButtonUIStroke_3.Color = Color3.fromRGB(255, 255, 255)

Min_3.Name = "Min"
Min_3.Parent = CommandBarHolder
Min_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Min_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Min_3.BorderSizePixel = 0
Min_3.Position = UDim2.new(0.788315594, 0, 0, 0)
Min_3.Size = UDim2.new(0.104444444, 0, 1, 0)
Min_3.Font = Enum.Font.SourceSans
Min_3.Text = "-"
Min_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Min_3.TextScaled = true
Min_3.TextSize = 14.000
Min_3.TextWrapped = true

MinButtonUIStroke_3.Name = "MinButtonUIStroke"
MinButtonUIStroke_3.Parent = Min_3
MinButtonUIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MinButtonUIStroke_3.Color = Color3.fromRGB(255, 255, 255)

CmdBarMain.Name = "CmdBarMain"
CmdBarMain.Parent = CommandBarHolder
CmdBarMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdBarMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
CmdBarMain.BorderSizePixel = 0
CmdBarMain.Position = UDim2.new(0, 0, 1, 0)
CmdBarMain.Size = UDim2.new(1.00000012, 0, 1.71428573, 0)

CmdBarMainUIStroke.Name = "CmdBarMainUIStroke"
CmdBarMainUIStroke.Parent = CmdBarMain
CmdBarMainUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CmdBarMainUIStroke.Color = Color3.fromRGB(255, 255, 255)

CommandBar.Name = "CommandBar"
CommandBar.Parent = CmdBarMain
CommandBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CommandBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
CommandBar.BorderSizePixel = 0
CommandBar.Position = UDim2.new(0.0239597075, 0, 0.0833334625, 0)
CommandBar.Size = UDim2.new(0.949999988, 0, 0.833000004, 0)
CommandBar.Font = Enum.Font.Nunito
CommandBar.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
CommandBar.PlaceholderText = "Command Bar"
CommandBar.Text = ""
CommandBar.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandBar.TextScaled = true
CommandBar.TextSize = 14.000
CommandBar.TextWrapped = true

CommandBarUIStroke.Name = "CommandBarUIStroke"
CommandBarUIStroke.Parent = CommandBar
CommandBarUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CommandBarUIStroke.Color = Color3.fromRGB(255, 255, 255)

CommandBarHolderUIStroke.Name = "CommandBarHolderUIStroke"
CommandBarHolderUIStroke.Parent = CommandBarHolder
CommandBarHolderUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CommandBarHolderUIStroke.Color = Color3.fromRGB(255, 255, 255)


NotifyHolder.Name = "NotifyHolder"
NotifyHolder.Parent = PrisonLife
NotifyHolder.AnchorPoint = Vector2.new(0.5, 0.5)
NotifyHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NotifyHolder.BackgroundTransparency = 1.000
NotifyHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
NotifyHolder.BorderSizePixel = 0
NotifyHolder.Position = UDim2.new(0.5, 0, 0.959999979, 0)
NotifyHolder.Size = UDim2.new(0.0250000004, 0, 0.0500000007, 0)

NotifyTemplate.Name = "NotifyTemplate"
NotifyTemplate.Parent = NotifyHolder
NotifyTemplate.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
NotifyTemplate.BackgroundTransparency = 0.700
NotifyTemplate.BorderColor3 = Color3.fromRGB(0, 0, 0)
NotifyTemplate.BorderSizePixel = 0
NotifyTemplate.Size = UDim2.new(13, 0, 0.870000005, 0)
NotifyTemplate.Visible = false

NotifyContentText.Name = "NotifyContentText"
NotifyContentText.Parent = NotifyTemplate
NotifyContentText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NotifyContentText.BackgroundTransparency = 1.000
NotifyContentText.BorderColor3 = Color3.fromRGB(0, 0, 0)
NotifyContentText.BorderSizePixel = 0
NotifyContentText.Size = UDim2.new(1, 0, 1, 0)
NotifyContentText.Font = Enum.Font.Nunito
NotifyContentText.Text = "This is a Notification Template!"
NotifyContentText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifyContentText.TextScaled = true
NotifyContentText.TextSize = 14.000
NotifyContentText.TextTransparency = 0.100
NotifyContentText.TextWrapped = true

NotUIStroke.Name = "NotUIStroke"
NotUIStroke.Parent = NotifyTemplate
NotUIStroke.Color = Color3.fromRGB(255, 255, 255)
NotUIStroke.Thickness = 0.700

NHolderUIListLayout.Name = "NHolderUIListLayout"
NHolderUIListLayout.Parent = NotifyHolder
NHolderUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NHolderUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NHolderUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NHolderUIListLayout.Padding = UDim.new(0, 5)

function PlaySound(SoundId)
	task.spawn(function()
		local Sound = Instance.new("Sound")
		Sound.SoundId = "rbxassetid://"..SoundId
		game:GetService("SoundService"):PlayLocalSound(Sound)
		task.wait(2)
		Sound:Destroy()
	end)
end

function Notify(Text, OnDisappear)
	task.spawn(function()
		local Template = NotifyTemplate:Clone()
		Template.Name = "Notify"
		Template.NotifyContentText.Text = Text
		Template.Parent = NotifyHolder
		Template.Visible = true
		PlaySound(17208361335)
		task.spawn(function()
			task.wait(4)
			TweenService:Create(Template.NotifyContentText, TweenInfo.new(1), {TextTransparency = .6}):Play()
			TweenService:Create(Template.NotUIStroke, TweenInfo.new(1), {Transparency = .6}):Play()
		end)
		task.wait(8)
		TweenService:Create(Template.NotifyContentText, TweenInfo.new(1), {TextTransparency = 1}):Play()
		TweenService:Create(Template.NotUIStroke, TweenInfo.new(1), {Transparency = 1}):Play()
		TweenService:Create(Template, TweenInfo.new(.85), {BackgroundTransparency = 1}):Play()
		task.wait(1)
		Template:Destroy()
		if OnDisappear then
			OnDisappear()
		end
	end)
end

Holder.Draggable = true
Holder.Active = true
CommandListHolder.Draggable = true
CommandListHolder.Active = true
CommandBarHolder.Draggable = true
CommandBarHolder.Active = true


Min.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

Close.MouseButton1Click:Connect(function()
	Holder.Visible = false
	if IsOnMobile then
		Notify("Toggled UI. Use "..Prefix.."hub to toggle it again.")
	else
		Notify("Toggled UI. Press "..tostring(CloseBind.Name).." to toggle it again.")
	end
end)

Min_2.MouseButton1Click:Connect(function()
	CmdMain.Visible = not CmdMain.Visible
end)

Close_2.MouseButton1Click:Connect(function()
	CommandListHolder.Visible = false
end)

Min_3.MouseButton1Click:Connect(function()
	CmdBarMain.Visible = not CmdBarMain.Visible
end)

Close_3.MouseButton1Click:Connect(function()
	CommandBarHolder.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gotittt)
	if not gotittt then
		if input.KeyCode == CloseBind then
			Holder.Visible = not Holder.Visible
		end
	end
end)

TabButtonMain.MouseButton1Click:Connect(function()
	MainTab.Visible = true
	LPTab.Visible = false
	SettingsTab.Visible = false
end)

TabButtonSettings.MouseButton1Click:Connect(function()
	MainTab.Visible = false
	LPTab.Visible = false
	SettingsTab.Visible = true
end)

TabButtonLP.MouseButton1Click:Connect(function()
	MainTab.Visible = false
	LPTab.Visible = true
	SettingsTab.Visible = false
end)

ChangeSpeedButton.MouseButton1Click:Connect(function()
	local inputtext = WalkspeedInputText.Text

	if #inputtext > 0 and #inputtext <= 10 and tonumber(inputtext) and inputtext:lower() ~= "inf" and inputtext:lower() ~= "nan" then
		local speed = tonumber(inputtext)
		if speed then
			local humanoid = plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = speed
				Notify("WalkSpeed changed to ["..tostring(speed).."]")
			end
		end
	elseif #inputtext > 10 then
		Notify("Input too long. Max 20 characters.")
	elseif #inputtext == 0 then
		Notify("Input is empty.")
	elseif not tonumber(inputtext) then
		Notify("Invalid input. Input must be a number.")
	elseif not char or not char:WaitForChild("Humanoid") or not char:WaitForChild("HumanoidRootPart") then
		Notify("Character not found.")
	elseif inputtext:lower() == "inf" or inputtext:lower() == "nan" then
		Notify("Input can't be 'inf' or 'nan'.")
	end
end)

ChangeJumpButton.MouseButton1Click:Connect(function()
	local inputtext = JumpPowerInputText.Text

	if #inputtext > 0 and #inputtext <= 10 and tonumber(inputtext) and inputtext:lower() ~= "inf" and inputtext:lower() ~= "nan" then
		local jumppower = tonumber(inputtext)
		if jumppower then
			local humanoid = plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.JumpPower = jumppower
				Notify("JumpPower changed to ["..tostring(jumppower).."]")
			end
		end
	elseif #inputtext > 10 then
		Notify("Input too long. Max 20 characters.")
	elseif #inputtext == 0 then
		Notify("Input is empty.")
	elseif not tonumber(inputtext) then
		Notify("Invalid input. Input must be a number.")
	elseif not char or not char:WaitForChild("Humanoid") or not char:WaitForChild("HumanoidRootPart") then
		Notify("Character not found.")
	elseif inputtext:lower() == "inf" or inputtext:lower() == "nan" then
		Notify("Input can't be 'inf' or 'nan'.")
	end
end)

CmdBarButtonOpen.MouseButton1Click:Connect(function()
	CommandBarHolder.Visible = not CommandBarHolder.Visible
	if CommandBarHolder.Visible then
		Notify("Command Bar opened.")
	else
		Notify("Command Bar closed.")
	end
end)

CommandsButton.MouseButton1Click:Connect(function()
	CommandListHolder.Visible = not CommandListHolder.Visible
	if CommandListHolder.Visible then
		Notify("Command List opened.")
	else
		Notify("Command List closed.")
	end
end)

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
	if player.DisplayName ~= player.Name then
		return string.format("%s (%s)", player.Name, player.DisplayName)
	end
	return player.Name
end

AddCommand("refresh", {"re", "reset"}, function(speaker)
	if speaker.Character then
		local root = speaker.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local pos = root.CFrame
			local cameraPos = workspace.CurrentCamera.CFrame
			task.wait(.005)
			speaker.Character:BreakJoints()
			speaker.CharacterAdded:Wait()
			if speaker.Character then
				speaker.Character:WaitForChild("HumanoidRootPart").CFrame = pos
				workspace.CurrentCamera.CFrame = cameraPos
			end
		end
	end
end)

AddCommand("cmds", {}, function()
	CommandListHolder.Visible = not CommandListHolder.Visible
	if CommandListHolder.Visible then
		Notify("Command List opened.")
	else
		Notify("Command List closed.")
	end
end)

everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))

function toClipboard(txt)
	if everyClipboard then
		everyClipboard(tostring(txt))
		Notify("Copied to clipboard")
	else
		Notify("You executor does not support the function to copy to clipboard.")
		task.wait(1.5)
		Notify("Content has been printed to the console.")
		print(tostring(txt))
	end
end

AddCommand("getscript", {"getgithub", "official"}, function(speaker)
	toClipboard("https://github.com/aleatorio-kk/JogoDaPrisaoLegal")
end)

AddCommand("console", {"f9", "devc"}, function()
	StarterGui:SetCore("DevConsoleVisible", true)
end)

AddCommand("dex", {}, function()
	Notify("Loading Dex...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

AddCommand("remotespy", {"rspy"}, function()
	Notify("Loading RemoteSpy...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

AddCommand("audiologger", {"alogger"}, function()
	Notify("Loading AudioLogger...")
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'), true))()
end)

function DoKAura(Size)
	local AuraBlock = Instance.new("Part")
	AuraBlock.Size = Vector3.new(Size, 20, Size) or Vector3.new(20, 20, 20)
	AuraBlock.Transparency = 1
	AuraBlock.CanCollide = false
	AuraBlock.CanTouch = true
	AuraBlock.Anchored = true
	AuraBlock.CFrame = char.HumanoidRootPart.CFrame
	AuraBlock.Parent = workspace
	AuraBlock.Name = "TotallyNotWeirdCompletelyNormalBlockPart"

	local visiblebox = Instance.new("Part")
	visiblebox.Size = Vector3.new(AuraBlock.Size.X, .001, AuraBlock.Size.Z)
	visiblebox.Transparency = 1
	visiblebox.CanCollide = false
	visiblebox.Anchored = true
	visiblebox.CFrame = char.HumanoidRootPart.CFrame
	visiblebox.Parent = AuraBlock
	visiblebox.Name = "visibilityHandlerPart"

	local Visibility = Instance.new("SelectionBox")
	Visibility.LineThickness = 0.01
	Visibility.Parent = AuraBlock
	Visibility.Adornee = visiblebox
	Visibility.Color3 = Color3.fromRGB(255, 255, 255)
	Visibility.SurfaceColor3 = Color3.fromRGB(255, 255, 255)
	Visibility.Visible = showaurastatus
	Visibility.Name = "Visibility"

	return AuraBlock
end

function PunchPlayer(Target)
	if Target:IsA("Player") then
		if Target.Character then
			if Target.Character:FindFirstChild("Humanoid") then
				if Target.Character.Humanoid.Health > 0 then
					if Target.Character:FindFirstChild("HumanoidRootPart") then
						local argssss = {
							Target
						}
						ReplicatedStorage:WaitForChild("meleeEvent"):FireServer(unpack(argssss))
					end
				end
			end
		end
	end
end

AddCommand("hub", {"kk"}, function()
	Holder.Visible = not Holder.Visible
end)

local killRender
local coolconnectionaura

AddCommand("killaura", {"aura"}, function(speaker)
	if speaker then
		if workspace:FindFirstChild("TotallyNotWeirdCompletelyNormalBlockPart") then
			workspace:FindFirstChild("TotallyNotWeirdCompletelyNormalBlockPart"):Destroy()
		end

		if killRender then
			killRender:Disconnect()
		end

		if coolconnectionaura then
			coolconnectionaura:Disconnect()
		end

		local AuraBlock = DoKAura(KASize)

		killRender = RunService.RenderStepped:Connect(function()
			AuraBlock:FindFirstChild("visibilityHandlerPart").CFrame = AuraBlock.CFrame
			if speaker.Character then
				local Root = getRoot(speaker.Character)
				if Root then
					AuraBlock.CFrame = Root.CFrame
				end
			end
		end)
		
		coolconnectionaura = AuraBlock.Touched:Connect(function(basepart)
			local players = Players:GetPlayers()
			
			for i, player in pairs(players) do
				if basepart:IsDescendantOf(player.Character) then
					if player ~= speaker then
						if player.Character:WaitForChild("Humanoid").Health > 0 then
							PunchPlayer(player)
						end
					end
				end
			end
		end)
	end
end)

AddCommand("unkillaura", {"unaura", "noaura"}, function(speaker)
	if speaker then
		if killRender then
			killRender:Disconnect()
			workspace:FindFirstChild("TotallyNotWeirdCompletelyNormalBlockPart"):Destroy()
		end
	end
end)

AddCommand("aurareload", {"reloadaura", "reaura"}, function(speaker)
	if speaker then
		if killRender then
			killRender:Disconnect()
			workspace:WaitForChild("TotallyNotWeirdCompletelyNormalBlockPart"):Destroy()
		end
		
		if coolconnectionaura then
			coolconnectionaura:Disconnect()
		end

		task.wait(1)

		local AuraBlock = DoKAura(KASize)

		killRender = RunService.RenderStepped:Connect(function()
			AuraBlock:WaitForChild("visibilityHandlerPart").CFrame = AuraBlock.CFrame
			if speaker.Character then
				local Root = getRoot(speaker.Character)
				if Root then
					AuraBlock.CFrame = Root.CFrame
				else
					AuraBlock.CFrame = CFrame.new(9999, 9999, 9999)
					speaker.CharacterAdded:Wait()
					AuraBlock.CFrame = getRoot(speaker.Character).CFrame * CFrame.new(0, 1.5, 0)
				end
			end
		end)
		
		coolconnectionaura = AuraBlock.Touched:Connect(function(basepart)
			local players = Players:GetPlayers()

			for i, player in pairs(players) do
				if basepart:IsDescendantOf(player.Character) then
					if player ~= speaker then
						if player.Character:WaitForChild("Humanoid").Health > 0 then
							PunchPlayer(player)
						end
					end
				end
			end
		end)

		Notify("Kill Aura reloaded.")
	end
end)

AddCommand("showaura", {"visibleaura", "showradius"}, function()
	showaurastatus = not showaurastatus
	if workspace:FindFirstChild("TotallyNotWeirdCompletelyNormalBlockPart") then
		workspace:FindFirstChild("TotallyNotWeirdCompletelyNormalBlockPart"):WaitForChild("Visibility").Visible = not workspace:FindFirstChild("TotallyNotWeirdCompletelyNormalBlockPart"):WaitForChild("Visibility").Visible
	end
end)

AddCommand("killaurasize", {"aurasize"}, function(speaker, args)
	if KASize and args[1] then
		if tonumber(args[1]) then
			if tonumber(args[1]) > 0 then
				if tonumber(args[1]) <= 20 then
					KASize = tonumber(args[1])
					task.spawn(function()
						ExecuteCommand("aurareload", plr)
					end)
					Notify("Kill Aura Size Changed to ["..args[1].."]")
				else
					Notify("Invalid Kill Aura Size. (Too High)")
				end
			else
				Notify("Invalid Kill Aura Size. (Too Small)")
			end
		end
	end
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

function randomString()
	local text = ""
	for i = 1, math.random(10, 15) do
		text = text .. string.char(math.random(33, 126))
	end
	return text
end

function isNumber(str)
	if tonumber(str) ~= nil or str == 'inf' then
		return true
	end
end
local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

local respawnatlastposition = true
local antiarrest = true
local antitaser = true
local CFW = true
local ASBP = true

local lastDeath
local lastCam

function onDied()
	task.spawn(function()
		if pcall(function() Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') end) and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(Players.LocalPlayer.Character) then
					lastDeath = getRoot(Players.LocalPlayer.Character).CFrame
					lastCam = workspace.CurrentCamera.CFrame
				end
			end)
		else
			wait(2)
			onDied()
		end
	end)
end

Clip = true
Players.LocalPlayer.CharacterAdded:Connect(function()
	NOFLY()
	Floating = false

	if not Clip then
		ExecuteCommand('unnoclip')
	end

	repeat wait() until getRoot(Players.LocalPlayer.Character)

	pcall(function()
		if respawnatlastposition then
			getRoot(Players.LocalPlayer.Character).CFrame = lastDeath
			workspace.CurrentCamera.CFrame = lastCam
		end
	end)

	onDied()
end)

onDied()

local notiflyfirst = false
local notivehicleflyfirst = false
AddCommand('fly',{},function(speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if not notiflyfirst then
		Notify("Fly Controls: W, A, S, D, Q, E", function()
			notiflyfirst = true
		end)
	end
end)

AddCommand('flyspeed',{'flysp'},function(speaker, args)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
		Notify("Fly Speed Changed To: ["..speed.."]")
	end
end)

AddCommand('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

AddCommand('vfly',{'vehiclefly'},function(speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if not notivehicleflyfirst then
		Notify("Vehicle Fly Controls: W, A, S, D, Q, E", function()
			notivehicleflyfirst = true
		end)
	end
end)

AddCommand('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(speaker, args)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
		Notify("Vehicle Fly Speed Changed To: ["..speed.."]")
	end
end)

CFspeed = 50
AddCommand('cframefly', {'cfly'}, function(speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

AddCommand('uncframefly',{'uncfly'},function(speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

AddCommand('cframeflyspeed',{'cflyspeed'},function(speaker, args)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

Floating = false
floatName = randomString()
local firstnotifyfloatinnnnnng = false
AddCommand('float', {},function(speaker)
	Floating = true
	local pchar = speaker.Character
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			firstnotifyfloatinnnnnng = true
			local Float = Instance.new('Part')
			Float.Name = floatName
			Float.Parent = pchar
			Float.Transparency = 1
			Float.Size = Vector3.new(2,0.2,1.5)
			Float.Anchored = true
			local FloatValue = -3.1
			Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0,FloatValue,0)
			if not firstnotifyfloatinnnnnng then
				Notify("Float Controls: Q, E")
			end
			qUp = mouse.KeyUp:Connect(function(KEY)
				if KEY == 'q' then
					FloatValue = FloatValue + 0.5
				end
			end)
			eUp = mouse.KeyUp:Connect(function(KEY)
				if KEY == 'e' then
					FloatValue = FloatValue - 1.5
				end
			end)
			qDown = mouse.KeyDown:Connect(function(KEY)
				if KEY == 'q' then
					FloatValue = FloatValue - 0.5
				end
			end)
			eDown = mouse.KeyDown:Connect(function(KEY)
				if KEY == 'e' then
					FloatValue = FloatValue + 1.5
				end
			end)
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				FloatingFunc:Disconnect()
				Float:Destroy()
				qUp:Disconnect()
				eUp:Disconnect()
				qDown:Disconnect()
				eDown:Disconnect()
				floatDied:Disconnect()
			end)
			local function FloatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0,FloatValue,0)
				else
					FloatingFunc:Disconnect()
					Float:Destroy()
					qUp:Disconnect()
					eUp:Disconnect()
					qDown:Disconnect()
					eDown:Disconnect()
					floatDied:Disconnect()
				end
			end			
			FloatingFunc = RunService.Heartbeat:Connect(FloatPadLoop)
		end)
	end
end)

AddCommand('unfloat',{'nofloat'},function(speaker)
	Floating = false
	local pchar = speaker.Character
	Notify("Float Disabled")
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		FloatingFunc:Disconnect()
		qUp:Disconnect()
		eUp:Disconnect()
		qDown:Disconnect()
		eDown:Disconnect()
		floatDied:Disconnect()
	end
end)


local Noclipping = nil
AddCommand('noclip',{},function(speaker)
	Clip = false
	wait(0.1)
	local function NoclipLoop()
		if Clip == false and speaker.Character ~= nil then
			for _, child in pairs(speaker.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
					child.CanCollide = false
				end
			end
		end
	end
	Noclipping = RunService.Stepped:Connect(NoclipLoop)
	Notify("Noclip Enabled")
end)

AddCommand('clip',{'unnoclip'},function(speaker)
	if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
	Notify("Noclip Disabled")
end)

AddCommand('goto',{'to'},function(speaker, args)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
		end
	end
	ExecuteCommand('breakvelocity')
end)

AddCommand("breakvelocity", {}, function(speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

AddCommand('spin',{},function(speaker, args)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "FingerSpini" then
			v:Destroy()
		end
	end
	local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "FingerSpini"
	Spin.Parent = getRoot(speaker.Character)
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end)

AddCommand('unspin',{},function(speaker)
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "FingerSpini" then
			v:Destroy()
		end
	end
end)

AddCommand("speed", {"wspeed", "walksp", "ws"}, function(speaker, args)
	local speed = args[1]
	if speed and isNumber(speed) then
		if speaker.Character:FindFirstChildOfClass('Humanoid') then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		Notify("Argument is not a valid number.")
	end
end)

AddCommand("jump", {"jpower", "jumpp", "jp"}, function(speaker, args)
	local jppoweeer = args[1]
	if jppoweeer and isNumber(jppoweeer) then
		if speaker.Character:FindFirstChildOfClass('Humanoid') then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jppoweeer
		end
	else
		Notify("Argument is not a valid number.")
	end
end)

AddCommand("antibring", {"nosit", "antisit"}, function(speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	Notify("Anti-Bring Enabled")
end)

AddCommand("unantibring", {"unnosit"}, function(speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	Notify("Anti-Bring Disabled")
end)

AddCommand("sit", {}, function(speaker)
	if speaker.Character:FindFirstChildOfClass('Humanoid') then
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = true
	end
end)

local thisoldpositionsosick

AddCommand("savepos", {"saveposition"}, function(speaker)
	local root = getRoot(speaker.Character)
	if root then
		local rootCFrame = root.CFrame
		thisoldpositionsosick = rootCFrame
		print("Position Saved:", rootCFrame)
		Notify("Position saved. Use "..Prefix.."loadpos to teleport back.")
	end
end)

AddCommand("loadpos", {"loadposition"}, function(speaker)
	local root = getRoot(speaker.Character)
	if root and thisoldpositionsosick then
		root.CFrame = thisoldpositionsosick
		Notify("Teleported back to saved position.")
	elseif root and not thisoldpositionsosick then
		Notify("No saved position found.")
	elseif not root then
		Notify("Error. Are you dead?")
	end
end)

AddCommand("cmdbar", {"commandbar", "cbar"}, function()
	if not CommandBarHolder.Visible then
		CommandBarHolder.Visible = true
	else
		CommandBarHolder.Visible = false
	end
end)

local loopu
AddCommand("kill", {}, function(speaker, args)
	if not loopu then
		local players = getPlayer(args[1], speaker)
		local target
		for i,v in pairs(players)do
			task.spawn(function()
				if Players[v].Name ~= speaker.Name then
					target = v
				end
			end)
		end
		
		if target then
			local targetPlayer = game.Players:FindFirstChild(target)
			if targetPlayer and targetPlayer.Character then
				local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					if humanoid.Health > 0 then
						if char then
							if char:FindFirstChild("Humanoid") then
								if char:FindFirstChild("Humanoid").Health > 0 then
									loopu = RunService.RenderStepped:Connect(function()
										getRoot(char).CFrame = getRoot(targetPlayer.Character).CFrame
									end)
									repeat wait() PunchPlayer(targetPlayer) until humanoid.Health <= 0 or not loopu
									if loopu then
										loopu:Disconnect()
									end
								end
							end
						end
					end
				end
			end
		end
	else
		loopu:Disconnect()
		loopu = nil
	end
end)

plr.Chatted:Connect(function(message)
	local args = string.split(message, " ")
	local commandname = args[1]:lower()
	table.remove(args, 1)
	if commandname then
		if commandname:sub(1, #Prefix) == Prefix then
			local Comm
			print(commandname, commandname:sub(1, #Prefix), commandname:sub(#Prefix + 1))
			if GetCommand(commandname:sub(#Prefix + 1)) ~= nil then
				Comm = GetCommand(commandname:sub(#Prefix + 1))
				ExecuteCommand(Comm.Name, plr, args)
			else
				SendSystemChatMessage("<font color='rgb(255, 0, 0)'>[Admin Hub]: Command not found. "..Prefix.."cmds for Commands.</font>")
			end
		end
	end
end)

local oncdtoreset = false

RefreshCharButton.MouseButton1Click:Connect(function()
	if not oncdtoreset then
		oncdtoreset = true
		RefreshCharButton.Interactable = false
		RefreshCharButton.Text = "Refreshing..."
		RefreshCharButton.TextTransparency = .5
		RefreshCharButton.UIStroke.Transparency = .5

		local root = getRoot(plr.Character)
		if root then
			ExecuteCommand("refresh", plr)
			repeat wait() until getRoot(plr.Character)
			RefreshCharButton.Text = "Refresh"
			RefreshCharButton.TextTransparency = 0
			RefreshCharButton.UIStroke.Transparency = 0
			RefreshCharButton.Interactable = true
			oncdtoreset = false
		end
	end
end)

CommandBar.FocusLost:Connect(function(Entered)
	if Entered then
		local args = string.split(CommandBar.Text, " ")
		local commandname = args[1]:lower()
		table.remove(args, 1)
		if commandname then
			if commandname:sub(1, #Prefix) == Prefix then
				local Comm
				print(commandname, commandname:sub(1, #Prefix), commandname:sub(#Prefix + 1))
				if GetCommand(commandname:sub(#Prefix + 1)) ~= nil then
					Comm = GetCommand(commandname:sub(#Prefix + 1))
					ExecuteCommand(Comm.Name, plr, args)
				else
					Notify("Command not found. "..Prefix.."cmds for Commands.")
				end
			else
				if GetCommand(commandname) ~= nil then
					local Comm = GetCommand(commandname)
					ExecuteCommand(Comm.Name, plr, args)
				else
					Notify("Command not found. "..Prefix.."cmds for Commands.")
				end
			end
		end
		CommandBar.Text = ""
	end
end)

task.spawn(function()
	local function BuildCommands()
		local ui = Scrollinnnnnng
		local template = CommandTemplate

		for i, v in Cmds do
			if not ui:FindFirstChild(v.Name) and GetCommand(v.Name) ~= nil then
				local Clone = template:Clone()
				Clone.Parent = ui
				Clone.LayoutOrder = i
				Clone.Text = ";"..v.Name
				Clone.Name = v.Name
				Clone.Visible = true

				Clone.MouseEnter:Connect(function()
					CommandTip.Visible = true
					TipDescLabel.Text = v.Description
					TipTextLabel.Text = v.Name
					if GetCommand(v.Name).Aliases then
						local Comandii = GetCommand(v.Name)
						if #Comandii.Aliases ~= 0 then
							TipAliasLabel.Text = "Aliases: "..table.concat(Comandii.Aliases, ", ")
						else
							TipAliasLabel.Text = "No aliases."
						end
					end
				end)

				Clone.MouseLeave:Connect(function()
					CommandTip.Visible = false
					TipDescLabel.Text = ""
					TipTextLabel.Text = ""
					TipAliasLabel.Text = ""
				end)
			end
		end
	end

	BuildCommands()
	
	local function CreateToggle(ToggleConfig)
		ToggleConfig = ToggleConfig or {}
		ToggleConfig.Name = ToggleConfig.Name or "Toggle"
		ToggleConfig.Default = ToggleConfig.Default or false
		ToggleConfig.Callback = ToggleConfig.Callback or function() end

		local Toggle = {Value = ToggleConfig.Default}

		local Button = ExampleSettingsButton:Clone()
		Button.Text = ToggleConfig.Name
		Button.Name = ToggleConfig.Name:lower():gsub(" ", "")
		Button.Parent = SettingsScrouller
		Button.Visible = true

		function Toggle:Set(Value)
			Toggle.Value = Value

			if Toggle.Value == true then
				Button.TextColor3 = Color3.fromRGB(0, 255, 0)
				Button.ExampleUIStrokeeeeerr.Color = Color3.fromRGB(0, 255, 0)
			else
				Button.TextColor3 = Color3.fromRGB(255, 0, 0)
				Button.ExampleUIStrokeeeeerr.Color = Color3.fromRGB(255, 0, 0)
			end

			ToggleConfig.Callback(Toggle.Value)
		end   

		Button.MouseButton1Click:Connect(function()
			Toggle:Set(not Toggle.Value)
		end)

		if Toggle.Value then
			ToggleConfig.Callback(Toggle.Value)
		end

		return Toggle
	end

	local RespawnLastPosition = CreateToggle({
		Name = "Respawn Last Position",
		Default = true,
		Callback = function(Value)
			if Value then
				respawnatlastposition = true
				Notify("Respawn Last Position Enabled.")
			else
				respawnatlastposition = false
				Notify("Respawn Last Position Disabled.")
			end
		end,
	})
	
	local function BuildAgainArrest()
		ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClientArrested").OnClientEvent:connect(function()
			local humanoid = char:WaitForChild("Humanoid")
			if humanoid then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://287112271"
				local animationarrested = humanoid:LoadAnimation(anim)

				StarterGui:SetCore("ResetButtonCallback", false)		
				plr:SetAttribute("BackpackEnabled", false)

				humanoid:UnequipTools()
				humanoid.WalkSpeed = 0
				humanoid.JumpHeight = 0
				animationarrested:Play()
			end
		end)
	end
	
	local AntiArrest = CreateToggle({
		Name = "Anti Arrest",
		Default = true,
		Callback = function(Value)
			if Value then
				antiarrest = true
				Notify("Anti Arrest Enabled.")
			else
				antiarrest = false
				BuildAgainArrest()
				Notify("Anti Arrest Disabled.")
			end
		end,
	})
	
	local function BuildTaserAgain()
		ReplicatedStorage:WaitForChild("GunRemotes"):WaitForChild("PlayerTased").OnClientEvent:connect(function()
			local humanoid = char:WaitForChild("Humanoid")
			if humanoid then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://279227693"
				local Animation = Instance.new("Animation")
				Animation.AnimationId = "rbxassetid://279229192"
				local animtaser = humanoid:LoadAnimation(anim)
				local animend = humanoid:LoadAnimation(Animation)
				plr:SetAttribute("BackpackEnabled", false)
				StarterGui:SetCore("ResetButtonCallback", false)	
				humanoid:UnequipTools()
				humanoid.WalkSpeed = 0
				humanoid.JumpHeight = 0
				anim:Play()
				anim.KeyframeReached:Connect(function(key)
					if key == "finish" then
						anim:Stop()
						animend:Play()
					end
				end)
				task.wait(3.5)
				anim:Stop()
				animend:Stop()
				if char then
					plr:SetAttribute("BackpackEnabled", true)
					StarterGui:SetCore("ResetButtonCallback", true)	
					humanoid.WalkSpeed = 16
					humanoid.JumpHeight = 5.5
				end
			end
		end)
	end
	
	local AntiTaser = CreateToggle({
		Name = "Anti Taser",
		Default = true,
		Callback = function(Value)
			if Value then
				antitaser = true
				Notify("Anti Taser Enabled.")
			else
				antitaser = false
				BuildTaserAgain()
				Notify("Anti Taser Disabled.")
			end
		end,
	})
	
	local NoSlowdown = CreateToggle({
		Name = "Crouch Fast Walk",
		Default = true,
		Callback = function(Value)
			if Value then
				CFW = true
				Notify("Crouch Fast Walk Enabled.")
			else
				CFW = false
				Notify("Crouch Fast Walk Disabled.")
			end
		end,
	})
	
	local BPAlways = CreateToggle({
		Name = "Always Show Backpack",
		Default = true,
		Callback = function(Value)
			if Value then
				ASBP = true
				Notify("Always Show Backpack Enabled.")
			else
				ASBP = false
				Notify("Always Show Backpack Disabled.")
			end
		end,
	})
end)

RunService.RenderStepped:Connect(function()
	task.spawn(function()
		local t
		local guisAtPosition = parentupvr:GetGuiObjectsAtPosition(mouse.X, mouse.Y)

		for _, gui in pairs(guisAtPosition) do
			if gui.Parent == Scrollinnnnnng then
				t = gui
			end
		end
		local x = mouse.X
		local y = mouse.Y
		local xP
		local yP
		if not IsOnMobile then
			if mouse.X > 200 then
				xP = x - 265
			else
				xP = x + 17
			end
			if mouse.Y > (mouse.ViewSizeY-96) then
				yP = y - 97
			else
				yP = y
			end
		else
			if mouse.X > 200 then
				xP = x - 201
			else
				xP = x + 21
			end
			if mouse.Y > (mouse.ViewSizeY-96) then
				yP = y - 97
			else
				yP = y
			end
		end
		CommandTip.Position = UDim2.new(0, xP, 0, yP)
	end)
	
	task.spawn(function()
		local function DisconnectClientEvent(RemoteName)
			for i, v in ReplicatedStorage:GetDescendants() do
				if v.Name == RemoteName then
					for _, connection in getconnections(v.OnClientEvent) do
						connection:Disconnect()
					end
				end
			end
		end
		
		if antitaser then
			DisconnectClientEvent("PlayerTased")
		end
		if antiarrest then
			DisconnectClientEvent("ClientArrested")
		end
		
		if CFW then
			local char = plr.Character
			if char then
				local humanoid = char:FindFirstChild("Humanoid")
				if humanoid then
					if humanoid.WalkSpeed == 5 then
						humanoid.WalkSpeed = 16
					end
				end
			end
		end
		
		if ASBP then
			plr:SetAttribute("BackpackEnabled", true)
		end
	end)
end)

if VersionBlitz then
	if game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(plr) == "BR" then
		Notify("Esse loadstring está desatualizado. Tente usar o original da minha GitHub")
		wait(1)
		Notify("Consiga minha GitHub usando: "..Prefix.."getscript")
	else
		Notify("Your current loadstring is outdated. Get new in official GitHub")
		wait(1)
		Notify("You can get it by using: "..Prefix.."getscript")		
	end
end

if game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(plr) == "BR" then
	Notify("Se você é brasileiro, saiba que todo o Hub está em Inglês")
	wait(1.5)
	Notify("Foi mal, mas esse é o público-alvo que eu quero chegar kkkkkk")
end
