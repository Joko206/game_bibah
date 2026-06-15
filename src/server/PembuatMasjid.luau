local Workspace = game:GetService("Workspace")

local PembuatMasjid = {}

-- ==========================================
-- PROCEDURAL MOSQUE LOBBY (Membuat Masjid)
-- ==========================================
function PembuatMasjid.bangunMasjidLobby()
    local lobbyLama = Workspace:FindFirstChild("LobbyMosque")
    if lobbyLama then
        lobbyLama:Destroy()
    end

    local modelLobby = Instance.new("Model")
    modelLobby.Name = "LobbyMosque"
    modelLobby.Parent = Workspace
    
    -- Hapus Baseplate Bawaan
    local baseplateLama = Workspace:FindFirstChild("Baseplate")
    if baseplateLama then baseplateLama:Destroy() end

    -- Plaza Utama (Lobby Floor)
    local alunAlun = Instance.new("Part")
    alunAlun.Name = "Plaza"
    alunAlun.Size = Vector3.new(200, 2, 200)
    alunAlun.Position = Vector3.new(0, -1, 0)
    alunAlun.Anchored = true
    alunAlun.Material = Enum.Material.Marble
    alunAlun.Color = Color3.fromRGB(122, 122, 114)
    alunAlun.Parent = modelLobby
    
    -- SpawnLocation
    local lokasiLahir = Instance.new("SpawnLocation")
    lokasiLahir.Size = Vector3.new(10, 1, 10)
    lokasiLahir.Position = Vector3.new(0, 0.5, -40)
    lokasiLahir.Anchored = true
    lokasiLahir.Material = Enum.Material.SmoothPlastic
    lokasiLahir.Color = Color3.fromRGB(96, 118, 100)
    lokasiLahir.Parent = modelLobby

    -- Bangunan Utama Masjid
    local bangunanUtama = Instance.new("Part")
    bangunanUtama.Name = "MainBuilding"
    bangunanUtama.Size = Vector3.new(60, 30, 40)
    bangunanUtama.Position = Vector3.new(0, 15, 0)
    bangunanUtama.Anchored = true
    bangunanUtama.Material = Enum.Material.SmoothPlastic
    bangunanUtama.Color = Color3.fromRGB(164, 164, 152)
    bangunanUtama.Parent = modelLobby
    
    -- Kubah Utama (Dome)
    local kubah = Instance.new("Part")
    kubah.Name = "Dome"
    kubah.Shape = Enum.PartType.Ball
    kubah.Size = Vector3.new(35, 35, 35)
    kubah.Position = Vector3.new(0, 30 + 17.5 - 5, 0) -- ditenggelamkan sedikit
    kubah.Anchored = true
    kubah.Material = Enum.Material.SmoothPlastic
    kubah.BrickColor = BrickColor.new("Khaki")
    kubah.Parent = modelLobby
    
    -- Pintu Masuk Raksasa (Arch)
    local gerbang = Instance.new("Part")
    gerbang.Size = Vector3.new(15, 20, 2)
    gerbang.Position = Vector3.new(0, 10, -20)
    gerbang.Anchored = true
    gerbang.Material = Enum.Material.SmoothPlastic
    gerbang.BrickColor = BrickColor.new("Dark green")
    gerbang.Parent = modelLobby
    
    local lubangGerbang = Instance.new("Part")
    lubangGerbang.Size = Vector3.new(13, 19, 2.2)
    lubangGerbang.Position = Vector3.new(0, 9.5, -20)
    lubangGerbang.Anchored = true
    lubangGerbang.Material = Enum.Material.SmoothPlastic
    lubangGerbang.BrickColor = BrickColor.new("Black")
    lubangGerbang.Parent = modelLobby

    -- Menara (Minarets)
    for _, xPos in ipairs({-35, 35}) do
        local menara = Instance.new("Part")
        menara.Shape = Enum.PartType.Cylinder
        menara.Size = Vector3.new(60, 8, 8) -- X=height di Roblox Cylinder
        menara.CFrame = CFrame.new(Vector3.new(xPos, 30, -15)) * CFrame.Angles(0, 0, math.pi/2)
        menara.Anchored = true
        menara.Material = Enum.Material.SmoothPlastic
        menara.Color = Color3.fromRGB(150, 150, 140)
        menara.Parent = modelLobby
        
        -- Kubah Kecil Menara
        local kubahKecil = Instance.new("Part")
        kubahKecil.Shape = Enum.PartType.Ball
        kubahKecil.Size = Vector3.new(10, 10, 10)
        kubahKecil.Position = Vector3.new(xPos, 60 + 5 - 2, -15)
        kubahKecil.Anchored = true
        kubahKecil.Material = Enum.Material.SmoothPlastic
        kubahKecil.BrickColor = BrickColor.new("Khaki")
        kubahKecil.Parent = modelLobby
    end
    
    -- Cahaya Masjid
    local cahayaLobby = Instance.new("PointLight")
    cahayaLobby.Range = 100
    cahayaLobby.Brightness = 1
    cahayaLobby.Color = Color3.fromRGB(187, 166, 126)
    cahayaLobby.Parent = bangunanUtama
end

return PembuatMasjid
