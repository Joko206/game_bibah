const fs = require("fs");

const raw = fs.readFileSync(0, "utf8");
const payload = JSON.parse(raw);

const ayahs = payload.data.ayahs.filter((a) => a.surah.number >= 78 && a.surah.number <= 114);
const bySurah = new Map();

for (const a of ayahs) {
  if (!bySurah.has(a.surah.number)) {
    bySurah.set(a.surah.number, {
      number: a.surah.number,
      name: a.surah.name,
      ayat: [],
    });
  }
  bySurah.get(a.surah.number).ayat.push([a.numberInSurah, a.text]);
}

const surahs = Array.from(bySurah.values())
  .sort((x, y) => x.number - y.number)
  .map((s) => ({
    number: s.number,
    name: s.name,
    ayat: s.ayat.sort((a, b) => a[0] - b[0]).map((x) => x[1]),
  }));

const escapeLua = (text) => text.replace(/\\/g, "\\\\").replace(/"/g, '\\"');

let surahData = "local SurahData = {\n";
for (const s of surahs) {
  surahData += "    {\n";
  surahData += `        name = "${escapeLua(s.name)}",\n`;
  surahData += "        ayat = {\n";
  surahData += s.ayat.map((a) => `            "${escapeLua(a)}"`).join(",\n");
  surahData += "\n        }\n";
  surahData += "    },\n";
}
surahData += "}\n\nreturn SurahData\n";

let ayatData = "local AyatData = {\n";
for (const s of surahs) {
  for (let i = 0; i < s.ayat.length - 1; i++) {
    ayatData += "    {\n";
    ayatData += `        awal = "${escapeLua(s.name)} ayat ${i + 1}",\n`;
    ayatData += `        teks = "${escapeLua(s.ayat[i])}",\n`;
    ayatData += `        sambungan = "${escapeLua(s.ayat[i + 1])}"\n`;
    ayatData += "    },\n";
  }
}
ayatData += "}\n\nreturn AyatData\n";

fs.writeFileSync("src/shared/SurahData.lua", surahData);
fs.writeFileSync("src/shared/AyatData.luau", ayatData);

console.log(`surah_count=${surahs.length}`);
console.log(`question_pairs=${ayatData.split("\n").filter((line) => line.trim() === "{").length - 1}`);
