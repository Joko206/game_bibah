local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DataSurah = require(Shared:WaitForChild("SurahData"))

local PembuatMasjid = require(script.Parent:WaitForChild("PembuatMasjid"))
local PembuatArena = require(script.Parent:WaitForChild("PembuatArena"))

-- ==========================================
-- CINEMATIC LIGHTING
-- ==========================================
local efekCahaya = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
efekCahaya.Intensity = 0.28
efekCahaya.Size = 14
efekCahaya.Threshold = 1
efekCahaya.Parent = Lighting

local koreksiWarna = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
koreksiWarna.Contrast = 0.08
koreksiWarna.Saturation = -0.05
koreksiWarna.TintColor = Color3.fromRGB(232, 236, 224)
koreksiWarna.Parent = Lighting

Lighting.Brightness = 1.35
Lighting.Ambient = Color3.fromRGB(42, 48, 40)
Lighting.OutdoorAmbient = Color3.fromRGB(28, 34, 30)

local Acara = ReplicatedStorage:WaitForChild("Events")
local AcaraBuatRuangan = Acara:WaitForChild("BuatRuangan")
local AcaraMasukRuangan = Acara:WaitForChild("MasukRuangan")
local AcaraKeluarRuangan = Acara:WaitForChild("KeluarRuangan")
local AcaraMulaiPermainan = Acara:WaitForChild("MulaiPermainan")
local AcaraMainLagi = Acara:WaitForChild("MainLagi")
local AcaraPerbaruiRuangan = Acara:WaitForChild("PerbaruiRuangan")
local AcaraStatusRuanganBerubah = Acara:WaitForChild("StatusRuanganBerubah")

-- Game State
local DaftarRuangan = {}
local RuanganPemain = {}
local PenghitungRuangan = 0

local MAKSIMAL_NYAWA = 3
local MAKSIMAL_PEMAIN = 4

-- ==========================================
-- LOGIKA PEMBANTU (MENGELOLA PEMAIN, GILIRAN, DLL)
-- ==========================================
local function siarkanDaftarRuangan()
    local daftar = {}
    for id, ruangan in pairs(DaftarRuangan) do
        if ruangan.status == "Menunggu" then
            table.insert(daftar, {
                id = id,
                namaHost = ruangan.host.Name,
                jumlahPemain = #ruangan.pemainPemain,
                maksimalPemain = ruangan.maksimalPemain
            })
        end
    end
    AcaraPerbaruiRuangan:FireAllClients(daftar)
end

local function siarkanStatusRuangan(ruangan)
    local dataStatus = {
        status = ruangan.status,
        pemainPemain = {},
        indeksGiliran = ruangan.indeksGiliran,
        pemenang = ruangan.pemenang
    }

    if ruangan.indeksSurah and DataSurah[ruangan.indeksSurah] then
        dataStatus.namaSurahSaatIni = DataSurah[ruangan.indeksSurah].name
        dataStatus.ayatSaatIni = DataSurah[ruangan.indeksSurah].ayat[ruangan.indeksAyat]
    end

    for _, p in ipairs(ruangan.pemainPemain) do
        table.insert(dataStatus.pemainPemain, {
            nama = p.Name,
            skor = ruangan.skorPemain[p] or 0,
            nyawa = ruangan.nyawaPemain[p] or 0,
            apakahHost = (p == ruangan.host),
            apakahGiliran = (ruangan.pemainPemain[ruangan.indeksGiliran] == p)
        })
    end

    for _, p in ipairs(ruangan.pemainPemain) do
        AcaraStatusRuanganBerubah:FireClient(p, dataStatus)
    end
end

local function pindahkanPemain(pemain, posisi)
    local karakter = pemain.Character
    if karakter and karakter:FindFirstChild("HumanoidRootPart") then
        karakter.HumanoidRootPart.CFrame = CFrame.new(posisi)
    end
end

