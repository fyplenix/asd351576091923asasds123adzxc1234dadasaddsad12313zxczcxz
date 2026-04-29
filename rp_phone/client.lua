local phoneBrowser = nil
local isPhoneOpen = false
local zilSesiMuzik = nil 

addEvent("telefon:paneliAc", true)
addEventHandler("telefon:paneliAc", root, function()
    triggerEvent("envanter:paneliKapat", localPlayer)

    setElementData(localPlayer, "telefon_elinde", true)
    
    if not isElement(phoneBrowser) then
        local eX, eY = guiGetScreenSize()
        phoneBrowser = guiCreateBrowser(0, 0, eX, eY, true, true, false)
        
        addEventHandler("onClientBrowserCreated", guiGetBrowser(phoneBrowser), function()
            loadBrowserURL(source, "http://mta/local/html/index.html")
        end)
        
        addEventHandler("onClientBrowserDocumentReady", guiGetBrowser(phoneBrowser), function()
            triggerServerEvent("telefon:verileriHazirla", resourceRoot)
        end)
    else
        triggerServerEvent("telefon:verileriHazirla", resourceRoot)
    end
    
    isPhoneOpen = true
    
    -- ÇÖZÜM: Telefon açıldığında rp_controls'a "fareyi aç" sinyali yollar!
    triggerEvent("rp_controls:fareyiAc", localPlayer)
    -- Klavyeyle telefonda (sahibinden, banka vb.) yazı yazabilmen için gerekli ayar:
    guiSetInputMode("no_binds_when_editing") 
    
    if isElement(phoneBrowser) then
        guiBringToFront(phoneBrowser)
    end
end)
addEvent("telefon:paneliKapat", true)
addEventHandler("telefon:paneliKapat", root, function()
    -- 1. Animasyonları ve telefonu sıfırla
    setElementData(localPlayer, "telefon_elinde", false)
    
    if isElement(phoneBrowser) then
        destroyElement(phoneBrowser)
        phoneBrowser = nil
    end
    
    isPhoneOpen = false
    guiSetInputMode("allow_binds")
    
    -- 2. KESİN ÇÖZÜM: Kendi içimizden kapatmak yerine rp_controls'a sinyal yolluyoruz!
    triggerEvent("rp_controls:fareyiKapat", localPlayer)
end)

-- JS (Html) üzerinden gelen kapatma tuşu sinyalini yakalar
addEvent("cef:telefonKapat", true)
addEventHandler("cef:telefonKapat", resourceRoot, function()
    triggerEvent("telefon:paneliKapat", localPlayer)
end)

addEvent("telefon:ekVerileriYukle", true)
addEventHandler("telefon:ekVerileriYukle", resourceRoot, function(iban, bakiye, isim, wp, casinoBal, numara)
    if isElement(phoneBrowser) then
        local browser = guiGetBrowser(phoneBrowser)
        executeBrowserJavascript(browser, string.format("loadBankApp('%s', %d, '%s')", iban or "Yok", bakiye or 0, isim or "Bilinmiyor"))
        executeBrowserJavascript(browser, string.format("setInitialWallpaper('%s')", wp or ""))
        executeBrowserJavascript(browser, string.format("loadCasinoApp(%d)", casinoBal or 0))
        executeBrowserJavascript(browser, string.format("setMyNumber('%s')", numara or "Atanmamış"))
    end
end)

addEvent("cef:telefonTransfer", true)
addEventHandler("cef:telefonTransfer", resourceRoot, function(hedefIban, miktar)
    triggerServerEvent("telefon:transferYap", resourceRoot, hedefIban, miktar)
end)


-- =======================================================
-- ÇÖZÜM: JAVASCRIPT (CEF) İLE SERVER ARASINDAKİ KÖPRÜLER
-- =======================================================
local jsKopruOlaylari = {
    "phone:addContact", "phone:requestContacts", "phone:setWallpaper",
    "phone:setRingtone", "casino:deposit", "casino:withdraw",
    "casino:spinRequest", "phone:startCall", "phone:acceptCall", "phone:endCall",
    "phone:requestPhotos", "phone:deletePhoto",
    "phone:shbRequestAllAds", "phone:shbRequestMyAd", "phone:shbPostAd", "phone:shbUpdateAd", "phone:shbDeleteAd",
    "phone:requestWeather", "phone:requestNews", "phone:postNews" -- <-- EKLENENLER BURADA
}

for _, olayAdi in ipairs(jsKopruOlaylari) do
    addEvent(olayAdi, true)
    addEventHandler(olayAdi, root, function(...)
        triggerServerEvent(olayAdi, localPlayer, ...)
    end)
