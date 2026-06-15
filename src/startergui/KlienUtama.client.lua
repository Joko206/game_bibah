local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PemainLokal = Players.LocalPlayer

local Acara = ReplicatedStorage:WaitForChild("Events")
local AcaraBuatRuangan = Acara:WaitForChild("BuatRuangan")
local AcaraMasukRuangan = Acara:WaitForChild("MasukRuangan")
local AcaraKeluarRuangan = Acara:WaitForChild("KeluarRuangan")
local AcaraMulaiPermainan = Acara:WaitForChild("MulaiPermainan")
local AcaraMainLagi = Acara:WaitForChild("MainLagi")
local AcaraPerbaruiRuangan = Acara:WaitForChild("PerbaruiRuangan")
local AcaraStatusRuanganBerubah = Acara:WaitForChild("StatusRuanganBerubah")

local SkripPemain = PemainLokal:WaitForChild("PlayerScripts")
local BantuanUI = require(SkripPemain:WaitForChild("Client"):WaitForChild("BantuanUI"))

local WARNA = BantuanUI.WARNA

local GuiPemain = PemainLokal:WaitForChild("PlayerGui")
local guiSebelumnya = GuiPemain:FindFirstChild("GameSambungAyatUI")
if guiSebelumnya then
    guiSebelumnya:Destroy()
end

local GuiLayar = Instance.new("ScreenGui")
GuiLayar.Name = "GameSambungAyatUI"
GuiLayar.ResetOnSpawn = false
GuiLayar.Parent = GuiPemain

-- ==========================================
-- PEMBUATAN UI: BAR PESAN (DI ATAS LAYAR)
-- ==========================================
local BilahPesan = BantuanUI.buatPanel("BilahPesan", UDim2.new(0.5, 0, 0.06, 0), UDim2.new(0.25, 0, 0.03, 0), true, GuiLayar)
local TeksPesan = BantuanUI.buatTeks(BilahPesan, "Marhaban. Pilih ruangan untuk mulai.", UDim2.fromScale(0.95, 0.9), UDim2.fromScale(0.025, 0.05), Enum.Font.GothamMedium, WARNA.textMuted)

-- ==========================================
-- PEMBUATAN UI: PANEL LOBBY UTAMA
-- ==========================================
local BingkaiLobby = BantuanUI.buatPanel("BingkaiLobby", UDim2.new(0.64, 0, 0.72, 0), UDim2.new(0.18, 0, 0.16, 0), true, GuiLayar)
local JudulLobby = BantuanUI.buatTeks(BingkaiLobby, "SAMBUNG AYAT", UDim2.new(0.9, 0, 0.13, 0), UDim2.new(0.05, 0, 0.03, 0), Enum.Font.GothamBlack, WARNA.accentGold)
local SubJudulLobby = BantuanUI.buatTeks(BingkaiLobby, "Tema tenang islami - fokus, nyaman, dan khusyuk", UDim2.new(0.9, 0, 0.08, 0), UDim2.new(0.05, 0, 0.14, 0), Enum.Font.Gotham, WARNA.textMuted)

local TombolBuatRuangan = Instance.new("TextButton")
TombolBuatRuangan.Size = UDim2.new(0.4, 0, 0.11, 0)
TombolBuatRuangan.Position = UDim2.new(0.3, 0, 0.24, 0)
TombolBuatRuangan.Parent = BingkaiLobby
BantuanUI.gayaTombol(TombolBuatRuangan, Color3.fromRGB(44, 86, 68), Color3.fromRGB(29, 56, 45)).Text = "BUAT RUANGAN"

local BingkaiDaftarRuangan = Instance.new("ScrollingFrame")
BingkaiDaftarRuangan.Name = "DaftarRuangan"
BingkaiDaftarRuangan.Size = UDim2.new(0.9, 0, 0.52, 0)
BingkaiDaftarRuangan.Position = UDim2.new(0.05, 0, 0.41, 0)
BingkaiDaftarRuangan.CanvasSize = UDim2.fromOffset(0, 0)
BingkaiDaftarRuangan.ScrollBarThickness = 6
BingkaiDaftarRuangan.BackgroundColor3 = Color3.fromRGB(14, 20, 18)
BingkaiDaftarRuangan.BackgroundTransparency = 0.2
BingkaiDaftarRuangan.BorderSizePixel = 0
BantuanUI.bulatkanSudut(BingkaiDaftarRuangan, 12)
BantuanUI.garisTepi(BingkaiDaftarRuangan, WARNA.accentSoft, 1)
BingkaiDaftarRuangan.Parent = BingkaiLobby

local TataLetakDaftar = Instance.new("UIListLayout")
TataLetakDaftar.Padding = UDim.new(0, 10)
TataLetakDaftar.Parent = BingkaiDaftarRuangan

TataLetakDaftar:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    BingkaiDaftarRuangan.CanvasSize = UDim2.fromOffset(0, TataLetakDaftar.AbsoluteContentSize.Y + 10)
end)

