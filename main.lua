-- [[ YOHUB PREMIUM - SEAMLESS AUTO LISTING FIX ANTI-NPC ]] --

-- =========================================================================
--  PENGATURAN CONFIG
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" -- Nama buah jualan lu
local HARGA_JUAL     = "500"          -- Harga jualan lu
local MENIT_AUTOHOP  = 20             -- Waktu sebelum pindah server (menit)

-- =========================================================================
--  LOGIKA UTAMA INTEGRATOR
-- =========================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local WAKTU_HOP_DETIK = MENIT_AUTOHOP * 60
shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- Fungsi klik virtual segala jenis tombol UI (Anti-Bug Executor)
local function paksaKlik(tombol)
    if tombol and tombol.Visible then
        firesignal(tombol.MouseButton1Click)
        firesignal(tombol.MouseButton1Down)
        firesignal(tombol.Activated)
        return true
    end
    return false
end

-- [[ INTI ALGORITMA: AUTO LISTING MENGIKUTI ALUR GAME ]] --
local function eksekusiAutoListingSesuaiAlur()
    pcall(function()
        local PlayerGui = localPlayer:WaitForChild("PlayerGui")
        
        -- =================================================================
        -- LANGKAH 1: KLIK "CREATE LISTING"
        -- =================================================================
        local pencetCreate = false
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            -- Kunci hanya ScreenGui yang aktif dan namanya berbau Booth/Market/Trade
            if gui:IsA("ScreenGui") and gui.Enabled and not string.find(string.lower(gui.Name), "steven") and not string.find(string.lower(gui.Name), "npc") then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        local txt = obj:IsA("TextButton") and string.lower(obj.Text) or ""
                        local nm = string.lower(obj.Name)
                        
                        if string.find(nm, "create") or string.find(txt, "create") or string.find(nm, "listing") or string.find(txt, "listing") then
                            if paksaKlik(obj) then
                                pencetCreate = true
                                break
                            end
                        end
                    end
                end
            end
            if pencetCreate then break end
        end
        
        if pencetCreate then task.wait(0.8) end -- Jeda agar UI Inventory terbuka

        -- =================================================================
        -- LANGKAH 2: PILIH BUAH DI MY INVENTORY
        -- =================================================================
        local buahTerpilih = false
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not string.find(string.lower(gui.Name), "steven") then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and string.find(string.lower(obj.Text), string.lower(NAMA_ITEM)) then
                        -- Cari tombol pembungkus dari tulisan buah tersebut
                        local tombolBuah = obj:IsA("TextButton") and obj or obj:FindFirstAncestorOfClass("TextButton") or obj.Parent
                        if tombolBuah and tombolBuah:IsA("GuiButton") then
                            if paksaKlik(tombolBuah) then
                                buahTerpilih = true
                                break
                            end
                        end
                    end
                end
            end
            if buahTerpilih then break end
        end
        
        if buahTerpilih then task.wait(0.5) end -- Jeda agar panel kanan muncul

        -- =================================================================
        -- LANGKAH 3: INPUT HARGA DI SEBELAH KANAN
        -- =================================================================
        local hargaTerinput = false
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not string.find(string.lower(gui.Name), "steven") then
                for _, box in ipairs(gui:GetDescendants()) do
                    if box:IsA("TextBox") and box.Visible then
                        box.Text = HARGA_JUAL
                        firesignal(box.FocusLost, true) -- Paksa system membaca inputan teks harga
                        hargaTerinput = true
                        break
                    end
                end
            end
            if hargaTerinput then break end
        end
        
        if hargaTerinput then task.wait(0.4) end

        -- =================================================================
        -- LANGKAH 4 & 5: KLIK "CONFIRM" LISTING (PROTEKSI ANTI STEVEN)
        -- =================================================================
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            -- Kita saring mati-mati-an: GUI NPC Steven dilarang masuk!
            if gui:IsA("ScreenGui") and gui.Enabled and not string.find(string.lower(gui.Name), "steven") and not string.find(string.lower(gui.Name), "npc") and not string.find(string.lower(gui.Name), "sell") then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local txt = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                        local nm = string.lower(btn.Name)
                        
                        -- Kita utamakan kata 'confirm' atau 'list' untuk menghindari tombol jual ke NPC
                        if string.find(nm, "confirm") or string.find(txt, "confirm") or string.find(nm, "post") or string.find(txt, "post") or (string.find(txt, "sell") and string.find(nm, "booth")) then
                            paksaKlik(btn)
                        end
                    end
                end
            end
        end
        
    end)
end

-- [[ SYSTEM: AUTO HOP SERVER ]] --
local function jalankanAutoHopServer()
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
   print("    YOHUB AUTO ALUR V2 (ANTI STEVEN)     ")
   print("=========================================")
   print("Wajib: Klaim booth pasar dulu!")
   print("=========================================")
   
   while true do
       eksekusiAutoListingSesuaiAlur()
       task.wait(12) -- Menjalankan urutan ritual di atas setiap 12 detik sekali
   end
end)

-- Loop Timer Pindah Server
task.spawn(function()
    while true do
        task.wait(WAKTU_HOP_DETIK)
        jalankanAutoHopServer()
    end
end)