end
-- =======================================================


-- MTA Voice ve Rehber Listesi Geri Dönüşleri
addEvent("phone:receiveContacts", true)
addEventHandler("phone:receiveContacts", root, function(jsonContacts)
    if isElement(phoneBrowser) then
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), string.format("loadContacts('%s')", jsonContacts))
    end
end)

addEvent("phone:incomingCall", true)
addEventHandler("phone:incomingCall", root, function(arayanIsim)
    if isElement(phoneBrowser) then
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), string.format("incomingCall('%s')", arayanIsim))
    end
    
    local secilenZil = getElementData(localPlayer, "telefon_zil") or "zil1.mp3"
    if fileExists("html/"..secilenZil) then
        zilSesiMuzik = playSound("html/" .. secilenZil, true)
    end
end)

addEvent("phone:callAnswered", true)
addEventHandler("phone:callAnswered", root, function()
    if isElement(phoneBrowser) then executeBrowserJavascript(guiGetBrowser(phoneBrowser), "answerCall()") end
    if isElement(zilSesiMuzik) then destroyElement(zilSesiMuzik) end
end)

addEvent("phone:callEnded", true)
addEventHandler("phone:callEnded", root, function()
    if isElement(phoneBrowser) then executeBrowserJavascript(guiGetBrowser(phoneBrowser), "closeCallScreen()") end
    if isElement(zilSesiMuzik) then destroyElement(zilSesiMuzik) end
end)



-- Sunucudan gelen slot sonucunu ekrana (Javascript'e) yansıt
addEvent("casino:spinResult", true)
addEventHandler("casino:spinResult", root, function(r1, r2, r3, mesaj, yeniBakiye)
    if isElement(phoneBrowser) then
        local jsCode = string.format("stopSpin('%s', '%s', '%s', '%s', %d)", r1, r2, r3, mesaj, yeniBakiye)
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), jsCode)
    end
end)





-- ==========================================
-- YENİ NESİL FIRST PERSON (FPS) VE SELFIE KAMERASI
-- ==========================================
local isUsingPhoneCamera = false
local originalFOV = 70
local currentFOV = 70

local rotX, rotY = 0, 0
local mouseSensitivity = 0.1
local isSelfieMode = false 
local selfieDistance = 1.3 -- 1.3 Metre selfie için en ideal (kol uzunluğu) mesafesidir

local sX, sY = guiGetScreenSize()
local screenCatcher = dxCreateScreenSource(sX, sY)
local photoCanvas = dxCreateRenderTarget(640, 480, false)

local function drawCameraUI()
    if not isUsingPhoneCamera then return end

    local cX, cY = getCursorPosition()
    if cX and cY then
        cX, cY = cX * sX, cY * sY
        local dX = cX - sX/2
        local dY = cY - sY/2

        mouseSensitivity = getElementData(localPlayer, "kamera_hassasiyet") or 0.1
        
        -- ÇÖZÜM: Selfie modundayken kameranın sağa/sola dönüşünü tersine çeviriyoruz (Ayna efekti)
        if isSelfieMode then
            rotX = rotX + dX * mouseSensitivity * 0.005
        else
            rotX = rotX - dX * mouseSensitivity * 0.005
        end
        
        rotY = rotY - dY * mouseSensitivity * 0.005

        if rotY > math.pi/2.2 then rotY = math.pi/2.2 end
        if rotY < -math.pi/2.2 then rotY = -math.pi/2.2 end

        setCursorPosition(sX/2, sY/2)
    end

    local hX, hY, hZ = getPedBonePosition(localPlayer, 8) 
    hZ = hZ + 0.15 

    local dirX = math.cos(rotX) * math.cos(rotY)
    local dirY = math.sin(rotX) * math.cos(rotY)
    local dirZ = math.sin(rotY)

    local camX, camY, camZ
    local lookX, lookY, lookZ

    if isSelfieMode then
        -- SELFIE MODU: Kamera tam yüzünün önünde durur ve yüzüne bakar
        camX = hX + dirX * selfieDistance
        camY = hY + dirY * selfieDistance
        camZ = hZ + dirZ * selfieDistance
        
        lookX, lookY, lookZ = hX, hY, hZ
        setElementAlpha(localPlayer, 255) -- Yüzümüzü görmek için görünürüz
    else
        -- NORMAL FPS MODU: Kamera kafanın içindedir ve ileriye bakar
        camX, camY, camZ = hX, hY, hZ
        
        lookX = hX + dirX * 10
        lookY = hY + dirY * 10
        lookZ = hZ + dirZ * 10
        
        setElementAlpha(localPlayer, 0) -- Kafatasının içini görmemek için görünmeziz
    end

    setCameraMatrix(camX, camY, camZ, lookX, lookY, lookZ, 0, currentFOV)
    setPedRotation(localPlayer, math.deg(-rotX) + 90)

    -- Ekran Çizgileri
    dxDrawLine(sX/3, 0, sX/3, sY, tocolor(255, 255, 255, 60), 1)
    dxDrawLine((sX/3)*2, 0, (sX/3)*2, sY, tocolor(255, 255, 255, 60), 1)
    dxDrawLine(0, sY/3, sX, sY/3, tocolor(255, 255, 255, 60), 1)
    dxDrawLine(0, (sY/3)*2, sX, (sY/3)*2, tocolor(255, 255, 255, 60), 1)

    local modeText = isSelfieMode and "ÖN KAMERA (SELFIE)" or "ARKA KAMERA (FPS)"
    dxDrawText("📷 " .. modeText, 0, sY - 130, sX, sY, tocolor(255, 255, 255, 255), 1.5, "default-bold", "center", "top")
    dxDrawText("Çek: Sol Tık | Mod Değiştir: Sağ Tık | Zoom: Tekerlek | Çıkış: Backspace", 0, sY - 95, sX, sY, tocolor(200, 200, 200, 255), 1.2, "default-bold", "center", "top")
