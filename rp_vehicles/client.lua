local galeriBrowser = nil

-- J Tuşu: Motor Kontrolü
bindKey("j", "down", function()
    if isChatBoxInputActive() or isConsoleActive() then return end
    if isPedInVehicle(localPlayer) then
        triggerServerEvent("arac:motorKontrol", resourceRoot)
    end
end)

-- K Tuşu: Kilit Kontrolü
bindKey("k", "down", function()
    if isChatBoxInputActive() or isConsoleActive() then return end
    triggerServerEvent("arac:kilitKontrol", resourceRoot)
end)

-- Galeri Panelini Aç
addEvent("galeri:paneliAc", true)
addEventHandler("galeri:paneliAc", root, function(dcBakiye)
    if isElement(galeriBrowser) then 
        destroyElement(galeriBrowser)
        galeriBrowser = nil
    end
    
    local eX, eY = guiGetScreenSize()
    galeriBrowser = guiCreateBrowser(0, 0, eX, eY, true, true, false)
    local theBrowser = guiGetBrowser(galeriBrowser)
    
    addEventHandler("onClientBrowserCreated", theBrowser, function()
        loadBrowserURL(source, "http://mta/local/html/index.html")
        showCursor(true)
        guiSetInputMode("no_binds_when_editing")
        
        -- HTML yüklendiğinde JavaScript'e DC miktarını gönder
        addEventHandler("onClientBrowserDocumentReady", source, function()
            -- dcBakiye nil gelirse 0 olarak ayarla
            local bakiyeDegeri = dcBakiye or 0 
            executeBrowserJavascript(source, "setPlayerDC(" .. bakiyeDegeri .. ")")
        end)
    end)
end)

-- JS'den gelen Yetersiz Bakiye Uyarısını Ekrana Yazdır
addEvent("cef:galeriUyari", true)
addEventHandler("cef:galeriUyari", resourceRoot, function(mesaj)
    -- Client side outputChatBox kullanımı:
    outputChatBox("[Galeri] " .. mesaj, 255, 0, 0)
end)
-- Galeri Panelini Kapat
addEvent("galeri:paneliKapat", true)
addEventHandler("galeri:paneliKapat", root, function()
    if isElement(galeriBrowser) then
        destroyElement(galeriBrowser)
        galeriBrowser = nil
    end
    showCursor(false)
    guiSetInputMode("allow_binds")
end)

-- JS'den gelen sinyaller
addEvent("cef:aracAl", true)
addEventHandler("cef:aracAl", resourceRoot, function(model, fiyat, r, g, b, ozelPlaka)
    triggerServerEvent("arac:satinAl", resourceRoot, model, fiyat, r, g, b, ozelPlaka)
end)

addEvent("cef:galeriKapat", true)
addEventHandler("cef:galeriKapat", resourceRoot, function()
    triggerEvent("galeri:paneliKapat", localPlayer)
end)



local font_plaka = dxCreateFont("files/font.ttf", 55, true) or "default-bold"
local bgTex_plaka = dxCreateTexture("files/number_tr.png")
local bgTex_police = dxCreateTexture("files/number_police_tr.png")

local aTexturesReplace = {
    "nomer", "numb", "numb1", "custom_car_plate",
    "nomera", "rpbox_nomer", "rpbox_bk_nm", "rp_bk_nm"
}

local pPlates = {}

local SHADER_CODE = [[
    texture gTexture;
    technique TexReplace {
        pass P0 {
            Texture[0] = gTexture;
        }
    }
]]

function plakayiUygula(arac)
    if not isElement(arac) or getElementType(arac) ~= "vehicle" then return end

    local plakaMetni = getElementData(arac, "arac:plaka") or getVehiclePlateText(arac)
    if not plakaMetni or plakaMetni == "" then plakaMetni = "34 TR 3434" end
    plakaMetni = utf8.upper(plakaMetni)

    -- ARACIN POLİS OLUP OLMADIĞINI KONTROL ET
    local factionID = tonumber(getElementData(arac, "arac:faction")) or 0
    local isPolice = (factionID == 1)
    
    -- POLİS VE SİVİL İÇİN ÖZEL AYARLAR
    local arkaplanGorsel = isPolice and bgTex_police or bgTex_plaka
    local yaziRengi = isPolice and tocolor(255, 255, 255, 255) or tocolor(15, 15, 15, 255)
    
    -- ÇÖZÜM: Polis plakası için yazıyı sola kaydırıyoruz (40), sivil için aynı kalıyor (65)
    local solBosluk = isPolice and 40 or 65 
    local sagBosluk = isPolice and 490 or 512

    local rt = dxCreateRenderTarget(512, 128, true)
    
    if rt then
        dxSetRenderTarget(rt, true)
        
        if arkaplanGorsel then
            dxDrawImage(0, 0, 512, 128, arkaplanGorsel)
        else
            if isPolice then
                dxDrawRectangle(0, 0, 512, 128, tocolor(0, 51, 153, 255))
            else
                dxDrawRectangle(0, 0, 512, 128, tocolor(255, 255, 255, 255))
            end
        end
        
        -- Ayarladığımız boşluklara göre çizimi yap
        dxDrawText(plakaMetni, solBosluk, 0, sagBosluk, 128, yaziRengi, 1, font_plaka, "center", "center")
        
        dxSetRenderTarget()

        local shader = dxCreateShader(SHADER_CODE)
        if shader then
            dxSetShaderValue(shader, "gTexture", rt)
            for _, texName in ipairs(aTexturesReplace) do
                engineApplyShaderToWorldTexture(shader, texName, arac)
            end
            
            plakayiSil(arac)
            pPlates[arac] = {shader, rt}
        end
    end
end

-- Alt kısımdaki eventler aynı kalacak (StreamIn, vb.)

function plakayiSil(arac)
    if pPlates[arac] then
        if isElement(pPlates[arac][1]) then destroyElement(pPlates[arac][1]) end
        if isElement(pPlates[arac][2]) then destroyElement(pPlates[arac][2]) end
        pPlates[arac] = nil
    end
end

addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then 
        plakayiUygula(source) 
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    if getElementType(source) == "vehicle" then plakayiSil(source) end
end)

addEventHandler("onClientElementDestroy", root, function()
    if getElementType(source) == "vehicle" then plakayiSil(source) end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, arac in ipairs(getElementsByType("vehicle", root, true)) do
        plakayiUygula(arac)
    end
end)

-- Alt-Tab (Siyah Plaka) sorunu için
addEventHandler("onClientRestore", root, function()
    for arac, veriler in pairs(pPlates) do
        if isElement(arac) then
            plakayiSil(arac)    
            plakayiUygula(arac) 
        end
    end
end)

-- ElementData (Özellikle Faction) değişirse plakayı anında güncelle
addEventHandler("onClientElementDataChange", root, function(veriAdi)
    if getElementType(source) == "vehicle" and (veriAdi == "arac:plaka" or veriAdi == "arac:faction") then
        plakayiUygula(source)
    end
end)