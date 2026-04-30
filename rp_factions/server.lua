local factionChats = {} 

local factionGarages = {
    [1] = { x = 1558.2763671875, y = -1610.4150390625, z = 13.3828125 }, -- LSPD
    [2] = { x = 1179.5166015625, y = -1308.76171875, z = 13.724889755249 }, -- LSMD
}

local factionDuties = {
    [1] = {"Bekçi", "Polis Memuru", "Trafik Polisi", "Komiser", "Emniyet Müdürü"},
    [2] = {"Stajyer Doktor", "İlk Yardım Görevlisi", "Uzman Doktor", "Cerrah", "Başhekim"},
}

local aracCikaranlar = {} 

addEventHandler("onResourceStart", resourceRoot, function()
    exports.mysql:calistir("DROP TABLE IF EXISTS faction_ranks")
    exports.mysql:calistir("DROP TABLE IF EXISTS faction_settings")
    
    local check = exports.mysql:sorgu("SHOW COLUMNS FROM factions LIKE 'r1_name'")
    local res = dbPoll(check, -1)
    if res and #res == 0 then
        exports.mysql:calistir("ALTER TABLE factions ADD COLUMN motd TEXT DEFAULT 'Birliğe hoş geldiniz!', ADD COLUMN r1_name VARCHAR(50) DEFAULT 'Rütbe 1', ADD COLUMN r1_sal INT DEFAULT 0, ADD COLUMN r2_name VARCHAR(50) DEFAULT 'Rütbe 2', ADD COLUMN r2_sal INT DEFAULT 0, ADD COLUMN r3_name VARCHAR(50) DEFAULT 'Rütbe 3', ADD COLUMN r3_sal INT DEFAULT 0, ADD COLUMN r4_name VARCHAR(50) DEFAULT 'Rütbe 4', ADD COLUMN r4_sal INT DEFAULT 0, ADD COLUMN r5_name VARCHAR(50) DEFAULT 'Rütbe 5', ADD COLUMN r5_sal INT DEFAULT 0, ADD COLUMN r6_name VARCHAR(50) DEFAULT 'Rütbe 6', ADD COLUMN r6_sal INT DEFAULT 0, ADD COLUMN r7_name VARCHAR(50) DEFAULT 'Rütbe 7', ADD COLUMN r7_sal INT DEFAULT 0, ADD COLUMN r8_name VARCHAR(50) DEFAULT 'Rütbe 8', ADD COLUMN r8_sal INT DEFAULT 0, ADD COLUMN r9_name VARCHAR(50) DEFAULT 'Rütbe 9', ADD COLUMN r9_sal INT DEFAULT 0, ADD COLUMN r10_name VARCHAR(50) DEFAULT 'Rütbe 10', ADD COLUMN r10_sal INT DEFAULT 0")
    end

    local checkVeh = exports.mysql:sorgu("SHOW COLUMNS FROM vehicles LIKE 'faction_vehid'")
    local resVeh = dbPoll(checkVeh, -1)
    if resVeh and #resVeh == 0 then exports.mysql:calistir("ALTER TABLE vehicles ADD COLUMN faction_vehid INT DEFAULT 0") end

    local checkVehRank = exports.mysql:sorgu("SHOW COLUMNS FROM vehicles LIKE 'faction_rank'")
    local resVehRank = dbPoll(checkVehRank, -1)
    if resVehRank and #resVehRank == 0 then exports.mysql:calistir("ALTER TABLE vehicles ADD COLUMN faction_rank INT DEFAULT 1") end

    local checkVehOtopark = exports.mysql:sorgu("SHOW COLUMNS FROM vehicles LIKE 'faction_otopark'")
    local resVehOtopark = dbPoll(checkVehOtopark, -1)
    if resVehOtopark and #resVehOtopark == 0 then exports.mysql:calistir("ALTER TABLE vehicles ADD COLUMN faction_otopark INT DEFAULT 0") end

    local checkDuty = exports.mysql:sorgu("SHOW COLUMNS FROM characters LIKE 'faction_duty'")
    local resDuty = dbPoll(checkDuty, -1)
    if resDuty and #resDuty == 0 then exports.mysql:calistir("ALTER TABLE characters ADD COLUMN faction_duty INT DEFAULT 0") end

    for fid, k in pairs(factionGarages) do
        local marker = createMarker(k.x, k.y, k.z - 1, "cylinder", 3.5, 52, 152, 219, 100)
        setElementData(marker, "faction_garage", fid)
    end
end)