end

-- Kameradayken Sağ Tık: Mod Değiştir (Selfie/Normal)
function toggleCameraMode(button, state)
    if not isUsingPhoneCamera or button ~= "right" or state ~= "down" then return end
    
    isSelfieMode = not isSelfieMode
    playSoundFrontEnd(41) 
    -- ÇÖZÜM: Karakteri ters çeviren hatalı satır tamamen silindi! Sadece mod değişecek.
end

-- ==========================================
-- ODAK KURTARMA VE SIFIRLAMA MOTORU
-- ==========================================
local function restoreCameraState()
    setCameraTarget(localPlayer) 
    setElementAlpha(localPlayer, 255) 
    setCursorAlpha(255) 
    
    unbindKey("mouse1", "down", takeSmartphonePhoto)
    unbindKey("backspace", "down", closeSmartphoneCamera)
    unbindKey("mouse_wheel_up", "down", zoomInCamera)
    unbindKey("mouse_wheel_down", "down", zoomOutCamera)

    removeEventHandler("onClientRender", root, drawCameraUI)
    removeEventHandler("onClientClick", root, toggleCameraMode)
    
    if isElement(phoneBrowser) then
        guiSetVisible(phoneBrowser, true)
        guiBringToFront(phoneBrowser) 
        showCursor(true)
        guiSetInputMode("no_binds_when_editing")
        isPhoneOpen = true
    end
end

function closeSmartphoneCamera()
    if not isUsingPhoneCamera then return end
    isUsingPhoneCamera = false
    restoreCameraState()
end

function takeSmartphonePhoto()
    if not isUsingPhoneCamera then return end
    isUsingPhoneCamera = false
    
    unbindKey("mouse1", "down", takeSmartphonePhoto)
    removeEventHandler("onClientRender", root, drawCameraUI)
    removeEventHandler("onClientClick", root, toggleCameraMode)
    
    playSoundFrontEnd(40)
    
    setTimer(function()
        dxUpdateScreenSource(screenCatcher)
        
        dxSetRenderTarget(photoCanvas, true)
        dxDrawImage(0, 0, 640, 480, screenCatcher)
        dxSetRenderTarget() 
        
        local pixels = dxGetTexturePixels(photoCanvas)
        local jpegData = dxConvertPixels(pixels, "jpeg", 70)
        local base64Data = encodeString("base64", jpegData) 
        local dataURI = "data:image/jpeg;base64," .. base64Data
        
        triggerServerEvent("phone:savePhoto", localPlayer, dataURI)
        restoreCameraState()
    end, 50, 1)
end

function zoomInCamera() currentFOV = math.max(20, currentFOV - 5) end
function zoomOutCamera() currentFOV = math.min(originalFOV, currentFOV + 5) end

