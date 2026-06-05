-- [[ YOHUB PREMIUM GAIB V3 - SMART BOOTH SCANNER ]] --

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

-- [[ FUNGSI PINTAR CARI BOOTH KOSONG / MILIK SENDIRI ]] --
local function eksekusiClaimDanStock()
    local targetBooth = nil
    local beneranClaimed = false

    -- 1. SCANNING: Cari objek di Workspace yang bertindak sebagai Booth
    for _, v in ipairs(workspace:GetDescendants()) do
        -- Kita cari objek yang namanya mengandung kata "booth"
        if string.find(string.lower(v.Name), "booth") and not v:IsA("BasePart") then
            
            -- Cek apakah ini booth milik kita yang sudah berhasil diklaim sebelumnya
            local isOwner = v:FindFirstChild("Owner") or v:FindFirstChild("Player") or v:FindFirstChild("User")
            
            if isOwner and tostring(isOwner.Value) == localPlayer.Name then
                targetBooth = v
                beneranClaimed = true
                print("YoHub: Booth lu terdeteksi -> " .. v.Name)
                break
            end
            
            -- Jika belum punya booth, simpan booth pertama yang kosong/tidak ada owner-nya
            if not targetBooth and (not isOwner or isOwner.Value == "" or isOwner.Value == nil or isOwner.Value == 0) then
                -- Pastikan objek ini punya kemiripan dengan struktur Booth jualan (punya slot / area interaksi)
                if v:FindFirstChild("Slots") or v:FindFirstChild("Structure") or v:FindFirstChild("Hitbox") or #v:GetChildren() > 2 then
                    targetBooth = v
                end
            end
        end
    end

    -- 2. ACTION: Eksekusi berdasarkan kondisi booth yang ditemukan
    if targetBooth then
        pcall(function()
            if not beneranClaimed then
                print("YoHub: Mencoba klaim otomatis -> " .. targetBooth.Name)
                -- Tembak remote claim dengan objek booth yang kita temukan
                if ReplicatedStorage:FindFirstChild("GameEvents") then
                    local tradeEvents = ReplicatedStorage.GameEvents:FindFirstChild("TradeEvents") or ReplicatedStorage.GameEvents
                    local boothsFolder = tradeEvents:FindFirstChild("Booths") or tradeEvents
                    local claimRemote = boothsFolder:FindFirstChild("ClaimBooth") or ReplicatedStorage.GameEvents:FindFirstChild("ClaimBooth")
                    
                    if claimRemote then
                        claimRemote:FireServer(targetBooth)
                        claimRemote:FireServer() -- Jalur cadangan kosongan
                    end
                end
            end
            
            -- 3. AUTO STOCK: Kirim data barang jualan langsung
            -- Kita tembak tipis-tipis jalurnya biar masuk ke server game
            local updateRemote = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("UpdateStock")
            if updateRemote then
                updateRemote:FireServer(NAMA_ITEM, HARGA_JUAL, 1, 1)
                updateRemote:FireServer(targetBooth, NAMA_ITEM, HARGA_JUAL)
                updateRemote:FireServer(NAMA_ITEM, HARGA_JUAL)
            end
        end)
    else
        print("YoHub: Belum menemukan booth yang cocok di server ini.")
    end
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

-- [[ RUNNING SYSTEM ]] --
task.spawn(function()
   print("=========================================")
   print("   YOHUB PREMIUM GAIB V3 (SMART SCAN)    ")
   print("=========================================")
   print("Target Item : " .. NAMA_ITEM)
   print("Harga Jual  : " .. tostring(HARGA_JUAL))
   print("=========================================")
   
   while true do
       eksekusiClaimDanStock()
       task.wait(8) -- Cek berkala setiap 8 detik
   end
end)

-- Loop timer untuk pindah server market
task.spawn(function()
    while true do
        task.wait(WAKTU_HOP_DETIK)
        jalankanAutoHopServer()
    end
end)
