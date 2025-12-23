--[[
	⣿⣿⣿⣿⣿ SIGMA SPY ⣿⣿⣿⣿⣿
	⣿⣿⣯⡉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉
	⠉⠻⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
	⠀⠀⠈⠻⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
	⠀⠀⠀⠀⠀⠙⢿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀
	⠀⠀⠀⠀⠀⠀⠀⣉⣿⣿⣿⠆⠀⠀⠀⠀⠀⠀⠀
	⠀⠀⠀⠀⠀⣠⣾⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀
	⠀⠀⢀⣴⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
	⣀⣴⣿⣿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
	⣿⣿⣟⣁⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀
	⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿

    Written by @depso (depthso)
    MIT License
    
    https://github.com/depthso
]]

--// Base Configuration
local Configuration = {
	UseWorkspace = false, 
	NoActors = false,
	RepoUrl = "https://raw.githubusercontent.com/BoostCC/SigmaSpyFIXED/refs/heads/main",
	ParserUrl = "https://raw.githubusercontent.com/depthso/Roblox-parser/refs/heads/main/"
}

--// Load overwrites
local Parameters = {...}
local Overwrites = Parameters[1]
if typeof(Overwrites) == "table" then
	for Key, Value in Overwrites do
		Configuration[Key] = Value
	end
end

--// Service handler
local Services = setmetatable({}, {
	__index = function(self, Name: string): Instance
		local Service = game:GetService(Name)
		return cloneref(Service)
	end,
})

--// Fetch Files module code
local FilesScript
if Configuration.UseWorkspace then
	FilesScript = readfile(`{Configuration.Folder}/lib/Files.lua`)
else
	FilesScript = game:HttpGet(`{Configuration.RepoUrl}/lib/Files.lua`)
end

--// Load files module
local Files = loadstring(FilesScript)()
Files:PushConfig(Configuration)
Files:Init({
	Services = Services
})

--// Load our fixed UI module directly
local UiScript = game:HttpGet("https://raw.githubusercontent.com/BoostCC/SigmaSpyFIXED/refs/heads/main/lib/Ui.lua")
local Ui = loadstring(UiScript)()

--// Modules (excluding Ui which we load separately)
local Scripts = {
	--// User configurations
	Config = Files:GetModule("Sigma Spy/Config", "Config"),
	ReturnSpoofs = Files:GetModule("Sigma Spy/Return spoofs", "Return Spoofs"),
	Configuration = Configuration,
	Files = Files,

	--// Libraries
	Process = Files:GetModule("lib/Process"),
	Hook = Files:GetModule("lib/Hook"),
	Flags = Files:GetModule("lib/Flags"),
	Generation = Files:GetModule("lib/Generation"),
	Communication = Files:GetModule("lib/Communication")
}

--// Services
local Players: Players = Services.Players

--// Dependencies
local Modules = Files:LoadLibraries(Scripts)
local Process = Modules.Process
local Hook = Modules.Hook
local Generation = Modules.Generation
local Communication = Modules.Communication

--// Add Ui to modules
Modules.Ui = Ui

--// Load modules
Files:LoadModules(Modules, {
	Modules = Modules,
	Services = Services
})

--// Create window
local Window = Ui:CreateWindow()

--// Check if Sigma spy is supported
local Supported = Process:CheckIsSupported()
if not Supported then 
	Window:Close()
	return
end

--// Create communication channel
local ChannelId = Communication:CreateChannel()
Communication:AddCommCallback("QueueLog", function(...)
	Ui:QueueLog(...)
end)

--// Generation swaps
local LocalPlayer = Players.LocalPlayer
Generation:SetSwapsCallback(function(self)
	self:AddSwap(LocalPlayer, {
		String = "LocalPlayer",
	})
	self:AddSwap(LocalPlayer.Character, {
		String = "Character",
		NextParent = LocalPlayer
	})
end)

--// Create window content
Ui:CreateWindowContent(Window)

--// Begin the Log queue service
Ui:BeginLogService()

--// Load hooks
local ActorCode = Files:MakeActorScript(Scripts, ChannelId)
Hook:LoadHooks(ActorCode, ChannelId)

print("Sigma Spy loaded successfully with asset error bypass!")
