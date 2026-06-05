-- [[ YOHUB PURE AUTO RESTOCK & HOP - NO UI VERSION ]] --

-- =========================================================================
--  PENGATURAN CONFIG (Sesuaikan sesuka lu sebelum execute)
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" -- Nama item jualan lu
local HARGA_JUAL     = 11           -- Harga jualan lu
local MENIT_AUTOHOP  = 20             -- Waktu nunggu sebelum pindah server (menit)

-- =========================================================================
--  LOGIKA UTAMA (FOKUS RESTOCK & SEARCHING BOOTH LU)
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- Fungsi nyari booth milik lu yang udah diklaim secara manual
local function cariBoothGua()
    for _, v in ipairs(workspace:GetDescendants()) do
        -- Cari objek yang namanya mengandung kata "booth"
        if string.find(string.lower(v.Name), "booth") and not v:IsA("BasePart") then
            -- Cek folder Owner / Player / User di dalam booth tersebut
            local owner = v:FindFirstChild("Owner") or v:FindFirstChild("Player") or v:FindFirstChild("User") or v:FindFirstChild("Username")
            if owner and tostring(owner.Value) == localPlayer.Name then
                return v -- Booth lu ketemu!
            end
        end
    end
    return nil
end

-- [[ LOOP PURE AUTO RESTOCK ]] --
local function jalankanAutoRestock()
    task.spawn(function()
        while true do
            local boothGua = cariBoothGua()
            
            if boothGua then
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("UpdateStock")
                    if remote then
                        -- Kita kirim 3 variasi struktur remote yang paling sering dipakai game Roblox:
                        
                        -- Variasi 1: Menyertakan Objek Booth Lu (Sangat sering di game booth baru)
                        remote:FireServer(boothGua, NAMA_ITEM, HARGA_JUAL)
                        
                        -- Variasi 2: Menyertakan Objek Booth + Slot Nomor 1
                        remote:FireServer(boothGua, NAMA_ITEM, HARGA_JUAL, 1)
                        
                        -- Variasi 3: Standar Item, Harga, Slot, Jumlah
                        remote:FireServer(NAMA_ITEM, HARGA_JUAL, 1, 1)
                    end
                end)
                print("[YoHub Restock]: Booth terdeteksi, mencoba menyetok " .. NAMA_ITEM .. " seharga " .. tostring(HARGA_JUAL))
            else
                print("[YoHub Restock]: Lu BELUM KLAIM BOOTH. Silakan klaim manual dulu di server!")
            end
            
            task.wait(5) -- Mencoba menyetok ulang otomatis setiap 5 detik
        end
    end)
end

-- [[ FUNGSI AUTO HOP ]] --
local function jalankanAutoHopServer()
   print("YoHub: Waktu AFK habis, mencari server market baru...")
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
           task.wait(1)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, localPlayer)
       else
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           jalankanAutoHopServer()
       end
   end
end

-- [[ EKSEKUSI ]] --
task.spawn(function()
   print("=========================================")
   print("    YOHUB PURE AUTO RESTOCK ACTIVE       ")
   print("=========================================")
   print("Target Item : " .. NAMA_ITEM)
   print("Harga Jual  : " .. tostring(HARGA_JUAL))
   print("Cara Pakai  : KLAIM BOOTH MANUAL DULU!")
   print("=========================================")
   
   jalankanAutoRestock()
   
   while true do
      task.wait(WAKTU_HOP_DETIK)
      jalankanAutoHopServer()
   end
end)
