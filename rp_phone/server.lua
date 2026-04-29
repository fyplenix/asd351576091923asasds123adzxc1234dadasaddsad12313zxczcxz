-- ==========================================
-- ARAYÜZ GÜNCELLEME MOTORU (Numara Çözümü Eklendi)
-- ==========================================
function telefonVerileriniGonder(oyuncu)
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end

    local sorgu = exports.mysql:sorgu("SELECT character_name, iban, bank_balance, phone_wallpaper, casino_balance FROM characters WHERE id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        local isim = string.gsub(sonuc[1].character_name, "_", " ")
        local iban = sonuc[1].iban or "Hesap Yok" 
        local bakiye = tonumber(sonuc[1].bank_balance) or 0
        local wp = sonuc[1].phone_wallpaper or ""
        local casinoBakiye = tonumber(sonuc[1].casino_balance) or 0
        
        local numara = "Numarasız"
        -- ÇÖZÜM: Eşyanın 'id'sini de çekiyoruz ki güncellerken tam nokta atışı yapalım
        local itemSorgu = exports.mysql:sorgu("SELECT id, metadata FROM character_items WHERE character_id = ? AND item_id = 'telefon' LIMIT 1", charID)
        local itemSonuc = dbPoll(itemSorgu, -1)
        
        if itemSonuc and #itemSonuc > 0 then
            -- 1. Varsa numarayı okumaya çalış
            if itemSonuc[1].metadata and string.len(tostring(itemSonuc[1].metadata)) > 5 then
                local parsedMeta = fromJSON(tostring(itemSonuc[1].metadata))
                if type(parsedMeta) == "table" then
                    local numaraData = parsedMeta[1] or parsedMeta
                    if type(numaraData) == "table" and numaraData.numara then
                        numara = tostring(numaraData.numara)
                    end
                end
            end
            
            -- 2. EĞER METADATA BOŞSA (NPC'den Yeni Alınmışsa) OTOMATİK NUMARA YAZDIR!
            if numara == "Numarasız" then
                local rastgeleNumara = "05" .. tostring(math.random(10000000, 99999999))
                local yeniMetadata = toJSON({numara = rastgeleNumara})
                
                local esyaID = itemSonuc[1].id
                -- Veritabanına bu yeni numarayı kalıcı olarak kaydet
                exports.mysql:calistir("UPDATE character_items SET metadata = ? WHERE id = ?", yeniMetadata, esyaID)
                
                numara = rastgeleNumara -- Ekrana da bu numarayı yansıt
            end
        end

        setElementData(oyuncu, "telefon_numarasi", numara)
        triggerClientEvent(oyuncu, "telefon:ekVerileriYukle", resourceRoot, iban, bakiye, isim, wp, casinoBakiye, numara)
        -- Telefon açıldığında hava durumu verisini de anında gönder
        if sonHavaDurumu then
            triggerClientEvent(oyuncu, "phone:updateWeather", oyuncu, sonHavaDurumu.temp, sonHavaDurumu.desc, sonHavaDurumu.low, sonHavaDurumu.high, sonHavaDurumu.summary, sonHavaDurumu.hourly, sonHavaDurumu.daily)
        end
    end
end

-- Telefon her açıldığında verileri gönderen fonksiyonu çağırdığından emin ol
addEvent("telefon:verileriHazirla", true)
addEventHandler("telefon:verileriHazirla", resourceRoot, function()
    -- Bu fonksiyon zaten içindeki 'telefonVerileriniGonder' ile casino bakiyesini yollar
    telefonVerileriniGonder(client)
end)

addEvent("telefon:transferYap", true)
addEventHandler("telefon:transferYap", resourceRoot, function(hedefIban, miktar)
    local oyuncu = client
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    miktar = tonumber(miktar)
    
    local kendiSorgu = exports.mysql:sorgu("SELECT iban, bank_balance FROM characters WHERE id = ?", charID)
    local kendiData = dbPoll(kendiSorgu, -1)[1]
    
    if not kendiData.iban then outputChatBox("[Banka] Lütfen önce IBAN oluşturun.", oyuncu, 255, 0, 0) return end
    if kendiData.iban == hedefIban then outputChatBox("[Banka] Kendinize para gönderemezsiniz!", oyuncu, 255, 0, 0) return end
    if kendiData.bank_balance < miktar then outputChatBox("[Banka] Yetersiz bakiye!", oyuncu, 255, 0, 0) return end

    local hedefSorgu = exports.mysql:sorgu("SELECT id, character_name FROM characters WHERE iban = ?", hedefIban)
    local hedefData = dbPoll(hedefSorgu, -1)
    
    if hedefData and #hedefData > 0 then
        local aliciID = hedefData[1].id
        local aliciIsim = string.gsub(hedefData[1].character_name, "_", " ")
        
        exports.mysql:calistir("UPDATE characters SET bank_balance = bank_balance - ? WHERE id = ?", miktar, charID)
        exports.mysql:calistir("UPDATE characters SET bank_balance = bank_balance + ? WHERE id = ?", miktar, aliciID)
        outputChatBox("[Banka] Başarıyla " .. aliciIsim .. " kişisine $"..miktar.." transfer ettiniz.", oyuncu, 0, 255, 0)
        
        telefonVerileriniGonder(oyuncu)
    else
        outputChatBox("[Banka] IBAN bulunamadı!", oyuncu, 255, 0, 0)
    end
end)

-- ==========================================
-- REHBER & AYARLAR
-- ==========================================
addEventHandler("onResourceStart", resourceRoot, function()
    -- 1. AŞAMA: SQL Veritabanı Kontrolleri ve Tablo Oluşturma (ASLA SİLİNMEYECEK)
    exports.mysql:calistir("CREATE TABLE IF NOT EXISTS phone_contacts (id INT AUTO_INCREMENT PRIMARY KEY, char_id INT, contact_number VARCHAR(15), contact_name VARCHAR(50))")
    
    local checkWall = exports.mysql:sorgu("SHOW COLUMNS FROM characters LIKE 'phone_wallpaper'")
    if checkWall and #dbPoll(checkWall, -1) == 0 then 
    -- Varsayılan değeri wp1.png olarak ayarladık
        exports.mysql:calistir("ALTER TABLE characters ADD COLUMN phone_wallpaper VARCHAR(255) DEFAULT 'wp1.png'") 
    end
        
    local checkCasino = exports.mysql:sorgu("SHOW COLUMNS FROM characters LIKE 'casino_balance'")
    if checkCasino and #dbPoll(checkCasino, -1) == 0 then exports.mysql:calistir("ALTER TABLE characters ADD COLUMN casino_balance INT DEFAULT 0") end

    -- 2. AŞAMA: Oyuncu Senkronizasyonu (Restart atıldığında bakiyelerin 0 olmasını engelleyen kod)
    for _, player in ipairs(getElementsByType("player")) do
        local charID = getElementData(player, "aktifKarakterID")
        if charID then
            -- telefonVerileriniGonder fonksiyonu zaten üst kısımlarda tanımlı olmalı
            telefonVerileriniGonder(player)
        end
    end
end)

addEvent("phone:addContact", true)
addEventHandler("phone:addContact", root, function(numara, isim)
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    if not charID then return end

    local checkNum = exports.mysql:sorgu("SELECT id FROM character_items WHERE metadata LIKE ?", '%"'..numara..'"%')
    local resNum = dbPoll(checkNum, -1)
    
    if resNum and #resNum > 0 then
        exports.mysql:calistir("INSERT INTO phone_contacts (char_id, contact_number, contact_name) VALUES (?, ?, ?)", charID, numara, isim)
        if exports.rp_bildirim then exports.rp_bildirim:goster(client, "success", "Rehber", isim .. " kaydedildi.") end
        
        local sorgu = exports.mysql:sorgu("SELECT contact_number, contact_name FROM phone_contacts WHERE char_id = ?", charID)
        local sonuc = dbPoll(sorgu, -1)
        if sonuc then triggerClientEvent(client, "phone:receiveContacts", client, toJSON(sonuc)) end
    else
        if exports.rp_bildirim then exports.rp_bildirim:goster(client, "error", "Hata", "Böyle bir numara kullanımda değil!") end
    end
end)

addEvent("phone:requestContacts", true)
addEventHandler("phone:requestContacts", root, function()
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    local sorgu = exports.mysql:sorgu("SELECT contact_number, contact_name FROM phone_contacts WHERE char_id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    if sonuc then triggerClientEvent(client, "phone:receiveContacts", client, toJSON(sonuc)) end
end)

addEvent("phone:setWallpaper", true)
addEventHandler("phone:setWallpaper", root, function(url)
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    exports.mysql:calistir("UPDATE characters SET phone_wallpaper = ? WHERE id = ?", url, charID)
    setElementData(client, "telefon_duvarkagidi", url)
end)

addEvent("phone:setRingtone", true)
addEventHandler("phone:setRingtone", root, function(ses)
    setElementData(client, "telefon_zil", ses)
end)

-- ==========================================
-- CASINO SİSTEMİ (Bug Onarıldı ve Güvenlik Eklendi)
-- ==========================================
addEvent("casino:deposit", true)
addEventHandler("casino:deposit", root, function(miktar)
    local oyuncu = client
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end

    -- Javascript'ten gelen veriyi kesinlikle tam sayıya (Integer) çeviriyoruz
    miktar = math.floor(tonumber(miktar) or 0)
    if miktar <= 0 then return end

    -- Güvenli SQL Okuma İşlemi
    local sorgu = exports.mysql:sorgu("SELECT bank_balance FROM characters WHERE id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        local banka = tonumber(sonuc[1].bank_balance) or 0
        
        if banka >= miktar then
            exports.mysql:calistir("UPDATE characters SET bank_balance = bank_balance - ?, casino_balance = casino_balance + ? WHERE id = ?", miktar, miktar, charID)
            if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Casino", miktar .. "$ hesabınıza aktarıldı.") end
            
            -- Bakiyelerin ekranda anında güncellenmesi için:
            telefonVerileriniGonder(oyuncu)
        else
            if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Hata", "Bankada yeterli bakiye yok.") end
        end
    else
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Hata", "Banka bilgileriniz okunamadı.") end
    end
end)

addEvent("casino:withdraw", true)
addEventHandler("casino:withdraw", root, function(miktar)
    local oyuncu = client
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end

    -- Tam sayıya (Integer) çevir
    miktar = math.floor(tonumber(miktar) or 0)
    if miktar <= 0 then return end

    local sorgu = exports.mysql:sorgu("SELECT casino_balance FROM characters WHERE id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        local casinoPara = tonumber(sonuc[1].casino_balance) or 0
        
        if casinoPara >= miktar then
            exports.mysql:calistir("UPDATE characters SET bank_balance = bank_balance + ?, casino_balance = casino_balance - ? WHERE id = ?", miktar, miktar, charID)
            if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Casino", miktar .. "$ bankaya çekildi.") end
            
            telefonVerileriniGonder(oyuncu)
        else
            if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Hata", "Casino hesabınızda yeterli bakiye yok.") end
        end
    end
end)

local semboller = {"🍒", "💎", "🍋", "🔔", "🍇"}

addEvent("casino:spinRequest", true)
addEventHandler("casino:spinRequest", root, function(istenenBahis)
    local oyuncu = client
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end
    
    -- Güvenlik: Gelen bahisi sayıya çevir, hileye karşı sadece belirli bahisleri kabul et
    local bahis = tonumber(istenenBahis) or 100
    if bahis ~= 100 and bahis ~= 500 and bahis ~= 1000 then bahis = 100 end
    
    local sorgu = exports.mysql:sorgu("SELECT casino_balance FROM characters WHERE id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        local casinoPara = tonumber(sonuc[1].casino_balance) or 0
        
        -- Bakiyesi seçtiği bahise yetiyor mu kontrolü
        if casinoPara < bahis then return end 
        
        -- Bahisi düş
        casinoPara = casinoPara - bahis
        exports.mysql:calistir("UPDATE characters SET casino_balance = ? WHERE id = ?", casinoPara, charID)
        
        local r1 = semboller[math.random(1, #semboller)]
        local r2 = semboller[math.random(1, #semboller)]
        local r3 = semboller[math.random(1, #semboller)]
        local mesaj = "Kazanamadın! (-" .. bahis .. "$)"
        
        if r1 == r2 and r2 == r3 then
            -- Çarpanlar: Elmas 100 Katı, Kiraz 50 Katı, Diğerleri 20 Katı!
            local carpan = 20
            if r1 == "💎" then carpan = 100 elseif r1 == "🍒" then carpan = 50 end
            
            local kazanc = bahis * carpan
            mesaj = "KAZANDIN! +" .. kazanc .. "$"
            casinoPara = casinoPara + kazanc
            exports.mysql:calistir("UPDATE characters SET casino_balance = ? WHERE id = ?", casinoPara, charID)
        end
        
        -- ÇÖZÜM: Direkt JS'ye müdahale etmek yerine, sonucu güvenle Client'a yolluyoruz
        telefonVerileriniGonder(oyuncu)
        triggerClientEvent(oyuncu, "casino:spinResult", resourceRoot, r1, r2, r3, mesaj, casinoPara)
    end
end)




-- ==========================================
-- FOTOĞRAF (GALERİ) SİSTEMİ
-- ==========================================
addEventHandler("onResourceStart", resourceRoot, function()
    -- Fotoğraflar için yüksek kapasiteli (LONGTEXT) veri tablosu
    exports.mysql:calistir("CREATE TABLE IF NOT EXISTS phone_photos (id INT AUTO_INCREMENT PRIMARY KEY, char_id INT, photo_data LONGTEXT)")
end)

addEvent("phone:savePhoto", true)
addEventHandler("phone:savePhoto", root, function(base64URI)
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    if not charID then return end
    
    -- Fotoğrafı SQL'e kaydet
    exports.mysql:calistir("INSERT INTO phone_photos (char_id, photo_data) VALUES (?, ?)", charID, base64URI)
    if exports.rp_bildirim then exports.rp_bildirim:goster(client, "info", "Kamera", "Fotoğraf başarıyla Film Rulosuna kaydedildi.") end
end)

addEvent("phone:requestPhotos", true)
addEventHandler("phone:requestPhotos", root, function()
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    if not charID then return end
    
    local sorgu = exports.mysql:sorgu("SELECT id, photo_data FROM phone_photos WHERE char_id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc then
        triggerClientEvent(client, "phone:receivePhotos", client, toJSON(sonuc))
    end
end)

addEvent("phone:deletePhoto", true)
addEventHandler("phone:deletePhoto", root, function(photoID)
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    if not charID then return end
    
    -- Fotoğrafı SQL'den sil
    exports.mysql:calistir("DELETE FROM phone_photos WHERE id = ? AND char_id = ?", photoID, charID)
    
    if exports.rp_bildirim then 
        exports.rp_bildirim:goster(client, "success", "Galeri", "Fotoğraf silindi.") 
    end
    
    -- ÇÖZÜM: Sildikten saniyeler sonra GÜNCEL LİSTEYİ çekip telefona geri yolla! (Anında yenilenir)
    local sorgu = exports.mysql:sorgu("SELECT id, photo_data FROM phone_photos WHERE char_id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        triggerClientEvent(client, "phone:receivePhotos", client, toJSON(sonuc))
    else
        -- Hiç fotoğraf kalmadıysa boş liste gönder
        triggerClientEvent(client, "phone:receivePhotos", client, "[[]]")
    end
end)


-- ==========================================
-- GEÇİCİ KAMERA (SİLAH) VERME SİSTEMİ
-- ==========================================
local tempCameras = {}

addEvent("phone:giveTempCamera", true)
addEventHandler("phone:giveTempCamera", root, function()
    local oyuncu = client
    
    -- Oyuncuda zaten kamera var mı diye bak (Kendi eşyasıysa silmeyelim)
    local kendiKamerasiVarMi = false
    if getPedWeapon(oyuncu, 9) == 43 then kendiKamerasiVarMi = true end
    
    tempCameras[oyuncu] = {
        sahipMi = kendiKamerasiVarMi,
        eskiSilah = getPedWeaponSlot(oyuncu)
    }
    
    -- Kamerayı ver (Silah ID 43) ve 50 mermi ekle, hemen eline aldır
    giveWeapon(oyuncu, 43, 50, true)
    setPedWeaponSlot(oyuncu, 9)
end)

addEvent("phone:takeTempCamera", true)
addEventHandler("phone:takeTempCamera", root, function()
    local oyuncu = client
    
    if tempCameras[oyuncu] then
        -- Eğer oyuncunun kendi kamerası yoksa, bizim verdiğimizi sil
        if not tempCameras[oyuncu].sahipMi then
            takeWeapon(oyuncu, 43)
        end
        
        -- Oyuncunun eline telefonu açmadan önceki eski silahını (veya yumruğunu) geri ver
        setPedWeaponSlot(oyuncu, tempCameras[oyuncu].eskiSilah or 0)
        
        tempCameras[oyuncu] = nil
    end
end)






-- ==========================================
-- SAHİBİNDEN.COM SİSTEMİ
-- ==========================================
addEventHandler("onResourceStart", resourceRoot, function()
    exports.mysql:calistir("CREATE TABLE IF NOT EXISTS phone_sahibinden (id INT AUTO_INCREMENT PRIMARY KEY, char_id INT, veh_id INT, veh_name VARCHAR(50), km VARCHAR(20), color VARCHAR(50), title VARCHAR(15), price INT, post_date DATETIME DEFAULT CURRENT_TIMESTAMP)")
    
    local checkPhoto = exports.mysql:sorgu("SHOW COLUMNS FROM phone_sahibinden LIKE 'photo_data'")
    if checkPhoto and #dbPoll(checkPhoto, -1) == 0 then exports.mysql:calistir("ALTER TABLE phone_sahibinden ADD COLUMN photo_data LONGTEXT") end
    
    local checkNum = exports.mysql:sorgu("SHOW COLUMNS FROM phone_sahibinden LIKE 'seller_number'")
    if checkNum and #dbPoll(checkNum, -1) == 0 then exports.mysql:calistir("ALTER TABLE phone_sahibinden ADD COLUMN seller_number VARCHAR(20) DEFAULT 'Bilinmiyor'") end
end)

addEvent("phone:shbRequestAllAds", true)
addEventHandler("phone:shbRequestAllAds", root, function()
    local sorgu = exports.mysql:sorgu("SELECT p.*, c.character_name AS seller_name, DATE_FORMAT(p.post_date, '%d.%m.%Y %H:%i') as post_date FROM phone_sahibinden p LEFT JOIN characters c ON p.char_id = c.id ORDER BY p.id DESC")
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        for i, ad in ipairs(sonuc) do
            sonuc[i].seller_name = string.gsub(ad.seller_name or "Bilinmiyor", "_", " ")
        end
        triggerClientEvent(client, "phone:shbReceiveAllAds", client, toJSON(sonuc, true))
    else
        triggerClientEvent(client, "phone:shbReceiveAllAds", client, "[[]]") -- <-- Burası düzeltildi
    end
end)

local function getClosestColorName(r, g, b)
    r, g, b = tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255
    local colors = {
        {adi = "Siyah", r = 0, g = 0, b = 0}, {adi = "Beyaz", r = 255, g = 255, b = 255}, {adi = "Gri", r = 128, g = 128, b = 128},
        {adi = "Kırmızı", r = 255, g = 0, b = 0}, {adi = "Yeşil", r = 0, g = 255, b = 0}, {adi = "Mavi", r = 0, g = 0, b = 255},
        {adi = "Lacivert", r = 0, g = 0, b = 128}, {adi = "Sarı", r = 255, g = 255, b = 0}, {adi = "Turuncu", r = 255, g = 165, b = 0},
        {adi = "Mor", r = 128, g = 0, b = 128}, {adi = "Pembe", r = 255, g = 105, b = 180}, {adi = "Kahverengi", r = 139, g = 69, b = 19}
    }
    local minMesafe, enYakin = 999999, "Belirsiz"
    for _, renk in ipairs(colors) do
        local mesafe = math.sqrt((r - renk.r)^2 + (g - renk.g)^2 + (b - renk.b)^2)
        if mesafe < minMesafe then minMesafe = mesafe; enYakin = renk.adi end
    end
    return enYakin
end

-- ==========================================
-- SAHİBİNDEN: KENDİ İLANIM VE ARAÇLARIM (FİLTRELİ & UYARISIZ)
-- ==========================================
addEvent("phone:shbRequestMyAd", true)
addEventHandler("phone:shbRequestMyAd", root, function()
    -- ÇÖZÜM: Sunucu içi tetiklemelerde 'client' boş dönerse 'source' kullan!
    local oyuncu = client or source
    if not isElement(oyuncu) then return end
    
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end
    
    -- 1. Veritabanından araçları çek
    local sorgu = exports.mysql:sorgu("SELECT * FROM vehicles WHERE owner_id = ?", charID)
    local vehSonuc = dbPoll(sorgu, -1)
    local adSonuc = dbPoll(exports.mysql:sorgu("SELECT * FROM phone_sahibinden WHERE char_id = ? LIMIT 1", charID), -1)

    -- 2. Temiz Tablo Oluşturma
    local temizVehicles = {}
    
    if vehSonuc and type(vehSonuc) == "table" and #vehSonuc > 0 then
        for i, v in ipairs(vehSonuc) do
            local modelID = tonumber(v.model or v.veh_model) or 411
            local cR = tonumber(v.color_r or v.color1_r) or 255
            local cG = tonumber(v.color_g or v.color1_g) or 255
            local cB = tonumber(v.color_b or v.color1_b) or 255
            
            local renkAdi = "Belirsiz"
            if getClosestColorName then renkAdi = getClosestColorName(cR, cG, cB) end

            table.insert(temizVehicles, {
                id = v.id,
                veh_name = getVehicleNameFromModel(modelID) or "Bilinmeyen Araç",
                km = tostring(math.floor(tonumber(v.odometer or v.km or v.mileage) or 0)),
                color = renkAdi,
                plate = tostring(v.plate or "Plakasız")
            })
        end
    end
    
    -- 3. JSON Çevirisi ve Temizlik
    local jsonAd = (adSonuc and #adSonuc > 0) and toJSON(adSonuc) or "[]"
    local jsonVeh = (#temizVehicles > 0) and toJSON(temizVehicles) or "[]"
    
    jsonAd = string.gsub(jsonAd, "[%c\r\n]", "")
    jsonVeh = string.gsub(jsonVeh, "[%c\r\n]", "")
    
    -- Telefona gönder
    triggerClientEvent(oyuncu, "phone:shbReceiveMyAd", oyuncu, jsonAd, jsonVeh)
end)

addEvent("phone:shbPostAd", true)
addEventHandler("phone:shbPostAd", root, function(vehId, title, price, photoData)
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    
    local check = dbPoll(exports.mysql:sorgu("SELECT id FROM phone_sahibinden WHERE char_id = ?", charID), -1)
    if check and #check > 0 then return end
    
    local vData = dbPoll(exports.mysql:sorgu("SELECT * FROM vehicles WHERE id = ?", vehId), -1)
    if vData and #vData > 0 then
        local vehName = getVehicleNameFromModel(tonumber(vData[1].model))
        local km = tostring(vData[1].odometer or vData[1].km or vData[1].mileage or 0)
        
        local cR, cG, cB = vData[1].color_r or 255, vData[1].color_g or 255, vData[1].color_b or 255
        local color = getClosestColorName(cR, cG, cB)
        
        local sellerNum = getElementData(client, "telefon_numarasi") or "Bilinmiyor"
        
        exports.mysql:calistir("INSERT INTO phone_sahibinden (char_id, veh_id, veh_name, km, color, title, price, photo_data, seller_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", charID, vehId, vehName, km, color, title, tonumber(price), photoData or "", sellerNum)
        
        if exports.rp_bildirim then exports.rp_bildirim:goster(client, "success", "Sahibinden", "İlanınız başarıyla yayınlandı!") end
        triggerEvent("phone:shbRequestMyAd", client)
    end
end)

addEvent("phone:shbUpdateAd", true)
addEventHandler("phone:shbUpdateAd", root, function(title, price)
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    exports.mysql:calistir("UPDATE phone_sahibinden SET title = ?, price = ? WHERE char_id = ?", title, tonumber(price), charID)
    if exports.rp_bildirim then exports.rp_bildirim:goster(client, "success", "Sahibinden", "İlan güncellendi.") end
    triggerEvent("phone:shbRequestMyAd", client) -- Güncellemeden sonra ekranı yenile
end)

addEvent("phone:shbDeleteAd", true)
addEventHandler("phone:shbDeleteAd", root, function()
    local charID = tonumber(getElementData(client, "aktifKarakterID"))
    exports.mysql:calistir("DELETE FROM phone_sahibinden WHERE char_id = ?", charID)
    if exports.rp_bildirim then exports.rp_bildirim:goster(client, "success", "Sahibinden", "İlan yayından kaldırıldı.") end
    triggerEvent("phone:shbRequestMyAd", client)
end)



-- HAVA DURUMU MOTORU (Önbellekli, Anında Veri Gönderimi ve JSON Korumalı)
local weatherTable = {
    [0] = {desc = "Güneşli", icon = "☀️", baseTemp = 28, mtaID = 0, summary = "Gün boyu güneşli hava bekleniyor. Sıcaklıklara dikkat."},
    [8] = {desc = "Yağmurlu", icon = "🌧️", baseTemp = 16, mtaID = 8, summary = "İlerleyen saatlerde sağanak yağış bekleniyor. Şemsiyenizi unutmayın."},
    [7] = {desc = "Parçalı Bulutlu", icon = "⛅", baseTemp = 22, mtaID = 7, summary = "Hava genel olarak açık, yer yer bulut geçişleri yaşanabilir."},
}

local gunIsimleri = {"Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"}
local sonHavaDurumu = nil -- Veriyi beklemeden fırlatmak için önbellek

function updateGlobalWeather()
    local realTime = getRealTime()
    local hour = realTime.hour
    local minute = realTime.minute
    local currentDayNum = realTime.weekday + 1
    
    -- ÇÖZÜM: OYUN SAATİNİ GERÇEK SAATE (TELEFONA) EŞİTLE
    setTime(hour, minute)
    
    local w = weatherTable[7]
    if hour >= 8 and hour <= 17 then w = weatherTable[0] end
    if hour > 17 and hour < 22 then w = weatherTable[7] end
    if hour >= 22 or hour < 8 then w = weatherTable[8] end

    setWeather(w.mtaID)
    
    local currentTemp = w.baseTemp + math.random(-1, 2)
    local currentLow = currentTemp - math.random(5, 8)
    local currentHigh = currentTemp + math.random(2, 5)

    local hourly = {}
    for i=1, 6 do
        local nextH = (hour + i - 1) % 24
        local geceMi = (nextH >= 19 or nextH <= 5)
        local iconDurumu = geceMi and "🌙" or w.icon
        local sicaklikDusus = geceMi and -3 or 0
        
        table.insert(hourly, {
            hour = string.format("%02d:00", nextH),
            temp = currentTemp + sicaklikDusus + math.random(-1, 1),
            icon = iconDurumu
        })
    end
    
    local daily = {}
    for i=1, 3 do
        local targetDay = ((currentDayNum + i - 2) % 7) + 1
        local rW = weatherTable[math.random(0,1) == 0 and 0 or 7]
        
        table.insert(daily, {
            day = gunIsimleri[targetDay],
            icon = rW.icon,
            low = rW.baseTemp - math.random(4, 7),
            high = rW.baseTemp + math.random(2, 5)
        })
    end
    
    daily[1].low = currentLow
    daily[1].high = currentHigh

    local temizHourly = string.gsub(toJSON(hourly), "[%c\r\n]", "")
    local temizDaily = string.gsub(toJSON(daily), "[%c\r\n]", "")

    sonHavaDurumu = {
        temp = currentTemp, desc = w.desc, low = currentLow, high = currentHigh,
        summary = w.summary, hourly = temizHourly, daily = temizDaily
    }

    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "aktifKarakterID") then
            triggerClientEvent(p, "phone:updateWeather", p, sonHavaDurumu.temp, sonHavaDurumu.desc, sonHavaDurumu.low, sonHavaDurumu.high, sonHavaDurumu.summary, sonHavaDurumu.hourly, sonHavaDurumu.daily)
        end
    end
end

-- Script başladığı AN ilk veriyi oluşturur ve döngüyü başlatır
addEventHandler("onResourceStart", resourceRoot, function()
    -- Oyun saatinin akış hızını gerçek zamana eşitler (1 dakika = 60000ms)
    setMinuteDuration(60000) 
    updateGlobalWeather()
    setTimer(updateGlobalWeather, 60000, 0)
end)

-- Script başladığı AN ilk veriyi oluşturur ve döngüyü başlatır
addEventHandler("onResourceStart", resourceRoot, function()
    updateGlobalWeather()
    setTimer(updateGlobalWeather, 60000, 0)
end)

-- YENİ EKLENEN KISIM: Telefondan uygulamaya tıklandığında anında veri yollayan event
addEvent("phone:requestWeather", true)
addEventHandler("phone:requestWeather", root, function()
    if sonHavaDurumu then
        triggerClientEvent(client, "phone:updateWeather", client, sonHavaDurumu.temp, sonHavaDurumu.desc, sonHavaDurumu.low, sonHavaDurumu.high, sonHavaDurumu.summary, sonHavaDurumu.hourly, sonHavaDurumu.daily)
    end
end)



-- ==========================================
-- HABERLER SİSTEMİ (TAM VE GÜNCEL VERSİYON)
-- ==========================================

-- 1. Tablo Oluşturma
addEventHandler("onResourceStart", resourceRoot, function()
    exports.mysql:calistir("CREATE TABLE IF NOT EXISTS phone_news (id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255), description TEXT, photo_data LONGTEXT, author VARCHAR(100), post_date DATETIME DEFAULT CURRENT_TIMESTAMP)")
end)

-- 2. Haberleri Görüntüleme ve Uygulama Açılışı (Buton Kontrolü)
addEvent("phone:requestNews", true)
addEventHandler("phone:requestNews", root, function()
    local oyuncu = client or source
    if not isElement(oyuncu) then return end

    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end

    local sorgu = exports.mysql:sorgu("SELECT id, title, description, photo_data, author, DATE_FORMAT(post_date, '%d.%m.%Y %H:%i') as post_date FROM phone_news ORDER BY id DESC")
    local sonuc = dbPoll(sorgu, -1)
    
    -- Geliştirilmiş Birlik Kontrolü
    local isReporter = false
    local dataIsimleri = {"faction", "birlik", "birlik_id", "faction_id", "meslek"}
    
    for _, dataAdi in ipairs(dataIsimleri) do
        local fData = getElementData(oyuncu, dataAdi)
        if type(fData) == "table" and fData[5] then 
            isReporter = true 
            break 
        elseif (type(fData) == "number" or type(fData) == "string") and tonumber(fData) == 5 then 
            isReporter = true 
            break 
        end
    end

    local jsonNews = "[]"
    if sonuc and #sonuc > 0 then
        jsonNews = string.gsub(toJSON(sonuc), "[%c\r\n]", "")
    end

    triggerClientEvent(oyuncu, "phone:receiveNews", oyuncu, jsonNews, isReporter)
end)

-- 3. Haber Paylaşma (Yayınlama Kontrolü)
addEvent("phone:postNews", true)
addEventHandler("phone:postNews", root, function(title, desc, photoData)
    local oyuncu = client
    if not isElement(oyuncu) then return end

    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
    if not charID then return end
    
    -- Geliştirilmiş Birlik Kontrolü
    local isReporter = false
    local dataIsimleri = {"faction", "birlik", "birlik_id", "faction_id", "meslek"}
    
    for _, dataAdi in ipairs(dataIsimleri) do
        local fData = getElementData(oyuncu, dataAdi)
        if type(fData) == "table" and fData[5] then 
            isReporter = true 
            break 
        elseif (type(fData) == "number" or type(fData) == "string") and tonumber(fData) == 5 then 
            isReporter = true 
            break 
        end
    end

    if not isReporter then 
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Hata", "Sadece Haberciler (Faction 5) paylaşım yapabilir.") end
        return 
    end

    -- Karakter İsmini Çekme
    local yazarIsmi = "Bilinmeyen Muhabir"
    local isimSorgu = exports.mysql:sorgu("SELECT character_name FROM characters WHERE id = ?", charID)
    local isimSonuc = dbPoll(isimSorgu, -1)
    if isimSonuc and #isimSonuc > 0 then
        yazarIsmi = string.gsub(isimSonuc[1].character_name, "_", " ")
    end

    -- SQL'e Kaydetme
    exports.mysql:calistir("INSERT INTO phone_news (title, description, photo_data, author) VALUES (?, ?, ?, ?)", title, desc, photoData or "", yazarIsmi)
    
    if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Haberler", "Haber başarıyla yayınlandı!") end
    
    -- Ekranı anında güncelle
    triggerEvent("phone:requestNews", oyuncu)
end)