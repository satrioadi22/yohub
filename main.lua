-- [[ YOHUB AUTO CLICKER STOCK - BYPASS PHYSICS SYSTEM ]] --

-- =========================================================================
--  PENGATURAN CONFIG
-- =========================================================================
local MENIT_AUTOHOP  = 20 -- Waktu tunggu sebelum pindah server market (menit)

-- =========================================================================
--  LOGIKA UTAMA (BYPASS CLICK SYSTEM)
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ FUNGSI AUTO CLICK TOMBOL JUAL DI SCREEN LU ]] --
local function paksaKlikTombolJualan()
    pcall(function()
        -- Script akan menggeledah UI Player lu secara otomatis
        local PlayerGui = localPlayer:WaitForChild("PlayerGui")
        
        -- Keliling nyari UI bertema Booth, Shop, Trade, atau Interaction
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                -- Cari tombol yang namanya mengandung unsur Jual / Confirm / Stock
                for _, tombol in ipairs(gui:GetDescendants()) do
                    if tombol:IsA("TextButton") or tombol:IsA("ImageButton") then
                        local namaTombol = string.lower(tombol.Name)
                        local teksTombol = tombol:IsA("TextButton") and string.lower(tombol.Text) or ""
                        
                        -- Jika mendapati tombol Confirm, Sell, Auto, atau Stock
                        if string.find(namaTombol, "confirm") or string.find(teksTombol, "confirm") 
                        or string.find(namaTombol, "sell") or string.find(teksTombol, "jual")
                        or string.find(namaTombol, "stock") or string.find(teksTombol, "stock") then
                            
                            -- Picu fungsi klik secara paksa lewat virtual script (Bypass UI Bug Delta!)
                            if tombol.Visible then
                                firesignal(tombol.MouseButton1Click)
                                firesignal(tombol.MouseButton1Down)
                                firesignal(tombol.Activated)
                                print("[YoHub]: Berhasil menembak Klik pada tombol: " .. tombol.Name)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- [[ LOOPING PENGECEKAN ]] --
local function jalankanAutoStock()
    task.spawn(function()
        while true do
            -- Jalankan paksa klik tombol jualan di background setiap 3 detik sekali
            paksaKlikTombolJualan()
            task.wait(3)
        end
    end)
end

-- [[ FUNGSI AUTO HOP SERVER ]] --
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
           print("YoHub: Otw Teleport ke server market baru...")
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
   print("    YOHUB FINAL BYPASS BUTTON ACTIVE     ")
   print("=========================================")
   print("Sistem      : Auto Clicker UI Integrator")
   print("Status      : Bypass Bug Input Delta")
   print("=========================================")
   
   jalankanAutoStock()
   
   while true do
      task.wait(WAKTU_HOP_DETIK)
      jalankanAutoHopServer()
   end
end)
