-- [[ YOHUB PREMIUM GAIB - FIX AUTO CLAIM BOOTH ]] --

-- =========================================================================
--  PENGATURAN CONFIG
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" 
local HARGA_JUAL     = 11          
local MENIT_AUTOHOP  = 20             

-- =========================================================================
--  LOGIKA UTAMA GAME
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ FUNGSI CARI DAN CLAIM BOOTH KOSONG ]] --
local function autoClaimBoothKosong()
    -- Cari folder penampung booth berdasarkan log scan lu kemarin (Workspace.Booths atau Workspace.TradeWorld.Booths)
    local folderBooths = workspace:FindFirstChild("Booths") or (workspace:FindFirstChild("TradeWorld") and workspace.TradeWorld:FindFirstChild("Booths"))
    
    if not folderBooths then
        warn("YoHub: Folder Booths tidak ditemukan di Workspace!")
        return nil
    end

    -- Scan semua booth di dalam folder
    for _, booth in ipairs(folderBooths:GetChildren()) do
        -- Cek apakah booth ini kosong (biasanya di game Roblox ditandai tidak ada nama pemilik/Owner Value-nya kosong atau nil)
        local ownerValue = booth:FindFirstChild("Owner") or booth:FindFirstChild("Player")
        
        -- Kalau booth gak ada owner-nya, berarti ini BOOTH KOSONG!
        if not ownerValue or ownerValue.Value == "" or ownerValue.Value == nil then
            print("YoHub: Menemukan Booth Kosong -> " .. booth.Name)
            
            -- Tembak Remote Claim dengan menyertakan objek Booth yang kosong tadi
            pcall(function()
                ReplicatedStorage.GameEvents.TradeEvents.Booths.ClaimBooth:FireServer(booth)
            end)
            
            return booth -- Keluar dari fungsi karena udah dapet booth
        end
    end
    
    -- Jikalau tidak ketemu booth kosong (semua penuh), coba paksa claim default aja
    pcall(function()
        ReplicatedStorage.GameEvents.TradeEvents.Booths.ClaimBooth:FireServer()
    end)
end

-- [[ FUNGSI AUTO STOCK ]] --
local function jalankanSistemBooth()
    task.spawn(function()
        while true do
            -- 1. Eksekusi cari dan claim booth otomatis
            autoClaimBoothKosong()
            task.wait(2)
            
            -- 2. Tembak stok barang jualan ke booth
            pcall(function()
                ReplicatedStorage.GameEvents.UpdateStock:FireServer(NAMA_ITEM, HARGA_JUAL, 1, 1)
                ReplicatedStorage.GameEvents.UpdateStock:FireServer(NAMA_ITEM, HARGA_JUAL)
            end)
            
            task.wait(10) -- Ulangi pengecekan setiap 10 detik
        end
    end)
end

-- [[ FUNGSI AUTO HOP ]] --
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
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           jalankanAutoHopServer()
       end
   end
end

-- [[ EKSEKUSI ]] --
task.spawn(function()
   print("=========================================")
   print("   YOHUB PREMIUM GAIB V2 (FIX CLAIM)     ")
   print("=========================================")
   print("Target Item : " .. NAMA_ITEM)
   print("Harga Jual  : " .. tostring(HARGA_JUAL))
   print("=========================================")
   
   jalankanSistemBooth()
   
   while true do
      task.wait(WAKTU_HOP_DETIK)
      jalankanAutoHopServer()
   end
end)
