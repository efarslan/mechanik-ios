import Foundation

enum JobQuickJobCatalog {
    static let categories: [String] = [
        "Bakım",
        "Motor / Mekanik",
        "Şanzıman / Debriyaj",
        "Alt Takım",
        "Fren Sistemi",
        "Elektrik Sistemi",
        "Soğutma Sistemi",
        "Egzoz Sistemi"
    ]

    static let jobsByCategory: [String: [String]] = [
        "Bakım": ["Yağ Değişimi", "Yağ Filtresi", "Hava Filtresi", "Polen Filtresi", "Yakıt Filtresi"],
        "Motor / Mekanik": ["Triger Kayışı Değişimi", "V Kayışı Değişimi", "Su Pompası", "Enjektör Servisi", "Turbo", "Motor Takozu"],
        "Şanzıman / Debriyaj": ["Debriyaj Seti Değişimi", "Şanzıman Yağı Değişimi", "Volan Değişimi"],
        "Alt Takım": ["Amortisör", "Salıncak", "Z Rot", "Rot Başı", "Rot Kolu"],
        "Fren Sistemi": ["Fren Balatası", "Fren Diski", "Fren Hidroliği Değişimi", "Fren Kaliperi"],
        "Elektrik Sistemi": ["Akü", "Marş Motoru", "Alternatör", "Buji Değişimi"],
        "Soğutma Sistemi": ["Radyatör Değişimi", "Termostat Değişimi", "Hortum Değişimi", "Antifriz Değişimi"],
        "Egzoz Sistemi": ["DPF Temizliği", "Katalitik Konvertör Temizliği", "Oksijen Sensörü Değişimi", "Manifold Contası", "Susturucu"]
    ]

    static let allNames: [String] = Array(Set(jobsByCategory.values.flatMap { $0 })).sorted()
}
