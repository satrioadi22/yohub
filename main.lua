local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FILE_NAME = "BoothTeleportConfig.json"
_G.AutoBooth = false

local function loadConfig()
    if isfile and isfile(FILE_NAME) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_NAME))
        end)
        if ok and type(data) == "table" and data.Enabled ~= nil then
            _G.AutoBooth = data.Enabled
        end
    end
end

local function saveConfig()
    if writefile then
        writefile(FILE_NAME, HttpService:JSONEncode({ Enabled = _G.AutoBooth }))
    end
end

loadConfig()

-- GUI
if CoreGui:FindFirstChild("BoothUI") then
    CoreGui.BoothUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoothUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 170, 0, 80)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Size = UDim2.new(1, 0, 0, 20)
Title.Text = "Booth Teleport"
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13

local Toggle = Instance.new("TextButton")
Toggle.Parent = Frame
Toggle.Position = UDim2.new(0.08, 0, 0, 30)
Toggle.Size = UDim2.new(0, 142, 0, 38)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 15
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

local function updateUI()
    if _G.AutoBooth then
        Toggle.Text = "Auto Booth: ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        Toggle.Text = "Auto Booth: OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
end

Toggle.MouseButton1Click:Connect(function()
    _G.AutoBooth = not _G.AutoBooth
    updateUI()
    saveConfig()
end)

updateUI()

-- Auto teleport loop
task.spawn(function()
    while true do
        task.wait(8)
        if _G.AutoBooth then
            pcall(function()
                local remote = ReplicatedStorage.GameEvents.PlayerTeleportTriggered
                remote:FireServer("Booth")
                print("Teleported to Booth!")
            end)
        end
    end
end)
