-- [[ LOAD RAYFIELD UI LIBRARY ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ WINDOW INITIALIZATION ]] --
local Window = Rayfield:CreateWindow({
   Name = "Hydra Hub | Grow a Garden",
   LoadingTitle = "Loading Hydra Hub...",
   LoadingSubtitle = "by Punpunzero02",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false -- Set true kalau lu mau pake sistem key nanti
})

-- [[ VARIABLES & CONFIG ]] --
local _G = getgenv and getgenv() or _G
_G.AutoHopEnabled = false
_G.WaktuTunggu = 1200 -- Default 20 menit (dalam detik)

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ FUNCTION AUTO HOP ]] --
local function doAutoHop()
   if not _G.AutoHopEnabled then return end
   
   local placeId = game.PlaceId
   local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
   
   local success, result = pcall(function()
       return HttpService:JSONDecode(game:HttpGet(url))
   end)
   
   if success and result and result.data then
       local validServers = {}
       
       for _, server in ipairs(result.data) do
           local isVisited = false
           for _, visitedId in ipairs(shared.VisitedServers) do
               if server.id == visitedId then
                   isVisited = true
                   break
               end
           end
           
           if not isVisited and server.playing < server.maxPlayers then
               table.insert(validServers, server.id)
           end
       end
       
       if #validServers > 0 and _G.AutoHopEnabled then
           local randomServerId = validServers[math.random(1, #validServers)]
           Rayfield:Notify({
              Title = "Hydra Hub",
              Content = "Server baru ketemu! Berpindah dalam hitungan detik...",
              Duration = 5,
              Image = 4483362458,
           })
           task.wait(2)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, Players.LocalPlayer)
       else
           print("Server penuh atau sudah dikunjungi, mengulang...")
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           doAutoHop()
       end
   end
end

-- Loop di background yang berjalan selama Toggle aktif
task.spawn(function()
   while true do
      task.wait(1) -- Cek setiap detik apakah waktu tunggu sudah habis
      if _G.AutoHopEnabled then
         local hitung Mundur = _G.WaktuTunggu
         while hitungMundur > 0 and _G.AutoHopEnabled do
            task.wait(1)
            hitungMundur = hitungMundur - 1
         end
         if _G.AutoHopEnabled then
            doAutoHop()
         end
      end
   end
end)

-- [[ UI TABS & ELEMENTS ]] --
local MainTab = Window:CreateTab("Main Features", 4483362458) -- Icon ID

-- Toggle untuk Aktif/Nonaktifkan Auto Hop
local HopToggle = MainTab:CreateToggle({
   Name = "Auto Hop Server",
   CurrentValue = false,
   Flag = "AutoHopToggle",
   Callback = function(Value)
      _G.AutoHopEnabled = Value
      if Value then
         Rayfield:Notify({
            Title = "Hydra Hub",
            Content = "Auto Hop Aktif! Server akan pindah setiap " .. (_G.WaktuTunggu / 60) .. " menit.",
            Duration = 5,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Hydra Hub",
            Content = "Auto Hop Dinonaktifkan.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- Slider untuk atur menit (Bisa pilih dari 1 menit sampai 60 menit)
local TimeSlider = MainTab:CreateSlider({
   Name = "Waktu Tunggu (Menit)",
   Min = 1,
   Max = 60,
   CurrentValue = 20,
   Flag = "WaktuSlider",
   Callback = function(Value)
      _G.WaktuTunggu = Value * 60 -- Ubah menit ke detik
   end,
})

-- Tombol buat Hop Instant tanpa nunggu timer
MainTab:CreateButton({
   Name = "Instant Hop Now",
   Callback = function()
      _G.AutoHopEnabled = true
      doAutoHop()
   end,
})
