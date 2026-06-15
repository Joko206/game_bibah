local TweenService = game:GetService("TweenService")
local BantuanUI = {}

BantuanUI.WARNA = {
    backgroundTop = Color3.fromRGB(16, 22, 20),
    backgroundBottom = Color3.fromRGB(8, 12, 10),
    panelTop = Color3.fromRGB(20, 34, 30),
    panelBottom = Color3.fromRGB(12, 22, 19),
    accentSoft = Color3.fromRGB(112, 152, 120),
    accentGold = Color3.fromRGB(186, 160, 96),
    accentRed = Color3.fromRGB(130, 74, 70),
    textMain = Color3.fromRGB(224, 228, 220),
    textMuted = Color3.fromRGB(162, 170, 158),
}

function BantuanUI.terapkanGradasi(induk, warna1, warna2, rotasi)
    local gradasi = Instance.new("UIGradient")
    gradasi.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, warna1),
        ColorSequenceKeypoint.new(1, warna2),
    })
    gradasi.Rotation = rotasi or 90
    gradasi.Parent = induk
end

function BantuanUI.bulatkanSudut(induk, radius)
    local sudut = Instance.new("UICorner")
    sudut.CornerRadius = UDim.new(0, radius)
    sudut.Parent = induk
end

function BantuanUI.garisTepi(induk, warna, ketebalan)
    local garis = Instance.new("UIStroke")
    garis.Color = warna
    garis.Thickness = ketebalan
    garis.Transparency = 0.2
    garis.Parent = induk
end

function BantuanUI.munculPerlahan(objek)
    objek.BackgroundTransparency = 1
    TweenService:Create(objek, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    }):Play()
end

function BantuanUI.buatPanel(nama, ukuran, posisi, terlihat, indukGui)
    local panel = Instance.new("Frame")
    panel.Name = nama
    panel.Size = ukuran
    panel.Position = posisi
    panel.BackgroundColor3 = BantuanUI.WARNA.panelTop
    panel.Visible = terlihat
    panel.Parent = indukGui

    BantuanUI.terapkanGradasi(panel, BantuanUI.WARNA.panelTop, BantuanUI.WARNA.panelBottom, 60)
    BantuanUI.bulatkanSudut(panel, 16)
    BantuanUI.garisTepi(panel, BantuanUI.WARNA.accentSoft, 2)
    BantuanUI.munculPerlahan(panel)
    return panel
end

function BantuanUI.buatTeks(induk, teks, ukuran, posisi, font, warna, diskala, perataan)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = ukuran
    label.Position = posisi
    label.Text = teks
    label.TextColor3 = warna or BantuanUI.WARNA.textMain
    label.Font = font or Enum.Font.GothamSemibold
    label.TextScaled = diskala == nil and true or diskala
    label.TextWrapped = true
    label.TextXAlignment = perataan or Enum.TextXAlignment.Center
    label.Parent = induk
    return label
end

function BantuanUI.gayaTombol(tombol, warnaAtas, warnaBawah)
    tombol.AutoButtonColor = false
    tombol.BackgroundColor3 = warnaAtas
    tombol.Text = ""
    BantuanUI.terapkanGradasi(tombol, warnaAtas, warnaBawah, 45)
    BantuanUI.bulatkanSudut(tombol, 12)
    BantuanUI.garisTepi(tombol, BantuanUI.WARNA.accentSoft, 1)

    local teksTombol = Instance.new("TextLabel")
    teksTombol.Name = "TeksTombol"
    teksTombol.BackgroundTransparency = 1
    teksTombol.Size = UDim2.fromScale(1, 1)
    teksTombol.Position = UDim2.fromScale(0, 0)
    teksTombol.TextColor3 = BantuanUI.WARNA.textMain
    teksTombol.Font = Enum.Font.GothamSemibold
    teksTombol.TextScaled = true
    teksTombol.TextWrapped = true
    teksTombol.Parent = tombol

    local ukuranAsli = tombol.Size
    tombol.MouseEnter:Connect(function()
        TweenService:Create(tombol, TweenInfo.new(0.12), {
            Size = UDim2.new(ukuranAsli.X.Scale * 1.02, ukuranAsli.X.Offset, ukuranAsli.Y.Scale * 1.02, ukuranAsli.Y.Offset),
        }):Play()
    end)
    tombol.MouseLeave:Connect(function()
        TweenService:Create(tombol, TweenInfo.new(0.12), {Size = ukuranAsli}):Play()
    end)
    return teksTombol
end

return BantuanUI
