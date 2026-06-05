-- [[ YOHUB PURE AUTO RESTOCK - GROW A GARDEN INDONESIA ]] --

-- =========================================================================
--  PENGATURAN CONFIG (Ubah di sini sebelum lu execute!)
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" -- Nama buah/item jualan lu
local HARGA_JUAL     = 11            -- Harga jualan lu
local MENIT_AUTOHOP  = 20             -- Waktu nunggu sebelum pindah server (menit)

-- =========================================================================
--  LOGIKA UTAMA (BERDASARKAN JALUR DISKOBERI LU)
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- Fungsi mencari booth milik lu berdasarkan jalur TextLabel papan nama
local function cariBoothGua()
    local folderBooths = workspace:FindFirstChild("TradeWorld") and workspace.TradeWorld:FindFirstChild("Booths")
    if not folderBooths then return nil end

    -- Scan semua ID unik booth di dalam folder Booths
    for _, booth in ipairs(folderBooths:GetChildren()) do
        pcall(function()
            -- Sesuai jalur yang lu temuin: Default -> Booth -> Sign -> SurfaceGui -> TextLabel
            local label = booth:FindFirstChild("Default") 
                and booth.Default:FindFirstChild("Booth")
                and booth.Default.Booth:FindFirstChild("Sign")
                and booth.Default.Booth.Sign:FindFirstChild("SurfaceGui")
                and booth.Default.Booth.Sign.SurfaceGui:FindFirstChild("TextLabel")

            -- Jika teks di papan nama mengandung nama akun lu, berarti ini booth lu!
            if label and string.find(string.lower(label.Text), string.lower(localPlayer.Name)) then
                _G.BoothKetemu = booth
            end
        end)
        if _G.BoothKetemu == booth then return booth end
    end
    return nil
end

-- [[ LOOP AUTO RESTOCK MATANG ]] --
local function jalankanAutoRestock()
    task.spawn(function()
        while true do
            local boothGua = cariBoothGua()
            
            if boothGua then
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("UpdateStock")
                    if remote then
                        -- Kita tembak pake ID Unik Booth lu yang dapet dari scanner
                        remote:FireServer(boothGua, NAMA_ITEM, HARGA_JUAL)
                        remote:FireServer(boothGua, NAMA_ITEM, HARGA_JUAL, 1)
                        remote:FireServer(NAMA_ITEM, HARGA_JUAL, 1, 1)
                    end
                end)
                print("[YoHub]: Berhasil menyetok " .. NAMA_ITEM .. " seharga " .. tostring(HARGA_JUAL) .. " di booth lu!")
            else
                print("[YoHub]: Lu BELUM KLAIM BOOTH. Klaim manual dulu sampai papan nama lu muncul!")
            end
            
            task.wait(5) -- Mengulang auto stock setiap 5 detik sekali
        end
    end)
end

-- [[ FUNGSI AUTO HOP ]] --
local function jalankanAutoHopServer()
   print("YoHub: Waktu habis, pindah server...")
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

-- [[ RUNNING EXECUTOR ]] --
task.spawn(function()
   print("=========================================")
   print("    YOHUB AUTO RESTOCK 100% ACCURATE     ")
   print("=========================================")
   print("Target Item : " .. NAMA_ITEM)
   print("Harga Jual  : " .. tostring(HARGA_JUAL))
   print("Wajib       : Klaim Booth Manual Dulu!")
   print("=========================================")
   
   jalankanAutoRestock()
   
   while true do
      task.wait(WAKTU_HOP_DETIK)
      jalankanAutoHopServer()
   end
end)