-- ==========================================
-- PEMBUATAN UI: PANEL SOAL & HUD GAME
-- ==========================================
local TampilanPermainan = BantuanUI.buatPanel("TampilanPermainan", UDim2.new(0.86, 0, 0.24, 0), UDim2.new(0.07, 0, 0.03, 0), false, GuiLayar)
local TeksAyat = BantuanUI.buatTeks(TampilanPermainan, "Menunggu ronde dimulai...", UDim2.new(0.95, 0, 0.5, 0), UDim2.new(0.025, 0, 0.08, 0), Enum.Font.GothamBold, WARNA.accentGold)
local TeksDaftarPemain = BantuanUI.buatTeks(TampilanPermainan, "", UDim2.new(0.95, 0, 0.22, 0), UDim2.new(0.025, 0, 0.56, 0), Enum.Font.Gotham, WARNA.textMain, true, Enum.TextXAlignment.Left)

local TombolMulaiGame = Instance.new("TextButton")
TombolMulaiGame.Size = UDim2.new(0.26, 0, 0.25, 0)
TombolMulaiGame.Position = UDim2.new(0.37, 0, 0.72, 0)
TombolMulaiGame.Parent = TampilanPermainan
BantuanUI.gayaTombol(TombolMulaiGame, Color3.fromRGB(86, 75, 40), Color3.fromRGB(56, 48, 24)).Text = "MULAI PERMAINAN"

-- ==========================================
-- PEMBUATAN UI: PANEL HASIL AKHIR (GAME OVER)
-- ==========================================
local BingkaiAkhir = BantuanUI.buatPanel("BingkaiAkhir", UDim2.new(0.58, 0, 0.56, 0), UDim2.new(0.21, 0, 0.22, 0), false, GuiLayar)
local JudulAkhir = BantuanUI.buatTeks(BingkaiAkhir, "PERMAINAN SELESAI", UDim2.new(0.9, 0, 0.22, 0), UDim2.new(0.05, 0, 0.08, 0), Enum.Font.GothamBlack, WARNA.accentGold)
local TeksPemenang = BantuanUI.buatTeks(BingkaiAkhir, "Pemenang: -", UDim2.new(0.9, 0, 0.14, 0), UDim2.new(0.05, 0, 0.36, 0), Enum.Font.GothamSemibold, WARNA.textMain)

local TombolMainLagi = Instance.new("TextButton")
TombolMainLagi.Size = UDim2.new(0.42, 0, 0.17, 0)
TombolMainLagi.Position = UDim2.new(0.29, 0, 0.58, 0)
TombolMainLagi.Parent = BingkaiAkhir
BantuanUI.gayaTombol(TombolMainLagi, Color3.fromRGB(44, 86, 68), Color3.fromRGB(29, 56, 45)).Text = "MAIN LAGI"

local TombolKeluar = Instance.new("TextButton")
TombolKeluar.Size = UDim2.new(0.42, 0, 0.17, 0)
TombolKeluar.Position = UDim2.new(0.29, 0, 0.79, 0)
TombolKeluar.Parent = BingkaiAkhir
BantuanUI.gayaTombol(TombolKeluar, Color3.fromRGB(82, 56, 50), Color3.fromRGB(52, 35, 31)).Text = "KEMBALI KE LOBBY"

-- ==========================================
-- LOGIKA UI: PENGATURAN TAMPILAN PANEL
-- ==========================================
local apakahHost = false

local function aturPesan(teks)
    TeksPesan.Text = teks
end

local function gantiTampilan(mode)
    BingkaiLobby.Visible = mode == "Lobby"
    TampilanPermainan.Visible = mode == "Permainan"
    BingkaiAkhir.Visible = mode == "Akhir"
end

local function tampilkanDaftarRuangan(daftarRuangan)
    for _, anak in ipairs(BingkaiDaftarRuangan:GetChildren()) do
        if anak:IsA("Frame") then
            anak:Destroy()
        end
    end

    if #daftarRuangan == 0 then
        local kosong = BantuanUI.buatTeks(BingkaiDaftarRuangan, "Belum ada ruangan aktif. Silakan buat ruangan baru.", UDim2.new(1, -12, 0, 52), UDim2.new(0, 6, 0, 0), Enum.Font.Gotham, WARNA.textMuted, false)
        kosong.TextSize = 18
        return
    end

    for _, ruangan in ipairs(daftarRuangan) do
        local kartu = Instance.new("Frame")
        kartu.Size = UDim2.new(1, -12, 0, 72)
        kartu.Position = UDim2.new(0, 6, 0, 0)
        kartu.BackgroundColor3 = Color3.fromRGB(18, 28, 25)
        kartu.Parent = BingkaiDaftarRuangan
        BantuanUI.bulatkanSudut(kartu, 10)
        BantuanUI.garisTepi(kartu, WARNA.accentSoft, 1)

        local labelRuangan = BantuanUI.buatTeks(
            kartu,
            string.format("Ruangan %s  |  Tuan Rumah: %s  |  %d/%d pemain", ruangan.id, ruangan.namaHost, ruangan.jumlahPemain, ruangan.maksimalPemain),
            UDim2.new(0.66, 0, 0.82, 0),
            UDim2.new(0.03, 0, 0.09, 0),
            Enum.Font.Gotham,
            WARNA.textMain,
            true,
            Enum.TextXAlignment.Left
        )
        labelRuangan.TextSize = 15

        local tombolGabung = Instance.new("TextButton")
        tombolGabung.Size = UDim2.new(0.26, 0, 0.68, 0)
        tombolGabung.Position = UDim2.new(0.71, 0, 0.16, 0)
        tombolGabung.Parent = kartu
        BantuanUI.gayaTombol(tombolGabung, Color3.fromRGB(69, 103, 84), Color3.fromRGB(45, 67, 55)).Text = "MASUK"

        tombolGabung.MouseButton1Click:Connect(function()
            local sukses, pesanEror = AcaraMasukRuangan:InvokeServer(ruangan.id)
            if sukses then
                apakahHost = false
                aturPesan("Berhasil bergabung ke ruangan. Menunggu tuan rumah memulai permainan.")
                gantiTampilan("Permainan")
            else
                aturPesan("Gagal masuk ruangan: " .. tostring(pesanEror))
            end
        end)
    end
