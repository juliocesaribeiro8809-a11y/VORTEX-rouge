--[[
    VORTEX RØUGE | DELTA ANDROID
    BUILD 3.0 - MODERN RED EDITION
    Interface local em LuaU.
    Funcionalidades: abrir/fechar/minimizar, arrastar, expandir,
    navegar, pesquisar/selecionar jogadores e spectate pela camera local.
    Spectate acompanha somente o avatar visivel no jogo; nao mostra a tela
    real do dispositivo de outro jogador.
    Nao inclui cheats, bypass ou alteracoes no Brookhaven.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "VortexRougeDelta"
local oldGui

local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return CoreGui
end

local guiParent = getGuiParent()
pcall(function()
    oldGui = guiParent:FindFirstChild(GUI_NAME)
    if oldGui then oldGui:Destroy() end
end)

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local Theme = {
    Background = Color3.fromRGB(9, 10, 14),
    Surface = Color3.fromRGB(17, 19, 25),
    Surface2 = Color3.fromRGB(25, 27, 35),
    Surface3 = Color3.fromRGB(34, 30, 39),
    Red = Color3.fromRGB(235, 35, 68),
    RedDark = Color3.fromRGB(125, 15, 42),
    Text = Color3.fromRGB(247, 247, 250),
    Muted = Color3.fromRGB(155, 158, 170),
    Green = Color3.fromRGB(75, 210, 140),
}

local gui = create("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = false,
}, guiParent)

local function corner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, colorA, colorB, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(colorA, colorB),
        Rotation = rotation or 0,
    }, parent)
end

local function addPadding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, parent)
end

local launcher = create("TextButton", {
    Name = "VortexLauncher",
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.new(0, 16, 0.46, 0),
    BackgroundColor3 = Theme.Red,
    Text = "V",
    TextColor3 = Theme.Text,
    TextSize = 27,
    Font = Enum.Font.GothamBlack,
    AutoButtonColor = true,
    ZIndex = 30,
}, gui)
corner(launcher, 18)
stroke(launcher, Color3.fromRGB(255, 125, 145), 1.4, 0.15)
gradient(launcher, Theme.Red, Theme.RedDark, 45)

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
local compactWidth = math.clamp(viewport.X - 28, 300, 390)
local expandedWidth = math.clamp(viewport.X - 28, 390, 570)
local windowWidth = compactWidth
local windowHeight = math.clamp(viewport.Y - 90, 390, 520)

local window = create("Frame", {
    Name = "MainWindow",
    Size = UDim2.fromOffset(windowWidth, windowHeight),
    Position = UDim2.new(0.5, -windowWidth / 2, 0.5, -windowHeight / 2),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
}, gui)
corner(window, 16)
stroke(window, Theme.Red, 1.5, 0.08)

local topbar = create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
}, window)
corner(topbar, 16)
gradient(topbar, Color3.fromRGB(39, 19, 30), Theme.Surface, 0)

local accent = create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = Theme.Red,
    BorderSizePixel = 0,
}, topbar)

create("TextLabel", {
    Size = UDim2.new(1, -166, 0, 25),
    Position = UDim2.fromOffset(16, 8),
    BackgroundTransparency = 1,
    Text = "VORTEX RØUGE",
    TextColor3 = Theme.Text,
    TextSize = 17,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
}, topbar)

create("TextLabel", {
    Size = UDim2.new(1, -166, 0, 17),
    Position = UDim2.fromOffset(17, 31),
    BackgroundTransparency = 1,
    Text = "DELTA ANDROID  •  BUILD 3.0",
    TextColor3 = Theme.Muted,
    TextSize = 9,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, topbar)

local function headerButton(text, xOffset, color, width)
    local button = create("TextButton", {
        Size = UDim2.fromOffset(width or 31, 31),
        Position = UDim2.new(1, xOffset, 0, 13),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true,
    }, topbar)
    corner(button, 9)
    return button
end

local expandButton = headerButton("↔", -111, Theme.Surface3, 31)
local minimizeButton = headerButton("—", -73, Theme.Surface3, 31)
local closeButton = headerButton("×", -35, Theme.Red, 29)

local sidebar = create("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 112, 1, -72),
    Position = UDim2.fromOffset(9, 65),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
}, window)
corner(sidebar, 12)
addPadding(sidebar, 7, 7, 8, 8)
local sideLayout = create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local content = create("ScrollingFrame", {
    Name = "PageContent",
    Size = UDim2.new(1, -133, 1, -72),
    Position = UDim2.fromOffset(122, 65),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Red,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, window)
corner(content, 12)
addPadding(content, 11, 11, 11, 12)
local contentLayout = create("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local pages = {"INÍCIO", "JOGADORES", "DESEMPENHO", "FERRAMENTAS", "SOBRE"}
local activePage = "INÍCIO"
local selectedPlayer = nil
local isExpanded = false
local isSpectating = false
local renderPage

local function makeLabel(parent, text, height, size, color, bold)
    return create("TextLabel", {
        Size = UDim2.new(1, 0, 0, height or 28),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Theme.Text,
        TextSize = size or 12,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function makeCard(title, description, height)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 82),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
    }, content)
    corner(card, 11)
    create("Frame", {
        Size = UDim2.new(0, 3, 1, -22),
        Position = UDim2.fromOffset(0, 11),
        BackgroundColor3 = Theme.Red,
        BorderSizePixel = 0,
    }, card)
    create("TextLabel", {
        Size = UDim2.new(1, -22, 0, 24),
        Position = UDim2.fromOffset(12, 9),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    create("TextLabel", {
        Size = UDim2.new(1, -22, 0, height and height - 38 or 42),
        Position = UDim2.fromOffset(12, 34),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Theme.Muted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, card)
    return card
end

local function makeAction(text, parent, callback, color)
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 39),
        BackgroundColor3 = color or Theme.RedDark,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true,
    }, parent or content)
    corner(button, 9)
    button.Activated:Connect(callback)
    return button
end

local function section(text)
    local bar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 31),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    }, content)
    corner(bar, 8)
    makeLabel(bar, "  " .. text, 31, 10, Theme.Text, true)