addEvent("cef:openNativeCamera", true)
addEventHandler("cef:openNativeCamera", root, function()
    if isElement(phoneBrowser) then
        guiSetVisible(phoneBrowser, false) 
    end
    
    isPhoneOpen = false
    isUsingPhoneCamera = true
    isSelfieMode = false -- Kamerayı açtığında her zaman FPS moduyla başlar
    
    originalFOV = getCameraFieldOfView("player") or 70
    currentFOV = originalFOV
    
    local camX, camY, camZ, lookX, lookY, lookZ = getCameraMatrix()
    rotX = math.atan2(lookY - camY, lookX - camX)
    rotY = math.asin((lookZ - camZ) / getDistanceBetweenPoints3D(camX, camY, camZ, lookX, lookY, lookZ))
    
    showCursor(true) 
    setCursorAlpha(0) 
    setCursorPosition(sX/2, sY/2) 
    
    bindKey("mouse1", "down", takeSmartphonePhoto)
    bindKey("backspace", "down", closeSmartphoneCamera)
    bindKey("mouse_wheel_up", "down", zoomInCamera)
    bindKey("mouse_wheel_down", "down", zoomOutCamera)
    
    addEventHandler("onClientRender", root, drawCameraUI)
    addEventHandler("onClientClick", root, toggleCameraMode)
end)








-- =======================================================
-- JAVASCRIPT GERİ BİLDİRİMLERİ (Çökmeler Engellendi)
-- =======================================================

-- Galerinin de çökmemsi için tırnaklarını güncelliyoruz
addEvent("phone:receivePhotos", true)
addEventHandler("phone:receivePhotos", root, function(jsonPhotos)
    if isElement(phoneBrowser) then
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), string.format("loadGallery(`%s`)", jsonPhotos))
    end
end)

-- Sunucudan Gelen Sahibinden Verilerini JS'ye Aktar (Backtick Kullanıldı)
addEvent("phone:shbReceiveAllAds", true)
addEventHandler("phone:shbReceiveAllAds", root, function(adsJson)
    if isElement(phoneBrowser) then 
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), string.format("loadShbAllAds(`%s`)", adsJson)) 
    end
end)

addEvent("phone:shbReceiveMyAd", true)
addEventHandler("phone:shbReceiveMyAd", root, function(myAdJson, myCarsJson)
    if isElement(phoneBrowser) then 
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), string.format("loadShbMyAd(`%s`, `%s`)", myAdJson, myCarsJson)) 
    end
end)



-- Kameradayken Sağ Tık: Mod Değiştir (Selfie/Normal)
function toggleCameraMode(button, state)
    if not isUsingPhoneCamera or button ~= "right" or state ~= "down" then return end
    
    isSelfieMode = not isSelfieMode
    playSoundFrontEnd(41) -- Hafif bir geçiş sesi
    
    if isSelfieMode then
        -- Selfie'ye geçerken rotasyonu 180 derece çevirip oyuncuya bakmasını sağlayalım
        rotX = rotX + math.pi 
        -- Selfie modunda alpha'yı drawCameraUI hallediyor.
    else
        -- Normale dönerken rotasyonu tekrar düzelt
        rotX = rotX - math.pi
    end
end



addEvent("phone:updateWeather", true)
addEventHandler("phone:updateWeather", root, function(temp, desc, low, high, summary, hourly, daily)
    if isElement(phoneBrowser) then
        -- JS'nin çökmesini engellemek için string formatını en güvenli hale getirdik
        local jsKodu = string.format("loadWeather(%d, '%s', %d, %d, '%s', '%s', '%s')", temp, desc, low, high, summary, hourly, daily)
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), jsKodu)
    end
end)



-- ==========================================
-- 3D TELEFON OBJESİ VE KEMİK ANİMASYONU (SYNC)
-- ==========================================
local phoneModel = 330
local activePhones = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- TXD ve DFF dosyalarını yüklüyoruz
    if fileExists("object/phone.txd") and fileExists("object/phone.dff") then
        local txd = engineLoadTXD("object/phone.txd")
        engineImportTXD(txd, phoneModel)
        local dff = engineLoadDFF("object/phone.dff")
        engineReplaceModel(dff, phoneModel)
    end
end)

