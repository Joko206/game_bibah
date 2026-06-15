local DataSurah = require(game.ReplicatedStorage.Shared.SurahData)

-- Module ini bertugas mengolah data surah dan verifikasi jawaban
-- Sengaja dipisah agar GameServer lebih fokus mengatur alur game
local ManajerPermainan = {}

-- Helper untuk menghapus tanda baca atau normalisasi teks jika dibutuhkan
local function normalisasiTeks(teks)
    -- Saat ini masih sederhana. Bila ayat ada harakat, bisa di-strip disini.
    return string.lower(teks:match("^%s*(.-)%s*$"))
end

function ManajerPermainan.ambilAyatAcak()
    local indeksSurah = math.random(1, #DataSurah)
    local surah = DataSurah[indeksSurah]
    local indeksAyat = math.random(1, #surah.ayat - 1)
    
    return surah.ayat[indeksAyat], surah.ayat[indeksAyat + 1], surah.name
end

function ManajerPermainan.cekJawaban(masukanPemain, jawabanSeharusnya)
    local nInput = normalisasiTeks(masukanPemain)
    local nTarget = normalisasiTeks(jawabanSeharusnya)
    
    return nInput == nTarget
end

return ManajerPermainan
