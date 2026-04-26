local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AyatData = require(ReplicatedStorage:WaitForChild("AyatData"))

-- Variabel status game
local nyawaPemain = 3 [cite: 11]
local skorPemain = 0 [cite: 10]

local function muatAyat() [cite: 4]
    local data = AyatData[math.random(1, #AyatData)]
    print("Ayat dimuat: " .. data.teks) [cite: 5]
    return data
end

-- Simulasi validasi jawaban [cite: 7]
local function cekJawaban(inputPemain, jawabanBenar)
    if inputPemain:lower() == jawabanBenar:lower() then
        skorPemain += 10 [cite: 9, 10]
        print("Benar! Skor sekarang: " .. skorPemain)
    else
        nyawaPemain -= 1 [cite: 8, 11]
        print("Salah! Sisa nyawa: " .. nyawaPemain)
    end
end

muatAyat()