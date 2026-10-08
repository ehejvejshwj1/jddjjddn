local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "挖矿助手",
    Icon = "rbxassetid://10734898176",
    Author = "你",
    Folder = "MineHelper",
    Size = UDim2.fromOffset(480, 320),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    MobileButtons = true,
})

local MainTab = Window:Tab({
    Title = "主功能",
    Icon = "rbxassetid://10734924532",
})

local SettingsTab = Window:Tab({
    Title = "设置",
    Icon = "rbxassetid://10734924532",
})

local statusGui = Instance.new("ScreenGui")
statusGui.Name = "StatusOverlay"
statusGui.ResetOnSpawn = false
statusGui.Parent = game.CoreGui

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 230, 0, 130)
statusFrame.Position = UDim2.new(0, 15, 0.15, 0)
statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusFrame.BackgroundTransparency = 0.2
statusFrame.Parent = statusGui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -16, 0, 22)
statusTitle.Position = UDim2.new(0, 8, 0, 4)
statusTitle.BackgroundTransparency = 1
statusTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
statusTitle.Text = "挖矿状态"
statusTitle.TextScaled = true
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.Parent = statusFrame

local statusBind = Instance.new("TextLabel")
statusBind.Size = UDim2.new(1, -16, 0, 20)
statusBind.Position = UDim2.new(0, 8, 0, 28)
statusBind.BackgroundTransparency = 1
statusBind.TextColor3 = Color3.fromRGB(200, 200, 200)
statusBind.Text = "状态: 待机"
statusBind.TextScaled = true
statusBind.Font = Enum.Font.Gotham
statusBind.TextXAlignment = Enum.TextXAlignment.Left
statusBind.TextTruncate = Enum.TextTruncate.AtEnd
statusBind.Parent = statusFrame

local statusDist = Instance.new("TextLabel")
statusDist.Size = UDim2.new(1, -16, 0, 20)
statusDist.Position = UDim2.new(0, 8, 0, 48)
statusDist.BackgroundTransparency = 1
statusDist.TextColor3 = Color3.fromRGB(255, 255, 100)
statusDist.Text = "盒饭: 0 个"
statusDist.TextScaled = true
statusDist.Font = Enum.Font.Gotham
statusDist.TextXAlignment = Enum.TextXAlignment.Left
statusDist.Parent = statusFrame

local statusCount = Instance.new("TextLabel")
statusCount.Size = UDim2.new(1, -16, 0, 20)
statusCount.Position = UDim2.new(0, 8, 0, 68)
statusCount.BackgroundTransparency = 1
statusCount.TextColor3 = Color3.fromRGB(100, 255, 100)
statusCount.Text = "挖矿: 0 次"
statusCount.TextScaled = true
statusCount.Font = Enum.Font.Gotham
statusCount.TextXAlignment = Enum.TextXAlignment.Left
statusCount.Parent = statusFrame

local statusFood = Instance.new("TextLabel")
statusFood.Size = UDim2.new(1, -16, 0, 20)
statusFood.Position = UDim2.new(0, 8, 0, 88)
statusFood.BackgroundTransparency = 1
statusFood.TextColor3 = Color3.fromRGB(255, 150, 150)
statusFood.Text = "吃饭: 关 | 0 次"
statusFood.TextScaled = true
statusFood.Font = Enum.Font.Gotham
statusFood.TextXAlignment = Enum.TextXAlignment.Left
statusFood.Parent = statusFrame

local statusBuy = Instance.new("TextLabel")
statusBuy.Size = UDim2.new(1, -16, 0, 20)
statusBuy.Position = UDim2.new(0, 8, 0, 108)
statusBuy.BackgroundTransparency = 1
statusBuy.TextColor3 = Color3.fromRGB(150, 200, 255)
statusBuy.Text = "买饭: 0 次 | 扔垃圾: 0 次"
statusBuy.TextScaled = true
statusBuy.Font = Enum.Font.Gotham
statusBuy.TextXAlignment = Enum.TextXAlignment.Left
statusBuy.Parent = statusFrame

