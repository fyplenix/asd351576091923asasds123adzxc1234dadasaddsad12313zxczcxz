local browser = nil
local dutyMarker = nil 

local factionDutyMarkers = {
    [1] = { x = 1577.236328125, y = -1686.822265625, z = 16.1953125 }, -- LSPD
    [2] = { x = 1172.9, y = -1323.3, z = 15.4 }, -- LSMD (Bunu daha sonra hastanenin içine göre değiştirirsin)
}

local factionDutyNames = {
    [1] = {"Bekçi", "Polis Memuru", "Trafik Polisi", "Komiser", "Emniyet Müdürü"},
    [2] = {"Stajyer Doktor", "İlk Yardım Görevlisi", "Uzman Doktor", "Cerrah", "Başhekim"},
}

bindKey("F3", "down", function()
    if isElement(browser) then
        destroyElement(browser)
        browser = nil
        showCursor(false)
        guiSetInputMode("allow_binds")
    else
        triggerServerEvent("f3:panelIstek", resourceRoot)
    end
end)

addEvent("f3:paneliAcVeDoldur", true)
addEventHandler("f3:paneliAcVeDoldur", root, function(fID, ad, kasa, rutbe, motd, jsonRanks, jsonUyeler, jsonChat, jsonVehicles, jsonDuties)
    local function temizle(str) return tostring(str):gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "\\n"):gsub("\r", "") end
    if isElement(browser) then
        executeBrowserJavascript(guiGetBrowser(browser), "loadFactionData("..fID..", '"..temizle(ad).."', "..kasa..", "..rutbe..", '"..temizle(motd).."', '"..temizle(jsonRanks).."', '"..temizle(jsonUyeler).."', '"..temizle(jsonChat).."', '"..temizle(jsonVehicles).."', '"..temizle(jsonDuties).."')")
        return
    end

    local sX, sY = guiGetScreenSize()
    browser = guiCreateBrowser(0, 0, sX, sY, true, true, false)
    addEventHandler("onClientBrowserCreated", guiGetBrowser(browser), function()
        loadBrowserURL(source, "http://mta/local/html/f3.html")
        showCursor(true)
        guiSetInputMode("no_binds_when_editing")
        setTimer(function()
            executeBrowserJavascript(guiGetBrowser(browser), "loadFactionData("..fID..", '"..temizle(ad).."', "..kasa..", "..rutbe..", '"..temizle(motd).."', '"..temizle(jsonRanks).."', '"..temizle(jsonUyeler).."', '"..temizle(jsonChat).."', '"..temizle(jsonVehicles).."', '"..temizle(jsonDuties).."')")
        end, 200, 1)
    end)
end)

addEvent("f3:sohbeteMesajEkle", true)
addEventHandler("f3:sohbeteMesajEkle", root, function(gonderen, mesaj)
    if isElement(browser) then
        local tGonderen = gonderen:gsub("'", "\\'")
        local tMesaj = mesaj:gsub("'", "\\'")
        executeBrowserJavascript(guiGetBrowser(browser), "appendMessage('"..tGonderen.."', '"..tMesaj.."')")
    end
end)

function paneliKapat()
    if isElement(browser) then destroyElement(browser) browser = nil showCursor(false) guiSetInputMode("allow_binds") end
end

addEvent("cef:f3Kapat", true)
addEventHandler("cef:f3Kapat", root, paneliKapat)
addEvent("cef:birlikIslem", true)
addEventHandler("cef:birlikIslem", root, function(hedefID, islem) triggerServerEvent("f3:liderIslem", resourceRoot, hedefID, islem) end)
addEvent("cef:birlikDavet", true)
addEventHandler("cef:birlikDavet", root, function(isim) triggerServerEvent("f3:davetEt", resourceRoot, isim) end)
addEvent("cef:motdKaydet", true)
addEventHandler("cef:motdKaydet", root, function(yeniNot) triggerServerEvent("f3:ayarlariKaydet", resourceRoot, "motd", yeniNot) end)
addEvent("cef:chatGonder", true)
addEventHandler("cef:chatGonder", root, function(mesaj) triggerServerEvent("f3:sohbetMesaji", resourceRoot, mesaj) end)

addEvent("cef:rutbeleriKaydet", true)
addEventHandler("cef:rutbeleriKaydet", root, function(n1, s1, n2, s2, n3, s3, n4, s4, n5, s5, n6, s6, n7, s7, n8, s8, n9, s9, n10, s10)
    local veriler = { n1, s1, n2, s2, n3, s3, n4, s4, n5, s5, n6, s6, n7, s7, n8, s8, n9, s9, n10, s10 }
    triggerServerEvent("f3:ayarlariKaydet", resourceRoot, "ranks", veriler)
end)

addEvent("cef:aracRutbeKaydet", true)
addEventHandler("cef:aracRutbeKaydet", root, function(vehID, rutbe) triggerServerEvent("f3:aracRutbeAyarla", resourceRoot, vehID, rutbe) end)
addEvent("cef:dutyVer", true)
addEventHandler("cef:dutyVer", root, function(hedefID, dutyTipi) triggerServerEvent("f3:dutyVer", resourceRoot, hedefID, dutyTipi) end)

local garajWindow = nil
local garajGrid = nil
local aktifFactionID = 0

