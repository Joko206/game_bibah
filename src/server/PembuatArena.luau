local Workspace = game:GetService("Workspace")

local PembuatArena = {}

-- ==========================================
-- 3D MAP GENERATOR (Membuat Arena & Pintu)
-- ==========================================
function PembuatArena.buatArena(idRuangan)
    local posisiAwal = Vector3.new(0, 50, idRuangan * 500)
    
    local modelArena = Instance.new("Model")
    modelArena.Name = "Arena_" .. idRuangan
    modelArena.Parent = Workspace
    
    -- Pencahayaan
    local cahayaSekitar = Instance.new("PointLight")
    cahayaSekitar.Range = 60
    cahayaSekitar.Brightness = 1.2
    cahayaSekitar.Color = Color3.fromRGB(142, 162, 128)
    
    -- Particle Effect (Debu Kosmik)
    local debu = Instance.new("ParticleEmitter")
    debu.Color = ColorSequence.new(Color3.fromRGB(255, 230, 150))
    debu.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.4), NumberSequenceKeypoint.new(1, 0)})
    debu.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.5), NumberSequenceKeypoint.new(1, 1)})
    debu.Lifetime = NumberRange.new(2, 5)
    debu.Rate = 50
    debu.Speed = NumberRange.new(1, 3)
    debu.SpreadAngle = Vector2.new(180, 180)
    
    -- Spectator Platform (Ruang Tunggu)
    local panggungPenonton = Instance.new("Part")
    panggungPenonton.Name = "PanggungPenonton"
    panggungPenonton.Size = Vector3.new(40, 2, 20)
    panggungPenonton.Position = posisiAwal + Vector3.new(0, 0, -50)
    panggungPenonton.Anchored = true
    panggungPenonton.Material = Enum.Material.Glass
    panggungPenonton.BrickColor = BrickColor.new("Navy blue")
    panggungPenonton.Parent = modelArena
    
    local d1 = debu:Clone()
    d1.Parent = panggungPenonton
    
    local cahayaPenonton = Instance.new("Part")
    cahayaPenonton.Size = Vector3.new(42, 1, 22)
    cahayaPenonton.Position = panggungPenonton.Position - Vector3.new(0, 0.5, 0)
    cahayaPenonton.Anchored = true
    cahayaPenonton.Material = Enum.Material.SmoothPlastic
    cahayaPenonton.BrickColor = BrickColor.new("Olive")
    cahayaPenonton.Parent = modelArena
    
    local l1 = cahayaSekitar:Clone()
    l1.Parent = panggungPenonton

    -- Tembok Pelindung Spectator
    local function buatTembok(ukuran, posisi)
        local t = Instance.new("Part")
        t.Size = ukuran
        t.Position = posisi
        t.Anchored = true
        t.Material = Enum.Material.Glass
        t.Color = Color3.fromRGB(70, 92, 83)
        t.Transparency = 0.35
        t.Parent = modelArena
    end
    
    local tinggiTembok = 15
    buatTembok(Vector3.new(1, tinggiTembok, 20), panggungPenonton.Position + Vector3.new(-20, tinggiTembok/2, 0)) -- Kiri
    buatTembok(Vector3.new(1, tinggiTembok, 20), panggungPenonton.Position + Vector3.new(20, tinggiTembok/2, 0))  -- Kanan
    buatTembok(Vector3.new(40, tinggiTembok, 1), panggungPenonton.Position + Vector3.new(0, tinggiTembok/2, -10)) -- Belakang
    buatTembok(Vector3.new(40, tinggiTembok, 1), panggungPenonton.Position + Vector3.new(0, tinggiTembok/2, 10))  -- Depan

    -- Start Platform (Arena Utama)
    local panggungMulai = Instance.new("Part")
    panggungMulai.Name = "PanggungMulai"
    panggungMulai.Size = Vector3.new(40, 2, 20)
    panggungMulai.Position = posisiAwal + Vector3.new(0, 0, 0)
    panggungMulai.Anchored = true
    panggungMulai.Material = Enum.Material.SmoothPlastic
    panggungMulai.BrickColor = BrickColor.new("Dark stone grey")
    panggungMulai.Parent = modelArena
    
    local d2 = debu:Clone()
    d2.Parent = panggungMulai
    
    local cahayaMulai = Instance.new("Part")
    cahayaMulai.Size = Vector3.new(42, 1, 22)
    cahayaMulai.Position = panggungMulai.Position - Vector3.new(0, 0.5, 0)
    cahayaMulai.Anchored = true
    cahayaMulai.Material = Enum.Material.SmoothPlastic
    cahayaMulai.BrickColor = BrickColor.new("Brown")
    cahayaMulai.Parent = modelArena
    
    local l2 = cahayaSekitar:Clone()
    l2.Brightness = 0.9
    l2.Color = Color3.fromRGB(168, 142, 88)
    l2.Parent = panggungMulai
    
    -- SUCCESS PLATFORM (Zona Aman di Belakang Pintu)
    local panggungBerhasil = Instance.new("Part")
    panggungBerhasil.Name = "PanggungBerhasil"
    panggungBerhasil.Size = Vector3.new(40, 2, 20)
    panggungBerhasil.Position = posisiAwal + Vector3.new(0, 0, 21)
    panggungBerhasil.Anchored = true
    panggungBerhasil.Material = Enum.Material.SmoothPlastic
    panggungBerhasil.BrickColor = BrickColor.new("Dark stone grey")
    panggungBerhasil.Parent = modelArena
    
    local cahayaBerhasil = Instance.new("Part")
    cahayaBerhasil.Size = Vector3.new(42, 1, 22)
    cahayaBerhasil.Position = panggungBerhasil.Position - Vector3.new(0, 0.5, 0)
    cahayaBerhasil.Anchored = true
    cahayaBerhasil.Material = Enum.Material.SmoothPlastic
    cahayaBerhasil.BrickColor = BrickColor.new("Sea green")
    cahayaBerhasil.Parent = modelArena
    
    local l3 = cahayaSekitar:Clone()
    l3.Brightness = 1
    l3.Color = Color3.fromRGB(132, 184, 132)
    l3.Parent = panggungBerhasil

    -- Void pit di bawah arena untuk reset pemain yang jatuh
    local jurangMaut = Instance.new("Part")
    jurangMaut.Name = "JurangMaut"
    jurangMaut.Size = Vector3.new(300, 10, 300)
    jurangMaut.Position = posisiAwal + Vector3.new(0, -150, 0)
    jurangMaut.Anchored = true
    jurangMaut.Material = Enum.Material.Slate
    jurangMaut.Color = Color3.fromRGB(50, 36, 34)
    jurangMaut.Parent = modelArena
    
    local api = Instance.new("ParticleEmitter")
    api.Color = ColorSequence.new(Color3.fromRGB(148, 80, 52), Color3.fromRGB(102, 56, 40))
    api.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 7)})
    api.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1)})
    api.Lifetime = NumberRange.new(2, 3)
    api.Rate = 120
    api.Speed = NumberRange.new(8, 14)
    api.EmissionDirection = Enum.NormalId.Top
    api.Parent = jurangMaut
    
    -- Mengeliminasi pemain yang jatuh dari arena
    jurangMaut.Touched:Connect(function(hit)
        local h = hit.Parent:FindFirstChild("Humanoid")
        if h then h.Health = 0 end
    end)

    -- Pilar Cahaya Bergaya Sci-Fi
    for _, xPos in ipairs({-19, 19}) do
        local pilar = Instance.new("Part")
        pilar.Shape = Enum.PartType.Cylinder
        pilar.Size = Vector3.new(20, 3, 3) -- Orientation Cylinder di Roblox membentang di sumbu X
        pilar.CFrame = CFrame.new(panggungMulai.Position + Vector3.new(xPos, 10, 8)) * CFrame.Angles(0, 0, math.pi/2)
        pilar.Anchored = true
        pilar.Material = Enum.Material.SmoothPlastic
        pilar.BrickColor = BrickColor.new("Dark green")
        pilar.Parent = modelArena
        
        -- Cincin Emas melayang di pilar
        local cincin = Instance.new("Part")
        cincin.Shape = Enum.PartType.Cylinder
        cincin.Size = Vector3.new(2, 3.5, 3.5)
        cincin.CFrame = CFrame.new(panggungMulai.Position + Vector3.new(xPos, 15, 8)) * CFrame.Angles(0, 0, math.pi/2)
        cincin.Anchored = true
        cincin.Material = Enum.Material.SmoothPlastic
        cincin.BrickColor = BrickColor.new("Khaki")
        cincin.Parent = modelArena
    end

    -- Papan Soal Raksasa
    local papanSoal = Instance.new("Part")
    papanSoal.Name = "PapanSoal"
    papanSoal.Size = Vector3.new(34, 18, 2)
    papanSoal.Position = posisiAwal + Vector3.new(0, 26, 22) -- Diangkat tinggi ke Y=26 agar tidak terhalang pintu
    papanSoal.Anchored = true
    papanSoal.Material = Enum.Material.SmoothPlastic
    papanSoal.BrickColor = BrickColor.new("Dark green")
    papanSoal.Parent = modelArena
    
    local layarSoal = Instance.new("Part")
    layarSoal.Size = Vector3.new(32, 16, 2.2)
    layarSoal.Position = papanSoal.Position
    layarSoal.Anchored = true
    layarSoal.Material = Enum.Material.SmoothPlastic
    layarSoal.BrickColor = BrickColor.new("Really black")
    layarSoal.Parent = modelArena
    
    local guiSoal = Instance.new("SurfaceGui")
    guiSoal.Face = Enum.NormalId.Front
    guiSoal.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    guiSoal.CanvasSize = Vector2.new(1600, 800)
    guiSoal.Parent = layarSoal
    
    local teksSoal = Instance.new("TextLabel")
    teksSoal.Name = "Text"
    teksSoal.Size = UDim2.new(0.9, 0, 0.9, 0)
    teksSoal.Position = UDim2.new(0.05, 0, 0.05, 0)
    teksSoal.BackgroundTransparency = 1
    teksSoal.TextScaled = true
    teksSoal.TextWrapped = true
    teksSoal.TextColor3 = Color3.fromRGB(255, 255, 255)
    teksSoal.Font = Enum.Font.GothamBold
    teksSoal.Text = "Menunggu Permainan Dimulai..."
    teksSoal.Parent = guiSoal
    
    local garisTepiSoal = Instance.new("UIStroke")
    garisTepiSoal.Color = Color3.fromRGB(160, 148, 96)
    garisTepiSoal.Thickness = 3
    garisTepiSoal.Parent = teksSoal
    
    -- 3 Pintu Tegak (Berdiri)
    local daftarPintu = {}
    for i = 1, 3 do
        local pintu = Instance.new("Part")
        pintu.Name = "Pintu_" .. i
        pintu.Size = Vector3.new(10, 14, 1) -- Lebar 10, Tinggi 14, Tebal 1
        pintu.Position = posisiAwal + Vector3.new((i-2)*13, 7, 10.5) -- Rapat dengan batas depan panggungMulai (Z=10)
        pintu.Anchored = true
        pintu.Material = Enum.Material.SmoothPlastic
        pintu.BrickColor = BrickColor.new("Black")
        pintu.Parent = modelArena
        
        local cahayaPintu = Instance.new("Part")
        cahayaPintu.Name = "Glow"
        cahayaPintu.Size = Vector3.new(10.5, 14.5, 0.5)
        cahayaPintu.Position = pintu.Position + Vector3.new(0, 0, 0.5) -- Dipindah ke belakang pintu agar tidak menutupi teks di depan (-Z)
        cahayaPintu.Anchored = true
        cahayaPintu.Material = Enum.Material.SmoothPlastic
        cahayaPintu.BrickColor = BrickColor.new("Dark stone grey")
        cahayaPintu.Parent = pintu
        
        local guiPintu = Instance.new("SurfaceGui")
        guiPintu.Face = Enum.NormalId.Front
        guiPintu.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
        guiPintu.CanvasSize = Vector2.new(500, 700)
        guiPintu.Parent = pintu
        
        local teksPintu = Instance.new("TextLabel")
        teksPintu.Name = "Text"
        teksPintu.Size = UDim2.new(0.9, 0, 0.9, 0)
        teksPintu.Position = UDim2.new(0.05, 0, 0.05, 0)
        teksPintu.BackgroundTransparency = 1
        teksPintu.TextScaled = true
        teksPintu.TextWrapped = true
        teksPintu.TextColor3 = Color3.fromRGB(255, 255, 255) -- Teks putih
        teksPintu.Font = Enum.Font.GothamBold
        teksPintu.Text = "Opsi " .. i
        teksPintu.Parent = guiPintu
        
        local garisTepiPintu = Instance.new("UIStroke")
        garisTepiPintu.Color = Color3.fromRGB(150, 140, 95)
        garisTepiPintu.Thickness = 2
        garisTepiPintu.Parent = teksPintu
        
        table.insert(daftarPintu, pintu)
    end
    
    return {
        model = modelArena,
        posisiMulai = panggungMulai.Position + Vector3.new(0, 5, 0),
        posisiPenonton = panggungPenonton.Position + Vector3.new(0, 5, 0),
        teksSoal = teksSoal,
        pintuPintu = daftarPintu,
        panggungMulai = panggungMulai,
        cahayaMulai = cahayaMulai
    }
end

return PembuatArena