local dragging, dragStart, startPos
statusFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = statusFrame.Position
    end
end)
statusFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        statusFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
statusFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local boundPrompt = nil
local isTriggering = false
local autoMine = false
local autoEat = false
local autoBuy = false
local autoTrash = false
local quickMode = false
local quickConn = nil
local autoThread = nil
local eatThread = nil
local checkThread = nil
local showStatus = true
local triggerCount = 0
local eatCount = 0
local buyCount = 0
local trashCount = 0
local isBusy = false
local afkConn = nil

local eatInterval = 60
local buyThreshold = 3
local trashAfterEat = true
local lastEatTime = 0
local lastCheckTime = 0
local trashName = "垃圾袋"

local minePos = nil

local function startAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    afkConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
end

local function getChar()
    return game.Players.LocalPlayer.Character
end

local function getRoot()
    local char = getChar()
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function getBackpack()
    return game.Players.LocalPlayer:FindFirstChild("Backpack")
end

local function getHumanoid()
    local char = getChar()
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
end

local function findNearestHoldPrompt()
    local root = getRoot()
    if not root then return nil, 0 end
    local nearest, minDist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and v.HoldDuration > 0 then
            local part = v.Parent
            if part and part:IsA("BasePart") then
                local d = (root.Position - part.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = v
                end
            end
        end
    end
    return nearest, minDist
end

local function findFoodPrompt()
    local m = workspace:FindFirstChild("地图")
    if not m then return nil end
    m = m:FindFirstChild("建筑")
    if not m then return nil end
    m = m:FindFirstChild("矿场")
    if not m then return nil end
    m = m:FindFirstChild("地下")
    if not m then return nil end
    m = m:FindFirstChild("第二层")
    if not m then return nil end
    m = m:FindFirstChild("Model")
    if not m then return nil end
    m = m:FindFirstChild("盒饭")
    if not m then return nil end
    m = m:FindFirstChild("生产")
    if not m then return nil end
    return m:FindFirstChild("ProximityPrompt")
end

local function findTrashPrompt()
    local nearest, minDist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local part = v.Parent
            if part and part:IsA("BasePart") then
                local n = part.Name:lower()
                local pn = part.Parent and part.Parent.Name:lower() or ""
                if n:find("垃圾") or n:find("桶") or n:find("bin") or n:find("trash")
                   or pn:find("垃圾") or pn:find("桶") or pn:find("bin") or pn:find("trash") then
                    table.insert({}, v)
                end
            end
        end
    end
    return nil
end

local function findTrashPromptReal()
    local root = getRoot()
    if not root then return nil end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local part = v.Parent
            if part and part:IsA("BasePart") then
                local n = part.Name:lower()
                local pn = ""
                if part.Parent then pn = part.Parent.Name:lower() end
                if n:find("垃圾") or n:find("桶") or n:find("bin") or n:find("trash")
                   or pn:find("垃圾") or pn:find("桶") or pn:find("bin") or pn:find("trash") then
                    return v
                end
            end
        end
    end
    return nil
end

local function countFood()
    local backpack = getBackpack()
    local char = getChar()
    local count = 0
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v.Name == "盒饭" then count = count + 1 end
        end
    end
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v.Name == "盒饭" then count = count + 1 end
        end
    end
    return count
end

local function hasTrash()
    local char = getChar()
    if not char then return false end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("垃圾") then
            return true
        end
    end
    return false
end

local function teleportTo(part)
    local root = getRoot()
    if not root or not part then return end
    local pos = part.Position
    local back = root.Position - pos
    if back.Magnitude < 0.1 then back = Vector3.new(0, 0, 1) end
    root.CFrame = CFrame.new(pos + back.Unit * 3)
    task.wait(0.3)
end

local function buyFood()
    local prompt = findFoodPrompt()
    if not prompt then return false end
    local root = getRoot()
    if not root then return false end
    local part = prompt.Parent
    if not part then return false end
    local originalCFrame = root.CFrame
    teleportTo(part)
    task.wait(0.3)
    pcall(function()
        fireproximityprompt(prompt)
    end)
    task.wait(0.5)
    root.CFrame = originalCFrame
    task.wait(0.3)
    buyCount = buyCount + 1
    return true
end

local function throwTrash()
    local char = getChar()
    if not char then return false end
    local trashTool = nil
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("垃圾") then
            trashTool = v
            break
        end
    end
    if not trashTool then return false end

    local prompt = findTrashPromptReal()
    if not prompt then return false end

    local root = getRoot()
    if not root then return false end
    local part = prompt.Parent
    if not part then return false end

    local originalCFrame = root.CFrame
    teleportTo(part)
    task.wait(0.3)

    pcall(function()
        fireproximityprompt(prompt)
    end)
    task.wait(0.5)

    if trashTool.Parent == char then
        pcall(function()
            trashTool:Destroy()
        end)
    end

    root.CFrame = originalCFrame
    task.wait(0.3)
    trashCount = trashCount + 1
    return true
end

local function eatOnce()
    if isBusy then return end
    isBusy = true

    local char = getChar()
    local humanoid = getHumanoid()
    local backpack = getBackpack()
    if not char or not humanoid or not backpack then isBusy = false return end

    local food = backpack:FindFirstChild("盒饭") or char:FindFirstChild("盒饭")
    if not food then
        buyFood()
        task.wait(1)
        food = backpack:FindFirstChild("盒饭") or char:FindFirstChild("盒饭")
        if not food then
            isBusy = false
            return
        end
    end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        humanoid:UnequipTools()
        task.wait(0.3)
    end

    humanoid:EquipTool(food)
    task.wait(0.5)

    local VirtualUser = game:GetService("VirtualUser")
    local center = workspace.CurrentCamera.ViewportSize / 2
    for i = 1, 3 do
        if not food.Parent or food.Parent ~= char then break end
        VirtualUser:Button1Down(center, workspace.CurrentCamera.CFrame)
        task.wait(0.15)
        VirtualUser:Button1Up(center, workspace.CurrentCamera.CFrame)
        task.wait(0.8)
    end

    task.wait(0.5)

    if hasTrash() then
        throwTrash()
    end

    if currentTool and currentTool.Parent then
        humanoid:UnequipTools()
        task.wait(0.2)
        humanoid:EquipTool(currentTool)
        task.wait(0.3)
    end

    lastEatTime = tick()
    eatCount = eatCount + 1
    isBusy = false
end

local function refreshStatus()
    statusBind.Text = "状态: " .. (isBusy and "忙碌中" or "待机")
    statusDist.Text = "盒饭: " .. countFood() .. " 个"
    statusCount.Text = "挖矿: " .. triggerCount .. " 次"
    statusFood.Text = "吃饭: " .. (autoEat and "开" or "关") .. " | " .. eatCount .. " 次"
    statusBuy.Text = "买饭: " .. buyCount .. " 次 | 扔垃圾: " .. trashCount .. " 次"
end

task.spawn(function()
    while true do
        if showStatus then
            statusFrame.Visible = true
            refreshStatus()
        else
            statusFrame.Visible = false
        end
        task.wait(0.5)
    end
end)

local function triggerOnce()
    if not boundPrompt or isTriggering then return end
    isTriggering = true
    pcall(function()
        fireproximityprompt(boundPrompt)
    end)
    triggerCount = triggerCount + 1
    isTriggering = false
end

local function startMineLoop()
    if autoThread then return end
    autoThread = task.spawn(function()
        while autoMine do
            if not isBusy and boundPrompt then
                triggerOnce()
            end
            task.wait(0.2)
        end
    end)
end

local function startEatLoop()
    if eatThread then return end
    eatThread = task.spawn(function()
        while true do
            task.wait(1)
            if autoEat and not isBusy then
                if tick() - lastEatTime >= eatInterval then
                    if countFood() > 0 then
                        eatOnce()
                    elseif autoBuy then
                        buyFood()
                        task.wait(1)
                        if countFood() > 0 then
                            eatOnce()
                        end
                    end
                end
            end
        end
    end)
end

local function startCheckLoop()
    if checkThread then return end
    checkThread = task.spawn(function()
        while true do
            task.wait(3)
            if autoBuy and not isBusy then
                if countFood() < buyThreshold then
                    buyFood()
                end
            end
            if trashAfterEat and not isBusy then
                if hasTrash() then
                    throwTrash()
                end
            end
        end
    end)
end

MainTab:Button({
    Title = "绑定挖矿点",
    Desc = "站在挖矿点旁边，点这个",
    Callback = function()
        local prompt, dist = findNearestHoldPrompt()
        if not prompt then
            WindUI:Notify({Title = "绑定失败", Content = "附近没有长按互动", Duration = 3})
            return
        end
        boundPrompt = prompt
        WindUI:Notify({Title = "绑定成功", Content = "距离 " .. math.floor(dist) .. " 米", Duration = 3})
    end,
})

MainTab:Toggle({
    Title = "全自动挖矿",
    Desc = "循环触发绑定的挖矿点",
    Value = false,
    Callback = function(state)
        autoMine = state
        if state then startMineLoop() end
    end,
})

MainTab:Toggle({
    Title = "自动吃饭",
    Desc = "定时切盒饭点屏幕吃",
    Value = false,
    Callback = function(state)
        autoEat = state
        if state then
            lastEatTime = tick()
            startEatLoop()
        end
    end,
})

MainTab:Toggle({
    Title = "自动买盒饭",
    Desc = "盒饭少于阈值时自动传送去摊位买",
    Value = false,
    Callback = function(state)
        autoBuy = state
        if state then startCheckLoop() end
    end,
})

MainTab:Toggle({
    Title = "自动扔垃圾",
    Desc = "检测到垃圾袋自动传送去垃圾桶扔",
    Value = false,
    Callback = function(state)
        trashAfterEat = state
        if state then startCheckLoop() end
    end,
})

MainTab:Toggle({
    Title = "快速互动",
    Desc = "把长按变瞬发",
    Value = false,
    Callback = function(state)
        quickMode = state
        if state then
            if quickConn then quickConn:Disconnect() end
            quickConn = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
                prompt.HoldDuration = 0
            end)
        else
            if quickConn then quickConn:Disconnect() quickConn = nil end
        end
    end,
})

