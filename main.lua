-- [[ YOHUB PREMIUM GAIB - GROW A GARDEN SPECIAL EDITION ]] --

-- =========================================================================
--  PENGATURAN CONFIG (Ubah di sini sebelum lu execute!)
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" -- Nama item hasil scan lu
local HARGA_JUAL     = 11           -- Atur harga jual yang lu mau
local MENIT_AUTOHOP  = 20             -- Otomatis pindah server tiap X menit

-- =========================================================================
--  LOGIKA UTAMA GAME (ANTI BUG UI DELTA)
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ FUNGSI AUTO CLAIM BOOTH & AUTO STOCK ]] --
local function jalankanSistemBooth()
    task.spawn(function()
        while true do
            pcall(function()
                -- 1. OTOMATIS CLAIM BOOTH KOSONG
                -- Kita panggil Remote ClaimBooth hasil scan pertama lu
                ReplicatedStorage.GameEvents.TradeEvents.Booths.ClaimBooth:FireServer()
                
                -- Beri jeda 2 detik setelah claim biar server gak lag
                task.wait(2)
                
                -- 2. OTOMATIS TEMBAK STOK BONE BLOSSOM
                -- Kita kirim beberapa variasi argumen remote biar server game terpaksa menerima datanya
                ReplicatedStorage.GameEvents.UpdateStock:FireServer(NAMA_ITEM, HARGA_JUAL, 1, 1)
                ReplicatedStorage.GameEvents.UpdateStock:FireServer(NAMA_ITEM, HARGA_JUAL)
            end)
            
            task.wait(10) -- Proses auto-claim dan re-stock berjalan otomatis tiap 10 detik sekali
        end
    end)
end

-- [[ FUNGSI AUTO HOP MOBILITAS SERVER ]] --
local function jalankanAutoHopServer()
   print("YoHub: Mencari server baru...")
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
               if server.id == visitedId then isVisited = true break end
           end
           if not isVisited and server.playing < server.maxPlayers then
               table.insert(validServers, server.id)
           end
       end
       
       if #validServers > 0 then
           local randomServerId = validServers[math.random(1, #validServers)]
           print("YoHub: Server baru ketemu! Otw Teleport...")
           task.wait(1)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, localPlayer)
       else
           print("YoHub: Mengulang scan server...")
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           jalankanAutoHopServer()
       end
   end
end

-- [[ EKSEKUSI UTAMA ]] --
task.spawn(function()
   print("=========================================")
   print("     YOHUB PREMIUM GAIB TELAH AKTIF      ")
   print("=========================================")
   print("Target Item : " .. NAMA_ITEM)
   print("Harga Jual  : " .. tostring(HARGA_JUAL))
   print("Sistem      : Auto Claim + Auto Stock Active")
   print("=========================================")
   
   -- Jalankan fungsi jualan otomatis di background
   jalankanSistemBooth()
   
   -- Loop timer untuk pindah server market
   while true do
      task.wait(WAKTU_HOP_DETIK)
      jalankanAutoHopServer()
   end
end)