-- Gelişmiş Kemik Matris Fonksiyonu
local function attachElementToBone(element, ped, bone, offX, offY, offZ, offrx, offry, offrz)
    if isElementOnScreen(ped) then
        local boneMat = getElementBoneMatrix(ped, bone)
        if not boneMat then return false end
        
        local sroll, croll, spitch, cpitch, syaw, cyaw = math.sin(offrz), math.cos(offrz), math.sin(offry), math.cos(offry), math.sin(offrx), math.cos(offrx)
        local rotMat = {
            { sroll * spitch * syaw + croll * cyaw, sroll * cpitch, sroll * spitch * cyaw - croll * syaw },
            { croll * spitch * syaw - sroll * cyaw, croll * cpitch, croll * spitch * cyaw + sroll * syaw },
            { cpitch * syaw, -spitch, cpitch * cyaw }
        }
        local finalMatrix = {
            {
                boneMat[2][1] * rotMat[1][2] + boneMat[1][1] * rotMat[1][1] + rotMat[1][3] * boneMat[3][1],
                boneMat[3][2] * rotMat[1][3] + boneMat[1][2] * rotMat[1][1] + boneMat[2][2] * rotMat[1][2],
                boneMat[2][3] * rotMat[1][2] + boneMat[3][3] * rotMat[1][3] + rotMat[1][1] * boneMat[1][3],
                0,
            },
            {
                rotMat[2][3] * boneMat[3][1] + boneMat[2][1] * rotMat[2][2] + rotMat[2][1] * boneMat[1][1],
                boneMat[3][2] * rotMat[2][3] + boneMat[2][2] * rotMat[2][2] + boneMat[1][2] * rotMat[2][1],
                rotMat[2][1] * boneMat[1][3] + boneMat[3][3] * rotMat[2][3] + boneMat[2][3] * rotMat[2][2],
                0,
            },
            {
                boneMat[2][1] * rotMat[3][2] + rotMat[3][3] * boneMat[3][1] + rotMat[3][1] * boneMat[1][1],
                boneMat[3][2] * rotMat[3][3] + boneMat[2][2] * rotMat[3][2] + rotMat[3][1] * boneMat[1][2],
                rotMat[3][1] * boneMat[1][3] + boneMat[3][3] * rotMat[3][3] + boneMat[2][3] * rotMat[3][2],
                0,
            },
            {
                offX * boneMat[1][1] + offY * boneMat[2][1] + offZ * boneMat[3][1] + boneMat[4][1],
                offX * boneMat[1][2] + offY * boneMat[2][2] + offZ * boneMat[3][2] + boneMat[4][2],
                offX * boneMat[1][3] + offY * boneMat[2][3] + offZ * boneMat[3][3] + boneMat[4][3],
                1,
            },
        }
        setElementMatrix(element, finalMatrix)
        return true
    else
        setElementPosition(element, 0, 0, -1000)
        return false
    end
end

-- Sürekli kemik güncellemesi (Animasyonun çalışması için)
addEventHandler("onClientPedsProcessed", root, function()
    -- Sadece yakındaki oyuncuları döngüye al (Optimizasyon)
    for _, player in ipairs(getElementsByType("player", root, true)) do
        -- Eğer oyuncunun telefon elementi "acik" ise:
        if getElementData(player, "telefon_elinde") then
            -- Telefon objesi yoksa yarat
            if not activePhones[player] then
                activePhones[player] = createObject(phoneModel, 0, 0, 0)
                setElementCollisionsEnabled(activePhones[player], false)
                setElementDimension(activePhones[player], getElementDimension(player))
                setElementInterior(activePhones[player], getElementInterior(player))
            end

            -- Sağ kolu telefona bakacak şekilde bük (Hold Animasyonu)
            setElementBoneRotation(player, 22, 0, 320, -70) -- Omuz
            setElementBoneRotation(player, 23, 0, -90, 25)  -- Dirsek
            setElementBoneRotation(player, 24, 175, 0, -55) -- Bilek
            setElementBoneRotation(player, 25, -25, 0, 25)  -- El

            -- Karakterin kafa kemiğini (Bone 8) telefona bakacak şekilde eğ (Açı: 25)
            setElementBoneRotation(player, 8, 25, 0, 0)

            -- ÇÖZÜM BURADA: Kemik rotasyonlarını MTA motoruna ZORLA işlet! (Eksik olan buydu)
            updateElementRpHAnim(player)

            -- Objeyi tam olarak ele yapıştır
            if activePhones[player] then
                attachElementToBone(activePhones[player], player, 25, 0.02, 0.018, 0.05, 4.85, 4.9, 4.5)
                
                -- Oyuncu interior/dimension değiştirirse objeyi de taşı
                if getElementInterior(activePhones[player]) ~= getElementInterior(player) then
                    setElementInterior(activePhones[player], getElementInterior(player))
                    setElementDimension(activePhones[player], getElementDimension(player))
                end
            end
        else
            -- Telefon kapalıysa objeyi yok et (Kemikler otomatik düzelir)
            if activePhones[player] then
                destroyElement(activePhones[player])
                activePhones[player] = nil
            end
        end
    end
end)



addEvent("phone:receiveNews", true)
addEventHandler("phone:receiveNews", root, function(newsJson, isReporter)
    -- DİKKAT: "phoneBrowser" yazan yeri kendi client.lua'ndaki tarayıcı değişkeniyle değiştir.
    if isElement(phoneBrowser) then 
        executeBrowserJavascript(guiGetBrowser(phoneBrowser), string.format("loadNewsData(`%s`, %s)", newsJson, tostring(isReporter)))
    end
end)