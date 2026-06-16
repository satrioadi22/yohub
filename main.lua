-- // AUTO HOP V6 (HOOK DELTA BYPASS - SENJATA RAHASIA) \\ --

local Players = game:GetService("Players")
local OldTeleport = nil
local LocalPlayer = Players.LocalPlayer

local MIN_PLAYERS = 5
local placeId = game.PlaceId

local isToggled = true 
local isHopping = false

-- // SENJATA RAHASIA: NYIMPEN FUNGSI TELEPORT SEBELUM DELTA HAPUS \\ --
pcall(function()
    -- Kita nyimpen fungsi asli Roblox sebelum sempat di-block sama Delta
    OldTeleport = game:GetService("TeleportService").TeleportToPlaceInstance
end)

-- // FUNGSI HOP DENGAN HOOK \\ --
local function forceHop()
    if isHopping then return end
    isHopping = true
    StatusLabel.Text = "Status: Forcing Hop..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

    local hopped = false

    -- CARA 1: Pake fungsi asli yang kita selametin tadi
    if OldTeleport then
        pcall(function()
            StatusLabel.Text = "Status: Hooked! Teleporting..."
            -- Kita pakai fungsi Roblox yang asli, bukan yang udah dioprek Delta
            OldTeleport(game:GetService("TeleportService"), placeId, game.JobId, LocalPlayer)
            hopped = true
        end)
    end

    -- CARA 2: Fallback ke game:HttpGet (Biasanya tembus kalau Cara 1 gagal ngambil job id)
    if not hopped then
        pcall(function()
            StatusLabel.Text = "Status: Rejoining Server..."
            game:GetService("TeleportService"):Teleport(placeId, LocalPlayer)
            hopped = true
        end)
    end

    -- CARA 3: Respawn karakter paksa
    if not hopped then
        pcall(function()
            StatusLabel.Text = "Status: Respawn Character..."
            LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
        end)
    end

    task.wait(8) -- Waktu buat loading screen
    isHopping = false
end

-- // BIKIN UI \\ --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

pcall(function()
    if game.CoreGui:FindFirstChild("AutoHopUI") then
        game.CoreGui:FindFirstChild("AutoHopUI"):Destroy()
    end
end)

ScreenGui.Name = "AutoHopUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true

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
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.65, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 35)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Hooked & Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true

ToggleBtn.MouseButton1Click:Connect(function()
    isToggled = not isToggled
    if isToggled then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        StatusLabel.Text = "Status: Aktif"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
                forceHop()
            else
                StatusLabel.Text = "Status: Aman ("..playerCount.." Pemain)"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end)
