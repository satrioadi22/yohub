-- [[ YOHUB FINAL VERSI GAIB - 100% BYPASS BUG UI DELTA ]] --

-- =========================================================================
--  PENGATURAN DAGANGAN LU (Ubah angkanya di sini sebelum di-execute!)
-- =========================================================================
local NAMA_BUAH      = "Bone Blossom"  -- Ganti dengan nama buah yang mau lu jual (Contoh: "Apple", "Orange", "Banana")
local HARGA_JUAL     = 11     -- Tentukan harga jual buah lu per biji di sini
local MENIT_AUTOHOP  = 20       -- Mau berapa menit sekali pindah server? (Default: 20 menit)

-- =========================================================================
--             LOGIKA UTAMA GAME (JANGAN DIUBAH SAMA SEKALI)
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ LOOP AUTO STOCK BERJALAN DI BACKGROUND ]] --
local function lakukanAutoStockOtomatis()
    task.spawn(function()
        while true do
            -- Memastikan karakter lu punya folder jualan/booth di game
            pcall(function()
                -- Tembak beberapa variasi argumen remote sekaligus biar server nerima datanya secara valid
                ReplicatedStorage.GameEvents.UpdateStock:FireServer(NAMA_BUAH, HARGA_JUAL, 1, 1)
                ReplicatedStorage.GameEvents.UpdateStock:FireServer(NAMA_BUAH, HARGA_JUAL)
            end)
            task.wait(5) -- Mengulang proses stok otomatis setiap 5 detik sekali
        end
    end)
end

-- [[ FUNGSI AUTO HOP SERVER MAJU KE MARKET LAIN ]] --
local function lakukanAutoHopServer()
   print("YoHub: Mencari server market baru...")
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
       
       if #validServers > 0 then
           print("YoHub: Server baru ditemukan! Otw Teleport...")
           task.wait(1)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, localPlayer)
       else
           print("YoHub: Server penuh atau sudah dikunjungi, mengulang pencarian...")
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           lakukanAutoHopServer()
       end
   else
       print("YoHub: Gagal membaca API Roblox, mencoba ulang...")
   end
end

-- [[ MENJALANKAN SYSTEM GABUNGAN ]] --
task.spawn(function()
   print("=========================================")
   print("   YOHUB VERSI GAIB DIAKTIFKAN BENERAN   ")
   print("=========================================")
   print("Target Buah : " .. NAMA_BUAH)
   print("Harga Jual  : " .. tostring(HARGA_JUAL))
   print("Auto Hop    : Setiap " .. tostring(MENIT_AUTOHOP) .. " Menit sekali.")
   print("=========================================")
   
   -- Jalankan fungsi jualan otomatis
   lakukanAutoStockOtomatis()
   
   -- Loop waktu mundur untuk pindah server publik
   while true do
      task.wait(WAKTU_HOP_DETIK)
      lakukanAutoHopServer()
   end
end)