addEventHandler("onVehicleEnter", root, function(oyuncu, seat)
    if seat ~= 0 then return end 
    local dbid = tonumber(getElementData(source, "dbid")) or tonumber(getElementData(source, "id"))
    if dbid then
        local s = exports.mysql:sorgu("SELECT faction_vehid FROM vehicles WHERE id = ?", dbid)
        local d = dbPoll(s, -1)
        if d and #d > 0 then
            local fID = tonumber(d[1].faction_vehid) or 0
            if fID > 0 then
                local charID = tonumber(getElementData(oyuncu, "aktifKarakterID"))
                if not charID then return end
                local cs = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", charID)
                local cd = dbPoll(cs, -1)
                if not cd or #cd == 0 then return end
                local pFaction = tonumber(cd[1].faction_id) or 0
                local pRank = tonumber(cd[1].faction_rank) or 0
                setElementData(oyuncu, "faction_id", pFaction)
                setElementData(oyuncu, "faction_rank", pRank)
                if pFaction ~= fID then
                    removePedFromVehicle(oyuncu)
                    outputChatBox("[Hata] Bu araç departmana aittir, siviller kullanamaz!", oyuncu, 255, 0, 0)
                end
            end
        end
    end
end)

addEventHandler("onMarkerHit", resourceRoot, function(hitElement, matchingDimension)
    if not matchingDimension then return end
    local fID = getElementData(source, "faction_garage")
    if not fID then return end
    local oyuncu = false
    if getElementType(hitElement) == "player" then oyuncu = hitElement
    elseif getElementType(hitElement) == "vehicle" then oyuncu = getVehicleOccupant(hitElement, 0) end
    if oyuncu then
        local charID = getElementData(oyuncu, "aktifKarakterID")
        if charID then
            local s = exports.mysql:sorgu("SELECT faction_id FROM characters WHERE id = ?", charID)
            local d = dbPoll(s, -1)
            if d and #d > 0 and tonumber(d[1].faction_id) == fID then
                garajBilgileriniGonder(oyuncu, fID)
            end
        end
    end
end)

function garajBilgileriniGonder(oyuncu, fID)
    local aracSorgu = exports.mysql:sorgu("SELECT id, model, plate, faction_otopark FROM vehicles WHERE faction_vehid = ?", fID)
    local bAraclar = dbPoll(aracSorgu, -1) or {}
    local liste = {}
    for _, arac in ipairs(bAraclar) do
        local vID = tonumber(arac.id)
        local durum = tonumber(arac.faction_otopark) == 1 and "Garajda" or "Dışarıda"
        for _, obj in ipairs(getElementsByType("vehicle")) do
            if tonumber(getElementData(obj, "dbid")) == vID or tonumber(getElementData(obj, "id")) == vID then
                if getElementDimension(obj) == 50 then durum = "Garajda" 
                elseif tonumber(arac.faction_otopark) == 0 and getElementDimension(obj) == 0 then durum = "Dışarıda" end
                break
            end
        end
        table.insert(liste, { id = vID, model = getVehicleNameFromModel(tonumber(arac.model)) or "Araç", plate = arac.plate or "PLAKASIZ", durum = durum })
    end
    triggerClientEvent(oyuncu, "garaj:paneliAc", resourceRoot, liste, fID)
end