local function dapatkanGiliranSelanjutnya(ruangan)
    local indeksAwal = ruangan.indeksGiliran
    local indeksLanjut = indeksAwal
    repeat
        indeksLanjut = (indeksLanjut % #ruangan.pemainPemain) + 1
        if ruangan.nyawaPemain[ruangan.pemainPemain[indeksLanjut]] > 0 then
            return indeksLanjut
        end
    until indeksLanjut == indeksAwal
    return nil
end

local TARGET_SKOR = 100 -- Butuh 10 soal (100 poin) untuk menang

local function cekPermainanSelesai(ruangan)
    local jumlahHidup = 0
    local pemenang = nil

    for _, p in ipairs(ruangan.pemainPemain) do
        if ruangan.nyawaPemain[p] > 0 then
            jumlahHidup = jumlahHidup + 1
        end
        if (ruangan.skorPemain[p] or 0) >= TARGET_SKOR then
            pemenang = p
        end
    end

    local apakahBanyakPemain = #ruangan.pemainPemain > 1
    local apakahSelesai = false
    
    if pemenang then
        apakahSelesai = true -- Seseorang mencapai target
    elseif jumlahHidup == 0 then
        apakahSelesai = true -- Semua orang mati (termasuk main solo)
    elseif apakahBanyakPemain and jumlahHidup == 1 then
        apakahSelesai = true -- Di multiplayer, orang terakhir yang hidup menang
    end

    if apakahSelesai then
        ruangan.status = "Selesai"
        
        -- Tentukan pemenang
        if not pemenang and jumlahHidup == 1 and apakahBanyakPemain then
            for _, p in ipairs(ruangan.pemainPemain) do
                if ruangan.nyawaPemain[p] > 0 then pemenang = p end
            end
        end
        
        ruangan.pemenang = pemenang and pemenang.Name or "Tidak ada"
        if ruangan.pemenang == "Tidak ada" then
            ruangan.arena.teksSoal.Text = "PERMAINAN BERAKHIR! Semua pemain gugur."
        else
            ruangan.arena.teksSoal.Text = "SELAMAT! Pemenang: " .. ruangan.pemenang
        end
        
        -- Teleport semua kembali ke LOBBY MASJID
        for _, p in ipairs(ruangan.pemainPemain) do
            pindahkanPemain(p, Vector3.new(0, 5, -40))
        end
        
        return true
    end
    return false
end

-- ==========================================
-- LOGIKA PENGAMBILAN SOAL & PENGECEKAN JAWABAN (PINTU)
-- ==========================================
local function perbaruiSoalArena(ruangan)
    -- Pastikan lantai tertutup kembali setelah ada yang jatuh
    ruangan.arena.panggungMulai.CanCollide = true
    ruangan.arena.panggungMulai.Transparency = 0
    ruangan.arena.cahayaMulai.CanCollide = true
    ruangan.arena.cahayaMulai.Transparency = 0
    
    -- Pastikan pintu tertutup kembali dan warnanya di-reset
    for _, pintu in ipairs(ruangan.arena.pintuPintu) do
        pintu.CanCollide = true
        pintu.Transparency = 0
        pintu.BrickColor = BrickColor.new("Black")
    end
    
    if ruangan.status ~= "Bermain" then return end
    
    local surahSaatIni = DataSurah[ruangan.indeksSurah]
    local ayatSaatIni = surahSaatIni.ayat[ruangan.indeksAyat]
    local jawabanBenar = surahSaatIni.ayat[ruangan.indeksAyat + 1]
    
    if not jawabanBenar then
        -- Surah habis, ganti ke surah acak baru!
        ruangan.indeksSurah = math.random(1, #DataSurah)
        ruangan.indeksAyat = 1
        surahSaatIni = DataSurah[ruangan.indeksSurah]
        ayatSaatIni = surahSaatIni.ayat[ruangan.indeksAyat]
        jawabanBenar = surahSaatIni.ayat[ruangan.indeksAyat + 1]
    end
    
    -- Setup Question Text
    local pemainAktif = ruangan.pemainPemain[ruangan.indeksGiliran]
    ruangan.arena.teksSoal.Text = "[".. pemainAktif.Name .. "]\n" .. ayatSaatIni
    
    -- Generate Wrong Options
    local pilihanJawaban = {jawabanBenar}
    local semuaAyat = {}
    for _, s in ipairs(DataSurah) do
        for _, a in ipairs(s.ayat) do
            if a ~= jawabanBenar then table.insert(semuaAyat, a) end
        end
    end
    
    while #pilihanJawaban < 3 do
        local kandidat = semuaAyat[math.random(1, #semuaAyat)]
        local sudahAda = false
        for _, opt in ipairs(pilihanJawaban) do
            if opt == kandidat then
                sudahAda = true
                break
            end
        end
        if not sudahAda then
            table.insert(pilihanJawaban, kandidat)
        end
    end
    
    -- Shuffle Options
    for i = #pilihanJawaban, 2, -1 do
        local j = math.random(i)
        pilihanJawaban[i], pilihanJawaban[j] = pilihanJawaban[j], pilihanJawaban[i]
    end
    
    ruangan.indeksPintuBenar = 0
    
    -- Assign to doors and bind Touch event
    for i, pintu in ipairs(ruangan.arena.pintuPintu) do
        pintu.SurfaceGui.Text.Text = pilihanJawaban[i]
        
        -- Disconnect old touches
        if ruangan.koneksiPintu[i] then ruangan.koneksiPintu[i]:Disconnect() end
        
        local cahayaPintu = pintu:FindFirstChild("Glow")
        if cahayaPintu then cahayaPintu.BrickColor = BrickColor.new("Dark stone grey") end
        
        if pilihanJawaban[i] == jawabanBenar then
            ruangan.indeksPintuBenar = i
        end
        
        ruangan.koneksiPintu[i] = pintu.Touched:Connect(function(hit)
            local karakter = hit.Parent
            local pemainMenyentuh = Players:GetPlayerFromCharacter(karakter)
            
            if pemainMenyentuh == pemainAktif and ruangan.status == "Bermain" and ruangan.sedangMemprosesGiliran == false then
                ruangan.sedangMemprosesGiliran = true
                
                if i == ruangan.indeksPintuBenar then
                    -- Benar!
                    if ruangan.koneksiPintu[i] then ruangan.koneksiPintu[i]:Disconnect() end
                    if not ruangan.skorPemain[pemainMenyentuh] then ruangan.skorPemain[pemainMenyentuh] = 0 end
                    ruangan.skorPemain[pemainMenyentuh] = ruangan.skorPemain[pemainMenyentuh] + 10
                    
                    pintu.BrickColor = BrickColor.new("Forest green")
                    pintu.CanCollide = false -- Nembus!
                    pintu.Transparency = 0.5
                    if cahayaPintu then cahayaPintu.BrickColor = BrickColor.new("Sea green") end
                    
                    -- Biarkan pemain berlari menembus pintu ke platform aman
                    task.wait(1.5)
                    
                    ruangan.indeksAyat = ruangan.indeksAyat + 1
                    
                    local apakahSelesai = cekPermainanSelesai(ruangan)
                    if not apakahSelesai then
                        pindahkanPemain(pemainMenyentuh, ruangan.arena.posisiPenonton)
                        ruangan.indeksGiliran = dapatkanGiliranSelanjutnya(ruangan)
                        if ruangan.indeksGiliran then
                            local pemainSelanjutnya = ruangan.pemainPemain[ruangan.indeksGiliran]
                            perbaruiSoalArena(ruangan)
                            pindahkanPemain(pemainSelanjutnya, ruangan.arena.posisiMulai)
                        end
                    end
                else
                    -- Salah!
                    ruangan.nyawaPemain[pemainMenyentuh] = ruangan.nyawaPemain[pemainMenyentuh] - 1
                    local hum = karakter:FindFirstChild("Humanoid")
                    if hum then hum.Health = 0 end
                    
                    if ruangan.nyawaPemain[pemainMenyentuh] <= 0 then
                        if not cekPermainanSelesai(ruangan) then
                            ruangan.indeksGiliran = dapatkanGiliranSelanjutnya(ruangan)
                            -- Note: Respawn handler will teleport pemainSelanjutnya
                        end
                    end
                end
                
                siarkanStatusRuangan(ruangan)
                task.wait(2)
                if cahayaPintu then cahayaPintu.BrickColor = BrickColor.new("Dark stone grey") end
                ruangan.sedangMemprosesGiliran = false
            end
        end)
    end
end

-- ==========================================
-- EVENT HANDLERS
-- ==========================================
PembuatMasjid.bangunMasjidLobby()

-- ==========================================
-- EVENTS
-- ==========================================
AcaraBuatRuangan.OnServerInvoke = function(pemain)
    if RuanganPemain[pemain] then return false, "Anda sudah berada di dalam ruangan." end
    
    PenghitungRuangan = PenghitungRuangan + 1
    local idRuangan = tostring(PenghitungRuangan)
    
    local arena = PembuatArena.buatArena(PenghitungRuangan)
    
    local ruanganBaru = {
        id = idRuangan,
        host = pemain,
        pemainPemain = {pemain},
        status = "Menunggu",
        maksimalPemain = MAKSIMAL_PEMAIN,
        indeksSurah = math.random(1, #DataSurah),
        indeksAyat = 1,
        indeksGiliran = 1,
        skorPemain = {[pemain] = 0},
        nyawaPemain = {[pemain] = MAKSIMAL_NYAWA},
        arena = arena,
        koneksiPintu = {},
        sedangMemprosesGiliran = false
    }
    
    DaftarRuangan[idRuangan] = ruanganBaru
    RuanganPemain[pemain] = idRuangan
    
    pindahkanPemain(pemain, arena.posisiPenonton)
    siarkanDaftarRuangan()
    siarkanStatusRuangan(ruanganBaru)
    return true, idRuangan
end

AcaraMasukRuangan.OnServerInvoke = function(pemain, idRuangan)
    if RuanganPemain[pemain] then return false, "Sudah ada di dalam ruangan." end
    local ruangan = DaftarRuangan[idRuangan]
    if not ruangan then return false, "Ruangan tidak ditemukan." end
    if ruangan.status ~= "Menunggu" then return false, "Permainan sudah dimulai." end
    if #ruangan.pemainPemain >= ruangan.maksimalPemain then return false, "Ruangan penuh." end
    
    table.insert(ruangan.pemainPemain, pemain)
    ruangan.skorPemain[pemain] = 0
    ruangan.nyawaPemain[pemain] = MAKSIMAL_NYAWA
    RuanganPemain[pemain] = idRuangan
    
    pindahkanPemain(pemain, ruangan.arena.posisiPenonton)
    siarkanDaftarRuangan()
    siarkanStatusRuangan(ruangan)
    return true
end

AcaraMulaiPermainan.OnServerEvent:Connect(function(pemain)
    local idRuangan = RuanganPemain[pemain]
    if not idRuangan then return end
    local ruangan = DaftarRuangan[idRuangan]
    if ruangan and ruangan.host == pemain and ruangan.status == "Menunggu" then
        ruangan.status = "Bermain"
        
        local pemainPertama = ruangan.pemainPemain[ruangan.indeksGiliran]
        pindahkanPemain(pemainPertama, ruangan.arena.posisiMulai)
        perbaruiSoalArena(ruangan)
        
        siarkanStatusRuangan(ruangan)
    end
end)

AcaraMainLagi.OnServerEvent:Connect(function(pemain)
    local idRuangan = RuanganPemain[pemain]
    if not idRuangan then return end
    local ruangan = DaftarRuangan[idRuangan]
    if ruangan and ruangan.host == pemain and ruangan.status == "Selesai" then
        ruangan.status = "Menunggu"
        ruangan.indeksSurah = math.random(1, #DataSurah)
        ruangan.indeksAyat = 1
        ruangan.indeksGiliran = 1
        ruangan.arena.teksSoal.Text = "Menunggu Permainan Dimulai..."
        
        for _, p in ipairs(ruangan.pemainPemain) do
            ruangan.skorPemain[p] = 0
            ruangan.nyawaPemain[p] = MAKSIMAL_NYAWA
            pindahkanPemain(p, ruangan.arena.posisiPenonton)
        end
        
        siarkanDaftarRuangan()
        siarkanStatusRuangan(ruangan)
    end
end)

AcaraKeluarRuangan.OnServerEvent:Connect(function(pemain)
    local idRuangan = RuanganPemain[pemain]
    if not idRuangan then return end
    
    local ruangan = DaftarRuangan[idRuangan]
    if ruangan then
        if ruangan.host == pemain then
            for _, p in ipairs(ruangan.pemainPemain) do
                RuanganPemain[p] = nil
                AcaraStatusRuanganBerubah:FireClient(p, {status = "Tutup"})
            end
            ruangan.arena.model:Destroy()
            DaftarRuangan[idRuangan] = nil
        else
            local pemainBaru = {}
            for _, p in ipairs(ruangan.pemainPemain) do
                if p ~= pemain then table.insert(pemainBaru, p) end
            end
            ruangan.pemainPemain = pemainBaru
            RuanganPemain[pemain] = nil
            AcaraStatusRuanganBerubah:FireClient(pemain, {status = "Tutup"})
            
            if ruangan.status == "Bermain" then cekPermainanSelesai(ruangan) end
            if DaftarRuangan[idRuangan] then siarkanStatusRuangan(ruangan) end
        end
    end
    siarkanDaftarRuangan()
end)

Players.PlayerRemoving:Connect(function(pemain)
    local idRuangan = RuanganPemain[pemain]
    if not idRuangan then
        return
    end

    local ruangan = DaftarRuangan[idRuangan]
    if not ruangan then
        RuanganPemain[pemain] = nil
        return
    end

    if ruangan.host == pemain then
        for _, p in ipairs(ruangan.pemainPemain) do
            RuanganPemain[p] = nil
            AcaraStatusRuanganBerubah:FireClient(p, {status = "Tutup"})
        end

        if ruangan.arena and ruangan.arena.model then
            ruangan.arena.model:Destroy()
        end
        DaftarRuangan[idRuangan] = nil
    else
        local pemainBaru = {}
        for _, p in ipairs(ruangan.pemainPemain) do
            if p ~= pemain then
                table.insert(pemainBaru, p)
            end
        end
        ruangan.pemainPemain = pemainBaru
        ruangan.skorPemain[pemain] = nil
        ruangan.nyawaPemain[pemain] = nil
        RuanganPemain[pemain] = nil

        if ruangan.status == "Bermain" then
            cekPermainanSelesai(ruangan)
        end

        if DaftarRuangan[idRuangan] then
            siarkanStatusRuangan(ruangan)
        end
    end

    siarkanDaftarRuangan()
end)

-- Handle Respawn to teleport back to correct area
Players.PlayerAdded:Connect(function(pemain)
    pemain.CharacterAdded:Connect(function(karakter)
        task.wait(0.5) -- tunggu fisik stabil
        local idRuangan = RuanganPemain[pemain]
        if idRuangan then
            local ruangan = DaftarRuangan[idRuangan]
            if ruangan then
                if ruangan.status == "Bermain" then
                    if ruangan.pemainPemain[ruangan.indeksGiliran] == pemain and ruangan.nyawaPemain[pemain] > 0 then
                        pindahkanPemain(pemain, ruangan.arena.posisiMulai)
                    else
                        pindahkanPemain(pemain, ruangan.arena.posisiPenonton)
                        -- Jika pemain mati dan kehabisan nyawa, giliran berpindah. Pindahkan pemain aktif ke tempat mulai.
                        local pemainAktifSekarang = ruangan.pemainPemain[ruangan.indeksGiliran]
                        if pemainAktifSekarang and ruangan.nyawaPemain[pemainAktifSekarang] > 0 then
                            pindahkanPemain(pemainAktifSekarang, ruangan.arena.posisiMulai)
                            perbaruiSoalArena(ruangan)
                        end
                    end
                else
                    pindahkanPemain(pemain, ruangan.arena.posisiPenonton)
                end
            end
        end
    end)
end)
