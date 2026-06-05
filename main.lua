-- [[ LOAD KAVO UI LIBRARY ]] --
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("YoHub | Grow a Garden", "BloodTheme")

-- [[ VARIABLES & CONFIG ]] --
local _G = getgenv and getgenv() or _G
_G.AutoHopEnabled = false
_G.WaktuTunggu = 1200
_G.SisaWaktuDetik = 1200

_G.AutoStockEnabled = false
_G.FruitYangDijual = ""
_G.HargaJual = 100

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ UI TABS ]] --
local MainTab = Window:NewTab("Main Features")
local UIConfigTab = Window:NewTab("UI Settings")

local HopSection = MainTab:NewSection("Auto Hop Server")
local StockSection = MainTab:NewSection("Auto Stock Booth")
local ConfigSection = UIConfigTab:NewSection("Tampilan UI")

-- [[ LABELS MONITORING ]] --
local StatusLabel = HopSection:NewLabel("Status: Auto Hop Mati")
local TimerLabel = HopSection:NewLabel("Sisa Waktu: --:--")

-- [[ FUNCTION SCAN INVENTORY UNTUK DROPDOWN ]] --
local function getInventoryFruits()
    local fruits = {}
    -- Cek di Backpack (Inventory yang sedang dipegang/bawa)
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            -- Memastikan tidak memasukkan Tool duplikat ke daftar
            if not table.find(fruits, item.Name) then
                table.insert(fruits, item.Name)
            end
        end
    end
    
    -- Cek juga di Character (kalau buahnya lagi di-equip/dipegang di tangan)
    local char = localPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and not table.find(fruits, item.Name) then
                table.insert(fruits, item.Name)
            end
        end
    end

    -- Jika inventory kosong, kasih opsi default
    if #fruits == 0 then
        table.insert(fruits, "Inventory Kosong / Pegang Buah Lu")
    end
    return fruits
end

-- [[ FUNCTION FORMAT WAKTU ]] --
local function formatWaktu(totalDetik)
    local menit = math.floor(totalDetik / 60)
    local detik = totalDetik % 60
    return string.format("%02d:%02d", menit, detik)
end

-- [[ FUNCTION AUTO HOP ]] --
local function doAutoHop()
   if not _G.AutoHopEnabled then return end
   StatusLabel:UpdateLabel("Status: Mencari Server Baru...")
   
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
       
       if #validServers > 0 and _G.AutoHopEnabled then
           local randomServerId = validServers[math.random(1, #validServers)]
           StatusLabel:UpdateLabel("Status: Server Ketemu! Teleporting...")
           task.wait(1)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, Players.LocalPlayer)
       else
           StatusLabel:UpdateLabel("Status: Server penuh, mengulang...")
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           doAutoHop()
       end
   else
       StatusLabel:UpdateLabel("Status: Gagal mengambil data API")
   end
end

-- [[ FUNCTION AUTO STOCK ]] --
local function doAutoStock()
    task.spawn(function()
        while _G.AutoStockEnabled do
            if _G.FruitYangDijual ~= "" and _G.FruitYangDijual ~= "Inventory Kosong / Pegang Buah Lu" then
                pcall(function()
                    ReplicatedStorage.GameEvents.UpdateStock:FireServer(_G.FruitYangDijual, _G.HargaJual)
                end)
            end
            task.wait(10)
        end
    end)
end

-- [[ BACKGROUND LOOP TIMER AUTO HOP ]] --
task.spawn(function()
   while true do
      task.wait(1)
      if _G.AutoHopEnabled then
         if _G.SisaWaktuDetik > 0 then
            _G.SisaWaktuDetik = _G.SisaWaktuDetik - 1
            TimerLabel:UpdateLabel("Sisa Waktu: " .. formatWaktu(_G.SisaWaktuDetik))
         else
            TimerLabel:UpdateLabel("Sisa Waktu: WAKTU HABIS!")
            doAutoHop()
         end
      else
         TimerLabel:UpdateLabel("Sisa Waktu: --:--")
      end
   end
end)


-- [[ UI ELEMENTS - AUTO HOP ]] --

HopSection:NewToggle("Aktifkan Auto Hop", "Otomatis pindah server pas waktu habis", function(Value)
    _G.AutoHopEnabled = Value
    if Value then
        _G.SisaWaktuDetik = _G.WaktuTunggu
        StatusLabel:UpdateLabel("Status: Auto Hop Berjalan")
    else
        StatusLabel:UpdateLabel("Status: Auto Hop Mati")
    end
end)

HopSection:NewSlider("Atur Menit Tunggu", "Geser buat ganti menit", 60, 1, function(Value)
    _G.WaktuTunggu = Value * 60
    if _G.AutoHopEnabled then
        _G.SisaWaktuDetik = _G.WaktuTunggu
    end
end)

HopSection:NewButton("Instant Hop Sekarang", "Pindah server langsung tanpa nunggu", function()
    _G.AutoHopEnabled = true
    doAutoHop()
end)


-- [[ UI ELEMENTS - AUTO STOCK ]] --

StockSection:NewToggle("Aktifkan Auto Stock", "Otomatis masukin buah ke booth", function(Value)
    _G.AutoStockEnabled = Value
    if Value then
        doAutoStock()
    end
end)

-- Dropdown Buah Otomatis (Membaca isi inventory lu)
local FruitDropdown = StockSection:NewDropdown("Pilih Buah Jualan", "Daftar buah di inventory lu", getInventoryFruits(), function(currentOption)
    _G.FruitYangDijual = currentOption
    print("YoHub: Buah dipilih -> " .. currentOption)
end)

-- Tombol Refresh Dropdown (Buat update daftar kalau lu abis panen buah baru)
StockSection:NewButton("🔄 Refresh Daftar Buah", "Klik jika abis ambil buah baru dari inventory", function()
    FruitDropdown:Refresh(getInventoryFruits())
end)

StockSection:NewTextBox("Harga Jual (Price)", "Masukkan angka harga", function(Text)
    local angka = tonumber(Text)
    if angka then
        _G.HargaJual = angka
    else
        _G.HargaJual = 0
    end
end)


-- [[ UI ELEMENTS - SETTINGS (RESIZE/MINIMIZE) ]] --

-- Tombol Sembunyikan UI (Biar gak menonjol dan layar lega)
ConfigSection:NewKeybind("Tombol Hide UI", "Pencet tombol ini buat nutup/buka menu", Enum.KeyCode.F3, function()
    Kavo:ToggleUI()
end)

ConfigSection:NewButton("Minimize / Sembunyikan Menu", "Klik untuk menyembunyikan sementara", function()
    Kavo:ToggleUI()
end)