end

local function stopSpectating()
    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then camera.CameraSubject = humanoid end
    end
    isSpectating = false
end

local function startSpectating(player)
    if not player or player == LocalPlayer or player.Parent ~= Players then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        makeCard("AVISO", "Esse jogador ainda não possui um personagem carregado.", 65)
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    isSpectating = true
end

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    content.CanvasPosition = Vector2.new(0, 0)
end

local function renderPlayers()
    section("JOGADORES DA SESSÃO")
    makeLabel(content, "Selecione um jogador para ver os dados públicos.", 28, 10, Theme.Muted)

    local searchBox = create("TextBox", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface2,
        Text = "",
        PlaceholderText = "  Pesquisar jogador...",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
    }, content)
    corner(searchBox, 9)

    local selectedCard = makeCard("JOGADOR SELECIONADO",
        selectedPlayer and (selectedPlayer.DisplayName .. "  @" .. selectedPlayer.Name ..
        "\nUserId: " .. tostring(selectedPlayer.UserId)) or "Nenhum jogador selecionado.", 76)

    local spectateButton
    spectateButton = makeAction("SPECTATE PLAYER  ▶", content, function()
        if selectedPlayer then
            startSpectating(selectedPlayer)
            if isSpectating then
                spectateButton.Text = "OBSERVANDO: " .. selectedPlayer.DisplayName
            end
        end
    end, Theme.RedDark)

    local returnButton = makeAction("VOLTAR À MINHA CÂMERA", content, function()
        stopSpectating()
        spectateButton.Text = "SPECTATE PLAYER  ▶"
    end, Theme.Surface3)

    local listHolder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, content)
    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.Name,
    }, listHolder)

    local function refreshList()
        for _, child in ipairs(listHolder:GetChildren()) do
            if child ~= listLayout then child:Destroy() end
        end
        local query = string.lower(searchBox.Text or "")
        local playerList = Players:GetPlayers()
        table.sort(playerList, function(a, b)
            return string.lower(a.DisplayName) < string.lower(b.DisplayName)
        end)
        for _, player in ipairs(playerList) do
            if player ~= LocalPlayer then
                local haystack = string.lower(player.DisplayName .. " " .. player.Name)
                if query == "" or string.find(haystack, query, 1, true) then
                    local item = create("TextButton", {
                        Name = player.Name,
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundColor3 = selectedPlayer == player and Theme.RedDark or Theme.Surface2,
                        Text = player.DisplayName .. "   @" .. player.Name,
                        TextColor3 = Theme.Text,
                        TextSize = 10,
                        Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = true,
                    }, listHolder)
                    corner(item, 8)
                    addPadding(item, 10, 6, 0, 0)
                    item.Activated:Connect(function()
                        selectedPlayer = player
                        renderPage("JOGADORES")
                    end)
                end
            end
        end
        if #playerList <= 1 then
            makeLabel(listHolder, "Não há outros jogadores nesta sessão.", 30, 10, Theme.Muted)
        end
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
    refreshList()
end

