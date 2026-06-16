-- // Auto Hop Server UI with Config Save \\ --

local Players = game:GetService("Players")
local TS = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- // PENGATURAN \\ --
local MIN_PLAYERS = 5
local CONFIG_NAME = "AutoHopConfig.txt"

-- // VARIABEL STATUS \\ --
local isToggled = false
local isHopping = false

-- // SISTEM SAVE CONFIG (BIAR INGAT KALAU DI EXECUTE LAGI) \\ --
local function saveConfig()
    if writefile then
        writefile(CONFIG_NAME, tostring(isToggled))
    end
end

local function loadConfig()
    if readfile and isfile and isfile(CONFIG_NAME) then
        local data = readfile(CONFIG_NAME)
        if data == "true" then
            return true
        end
    end
    return false
end

-- // FUNGSI TELEPORT BYPASS DELTA \\ --
local function teleportTo(placeId, jobId)
    if getconnections then
        for _, conn in pairs(getconnections(TS.InternalTeleport)) do
            conn:Enable()
        end
    end
    TS:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
end

-- // FUNGSI CARI SERVER \\ --
local function findNewServer()
    if isHopping then return end
    isHopping = true
    StatusLabel.Text = "Status: Mencari server..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

    local placeId = game.PlaceId
    local cursor = nil
    
    pcall(function()
        while true do
            local url = cursor and ("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor) or ("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
            
            local response = HttpService:JSONDecode(game:HttpGet(url))
            
            for _, server in pairs(response.data) do
                if server.playing >= MIN_PLAYERS and server.id ~= game.JobId then
                    print("[HOP] Server ditemukan! Pemain: " .. server.playing)
                    StatusLabel.Text = "Status: Hopping!"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    teleportTo(placeId, server.id)
                    task.wait(5)
                    isHopping = false
                    return
                end
            end
            
            cursor = response.nextPageCursor
            if not cursor then break end
            task.wait(1)
        end
    end)
    
    StatusLabel.Text = "Status: Server tidak ditemukan"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    isHopping = false
end

-- // BIKIN UI \\ --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "AutoHopUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0) -- Posisi di kiri layar
MainFrame.Size = UDim2.new(0, 180, 0, 120)
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa dipindahin posisinya

-- Bikin kampak (bulat dikit)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "AUTO HOP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah = OFF
ToggleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.7, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Standby"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12

-- // LOGIKA TOMBOL ON/OFF \\ --
ToggleBtn.MouseButton1Click:Connect(function()
    isToggled = not isToggled
    saveConfig() -- Simpan ke file biar ingat
    
    if isToggled then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Hijau = ON
        StatusLabel.Text = "Status: Aktif"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah = OFF
        StatusLabel.Text = "Status: Mati"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- // LOOPING UTAMA \\ --
task.spawn(function()
    while task.wait(3) do
        if isToggled and not isHopping then
            local playerCount = #Players:GetPlayers()
            if playerCount < MIN_PLAYERS then
                findNewServer()
            else
                StatusLabel.Text = "Status: Aman ("..playerCount.." Pemain)"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end)

-- // CEK CONFIG SEBELUMNYA (AUTO ON KALAU EXECUTE LAGI) \\ --
if loadConfig() then
    isToggled = true
    ToggleBtn.Text = "ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    StatusLabel.Text = "Status: Aktif (Auto)"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
end
