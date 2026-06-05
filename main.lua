-- [[ YOHUB PREMIUM SEMI-AFK (NO AUTO CLAIM) ]] --

-- =========================================================================
--  PENGATURAN CONFIG
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" -- Nama buah yang mau dijual otomatis
local HARGA_JUAL     = "11"          -- Harga (Wajib pakai tanda kutip untuk input teks)
local MENIT_AUTOHOP  = 20             -- Otomatis pindah server tiap X menit

-- =========================================================================
--  LOGIKA UTAMA GAME
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- Fungsi klik virtual anti-bug Delta
local function klikTombol(objek)
    if objek and objek.Visible then
        firesignal(objek.MouseButton1Click)
        firesignal(objek.MouseButton1Down)
        firesignal(objek.Activated)
        return true
    end
    return false
end

-- [[ SYSTEM: PURE AUTOMATIC STOCKING VIA UI ]] --
local function eksekusiAutoStockJeroanUI()
    pcall(function()
        local PlayerGui = localPlayer:WaitForChild("PlayerGui")
        
        -- 1. OTOMATIS BUKA/KLIK MENU EDIT BOOTH JIKA BELUM TERBUKA
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") and (string.find(string.lower(btn.Name), "edit") or string.find(string.lower(btn.Text), "edit")) then
                        klikTombol(btn)
                    end
                end
            end
        end
        
        task.wait(1) -- Tunggu UI terbuka
        
        -- 2. CARI BUAH DI DAFTAR UI INVENTORY
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, itemUI in ipairs(gui:GetDescendants()) do
                    if (itemUI:IsA("TextLabel") or itemUI:IsA("TextButton")) and string.find(string.lower(itemUI.Text), string.lower(NAMA_ITEM)) then
                        local tombolPilih = itemUI:IsA("TextButton") and itemUI or itemUI:FindFirstAncestorOfClass("TextButton") or itemUI.Parent
                        if tombolPilih and tombolPilih:IsA("GuiButton") then
                            klikTombol(tombolPilih) -- Pilih Bone Blossom otomatis
                        end
                    end
                end
            end
        end
        
        task.wait(0.5)
        
        -- 3. OTOMATIS INPUT HARGA JUAL
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, box in ipairs(gui:GetDescendants()) do
                    if box:IsA("TextBox") then
                        box.Text = HARGA_JUAL -- Masukin angka 500
                        box:ReleaseFocus(true) -- Tekan Enter otomatis
                    end
                end
            end
        end
        
        task.wait(0.5)
        
        -- 4. OTOMATIS KLIK TOMBOL CONFIRM
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local n = string.lower(btn.Name)
                        local t = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                        
                        if string.find(n, "sell") or string.find(t, "jual") or string.find(n, "confirm") or string.find(t, "confirm") then
                            klikTombol(btn) -- Confirm otomatis!
                        end
                    end
                end
            end
        end
    end)
end

-- [[ SYSTEM: AUTO HOP SERVER ]] --
local function jalankanAutoHopServer()
   print("YoHub: Pindah server market...")
   local placeId = game.PlaceId
   local url = "https://games.roblem.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
   
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

-- [[ RUNNING ENGINE ]] --
task.spawn(function()
   print("=========================================")
   print("    YOHUB AUTO RESTOCK UI (NO CLAIM)     ")
   print("=========================================")
   print("Cara Pakai: KLAIM BOOTH MANUAL TERLEBIH DAHULU")
   print("=========================================")
   
   while true do
       eksekusiAutoStockJeroanUI()
       task.wait(30) -- Cek dan isi ulang stok tiap 10 detik sekali jika abis
   end
end)

-- Loop Timer Pindah Server
task.spawn(function()
    while true do
        task.wait(WAKTU_HOP_DETIK)
        jalankanAutoHopServer()
    end
end)