MainTab:Button({
    Title = "立即吃一次",
    Desc = "马上切盒饭点屏幕吃",
    Callback = function()
        eatOnce()
    end,
})

MainTab:Button({
    Title = "立即买一次",
    Desc = "传送去摊位买一个盒饭",
    Callback = function()
        buyFood()
    end,
})

MainTab:Button({
    Title = "立即扔一次",
    Desc = "传送去垃圾桶扔垃圾袋",
    Callback = function()
        throwTrash()
    end,
})

SettingsTab:Toggle({
    Title = "防AFK",
    Desc = "防止挂机被踢",
    Value = false,
    Callback = function(state)
        if state then startAntiAFK() else stopAntiAFK() end
    end,
})

SettingsTab:Toggle({
    Title = "显示状态框",
    Value = true,
    Callback = function(state) showStatus = state end,
})

SettingsTab:Slider({
    Title = "吃饭间隔",
    Desc = "每多少秒吃一次",
    Value = { Min = 10, Max = 36000, Default = 60, Decimals = 1 },
    Callback = function(v) eatInterval = v end,
})

SettingsTab:Slider({
    Title = "盒饭阈值",
    Desc = "少于多少个盒饭自动补",
    Value = { Min = 1, Max = 20, Default = 3, Decimals = 0 },
    Callback = function(v) buyThreshold = v end,
})

SettingsTab:Button({
    Title = "重置计数",
    Callback = function()
        triggerCount = 0
        eatCount = 0
        buyCount = 0
        trashCount = 0
    end,
})