addEvent("garaj:islemYap", true)
addEventHandler("garaj:islemYap", resourceRoot, function(islem, fID, vehID)
    local oyuncu = client
    local gx, gy, gz = factionGarages[fID].x, factionGarages[fID].y, factionGarages[fID].z
    local charID = tonumber(getElementData(oyuncu, "aktifKarakterID")) 
    
    if islem == "park" then
        local binenArac = getPedOccupiedVehicle(oyuncu)
        if not binenArac then outputChatBox("[Hata] Park etmek için birliğinize ait bir aracın içinde olmalısınız!", oyuncu, 255, 0, 0) return end
        local vID = tonumber(getElementData(binenArac, "dbid")) or tonumber(getElementData(binenArac, "id"))
        local s = exports.mysql:sorgu("SELECT id FROM vehicles WHERE id = ? AND faction_vehid = ?", vID, fID)
        local d = dbPoll(s, -1)
        if not d or #d == 0 then outputChatBox("[Hata] Bu araç birliğinize ait değil!", oyuncu, 255, 0, 0) return end
        
        for seat, occupant in pairs(getVehicleOccupants(binenArac)) do removePedFromVehicle(occupant) setElementPosition(occupant, gx, gy, gz) end
        setElementDimension(binenArac, 50)
        setElementFrozen(binenArac, true)
        
        aracCikaranlar[vID] = nil 
        exports.mysql:calistir("UPDATE vehicles SET faction_otopark = 1 WHERE id = ?", vID)
        outputChatBox("[Garaj] Araç başarıyla garaja (Boyut 50) park edildi.", oyuncu, 0, 255, 0)
        garajBilgileriniGonder(oyuncu, fID)
        
    elseif islem == "cikar" then
        if not vehID then return end
        local cs = exports.mysql:sorgu("SELECT faction_rank FROM characters WHERE id = ?", charID)
        local cd = dbPoll(cs, -1)
        local pRank = (cd and #cd > 0) and tonumber(cd[1].faction_rank) or 0
        local aSorgu = exports.mysql:sorgu("SELECT faction_rank, model, plate, faction_otopark FROM vehicles WHERE id = ? AND faction_vehid = ?", vehID, fID)
        local aData = dbPoll(aSorgu, -1)
        if not aData or #aData == 0 then return end
        local reqRank = tonumber(aData[1].faction_rank) or 1
        
        if pRank ~= reqRank then
            outputChatBox("[Hata] Bu aracı SADECE Rütbe " .. reqRank .. " personelleri garajdan çıkartabilir!", oyuncu, 255, 0, 0)
            return
        end
        
        local aracBulundu = false
        for _, obj in ipairs(getElementsByType("vehicle")) do
            if tonumber(getElementData(obj, "dbid")) == vehID or tonumber(getElementData(obj, "id")) == vehID then aracBulundu = obj break end
        end
        
        if aracBulundu then
            setElementDimension(aracBulundu, 0)
            setElementPosition(aracBulundu, gx, gy, gz + 1)
            setElementFrozen(aracBulundu, false)
            warpPedIntoVehicle(oyuncu, aracBulundu)
            aracCikaranlar[vehID] = charID
            exports.mysql:calistir("UPDATE vehicles SET faction_otopark = 0 WHERE id = ?", vehID)
            outputChatBox("[Garaj] Aracınız garajdan çıkartıldı.", oyuncu, 0, 255, 0)
        else
            local yeniArac = createVehicle(tonumber(aData[1].model), gx, gy, gz + 1)
            setElementData(yeniArac, "dbid", vehID)
            setElementData(yeniArac, "faction", fID)
            if aData[1].plate then setVehiclePlateText(yeniArac, aData[1].plate) end
            warpPedIntoVehicle(oyuncu, yeniArac)
            aracCikaranlar[vehID] = charID
            exports.mysql:calistir("UPDATE vehicles SET faction_otopark = 0 WHERE id = ?", vehID)
            outputChatBox("[Garaj] Aracınız garajdan çıkartıldı.", oyuncu, 0, 255, 0)
        end
        garajBilgileriniGonder(oyuncu, fID)
    end
end)

setTimer(function()
    for _, oyuncu in ipairs(getElementsByType("player")) do
        local charID = getElementData(oyuncu, "aktifKarakterID")
        if charID then
            local s = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", charID)
            local d = dbPoll(s, -1)
            if d and #d > 0 and tonumber(d[1].faction_id) > 0 then
                local fID, fRank = tonumber(d[1].faction_id), tonumber(d[1].faction_rank)
                local bs = exports.mysql:sorgu("SELECT * FROM factions WHERE id = ?", fID)
                local bd = dbPoll(bs, -1)
                if bd and #bd > 0 then
                    local maas = tonumber(bd[1]["r"..fRank.."_sal"]) or 0
                    if maas > 0 then
                        exports.mysql:calistir("UPDATE characters SET bank_balance = bank_balance + ? WHERE id = ?", maas, charID)
                        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Maaş Yattı", "Birlik maaşınız: $"..maas) end
                    end
                end
            end
        end
    end
end, 3600000, 0) 

-- YENİ: KESİN SENKRONİZASYON (Hem Duty Hem Faction ID)
setTimer(function()
    for _, p in ipairs(getElementsByType("player")) do
        local charID = tonumber(getElementData(p, "aktifKarakterID"))
        if charID then
            local s = exports.mysql:sorgu("SELECT faction_id, faction_duty FROM characters WHERE id = ?", charID)
            local d = dbPoll(s, -1)
            if d and #d > 0 then
                local sqlDuty = tonumber(d[1].faction_duty) or 0
                local sqlFaction = tonumber(d[1].faction_id) or 0
                
                if tonumber(getElementData(p, "faction_duty")) ~= sqlDuty then 
                    setElementData(p, "faction_duty", sqlDuty) 
                end
                if tonumber(getElementData(p, "faction_id")) ~= sqlFaction then 
                    setElementData(p, "faction_id", sqlFaction) 
                end
            end
        end
    end
end, 3000, 0) -- Hızlı bulsun diye 3 saniyeye düşürdüm

addEvent("f3:panelIstek", true)
addEventHandler("f3:panelIstek", resourceRoot, function()
    local oyuncu = client or source
    local charID = getElementData(oyuncu, "aktifKarakterID")
    if not charID then return end

    local s = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", charID)
    local d = dbPoll(s, -1)
    if not d or #d == 0 or tonumber(d[1].faction_id) == 0 then outputChatBox("[Sistem] Herhangi bir birliğe üye değilsiniz.", oyuncu, 255, 0, 0) return end

    local fID, fRank = tonumber(d[1].faction_id), tonumber(d[1].faction_rank)
    local bs = exports.mysql:sorgu("SELECT * FROM factions WHERE id = ?", fID)
    local bd = dbPoll(bs, -1)
    if not bd or #bd == 0 then return end
    
    local fData = bd[1]
    local motd = fData.motd or "Birliğe hoş geldiniz!"
    local ranksData = {}
    for i=1, 10 do table.insert(ranksData, { name = fData["r"..i.."_name"] or "Rütbe "..i, salary = tonumber(fData["r"..i.."_sal"]) or 0 }) end
    
    if not factionChats[fID] then factionChats[fID] = {} end
    
    local uyeSorgu = exports.mysql:sorgu("SELECT id, character_name, faction_rank, faction_duty FROM characters WHERE faction_id = ? ORDER BY faction_rank DESC", fID)
    local uyeler = dbPoll(uyeSorgu, -1) or {}
    
    local temizUyeler = {}
    for _, uye in ipairs(uyeler) do
        local isOnline = false
        for _, py in ipairs(getElementsByType("player")) do
            if getElementData(py, "aktifKarakterID") == tonumber(uye.id) then isOnline = true break end
        end
        local rID = tonumber(uye.faction_rank)
        table.insert(temizUyeler, { 
            charID = tonumber(uye.id), 
            name = string.gsub(uye.character_name, "_", " "), 
            rank = rID, 
            rankName = ranksData[rID] and ranksData[rID].name or "Rütbe "..rID, 
            salary = ranksData[rID] and ranksData[rID].salary or 0, 
            online = isOnline,
            duty = tonumber(uye.faction_duty) or 0
        })
    end

    local aracSorgu = exports.mysql:sorgu("SELECT id, model, plate, faction_rank, faction_otopark FROM vehicles WHERE faction_vehid = ?", fID)
    local bAraclar = dbPoll(aracSorgu, -1) or {}
    local temizAraclar = {}
    for _, arac in ipairs(bAraclar) do
        local vID = tonumber(arac.id)
        local minR = tonumber(arac.faction_rank) or 1
        local isSpawned = (tonumber(arac.faction_otopark) == 0)
        for _, obj in ipairs(getElementsByType("vehicle")) do
            if tonumber(getElementData(obj, "dbid")) == vID or tonumber(getElementData(obj, "id")) == vID then
                if getElementDimension(obj) == 0 then isSpawned = true end break
            end
        end
        table.insert(temizAraclar, { id = vID, modelName = getVehicleNameFromModel(tonumber(arac.model)) or "Bilinmeyen Model", plate = arac.plate or "PLAKASIZ", spawned = isSpawned, minRank = minR })
    end

    local gGorevler = factionDuties[fID] or {"Görev 1", "Görev 2", "Görev 3", "Görev 4", "Görev 5"}

    local jsonRanks = toJSON(ranksData):gsub("\n", ""):gsub("\r", "")
    local jsonUyeler = toJSON(temizUyeler):gsub("\n", ""):gsub("\r", "")
    local jsonChat = toJSON(factionChats[fID]):gsub("\n", ""):gsub("\r", "")
    local jsonVehicles = toJSON(temizAraclar):gsub("\n", ""):gsub("\r", "")
    local jsonDuties = toJSON(gGorevler):gsub("\n", ""):gsub("\r", "")
    
    triggerClientEvent(oyuncu, "f3:paneliAcVeDoldur", resourceRoot, fID, fData.name, fData.bank, fRank, motd, jsonRanks, jsonUyeler, jsonChat, jsonVehicles, jsonDuties)
end)

addEvent("f3:aracRutbeAyarla", true)
addEventHandler("f3:aracRutbeAyarla", resourceRoot, function(vehID, rutbe)
    local lider = client
    local s = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", getElementData(lider, "aktifKarakterID"))
    local d = dbPoll(s, -1)
    if not d or tonumber(d[1].faction_rank) < 9 then return end 
    local fID = tonumber(d[1].faction_id)
    exports.mysql:calistir("UPDATE vehicles SET faction_rank = ? WHERE id = ? AND faction_vehid = ?", tonumber(rutbe), vehID, fID)
    outputChatBox("[Birlik] Aracın kullanım yetkisi SADECE Rütbe " .. rutbe .. " olarak ayarlandı.", lider, 0, 255, 0)
end)

addEvent("f3:ayarlariKaydet", true)
addEventHandler("f3:ayarlariKaydet", resourceRoot, function(tur, veri)
    local lider = client
    local s = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", getElementData(lider, "aktifKarakterID"))
    local d = dbPoll(s, -1)
    if not d or tonumber(d[1].faction_rank) < 9 then return end 
    local fID = tonumber(d[1].faction_id)
    if tur == "motd" then exports.mysql:calistir("UPDATE factions SET motd = ? WHERE id = ?", veri, fID)
    elseif tur == "ranks" then
        local r = veri 
        exports.mysql:calistir("UPDATE factions SET r1_name=?, r1_sal=?, r2_name=?, r2_sal=?, r3_name=?, r3_sal=?, r4_name=?, r4_sal=?, r5_name=?, r5_sal=?, r6_name=?, r6_sal=?, r7_name=?, r7_sal=?, r8_name=?, r8_sal=?, r9_name=?, r9_sal=?, r10_name=?, r10_sal=? WHERE id=?", r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15], r[16], r[17], r[18], r[19], r[20], fID)
    end
    triggerEvent("f3:panelIstek", lider)
end)