end

-- ==========================================
-- KONEKSI EVENT (MENERIMA DATA DARI SERVER)
-- ==========================================
TombolBuatRuangan.MouseButton1Click:Connect(function()
    local sukses, idRuanganAtauEror = AcaraBuatRuangan:InvokeServer()
    if sukses then
        apakahHost = true
        aturPesan("Ruangan dibuat. Anda adalah tuan rumah ruangan " .. tostring(idRuanganAtauEror) .. ".")
        gantiTampilan("Permainan")
    else
        aturPesan("Gagal membuat ruangan: " .. tostring(idRuanganAtauEror))
    end
end)

AcaraPerbaruiRuangan.OnClientEvent:Connect(function(daftarRuangan)
    tampilkanDaftarRuangan(daftarRuangan)
end)

AcaraStatusRuanganBerubah.OnClientEvent:Connect(function(dataStatus)
    if dataStatus.status == "Tutup" then
        gantiTampilan("Lobby")
        aturPesan("Anda kembali ke lobby.")
        TombolMulaiGame.Visible = false
        return
    end

    if dataStatus.status == "Menunggu" then
        gantiTampilan("Permainan")
        TeksAyat.Text = "Menunggu tuan rumah memulai permainan..."
        TeksDaftarPemain.Text = ""

        local apakahPemainIniHost = false
        local baris = {}
        for _, p in ipairs(dataStatus.pemainPemain) do
            if p.nama == PemainLokal.Name then
                apakahPemainIniHost = p.apakahHost
                apakahHost = p.apakahHost
            end
            table.insert(baris, string.format("%s - skor %d - nyawa %d", p.nama, p.skor, p.nyawa))
        end

        TeksDaftarPemain.Text = table.concat(baris, "\n")
        TombolMulaiGame.Visible = apakahPemainIniHost
        aturPesan("Ruangan aktif. Siapkan hafalan untuk ronde berikutnya.")
    elseif dataStatus.status == "Bermain" then
        gantiTampilan("Permainan")
        TombolMulaiGame.Visible = false

        local baris = {}
        for _, p in ipairs(dataStatus.pemainPemain) do
            if p.nama == PemainLokal.Name then
                apakahHost = p.apakahHost
            end
            local penanda = p.apakahGiliran and " <GILIRAN>" or ""
            table.insert(baris, string.format("%s - skor %d - nyawa %d%s", p.nama, p.skor, p.nyawa, penanda))
        end
        TeksDaftarPemain.Text = table.concat(baris, "\n")

        if dataStatus.namaSurahSaatIni then
            TeksAyat.Text = string.format("Surah %s\n%s", dataStatus.namaSurahSaatIni, dataStatus.ayatSaatIni or "(selesai)")
        else
            TeksAyat.Text = "Menunggu soal berikutnya..."
        end

        aturPesan("Ronde berjalan. Pilih sambungan ayat yang benar.")
    elseif dataStatus.status == "Selesai" then
        gantiTampilan("Akhir")
        TeksPemenang.Text = "Pemenang: " .. tostring(dataStatus.pemenang)
        TombolMainLagi.Visible = apakahHost

        if dataStatus.pemenang == PemainLokal.Name then
            JudulAkhir.Text = "ALHAMDULILLAH, MENANG"
            JudulAkhir.TextColor3 = Color3.fromRGB(145, 193, 128)
            aturPesan("Selamat, Anda memenangkan ronde ini.")
        else
            JudulAkhir.Text = "PERMAINAN SELESAI"
            JudulAkhir.TextColor3 = WARNA.accentGold
            aturPesan("Ronde selesai. Anda bisa lanjut main lagi.")
        end
    end
end)

TombolMulaiGame.MouseButton1Click:Connect(function()
    AcaraMulaiPermainan:FireServer()
end)

TombolMainLagi.MouseButton1Click:Connect(function()
    AcaraMainLagi:FireServer()
end)

TombolKeluar.MouseButton1Click:Connect(function()
    AcaraKeluarRuangan:FireServer()
    gantiTampilan("Lobby")
    aturPesan("Keluar dari ruangan dan kembali ke lobby.")
end)