renderPage = function(page)
    activePage = page
    clearContent()

    if page == "INÍCIO" then
        section("PAINEL PRINCIPAL")
        makeLabel(content, "Bem-vindo de volta.", 34, 17, Theme.Text, true)
        makeCard("VORTEX RØUGE  /  3.0", "Interface redesenhada com visual moderno vermelho e preto, adaptada para telas móveis.", 82)
        makeCard("ATALHOS", "Abra JOGADORES para selecionar alguém e usar o modo Spectate Player.", 75)
        makeCard("CONTROLES", "Arraste pela barra superior • ↔ expande • — minimiza • × fecha.", 75)
    elseif page == "JOGADORES" then
        renderPlayers()
    elseif page == "DESEMPENHO" then
        section("STATUS DA SESSÃO")
        makeCard("JOGADORES CONECTADOS", tostring(#Players:GetPlayers()) .. " jogador(es) nesta sessão.", 65)
        makeCard("INTERFACE", "Rolagem e navegação ativas. O painel não altera as configurações internas do jogo.", 72)
        makeAction("ATUALIZAR STATUS", content, function()
            renderPage("DESEMPENHO")
        end, Theme.Surface3)
    elseif page == "FERRAMENTAS" then
        section("FERRAMENTAS LOCAIS")
        makeCard("CÂMERA", "O modo Spectate Player acompanha o avatar selecionado usando a câmera local.", 75)
        makeAction("VOLTAR À MINHA CÂMERA", content, stopSpectating, Theme.RedDark)
        makeCard("LIMITES", "Não mostra a tela real do celular/computador de outra pessoa e não inclui cheats ou bypass.", 83)
    elseif page == "SOBRE" then
        section("SOBRE O PROJETO")
        makeCard("VORTEX RØUGE", "Build 3.0 • LuaU • Delta Android", 65)
        makeCard("COMPATIBILIDADE", "Feito para clientes Roblox que permitem executar interfaces locais. A compatibilidade deve ser confirmada no seu Delta.", 82)
        makeCard("PRIVACIDADE", "A lista exibe somente nome, DisplayName e UserId públicos do jogador.", 75)
    end
end

local tabButtons = {}
for index, page in ipairs(pages) do
    local tab = create("TextButton", {
        Name = "Tab_" .. page,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = page == activePage and Theme.RedDark or Theme.Surface2,
        Text = page,
        TextColor3 = Theme.Text,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true,
        LayoutOrder = index,
    }, sidebar)
    corner(tab, 8)
    tabButtons[page] = tab
    tab.Activated:Connect(function()
        for name, button in pairs(tabButtons) do
            button.BackgroundColor3 = name == page and Theme.RedDark or Theme.Surface2
        end
        renderPage(page)
    end)
end

local function applyWidth()
    local width = isExpanded and expandedWidth or compactWidth
    windowWidth = width
    window.Size = UDim2.fromOffset(width, windowHeight)
    local maxX = math.max(8, viewport.X - width - 8)
    local x = math.clamp(window.Position.X.Offset, 8, maxX)
    window.Position = UDim2.new(0, x, window.Position.Y.Scale, window.Position.Y.Offset)
    content.Size = UDim2.new(1, -133, 1, -72)
    content.Position = UDim2.fromOffset(122, 65)
end

expandButton.Activated:Connect(function()
    isExpanded = not isExpanded
    applyWidth()
end)

minimizeButton.Activated:Connect(function()
    window.Visible = false
end)

closeButton.Activated:Connect(function()
    stopSpectating()
    window.Visible = false
end)

launcher.Activated:Connect(function()
    window.Visible = not window.Visible
end)

-- Arrastar pela barra superior, sem iniciar o arrasto sobre os botões.
local dragging = false
local dragInput, dragStart, startPosition

topbar.InputBegan:Connect(function(input)
    local isPointer = input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1
    if not isPointer then return end
    local mouseX = input.Position.X
    local rightEdge = topbar.AbsolutePosition.X + topbar.AbsoluteSize.X
    if mouseX > rightEdge - 120 then return end
    dragging = true
    dragStart = input.Position
    startPosition = window.Position
    dragInput = input
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        local newX = startPosition.X.Offset + delta.X
        local newY = startPosition.Y.Offset + delta.Y
        local screen = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or viewport
        newX = math.clamp(newX, 4, math.max(4, screen.X - window.AbsoluteSize.X - 4))
        newY = math.clamp(newY, 4, math.max(4, screen.Y - window.AbsoluteSize.Y - 4))
        window.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragInput = nil
    end
end)

Players.PlayerAdded:Connect(function()
    if activePage == "JOGADORES" then task.defer(renderPage, "JOGADORES") end
end)

Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        if isSpectating then stopSpectating() end
        selectedPlayer = nil
    end
    if activePage == "JOGADORES" then task.defer(renderPage, "JOGADORES") end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if not isSpectating then
        task.wait(0.25)
        local camera = workspace.CurrentCamera
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if camera and humanoid then
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
        end
    end
end)

renderPage("INÍCIO")
print("[VORTEX RØUGE] Build 3.0 carregada.")
