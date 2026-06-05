-- [[ YOHUB PREMIUM - PURE MARKET BOOTH STOCKER ]] --

-- =========================================================================
--  PENGATURAN CONFIG
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" 
local HARGA_JUAL     = "11"          
local MENIT_AUTOHOP  = 20             

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

-- [[ SYSTEM: PURE AUTOMATIC STOCKING VIA UI MARKET ONLY ]] --
local function eksekusiAutoStockJeroanUI()
    pcall(function()
        local PlayerGui = localPlayer:WaitForChild("PlayerGui")
        
        -- Kita cari ScreenGui yang beneran punya unsur nama "Booth", "Trade", "Market", atau "Shop"
        -- Ini biar gak nyasar ke UI Kebun / UI NPC Steven lagi!
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            local namaGui = string.lower(gui.Name)
            if gui:IsA("ScreenGui") and gui.Enabled and (string.find(namaGui, "booth") or string.find(namaGui, "trade") or string.find(namaGui, "market") or string.find(namaGui, "shop") or string.find(namaGui, "main")) then
                
                -- 1. OTOMATIS BUKA MENU EDIT BOOTH (Jika belum kebuka)
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") and (string.find(string.lower(btn.Name), "edit") or string.find(string.lower(btn.Text), "edit booth")) then
                        klikTombol(btn)
                    end
                end
                
                task.wait(0.8) -- Jeda bentar biar UI-nya kebuka sempurna
                
                -- 2. CARI BUAH BONE BLOSSOM DI DALAM TEMPLATE INVENTORY BOOTH
                for _, itemUI in ipairs(gui:GetDescendants()) do
                    if (itemUI:IsA("TextLabel") or itemUI:IsA("TextButton")) and string.find(string.lower(itemUI.Text), string.lower(NAMA_ITEM)) then
                        local tombolPilih = itemUI:IsA("TextButton") and itemUI or itemUI:FindFirstAncestorOfClass("TextButton") or itemUI.Parent
                        if tombolPilih and tombolPilih:IsA("GuiButton") then
                            klikTombol(tombolPilih) -- Klik/Pilih buahnya
                        end
                    end
                end
                
                task.wait(0.4)
                
                -- 3. INPUT ANGKA HARGA JUAL PADA BOX YANG COCOK
                for _, box in ipairs(gui:GetDescendants()) do
                    if box:IsA("TextBox") and box.Visible then
                        box.Text = HARGA_JUAL -- Masukin harga 500
                        box:ReleaseFocus(true) -- Tekan Enter otomatis
                    end
                end
                
                task.wait(0.4)
                
                -- 4. KLIK CONFIRM / STOCK DI MENU BOOTH
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local n = string.lower(btn.Name)
                        local t = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                        
                        -- Kita saring ketat, tombol confirm harus di dalam UI booth, bukan UI Steven
                        if string.find(n, "confirm") or string.find(t, "confirm") or string.find(n, "stock") or string.find(t, "stock") then
                            klikTombol(btn)
                        end
                    end
                end
                
            end
        end
    end)
end

-- [[ SYSTEM: AUTO HOP SERVER ]] --
local function jalankanAutoHopServer()
   print("[YoHub]: Waktu habis, mencari server market baru...")
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

-- [[ RUNNING ENGINE ]] --
task.spawn(function()
   print("=========================================")
   print("    YOHUB AUTO RESTOCK MARKET ONLY       ")
   print("=========================================")
   print("[INFO]: Script aktif. Silakan Klaim Booth!")
   print("=========================================")
   
   while true do
       eksekusiAutoStockJeroanUI()
       task.wait(8) -- Nge-cek slot kosong tiap 8 detik
   end
end)

-- Loop Timer Pindah Server
task.spawn(function()
    while true do
        task.wait(WAKTU_HOP_DETIK)
        jalankanAutoHopServer()
    end
end)
