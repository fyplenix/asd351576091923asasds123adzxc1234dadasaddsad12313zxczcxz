-- server.lua

local galeriX, galeriY, galeriZ = 2131.7, -1150.5, 24.1 

local harfler = {"A","B","C","D","E","F","G","H","J","K","L","M","N","P","R","S","T","U","V","Y","Z"}
function plakaUret()
    local harf1 = harfler[math.random(1, #harfler)]
    local harf2 = harfler[math.random(1, #harfler)]
    local sayi = math.random(100, 999)
    return "34 " .. harf1 .. harf2 .. " " .. sayi
end

addEventHandler("onResourceStart", resourceRoot, function()
    -- ==========================================
    -- ÇÖZÜM: YÖN (ROTASYON) SÜTUNLARINI OTOMATİK EKLE
    -- (Eğer tabloda yoksa ekler, varsa hata vermeden devam eder)
    -- ==========================================
    --exports.mysql:calistir("ALTER TABLE vehicles ADD COLUMN rx FLOAT DEFAULT 0")
    --exports.mysql:calistir("ALTER TABLE vehicles ADD COLUMN ry FLOAT DEFAULT 0")
    --exports.mysql:calistir("ALTER TABLE vehicles ADD COLUMN rz FLOAT DEFAULT 0")

    local galeriNPC = createPed(147, galeriX, galeriY, galeriZ, 180)
    setElementFrozen(galeriNPC, true)
    addEventHandler("onElementDamage", galeriNPC, cancelEvent) 

    local galeriMarker = createMarker(galeriX, galeriY, galeriZ - 1, "cylinder", 1.5, 0, 150, 255, 100)
    
    addEventHandler("onMarkerHit", galeriMarker, function(hitElement, matchingDimension)
        if matchingDimension and getElementType(hitElement) == "player" and not isPedInVehicle(hitElement) then
            local charID = getElementData(hitElement, "aktifKarakterID")
            if not charID then return end
            
            local dcSorgu = exports.mysql:sorgu("SELECT donate_cash FROM characters WHERE id = ?", charID)
            local dcSonuc = dbPoll(dcSorgu, -1) 
            local dcBakiye = 0
            
            if dcSonuc and #dcSonuc > 0 then
                dcBakiye = tonumber(dcSonuc[1].donate_cash) or 0
            end
            
            triggerClientEvent(hitElement, "galeri:paneliAc", root, dcBakiye)
        end
    end)
end)

addEvent("arac:satinAl", true)
addEventHandler("arac:satinAl", resourceRoot, function(modelID, fiyat, r, g, b, ozelPlaka)
    local oyuncu = client
    local charID = getElementData(oyuncu, "aktifKarakterID")
    if not charID then return end
    
    modelID = tonumber(modelID)
    fiyat = tonumber(fiyat) or 0
    r = tonumber(r) or 255
    g = tonumber(g) or 255
    b = tonumber(b) or 255
    
    local ceptekiPara = getPlayerMoney(oyuncu)
    local ozelPlakaBedeli = 500
    
    local dcSorgu = exports.mysql:sorgu("SELECT donate_cash FROM characters WHERE id = ?", charID)
    local dcSonuc = dbPoll(dcSorgu, -1)
    local dcBakiye = 0
    if dcSonuc and #dcSonuc > 0 then
        dcBakiye = tonumber(dcSonuc[1].donate_cash) or 0
    end
    
    if ceptekiPara < fiyat then
        outputChatBox("[Galeri] Üzerinizde araç için yeterli nakit (Cash) bulunmuyor!", oyuncu, 255, 0, 0)
        return
    end
    
    local plakaUygulanacak = ""
    local dcKullanildi = false
    
    if ozelPlaka and ozelPlaka ~= "" then
        if dcBakiye < ozelPlakaBedeli then
            outputChatBox("[Galeri] Özel plaka için yeterli Donate Cash (DC) bakiyeniz yok!", oyuncu, 255, 0, 0)
            return
        end
        
        local plakaKontrolSorgu = exports.mysql:sorgu("SELECT id FROM vehicles WHERE plate = ?", ozelPlaka)
        local plakaKontrolSonuc = dbPoll(plakaKontrolSorgu, -1)
        
        if plakaKontrolSonuc and #plakaKontrolSonuc > 0 then
            outputChatBox("[Galeri] Maalesef '" .. ozelPlaka .. "' plakası başka bir araçta kullanılıyor!", oyuncu, 255, 0, 0)
            return
        end
        
        plakaUygulanacak = ozelPlaka
        dcKullanildi = true
    else
        local benzersiz = false
        local uretilenPlaka = ""
        
        while not benzersiz do
            uretilenPlaka = plakaUret()
            local rastgeleSorgu = exports.mysql:sorgu("SELECT id FROM vehicles WHERE plate = ?", uretilenPlaka)
            local rastgeleSonuc = dbPoll(rastgeleSorgu, -1)
            
            if not rastgeleSonuc or #rastgeleSonuc == 0 then
                benzersiz = true 
            end
        end
        plakaUygulanacak = uretilenPlaka
    end
    
    takePlayerMoney(oyuncu, fiyat)
    
    if dcKullanildi then
        exports.mysql:calistir("UPDATE characters SET cash = cash - ?, donate_cash = donate_cash - ? WHERE id = ?", fiyat, ozelPlakaBedeli, charID)
        outputChatBox("[Galeri] Özel plaka bedeli olarak hesabınızdan " .. ozelPlakaBedeli .. " DC kesildi.", oyuncu, 255, 159, 67)
    else
        exports.mysql:calistir("UPDATE characters SET cash = cash - ? WHERE id = ?", fiyat, charID)
    end
    
    local spawnX, spawnY, spawnZ = 2131.5, -1134.5, 24.5
    
    -- ÇÖZÜM: Yeni aracı eklerken rotasyon (rx, ry, rz) değerlerini de 0 olarak başlatıyoruz
    local ekle = exports.mysql:calistir("INSERT INTO vehicles (owner_id, model, x, y, z, rx, ry, rz, color_r, color_g, color_b, plate) VALUES (?, ?, ?, ?, ?, 0, 0, 90, ?, ?, ?, ?)", charID, modelID, spawnX, spawnY, spawnZ + 0.5, r, g, b, plakaUygulanacak)
    
    if ekle then
        local arac = createVehicle(modelID, spawnX, spawnY, spawnZ + 0.5)
        setElementRotation(arac, 0, 0, 90) -- Galeride yola doğru baksın
        setVehicleColor(arac, r, g, b)
        setVehiclePlateText(arac, plakaUygulanacak)
        setVehicleLocked(arac, true)
        setVehicleEngineState(arac, false)
        
        local idSorgu = exports.mysql:sorgu("SELECT id FROM vehicles WHERE plate = ?", plakaUygulanacak)
        local idSonuc = dbPoll(idSorgu, -1)
        if idSonuc and #idSonuc > 0 then
            local yeniID = tonumber(idSonuc[1].id)
            setElementData(arac, "id", yeniID)
            setElementData(arac, "dbid", yeniID)
        end

        setElementData(arac, "arac:sahibi", charID)
        setElementData(arac, "arac:plaka", plakaUygulanacak)
        setElementData(arac, "modifications", "{}") 
        
        exports.mysql:calistir("INSERT INTO character_items (character_id, item_id, quantity, metadata) VALUES (?, 'arac_anahtari', 1, ?)", charID, plakaUygulanacak)
        
        outputChatBox("[Galeri] Başarıyla aracı satın aldınız! Plakanız: " .. plakaUygulanacak, oyuncu, 0, 255, 0)
        outputChatBox("[Galeri] Aracınız galerinin önüne park edildi ve anahtarı sırt çantanıza eklendi.", oyuncu, 255, 255, 0)
        
        triggerClientEvent(oyuncu, "galeri:paneliKapat", resourceRoot)
    end
end)

addEvent("arac:motorKontrol", true)
addEventHandler("arac:motorKontrol", resourceRoot, function()
    local oyuncu = client
    local charID = getElementData(oyuncu, "aktifKarakterID")
    local arac = getPedOccupiedVehicle(oyuncu)
    
    if arac and getVehicleController(arac) == oyuncu then
        local plaka = getElementData(arac, "arac:plaka")
        if not plaka then return end
        
        -- YENİ EKLENTİ: Araç Bozuk mu Kontrolü (Canı 300 veya altındaysa çalışmaz)
        if getElementHealth(arac) <= 300 or getElementData(arac, "arac:bozuk") then
            outputChatBox("[Araç] Araç ağır hasarlı, motor çalıştırılamıyor! (Çekici/Tamirci çağırın)", oyuncu, 255, 0, 0)
            return
        end
        
        local sorgu = exports.mysql:sorgu("SELECT id FROM character_items WHERE character_id = ? AND item_id = 'arac_anahtari' AND metadata = ?", charID, plaka)
        local sonuc = dbPoll(sorgu, -1)
        
        if sonuc and #sonuc > 0 then
            local motorDurumu = getVehicleEngineState(arac)
            setVehicleEngineState(arac, not motorDurumu)
            
            if not motorDurumu then
                outputChatBox("[Araç] Motor çalıştırıldı.", oyuncu, 0, 255, 0)
            else
                outputChatBox("[Araç] Motor durduruldu.", oyuncu, 255, 255, 0)
            end
        else
            outputChatBox("[Araç] Bu aracın anahtarı sizde değil!", oyuncu, 255, 0, 0)
        end
    end
end)

addEvent("arac:kilitKontrol", true)
addEventHandler("arac:kilitKontrol", resourceRoot, function()
    local oyuncu = client
    local charID = getElementData(oyuncu, "aktifKarakterID")
    
    local sorgu = exports.mysql:sorgu("SELECT metadata FROM character_items WHERE character_id = ? AND item_id = 'arac_anahtari'", charID)
    local anahtarlar = dbPoll(sorgu, -1)
    
    if not anahtarlar or #anahtarlar == 0 then
        outputChatBox("[Araç] Üzerinizde hiçbir araç anahtarı yok.", oyuncu, 255, 0, 0)
        return
    end

    local yakinArac = nil
    local icindekiArac = getPedOccupiedVehicle(oyuncu)
    
    if icindekiArac then
        yakinArac = icindekiArac
    else
        local x, y, z = getElementPosition(oyuncu)
        for i, arac in ipairs(getElementsByType("vehicle")) do
            local ax, ay, az = getElementPosition(arac)
            if getDistanceBetweenPoints3D(x, y, z, ax, ay, az) < 5 then
                yakinArac = arac
                break
            end
        end
    end
    
    if yakinArac then
        local aracPlaka = getElementData(yakinArac, "arac:plaka")
        local anahtarVarMi = false
        
        for k, v in ipairs(anahtarlar) do
            if v.metadata == aracPlaka then
                anahtarVarMi = true
                break
            end
        end
        
        if anahtarVarMi then
            local kilitDurumu = isVehicleLocked(yakinArac)
            local yeniKilitDurumu = not kilitDurumu 
            
            setVehicleLocked(yakinArac, yeniKilitDurumu)
            
            -- SADECE OYUNCU DIŞARIDAYSA EFEKTLER ÇALIŞSIN
            if not icindekiArac then
                local modelID = getElementModel(yakinArac)
                local mevcutDortlu = getElementData(yakinArac, "emergency_light") or false
                
                -- 404 (Audi RS7) VE 527 (BMW M4 F82) İÇİN ÖZEL ANİMASYON + SİNYAL EFEKTİ
                if modelID == 404 or modelID == 527 then
                    setElementData(yakinArac, "emergency_light", true) -- Sinyalleri yak
                    
                    if yeniKilitDurumu then
                        triggerClientEvent(root, "arac:ozelAnimasyonTetikle", root, yakinArac, "anim_off")
                        
                        -- 1.5 saniye sonra sinyali kapatıp farları söndür
                        setTimer(function(arac, eskiDortlu)
                            if isElement(arac) then
                                setElementData(arac, "emergency_light", eskiDortlu)
                                setElementData(arac, "lights", 0) 
                            end
                        end, 1500, 1, yakinArac, mevcutDortlu)
                    else
                        triggerClientEvent(root, "arac:ozelAnimasyonTetikle", root, yakinArac, "anim_on")
                        
                        -- 1.5 saniye sonra sinyali kapatıp farları açık bırak
                        setTimer(function(arac, eskiDortlu)
                            if isElement(arac) then
                                setElementData(arac, "emergency_light", eskiDortlu)
                                setElementData(arac, "lights", 1)
                            end
                        end, 1500, 1, yakinArac, mevcutDortlu)
                    end
                else
                    -- DİĞER TÜM ARAÇLAR İÇİN STANDART DÖRTLÜ VE FAR SİSTEMİ
                    setElementData(yakinArac, "emergency_light", true)
                    
                    setTimer(function(arac, eskiDortlu, kilitliMi)
                        if isElement(arac) then
                            setElementData(arac, "emergency_light", eskiDortlu)
                            
                            if kilitliMi then
                                setElementData(arac, "lights", 0) 
                            else
                                setElementData(arac, "lights", 1) 
                            end
                        end
                    end, 1500, 1, yakinArac, mevcutDortlu, yeniKilitDurumu)
                end
            end
            
            if yeniKilitDurumu then
                outputChatBox("[Araç] Araç kilitlendi.", oyuncu, 255, 0, 0)
            else
                outputChatBox("[Araç] Araç kilidi açıldı.", oyuncu, 0, 255, 0)
            end
        else
            outputChatBox("[Araç] Bu aracın anahtarı sizde değil!", oyuncu, 255, 0, 0)
        end
    else
        outputChatBox("[Araç] Yakınınızda aracınız bulunamadı.", oyuncu, 255, 0, 0)
    end
end)


-- ==========================================
-- KONUM KAYDETME SİSTEMİ (PARK ETME)
-- ==========================================
addEventHandler("onVehicleExit", root, function(oyuncu, koltuk)
    local aracID = getElementData(source, "id")
    if aracID then
        local x, y, z = getElementPosition(source)
        local rx, ry, rz = getElementRotation(source)
        exports.mysql:calistir("UPDATE vehicles SET x=?, y=?, z=?, rx=?, ry=?, rz=? WHERE id=?", x, y, z, rx, ry, rz, aracID)
    end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for i, arac in ipairs(getElementsByType("vehicle")) do
        local yolcular = getVehicleOccupants(arac)
        if yolcular then
            for koltuk, yolcu in pairs(yolcular) do
                removePedFromVehicle(yolcu) 
                setElementDimension(yolcu, 0) 
            end
        end

        local aracID = getElementData(arac, "id")
        if aracID then
            local x, y, z = getElementPosition(arac)
            local rx, ry, rz = getElementRotation(arac)
            exports.mysql:calistir("UPDATE vehicles SET x=?, y=?, z=?, rx=?, ry=?, rz=? WHERE id=?", x, y, z, rx, ry, rz, aracID)
        end
    end
end)


-- ==========================================
-- ARAÇLARI VERİTABANINDAN HARİTAYA DİZME MOTORU
-- ==========================================
addEventHandler("onResourceStart", resourceRoot, function()
    local sorgu = exports.mysql:sorgu("SELECT * FROM vehicles")
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        local yuklenenAracSayisi = 0
        
        for i, veri in ipairs(sonuc) do
            local vID = tonumber(veri.id)
            local model = tonumber(veri.model)
            
            local x, y, z = tonumber(veri.x), tonumber(veri.y), tonumber(veri.z)
            local rx = tonumber(veri.rx) or 0
            local ry = tonumber(veri.ry) or 0
            local rz = tonumber(veri.rz) or 0
            
            local r, g, b = tonumber(veri.color_r), tonumber(veri.color_g), tonumber(veri.color_b)
            local plaka = tostring(veri.plate)
            local sahip = tonumber(veri.owner_id)
            local yakit = tonumber(veri.fuel) or 100
            local km = tonumber(veri.km) or 0
            
            local modifiyeler = tostring(veri.modifications) or "{}"
            if modifiyeler == "nil" or modifiyeler == "" then modifiyeler = "{}" end
            
            local factionID = tonumber(veri.faction_vehid) or 0
            
            if model and x and y and z then
                local arac = createVehicle(model, x, y, z + 0.5, rx, ry, rz)
                
                setVehicleColor(arac, r, g, b)
                setVehiclePlateText(arac, plaka)
                setVehicleEngineState(arac, false) 
                setVehicleLocked(arac, true) 
                
                setElementData(arac, "id", vID)
                setElementData(arac, "dbid", vID)
                setElementData(arac, "arac:sahibi", sahip)
                setElementData(arac, "arac:plaka", plaka)
                setElementData(arac, "arac:faction", factionID)
                setElementData(arac, "fuel", yakit)
                setElementData(arac, "km", km)
                
                setElementData(arac, "modifications", modifiyeler)
                
                yuklenenAracSayisi = yuklenenAracSayisi + 1
            end
        end
        outputDebugString("[RP_VEHICLES] Başarıyla " .. yuklenenAracSayisi .. " adet araç veritabanından haritaya yüklendi!")
    else
        outputDebugString("[RP_VEHICLES] Veritabanında yüklenecek araç bulunamadı.")
    end
end)


-- ====================================================================
-- ENVANTERDEKİ KASADAN GELEN ARACI OLUŞTURMA FONKSİYONU
-- ====================================================================
addEvent("arac:kasaHediyesiVer", true)
addEventHandler("arac:kasaHediyesiVer", root, function(oyuncu, modelID)
    local charID = getElementData(oyuncu, "aktifKarakterID")
    if not charID then return end
    
    local uretilenPlaka = ""
    local benzersiz = false
    while not benzersiz do
        uretilenPlaka = plakaUret()
        local rSorgu = exports.mysql:sorgu("SELECT id FROM vehicles WHERE plate = ?", uretilenPlaka)
        local rSonuc = dbPoll(rSorgu, -1)
        if not rSonuc or #rSonuc == 0 then benzersiz = true end
    end
    
    local spawnX, spawnY, spawnZ = 0, 0, 0 
    
    local ekle = exports.mysql:calistir("INSERT INTO vehicles (owner_id, model, otopark, x, y, z, rx, ry, rz, color_r, color_g, color_b, plate) VALUES (?, ?, 1, ?, ?, ?, 0, 0, 90, 255, 255, 255, ?)", charID, modelID, spawnX, spawnY, spawnZ, uretilenPlaka)
    
    if ekle then
        exports.mysql:calistir("INSERT INTO character_items (character_id, item_id, quantity, metadata) VALUES (?, 'arac_anahtari', 1, ?)", charID, uretilenPlaka)
        outputChatBox("[Kasa] TEBRİKLER! Kasadan çıkan lüks aracınız doğrudan Otoparka (Garaj) gönderildi.", oyuncu, 0, 255, 0)
        outputChatBox("[Kasa] Anahtarı envanterinize (I) eklendi. Otoparktan aracınızı çıkartabilirsiniz.", oyuncu, 255, 255, 0)
    end
end)


-- ==========================================
-- ARAÇ HASAR, PATLAMA ENGELLEME VE DÖRTLÜ SİSTEMİ (GÜNCELLENDİ)
-- ==========================================

-- 1. KESİN ÇÖZÜM: Araç patlamasını sunucu genelinde kökünden yasaklar
addEventHandler("onVehicleExplode", root, function()
    cancelEvent() -- Patlamayı engeller
    fixVehicle(source) -- Siyah yanmış araba modeline dönüşmesini iptal eder ve ateşi söndürür
    setElementHealth(source, 300) -- Canı patlama noktasından siyah duman seviyesine geri sabitler
    
    if not getElementData(source, "arac:bozuk") then
        setElementData(source, "arac:bozuk", true)
        setElementData(source, "emergency_light", true)
        setVehicleEngineState(source, false)
        setVehicleDamageProof(source, true) 
        
        triggerClientEvent(root, "arac:dortluZorla", root, source, true)
        
        local surucu = getVehicleController(source)
        if surucu then
            outputChatBox("[Araç] Aracınız ağır hasar aldı ve motor kendini kilitledi!", surucu, 255, 0, 0)
        end
    end
end)

-- 2. Çarpışma, kurşun ve takla atma durumları
addEventHandler("onVehicleDamage", root, function(loss)
    local can = getElementHealth(source)
    
    -- Eğer alınacak hasar canı 300'ün altına düşürecekse (Alev alma riskini ortadan kaldır)
    if (can - loss) <= 300 then
        cancelEvent() -- Hasarı reddet
        
        if not getElementData(source, "arac:bozuk") then
            -- GTA motoru bazen takla atmalarda canı hızlı sömürür, eğer ateş aldıysa (250 altı) söndür
            if can - loss < 250 then
                fixVehicle(source)
            end
            
            setElementHealth(source, 300)
            setVehicleEngineState(source, false)
            setElementData(source, "arac:bozuk", true)
            setElementData(source, "emergency_light", true) 
            setVehicleDamageProof(source, true) 
            
            triggerClientEvent(root, "arac:dortluZorla", root, source, true)
            
            local surucu = getVehicleController(source)
            if surucu then
                outputChatBox("[Araç] Aracınız ağır hasar aldı ve motor kendini kilitledi!", surucu, 255, 0, 0)
            end
        end
    end
end)

-- 3. VERİ KİLİDİ: Oyuncu dörtlüyü kapatmaya çalışırsa anında geri açma sistemi
addEventHandler("onElementDataChange", root, function(dataName, oldValue)
    if getElementType(source) == "vehicle" and dataName == "emergency_light" then
        local yeniDurum = getElementData(source, "emergency_light")
        if getElementData(source, "arac:bozuk") and not yeniDurum then
            setElementData(source, "emergency_light", true)
            triggerClientEvent(root, "arac:dortluZorla", root, source, true)
        end
    end
end)

-- 4. Tamir kontrolü ve ekstra güvenlik döngüsü
setTimer(function()
    for i, arac in ipairs(getElementsByType("vehicle")) do
        if getElementData(arac, "arac:bozuk") then
            local can = getElementHealth(arac)
            
            -- Eğer mekanik aracı tamir ettiyse (Can 300'ün üstüne çıktıysa)
            if can > 300 then
                setElementData(arac, "arac:bozuk", false)
                setElementData(arac, "emergency_light", false) 
                setVehicleDamageProof(arac, false) 
                triggerClientEvent(root, "arac:dortluZorla", root, arac, false)
            else
                -- GTA inatla aracı yakmaya çalışıyorsa koruma kalkanı:
                if can < 250 then
                    fixVehicle(arac) -- Ateş varsa söndür
                    setElementHealth(arac, 300)
                elseif can < 300 then
                    setElementHealth(arac, 300)
                end
                
                setVehicleEngineState(arac, false)
            end
        end
    end
end, 1000, 0)