addEvent("f3:sohbetMesaji", true)
addEventHandler("f3:sohbetMesaji", resourceRoot, function(mesaj)
    local oyuncu = client
    local s = exports.mysql:sorgu("SELECT faction_id FROM characters WHERE id = ?", getElementData(oyuncu, "aktifKarakterID"))
    local d = dbPoll(s, -1)
    if not d then return end
    local fID = tonumber(d[1].faction_id)
    local isim = string.gsub(getPlayerName(oyuncu), "_", " ")
    if not factionChats[fID] then factionChats[fID] = {} end
    table.insert(factionChats[fID], {sender = isim, msg = mesaj})
    if #factionChats[fID] > 50 then table.remove(factionChats[fID], 1) end
    for _, py in ipairs(getElementsByType("player")) do
        local ps = exports.mysql:sorgu("SELECT faction_id FROM characters WHERE id = ?", getElementData(py, "aktifKarakterID"))
        local pd = dbPoll(ps, -1)
        if pd and #pd > 0 and tonumber(pd[1].faction_id) == fID then triggerClientEvent(py, "f3:sohbeteMesajEkle", resourceRoot, isim, mesaj) end
    end
end)

addEvent("f3:liderIslem", true)
addEventHandler("f3:liderIslem", resourceRoot, function(hedefCharID, islem)
    local lider = client
    local s = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", getElementData(lider, "aktifKarakterID"))
    local d = dbPoll(s, -1)
    if not d or tonumber(d[1].faction_rank) < 9 then return end 
    local fID = tonumber(d[1].faction_id)
    if islem == "terfi" then exports.mysql:calistir("UPDATE characters SET faction_rank = faction_rank + 1 WHERE id = ? AND faction_rank < 10 AND faction_id = ?", hedefCharID, fID)
    elseif islem == "dusur" then exports.mysql:calistir("UPDATE characters SET faction_rank = faction_rank - 1 WHERE id = ? AND faction_rank > 1 AND faction_id = ?", hedefCharID, fID)
    elseif islem == "at" then 
        -- YENİ GÜVENLİK: Atılan kişinin dutysi 0 (sivil) yapılır!
        exports.mysql:calistir("UPDATE characters SET faction_id = 0, faction_rank = 0, faction_duty = 0 WHERE id = ? AND faction_id = ?", hedefCharID, fID) 
    end
    triggerEvent("f3:panelIstek", lider)
end)