addEvent("garaj:paneliAc", true)
addEventHandler("garaj:paneliAc", root, function(araclar, fID)
    if isElement(garajWindow) then destroyElement(garajWindow) end
    aktifFactionID = fID
    showCursor(true)
    guiSetInputMode("no_binds")

    local sX, sY = guiGetScreenSize()
    local w, h = 500, 350
    local x, y = (sX - w) / 2, (sY - h) / 2

    garajWindow = guiCreateWindow(x, y, w, h, "Birlik Araç Garajı", false)
    guiWindowSetSizable(garajWindow, false)
    guiSetAlpha(garajWindow, 0.95)

    garajGrid = guiCreateGridList(10, 30, 480, 250, false, garajWindow)
    guiGridListAddColumn(garajGrid, "ID", 0.15)
    guiGridListAddColumn(garajGrid, "Model", 0.35)
    guiGridListAddColumn(garajGrid, "Plaka", 0.25)
    guiGridListAddColumn(garajGrid, "Durum", 0.2)

    for _, arac in ipairs(araclar) do
        local row = guiGridListAddRow(garajGrid)
        guiGridListSetItemText(garajGrid, row, 1, tostring(arac.id), false, false)
        guiGridListSetItemText(garajGrid, row, 2, arac.model, false, false)
        guiGridListSetItemText(garajGrid, row, 3, arac.plate, false, false)
        guiGridListSetItemText(garajGrid, row, 4, arac.durum, false, false)
        if arac.durum == "Garajda" then guiGridListSetItemColor(garajGrid, row, 4, 46, 204, 113) else guiGridListSetItemColor(garajGrid, row, 4, 231, 76, 60) end
    end

    local btnCikar = guiCreateButton(10, 290, 150, 45, "Seçili Aracı Çıkar", false, garajWindow)
    local btnPark = guiCreateButton(170, 290, 150, 45, "Aracı Park Et", false, garajWindow)
    local btnKapat = guiCreateButton(330, 290, 160, 45, "Garajı Kapat", false, garajWindow)

    addEventHandler("onClientGUIClick", btnKapat, function() destroyElement(garajWindow) showCursor(false) guiSetInputMode("allow_binds") end, false)

    addEventHandler("onClientGUIClick", btnCikar, function()
        local row = guiGridListGetSelectedItem(garajGrid)
        if row ~= -1 then
            local vID = guiGridListGetItemText(garajGrid, row, 1)
            local durum = guiGridListGetItemText(garajGrid, row, 4)
            if durum == "Dışarıda" then outputChatBox("[Hata] Seçtiğiniz araç zaten garajın dışında!", 255, 0, 0)
            else triggerServerEvent("garaj:islemYap", resourceRoot, "cikar", aktifFactionID, tonumber(vID)) end
        else
            outputChatBox("[Hata] Lütfen listeden çıkartmak istediğiniz aracı seçin.", 255, 0, 0)
        end
    end, false)

    addEventHandler("onClientGUIClick", btnPark, function() triggerServerEvent("garaj:islemYap", resourceRoot, "park", aktifFactionID) end, false)
end)


-- ==========================================
-- AKILLI MARKER SİSTEMİ (KESİN ÇÖZÜM)
-- ==========================================
setTimer(function()
    local myDuty = tonumber(getElementData(localPlayer, "faction_duty")) or 0
    local myFaction = tonumber(getElementData(localPlayer, "faction_id")) or 0
    
    -- 1. Marker varsa, ama oyuncunun birliği veya mesaisi değişmişse markerı YOK ET!
    if isElement(dutyMarker) then
        local markerFaction = tonumber(getElementData(dutyMarker, "owner_faction")) or 0
        if myDuty == 0 or myFaction ~= markerFaction then
            destroyElement(dutyMarker)
            dutyMarker = nil
        end
    end
    
    -- 2. Marker yoksa, oyuncunun mesaisi ve birliği geçerliyse YENİ marker yarat!
    if myDuty > 0 and myFaction > 0 and not isElement(dutyMarker) then
        local pos = factionDutyMarkers[myFaction]
        if pos then
            dutyMarker = createMarker(pos.x, pos.y, pos.z - 1, "cylinder", 1.5, 52, 152, 219, 150)
            setElementData(dutyMarker, "owner_faction", myFaction)
            
            addEventHandler("onClientMarkerHit", dutyMarker, function(hitElement, match)
                if hitElement == localPlayer and match then
                    local pFaction = tonumber(getElementData(localPlayer, "faction_id")) or 0
                    local mFaction = tonumber(getElementData(source, "owner_faction")) or 0
                    
                    -- SADECE kendi birliğinin markerına girerse paneli aç
                    if pFaction == mFaction then
                        local fNames = factionDutyNames[pFaction] or {}
                        local currentD = tonumber(getElementData(localPlayer, "faction_duty")) or 0
                        triggerEvent("duty:paneliAc", localPlayer, fNames[currentD] or "Bilinmeyen Görev")
                    end
                end
            end)
        end
    end
end, 2000, 0)

local dutyWindow = nil
addEvent("duty:paneliAc", true)
addEventHandler("duty:paneliAc", root, function(dutyIsmi)
    if isElement(dutyWindow) then destroyElement(dutyWindow) end
    showCursor(true)
    guiSetInputMode("no_binds")
    local sX, sY = guiGetScreenSize()
    local w, h = 400, 200
    local x, y = (sX - w) / 2, (sY - h) / 2
    
    dutyWindow = guiCreateWindow(x, y, w, h, "Departman Ekipman Odası", false)
    guiWindowSetSizable(dutyWindow, false)
    
    local lbl = guiCreateLabel(10, 40, 380, 50, "Mevcut Göreviniz: " .. dutyIsmi .. "\n\n(Kıyafet ve Silah listesi buraya eklenecek)", false, dutyWindow)
    guiLabelSetHorizontalAlign(lbl, "center")
    guiSetFont(lbl, "default-bold-small")
    
    local btnKapat = guiCreateButton(125, 130, 150, 40, "Paneli Kapat", false, dutyWindow)
    addEventHandler("onClientGUIClick", btnKapat, function()
        destroyElement(dutyWindow)
        showCursor(false)
        guiSetInputMode("allow_binds")
    end, false)
end)