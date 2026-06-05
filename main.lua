-- [[ YOHUB PREMIUM - 4-STEP SCREENSHOT AUTOMATION ]] --

-- =========================================================================
--  PENGATURAN CONFIG
-- =========================================================================
local NAMA_ITEM      = "Bone Blossom" -- Nama buah di foto lu
local MENIT_AUTOHOP  = 20             -- Waktu sebelum pindah server

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

-- Fungsi klik tangguh khusus executor Delta
local function klikMulus(objek)
    if objek and objek.Visible then
        firesignal(objek.MouseButton1Click)
        firesignal(objek.MouseButton1Down)
        firesignal(objek.Activated)
        return true
    end
    return false
end

-- [[ INTEGRASI 4 LANGKAH VISUAL LU ]] --
local function eksekusiRitualAutoListing()
    pcall(function()
        local PlayerGui = localPlayer:WaitForChild("PlayerGui")
        
        -- Kita cari core UI Pasar yang sedang aktif di layar lu
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not string.find(string.lower(gui.Name), "steven") then
                
                -- =================================================================
                -- FOTO 1: KLIK TOMBOL "CREATE LISTING" (Tombol Hijau Plus)
                -- =================================================================
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        local teks = obj:IsA("TextButton") and string.lower(obj.Text) or ""
                        if string.find(string.lower(obj.Name), "create") or string.find(teks, "create listing") then
                            if klikMulus(obj) then 
                                task.wait(0.6) 
                                break 
                            end
                        end
                    end
                end
                
                -- =================================================================
                -- FOTO 2: PILIH BUAH "BONE BLOSSOM" DI MY INVENTORY
                -- =================================================================
                for _, obj in ipairs(gui:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and string.find(obj.Text, NAMA_ITEM) then
                        local slotBuah = obj:IsA("TextButton") and obj or obj:FindFirstAncestorOfClass("TextButton") or obj.Parent
                        if slotBuah and slotBuah:IsA("GuiButton") then
                            if klikMulus(slotBuah) then 
                                task.wait(0.6) 
                                break 
                            end
                        end
                    end
                end
                
                -- =================================================================
                -- FOTO 3: KLIK TOMBOL "SELL" HIJAU DI PANEL KANAN
                -- =================================================================
                -- (Note: Karena sistem harga di game ini sensitif, script akan otomatis langsung)
                -- (menekan tombol SELL hijau bawaan agar buahnya langsung ke-listing dengan harga default RAP-nya!)
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") and obj.Text == "SELL" and obj.Visible then
                        -- Kita pastikan dia bertuliskan kapital "SELL" murni di panel pasar
                        if klikMulus(obj) then 
                            task.wait(0.6) 
                            break 
                        end
                    end
                end
                
                -- =================================================================
                -- FOTO 4: KLIK POP-UP "CONFIRM" HIJAU FINAL
                -- =================================================================
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") and obj.Text == "Confirm" and obj.Visible then
                        klikMulus(obj)
                        break
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
   print("    YOHUB PREMIUM 4-STAGE ENGINE FIXED   ")
   print("=========================================")
   print("Status: Menunggu Lu Klaim Booth Manual...")
   print("=========================================")
   
   while true do
       eksekusiRitualAutoListing()
       task.wait(8) -- Setiap 8 detik script nge-scan & ngisi slot kosong otomatis
   end
end)

-- Loop Timer Pindah Server
task.spawn(function()
    while true do
        task.wait(WAKTU_HOP_DETIK)
        jalankanAutoHopServer()
    end
end)