addEvent("f3:davetEt", true)
addEventHandler("f3:davetEt", resourceRoot, function(isim)
    local lider = client
    local hedef = false
    for _, py in ipairs(getElementsByType("player")) do
        if string.find(string.lower(getPlayerName(py)), string.lower(isim), 1, true) then hedef = py break end
    end
    if not hedef or hedef == lider then return end
    local liderSorgu = exports.mysql:sorgu("SELECT faction_id FROM characters WHERE id = ?", getElementData(lider, "aktifKarakterID"))
    local fID = tonumber(dbPoll(liderSorgu, -1)[1].faction_id)
    
    -- YENİ GÜVENLİK: Davet edilen kişi Sivil (Duty 0) olarak başlar!
    exports.mysql:calistir("UPDATE characters SET faction_id = ?, faction_rank = 1, faction_duty = 0 WHERE id = ?", fID, getElementData(hedef, "aktifKarakterID"))
    triggerEvent("f3:panelIstek", lider)
end)

addEvent("f3:dutyVer", true)
addEventHandler("f3:dutyVer", resourceRoot, function(hedefCharID, dutyTipi)
    local lider = client
    local s = exports.mysql:sorgu("SELECT faction_id, faction_rank FROM characters WHERE id = ?", getElementData(lider, "aktifKarakterID"))
    local d = dbPoll(s, -1)
    
    if not d or tonumber(d[1].faction_rank) < 9 then 
        outputChatBox("[Hata] Bunu yapmak için lider yetkisine sahip olmalısınız!", lider, 255, 0, 0)
        return 
    end 
    
    local fID = tonumber(d[1].faction_id)
    exports.mysql:calistir("UPDATE characters SET faction_duty = ? WHERE id = ? AND faction_id = ?", dutyTipi, hedefCharID, fID)
    
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "aktifKarakterID") == hedefCharID then
            setElementData(p, "faction_duty", dutyTipi)
            setElementData(p, "faction_id", fID) -- GÜVENCE: Buradan da anında yapıştıralım
            
            if dutyTipi == 0 then
                outputChatBox("[Birlik] Lider tarafından mesainiz iptal edildi. Artık sivil durumdasınız.", p, 255, 0, 0)
                outputChatBox("[Birlik] Personelin mesaisini başarıyla kapattınız.", lider, 0, 255, 0)
            else
                local dNames = factionDuties[fID] or {"Görev 1"}
                outputChatBox("[Birlik] Lider size [" .. (dNames[dutyTipi] or "Yeni Görev") .. "] mesaisi atadı! Departmandaki mavi alana giderek ekipmanlarınızı kuşanın.", p, 52, 152, 219)
                outputChatBox("[Birlik] Personele başarıyla duty verdiniz.", lider, 0, 255, 0)
            end
            break
        end
    end
end)

setTimer(function()
    local s = exports.mysql:sorgu("SELECT id FROM vehicles WHERE faction_otopark = 1 AND faction_vehid > 0")
    local d = dbPoll(s, -1)
    if d and #d > 0 then
        local parked = {}
        for _, v in ipairs(d) do parked[tonumber(v.id)] = true end
        for _, obj in ipairs(getElementsByType("vehicle")) do
            local vID = tonumber(getElementData(obj, "dbid")) or tonumber(getElementData(obj, "id"))
            if vID and parked[vID] then
                if getElementDimension(obj) ~= 50 then
                    setElementDimension(obj, 50)
                    setElementFrozen(obj, true)
                end
            end
        end
    end
end, 10000, 0)

addEventHandler("onPlayerQuit", root, function()
    local charID = tonumber(getElementData(source, "aktifKarakterID"))
    if charID then
        setTimer(function(cID)
            local isOnline = false
            for _, p in ipairs(getElementsByType("player")) do
                if tonumber(getElementData(p, "aktifKarakterID")) == cID then isOnline = true break end
            end
            if not isOnline then
                for vID, kimCikardi in pairs(aracCikaranlar) do
                    if kimCikardi == cID then
                        exports.mysql:calistir("UPDATE vehicles SET faction_otopark = 1 WHERE id = ?", vID)
                        for _, veh in ipairs(getElementsByType("vehicle")) do
                            local bID = tonumber(getElementData(veh, "dbid")) or tonumber(getElementData(veh, "id"))
                            if bID == vID then
                                setElementDimension(veh, 50)
                                setElementFrozen(veh, true)
                            end
                        end
                        aracCikaranlar[vID] = nil 
                    end
                end
            end
        end, 300000, 1, charID)
    end
end)