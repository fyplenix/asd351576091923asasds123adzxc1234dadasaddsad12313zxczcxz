local r5_0 = {
  ClientKey = "123",
  ServerKey = "123",
}

local r6_0 = {
  guiGetScreenSize()
}
local r7_0 = r6_0[1] / 1920
local r8_0 = r6_0[2] / 1080
local r9_0 = r6_0[1] / 1920
local r10_0 = r6_0[2] / 1080
local r11_0 = {}
local r12_0 = {}
local r13_0 = false
local r14_0 = "2"
local r15_0 = "2"
local r16_0 = 0
local r17_0 = {}
local r18_0 = {
  head = 1,
  body = 0.5,
  feet = -0.5,
}
local r19_0 = "http://mta/" .. getResourceName(getThisResource()) .. "/core/web-side/ui.html"
local r20_0 = createBrowser(r6_0[1], r6_0[2], true, true)
local r24_0 = false

function dxCustomCreate()
  dxDrawImage(0, 0, r6_0[1], r6_0[2], r20_0, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end

addEventHandler("onClientBrowserCreated", r20_0, function()
  loadBrowserURL(source, r19_0)
end)

-- ========================================================
-- ÇÖZÜM 1: OYUNCU KUTUCUĞA TIKLADIĞINDA ALGILAYAN SİSTEM
-- ========================================================
local isTypingInBrowser = false
addEventHandler("onClientBrowserInputFocusChanged", root, function(gainedFocus)
    if source == r20_0 then
        isTypingInBrowser = gainedFocus
    end
end)

addEventHandler("onClientClick", root, function(r0_9, r1_9)
  if r1_9 == "down" then
    injectBrowserMouseDown(r20_0, r0_9)
    if r24_0 then
        focusBrowser(r20_0)
    end
  else
    injectBrowserMouseUp(r20_0, r0_9)
  end
end)

addEventHandler("onClientCursorMove", root, function(r0_10, r1_10, r2_10, r3_10)
  injectBrowserMouseMove(r20_0, r2_10, r3_10)
end)
addEventHandler("onClientKey", root, function(r0_11)
  if r0_11 == "mouse_wheel_down" then
    injectBrowserMouseWheel(r20_0, -40, 0)
  elseif r0_11 == "mouse_wheel_up" then
    injectBrowserMouseWheel(r20_0, 40, 0)
  end
end)

function SendNUIMessage(r0_12, r1_12)
  if isElement(r0_12) and type(r1_12) == "table" then
    return executeBrowserJavascript(r0_12, "window.postMessage(" .. toJSON(r1_12) .. "[0])")
  end
end
_isCursorOnElement = isCursorOnElement
function isCursorOnElement(r0_13, r1_13, r2_13, r3_13)
  return _isCursorOnElement(r9_0 * r0_13, r10_0 * r1_13, r9_0 * r2_13, r10_0 * r3_13)
end
function _isCursorOnElement (x, y, w, h)
    if (not isCursorShowing ( )) then
        return false
    end
    local cursorX, cursorY = getCursorPosition ( )
    if (cursorX and cursorY) then
        cursorX, cursorY = cursorX * r9_0, cursorY * r10_0
        return (cursorX >= x and cursorX <= x + w and cursorY >= y and cursorY <= y + h)
    end
    return false
end

local r21_0 = nil
local r22_0 = nil
local r23_0 = nil
function onLoadModels()
  for r4_15, r5_15 in pairs({
    [7] = { "core/assets/loader/male" },
    [9] = { "core/assets/loader/female" },
    [271] = { "core/assets/loader/male_police" },
    [272] = { "core/assets/loader/female_police" },
  }) do
    DFF = engineLoadDFF(r5_15[1] .. ".dff")
    TXD = engineLoadTXD(r5_15[1] .. ".txd")
    engineImportTXD(TXD, r4_15)
    engineReplaceModel(DFF, r4_15)
  end
  r21_0 = createObject(1915, -153.66035, 111.52838, -38.47705, 0, 0, 0)
  r22_0 = createObject(1938, -153.66035, 111.52838, -38.47705, 0, 0, 0)
  r23_0 = createObject(1865, -153.66035, 111.52838, -38.47705, 0, 0, 0)
  local r1_15 = engineLoadDFF("core/assets/loader/interior/policestation.dff", 1865)
  local r2_15 = engineLoadTXD("core/assets/loader/interior/policestation.txd")
  local r3_15 = engineLoadCOL("core/assets/loader/interior/policestation.col")
  engineImportTXD(r2_15, 1865)
  engineReplaceModel(r1_15, 1865)
  engineReplaceCOL(r3_15, 1865)
  engineReplaceModel(engineLoadDFF("core/assets/loader/interior/policestation2.dff", 1915), 1915)
  engineReplaceModel(engineLoadDFF("core/assets/loader/interior/policestation3.dff", 1938), 1938)
  local r6_15 = engineLoadDFF("core/assets/loader/interior/board.dff", 1937)
  engineImportTXD(engineLoadTXD("core/assets/loader/interior/board.txd"), 1937)
  engineReplaceModel(r6_15, 1937)
end
addEventHandler("onClientResourceStart", resourceRoot, onLoadModels)

local r25_0 = false
local r26_0 = false
local r27_0 = 0
local r28_0 = 0
local function r29_0()
  r27_0 = r27_0 + 0.002
  r28_0 = r28_0 + 0.0005
  if r28_0 >= 0.201 then
    r28_0 = 0
  end
  local r0_16 = { getElementPosition(r26_0) }
  setElementPosition(r26_0, r0_16[1] + r27_0, r0_16[2], r0_16[3] - r28_0)
end
addCommandHandler("camtest", function()
  startCutscene()
end)

function startCutscene()
  if not r25_0 then
    r25_0 = true
    setCameraMatrix(1595.6722412109, -2411.0598144531, 24.944299697876, 1595.0710449219, -2411.8510742188, 24.83310508728)
    r26_0 = createVehicle(592, 1420, -2496.66846, 55)
    setElementRotation(r26_0, 0, 0, -90)
    setElementFrozen(r26_0, true)
    addEventHandler("onClientRender", root, r29_0)
    setTimer(function()
      if r25_0 then
        fadeCamera(false, 0, 0, 0, 0)
        r25_0 = false
        setCameraTarget(localPlayer)
        destroyElement(r26_0)
        removeEventHandler("onClientRender", root, r29_0)
        r27_0 = 0
        r28_0 = 0
        setTimer(function()
          fadeCamera(true, 0.5)
          setElementPosition(localPlayer, config.Global.finishCustom[1], config.Global.finishCustom[2], config.Global.finishCustom[3])
          setElementRotation(localPlayer, 0, 0, config.Global.finishCustom[4])
        end, 800, 1)
      end
    end, 8000, 1)
  end
end

function onPreRenderHandler(r0_21)
  if getKeyState("mouse1") and isCursorOnElement(583, 7, 759, 933) then
    local r1_21, r2_21 = getCursorPosition()
    if tonumber(r1_21) then
      r1_21 = r1_21 * r6_0[1]
      r2_21 = r2_21 * r6_0[2]
      if not lastCursorPos then
        lastCursorPos = { onMoveStartX = r1_21, onMoveStartY = r2_21, yawStart = r13_0.rotation, pitchStart = r13_0.height }
      end
      r13_0.rotation = lastCursorPos.yawStart - (r1_21 - lastCursorPos.onMoveStartX) / r6_0[1] * 270
      r13_0.height = lastCursorPos.pitchStart + (r2_21 - lastCursorPos.onMoveStartY) / r6_0[2] * 20
      if r13_0.rotation <= 139.5 then r13_0.rotation = 139.5 end
      if r13_0.rotation >= 222 then r13_0.rotation = 222 end
      local r3_21 = math.abs(getElementDistanceFromCentreOfMassToBaseOfModel(localPlayer) - 1)
      if r3_21 < r13_0.height then
        r13_0.height = r3_21
      elseif r13_0.height < -2 then
        r13_0.height = -2
      end
    end
  elseif lastCursorPos then
    lastCursorPos = false
  end
  local r1_21 = 1.5
  local r2_21 = 0.1
  
  -- ÇÖZÜM 2: YAZI YAZARKEN YÖN TUŞLARI KAMERAYI DÖNDÜRMESİN
  if not isTypingInBrowser then
      if getKeyState("arrow_l") and not isMTAWindowActive() then
        if r13_0.rotation <= 139.5 then r13_0.rotation = 139.5 else r13_0.rotation = r13_0.rotation - r1_21 end
      end
      if getKeyState("arrow_r") and not isMTAWindowActive() then
        if r13_0.rotation >= 222 then r13_0.rotation = 222 else r13_0.rotation = r13_0.rotation + r1_21 end
      end
      if getKeyState("arrow_u") and not isMTAWindowActive() then
        r13_0.height = r13_0.height + r2_21
        local r3_21 = math.abs(getElementDistanceFromCentreOfMassToBaseOfModel(localPlayer) - 1)
        if r3_21 < r13_0.height then r13_0.height = r3_21 end
      end
      if getKeyState("arrow_d") and not isMTAWindowActive() then
        r13_0.height = r13_0.height - r2_21
        if r13_0.height < -2 then r13_0.height = -2 end
      end
  end

  if r13_0.zoomInterpolate then
    local r4_21 = (getTickCount() - r13_0.zoomInterpolate[1]) / 150
    r13_0.zoomLevel = interpolateBetween(r13_0.zoomInterpolate[2], 0, 0, r13_0.zoomInterpolate[3], 0, 0, r4_21, "InOutQuad")
    if r4_21 >= 1 then r13_0.zoomInterpolate = false end
  end
  if r13_0.moveInterpolate then
    local r4_21 = (getTickCount() - r13_0.moveInterpolate) / 475
    local r5_21, r6_21, r7_21 = r13_0, r13_0, r13_0
    local r8_21 = interpolateBetween
    local r9_21, r10_21, r11_21 = r13_0.startPos[1], r13_0.startPos[2], r13_0.startPos[3]
    local r12_21 = r13_0.stopPos[1] or r13_0.startPos[1]
    local r13_21 = r13_0.stopPos[2] or r13_0.startPos[2]
    r5_21.rotation, r6_21.height, r7_21.zoomLevel = r8_21(r9_21, r10_21, r11_21, r12_21, r13_21, r13_0.stopPos[3] or r13_0.startPos[3], r4_21, "InOutQuad")
    if r4_21 >= 1 then
      r13_0.moveInterpolate = false
      r13_0.zoomInterpolate = false
    end
  end
  r13_0.deltaX = r13_0.position[1] - r13_0.position[4]
  r13_0.deltaY = r13_0.position[2] - r13_0.position[5]
  r13_0.theta = math.rad(r13_0.rotation)
  local r3_21 = { ["1"] = { ["1"] = 0.7, ["2"] = 0.7, ["3"] = 0.7 }, ["2"] = { ["1"] = 0.1, ["2"] = 0.1, ["3"] = 0.1 }, ["3"] = { ["1"] = -0.7, ["2"] = -0.7, ["3"] = -0.7 } }
  camHeightOffset = interpolateBetween(r3_21[r15_0][r14_0], 0, 0, r3_21[r14_0][r15_0], 0, 0, (getTickCount() - r13_0.tickCount) / 350, "Linear")
  setCameraMatrix(r13_0.position[4] + r13_0.deltaX * math.cos(r13_0.theta) - r13_0.deltaY * math.sin(r13_0.theta), r13_0.position[5] + r13_0.deltaX * math.sin(r13_0.theta) + r13_0.deltaY * math.cos(r13_0.theta), r13_0.position[3] + r13_0.height + camHeightOffset, r13_0.position[4], r13_0.position[5], r13_0.position[6] + camHeightOffset, 0, 70 / r13_0.zoomLevel)
end

function changeCamPos(r0_22)
  r15_0 = r14_0
  if r0_22 == "0" then return elseif r0_22 == "1" or r0_22 == "2" or r0_22 == "3" then
    r14_0 = r0_22
    r13_0.tickCount = getTickCount()
  end
end

function onKeyHandler(r0_23, r1_23)
  -- ÇÖZÜM 3: EĞER KUTUCUĞA YAZI YAZILIYORSA TUŞLAR ASLA KAMERAYI ETKİLEMEZ
  if isTypingInBrowser then return end 

  if isCursorShowing() and not isMTAWindowActive() and r13_0 then
    if isCursorOnElement(583, 7, 759, 933) and (r0_23 == "mouse_wheel_up" or r0_23 == "mouse_wheel_down") and not r13_0.zoomInterpolate then
      local r2_23 = 0
      if r0_23 == "mouse_wheel_down" and r13_0.zoomLevel > 0.8 then r2_23 = r13_0.zoomLevel - 0.2 * r13_0.zoomLevel
      elseif r0_23 == "mouse_wheel_up" and r13_0.zoomLevel <= 2.5 then r2_23 = r13_0.zoomLevel + 0.2 * r13_0.zoomLevel end
      if r2_23 < 0.8 then r2_23 = 0.8 elseif r2_23 > 2.5 then r2_23 = 2.5 end
      r13_0.zoomInterpolate = { getTickCount(), r13_0.zoomLevel, r2_23 }
    end
    if r0_23 == "w" and r1_23 then
      if r14_0 == "1" then changeCamPos("3") elseif r14_0 == "2" then changeCamPos("1") elseif r14_0 == "3" then changeCamPos("2") end
    end
    if r0_23 == "s" and r1_23 then
      if r14_0 == "1" then changeCamPos("2") elseif r14_0 == "2" then changeCamPos("3") elseif r14_0 == "3" then changeCamPos("1") end
    end
    if r0_23 == "a" and r1_23 then
      local r2_23 = { getElementRotation(localPlayer) }
      setElementRotation(localPlayer, r2_23[1], r2_23[2], r2_23[3] - 20)
    end
    if r0_23 == "d" and r1_23 then
      local r2_23 = { getElementRotation(localPlayer) }
      setElementRotation(localPlayer, r2_23[1], r2_23[2], r2_23[3] + 20)
    end
  end
end

function startCam()
  local r0_24, r1_24, r2_24 = getElementPosition(localPlayer)
  local r3_24, r4_24, r5_24 = getElementRotation(localPlayer)
  addEventHandler("onClientKey", getRootElement(), onKeyHandler, true, "low-500")
  addEventHandler("onClientPreRender", getRootElement(), onPreRenderHandler)
  r13_0 = {}
  r13_0.tickCount = getTickCount()
  r13_0.view = "base"
  r13_0.rotation = 180
  r13_0.height = -1
  r13_0.zoomLevel = 1
  r13_0.zoomInterpolate = false
  r13_0.moveInterpolate = false
  r13_0.startPos = false
  r13_0.stopPos = false
  r13_0.position = {
    r0_24 - 7.5 * math.sin(r3_24),
    r1_24 + 1 * math.cos(r3_24) + 1.5,
    r2_24 + 1.5,
    r0_24,
    r1_24,
    r2_24
  }
end

local r30_0 = nil

function startCreation(r0_25, targetGender)
  local secilenCinsiyet = targetGender or 7 

  if r24_0 then
    SendNUIMessage(r20_0, { showVexCreator = false })
    removeEventHandler("onClientRender", root, dxCustomCreate)
    r24_0 = false
    if config.Global.ShowCursor then showCursor(false) end
    
    guiSetInputEnabled(false)
    showChat(true)
    setPlayerHudComponentVisible("all", false) -- GTA'nın eski Radar ve Para/Silah HUD'unu tamamen kapat!
    setPlayerHudComponentVisible("crosshair", true) -- Sadece silah nişangahı (artı işareti) açık kalsın
    
    setCameraTarget(r0_25)
    setElementDimension(r0_25, 0)
    fadeCamera(true, 1.0)
    
    if r30_0 and isElement(r30_0) then destroyElement(r30_0) end
    removeEventHandler("onClientKey", getRootElement(), onKeyHandler, true, "low-500")
    removeEventHandler("onClientPreRender", getRootElement(), onPreRenderHandler)
    removeEventHandler("onClientPedsProcessed", getRootElement(), changeBoneRotation)
  else
    fadeCamera(false, 0.8, 0, 0, 0)
    
    SendNUIMessage(r20_0, { showVexCreator = true, forceGender = secilenCinsiyet })
    
    r24_0 = true
    addEventHandler("onClientRender", root, dxCustomCreate)
    if config.Global.ShowCursor then showCursor(true) end
    
    guiSetInputEnabled(true)
    focusBrowser(r20_0)
    
    -- ÇÖZÜM 4: CHAT VE HUD BURADA GİZLENİYOR
    showChat(false)
    setPlayerHudComponentVisible("all", false)
    
    triggerServerEvent("HG->changeSkinID", r0_25, secilenCinsiyet)
    
    local ozelBoyut = getElementData(r0_25, config.Global.elementID) or getElementData(r0_25, "hesapID") or math.random(1000, 9000)
    
    setElementDimension(r21_0, ozelBoyut)
    setElementDimension(r22_0, ozelBoyut)
    setElementDimension(r23_0, ozelBoyut)
    setElementDimension(r0_25, ozelBoyut)
    
    setElementAlpha(r0_25, 255)
    setElementPosition(r0_25, -153.2, 112.40108, -37.47705)
    setElementRotation(r0_25, 0, 0, 180)
    
    r11_0[r0_25] = { 1, 1 }
    function changeBoneRotation()
      setElementBoneRotation(r0_25, 23, 0, -90, 20)
      updateElementRpHAnim(r0_25)
    end
    addEventHandler("onClientPedsProcessed", getRootElement(), changeBoneRotation)
    
    if not isElement(r30_0) then r30_0 = createObject(1937, 0, 0, 0) end
    setObjectScale(r30_0, 1.15)
    setElementDimension(r30_0, ozelBoyut)
    
    if exports.sintonia_pAttach then
        exports.sintonia_pAttach:attach(r30_0, r0_25, 25, 0.24, 0.067, 0, 0, 0, 18)
    end
    
    setTimer(function()
      fadeCamera(true, 0.5)
      startCam()
    end, 800, 1)
  end
end

addEvent("HG->CustomopenMenu", true)
addEventHandler("HG->CustomopenMenu", root, startCreation)

addEvent("HG->changeGenderCreation", true)
addEventHandler("HG->changeGenderCreation", root, function(r0_28)
  if r0_28 then
    r17_0 = {}
    if r0_28 == "Mulher" then
      triggerServerEvent("HG->changeSkinID", localPlayer, 9)
      setRoupa(localPlayer, 9, "rosto", 1, 1)
      setRoupa(localPlayer, 9, "torso1", 1, 1)
      setRoupa(localPlayer, 9, "torso2", 1, 1)
      setRoupa(localPlayer, 9, "torso3", 1, 1)
      setRoupa(localPlayer, 9, "torso4", 1, 1)
      setRoupa(localPlayer, 9, "mao", 1, 1)
      setRoupa(localPlayer, 9, "bracoe", 1, 1)
      setRoupa(localPlayer, 9, "ombroe", 1, 1)
      setRoupa(localPlayer, 9, "pernae1", 1, 1)
      setRoupa(localPlayer, 9, "pernae2", 1, 1)
      setRoupa(localPlayer, 9, "pernae3", 1, 1)
      setRoupa(localPlayer, 9, "pernae4", 1, 1)
      setRoupa(localPlayer, 9, "pernae5", 1, 1)
      setRoupa(localPlayer, 9, "pernae6", 1, 1)
      setRoupa(localPlayer, 9, "bracod", 1, 1)
      setRoupa(localPlayer, 9, "ombrod", 1, 1)
      setRoupa(localPlayer, 9, "pernad1", 1, 1)
      setRoupa(localPlayer, 9, "pernad2", 1, 1)
      setRoupa(localPlayer, 9, "pernad3", 1, 1)
      setRoupa(localPlayer, 9, "pernad4", 1, 1)
      setRoupa(localPlayer, 9, "pernad5", 1, 1)
      setRoupa(localPlayer, 9, "pernad6", 1, 1)
      setRoupa(localPlayer, 9, "pe1", 1, 1)
      setRoupa(localPlayer, 9, "calca", 1, 1)
      setRoupa(localPlayer, 9, "camisa", 1, 1)
    elseif r0_28 == "Homem" then
      triggerServerEvent("HG->changeSkinID", localPlayer, 7)
      setRoupa(localPlayer, 7, "rosto", 1, 1)
      setRoupa(localPlayer, 7, "torso1", 1, 1)
      setRoupa(localPlayer, 7, "torso2", 1, 1)
      setRoupa(localPlayer, 7, "torso3", 1, 1)
      setRoupa(localPlayer, 7, "mao", 1, 1)
      setRoupa(localPlayer, 7, "bracoe", 1, 1)
      setRoupa(localPlayer, 7, "ombroe", 1, 1)
      setRoupa(localPlayer, 7, "pernae1", 1, 1)
      setRoupa(localPlayer, 7, "pernae2", 1, 1)
      setRoupa(localPlayer, 7, "pernae3", 1, 1)
      setRoupa(localPlayer, 7, "pernae4", 1, 1)
      setRoupa(localPlayer, 7, "pernae5", 1, 1)
      setRoupa(localPlayer, 7, "pee", 1, 1)
      setRoupa(localPlayer, 7, "bracod", 1, 1)
      setRoupa(localPlayer, 7, "ombrod", 1, 1)
      setRoupa(localPlayer, 7, "pernad1", 1, 1)
      setRoupa(localPlayer, 7, "pernad2", 1, 1)
      setRoupa(localPlayer, 7, "pernad3", 1, 1)
      setRoupa(localPlayer, 7, "pernad4", 1, 1)
      setRoupa(localPlayer, 7, "pernad5", 1, 1)
      setRoupa(localPlayer, 7, "ped", 1, 1)
    end
  end
end)

local r31_0 = {}
local r32_0 = {}
local r33_0 = {}
local r34_0 = "\ttexture tex;\n\ttechnique replace {\n\t\tpass P0 {\n\t\t\tTexture[0] = tex;\n\t\t}\n\t}\n"

function applyTexture(r0_29, r1_29, r2_29)
  local r3_29 = string.sub(r2_29, 1, -5)
  local r4_29 = r3_29 .. ".png"
  if not fileExists(r4_29) then
    r4_29 = r3_29 .. ".jpeg"
    if not fileExists(r4_29) then return end
  end
  r31_0[r0_29] = dxCreateTexture(r4_29)
  dxSetShaderValue(r1_29, "tex", r31_0[r0_29])
  destroyElement(r31_0[r0_29])
  r31_0[r0_29] = {}
end

function clearShaderClothe(r0_30, r1_30, r2_30, r3_30)
  if not r32_0[r0_30] then r32_0[r0_30] = {}; r31_0[r0_30] = {} end
  if not r32_0[r0_30][r2_30] then r32_0[r0_30][r2_30] = {} end
  if not isElement(r32_0[r0_30][r2_30]) then r32_0[r0_30][r2_30] = {} end
  if isElement(r32_0[r0_30][r2_30]) then
    destroyElement(r32_0[r0_30][r2_30])
    r32_0[r0_30][r2_30] = {}
  end
  if not r17_0[r2_30] then r17_0[r2_30] = {} end
  if r3_30 then
    r32_0[r0_30][r2_30] = dxCreateShader(r34_0, 0, 0, false, "ped")
    engineApplyShaderToWorldTexture(r32_0[r0_30][r2_30], roupas_categorias[r1_30][r2_30][r3_30], r0_30)
  end
end
addEvent("clearShaderClothe", true)
addEventHandler("clearShaderClothe", root, clearShaderClothe)

local r35_0 = {}
local r36_0 = {}

function setRoupa(r0_31, r1_31, r2_31, r3_31, r4_31)
  if not roupas_categorias[r1_31][r2_31] then return end
  r3_31 = tonumber(r3_31)
  r4_31 = tonumber(r4_31)
  if r4_31 <= 0 then
    if r1_31 == 272 and r2_31 ~= "chapeu" then return end
    if r2_31 == "chapeu" then setPlayerRoupa(r0_31, "cabelo", r35_0[1], r35_0[2])
    elseif r2_31 == "camisa" then
      if r1_31 == 9 then r4_31 = 1; r3_31 = 1 end
      setPlayerRoupa(r0_31, "torso1", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
      addNewItemToCart(r0_31, r2_31, "remove")
    elseif r2_31 == "calca" then
      setPlayerRoupa(r0_31, "pernae1", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernae2", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernad1", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernad2", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
      setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
      if r1_31 == 9 then
        setPlayerRoupa(r0_31, "pernae6", r11_0[r0_31][1], r11_0[r0_31][2])
        setPlayerRoupa(r0_31, "pernad6", r11_0[r0_31][1], r11_0[r0_31][2])
        r4_31 = 1; r3_31 = 1
      else
        setPlayerRoupa(r0_31, "cueca", r11_0[r0_31][1], r11_0[r0_31][2])
      end
      addNewItemToCart(r0_31, r2_31, "remove")
    elseif r2_31 == "sapato" then
      if r1_31 == 9 then
        setPlayerRoupa(r0_31, "pe1", r11_0[r0_31][1], r11_0[r0_31][2])
        setPlayerRoupa(r0_31, "pe2", r11_0[r0_31][1], r11_0[r0_31][2])
        setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
        setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
      elseif r1_31 == 7 or r1_31 == 271 then
        setPlayerRoupa(r0_31, "pee", r11_0[r0_31][1], r11_0[r0_31][2])
        setPlayerRoupa(r0_31, "ped", r11_0[r0_31][1], r11_0[r0_31][2])
      end
      addNewItemToCart(r0_31, r2_31, "remove")
    end
    clearShaderClothe(r0_31, r1_31, r2_31)
    addNewItemToCart(r0_31, r2_31, "remove")
  end
  if roupas_categorias[r1_31][r2_31][r3_31] and 0 < r4_31 then
    clearShaderClothe(r0_31, r1_31, r2_31, r3_31)
    r17_0[r2_31] = { r3_31, r4_31 }
    if r1_31 == 7 then
      if r2_31 == "rosto" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/heads/" .. r4_31 .. ".png")
      elseif r2_31 == "torso1" or r2_31 == "torso2" or r2_31 == "torso3" or r2_31 == "mao" or r2_31 == "bracoe" or r2_31 == "ombroe" or r2_31 == "bracod" or r2_31 == "ombrod" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/torso/" .. r4_31 .. ".png")
      elseif r2_31 == "pernae1" or r2_31 == "pernae2" or r2_31 == "pernae3" or r2_31 == "pernae4" or r2_31 == "pernae5" or r2_31 == "pernad1" or r2_31 == "pernad2" or r2_31 == "pernad3" or r2_31 == "pernad4" or r2_31 == "pernad5" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/leg/" .. r4_31 .. ".png")
      elseif r2_31 == "pee" or r2_31 == "ped" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/feet/" .. r4_31 .. ".png")
      elseif r2_31 == "cueca" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/underwear/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "cabelo" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        r35_0 = { r3_31, r4_31 }
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/hair/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "sobrancelha" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/eyebrown/" .. r4_31 .. ".png")
      elseif r2_31 == "barba" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/beards/" .. r4_31 .. ".png")
      elseif r2_31 == "camisa" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        if r3_31 == 1 then
          clearShaderClothe(r0_31, r1_31, "tatto_corpo")
          clearShaderClothe(r0_31, r1_31, "tatto_costas")
          clearShaderClothe(r0_31, r1_31, "torso1")
          setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 then
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso3")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          clearShaderClothe(r0_31, r1_31, "bracoe")
          clearShaderClothe(r0_31, r1_31, "bracod")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "tatto_corpo")
          clearShaderClothe(r0_31, r1_31, "tatto_costas")
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          clearShaderClothe(r0_31, r1_31, "bracoe")
          clearShaderClothe(r0_31, r1_31, "bracod")
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "calca" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        if r3_31 == 1 or r3_31 == 2 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae5")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad5")
          clearShaderClothe(r0_31, r1_31, "cueca")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "cueca")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "cueca")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 5 or r3_31 == 6 or r3_31 == 7 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "cueca")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          setPlayerRoupa(r0_31, "pernae2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad1")
          setPlayerRoupa(r0_31, "pernad2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "sapato" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        if r3_31 == 1 or r3_31 == 2 then
          setPlayerRoupa(r0_31, "pee", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ped", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/slipper/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "pee")
          clearShaderClothe(r0_31, r1_31, "ped")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/slipper/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "pee")
          clearShaderClothe(r0_31, r1_31, "ped")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/boot/1/" .. r4_31 .. ".png")
        elseif r3_31 == 5 then
          clearShaderClothe(r0_31, r1_31, "pee")
          clearShaderClothe(r0_31, r1_31, "ped")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/boot/2/" .. r4_31 .. ".png")
        elseif r3_31 == 6 then
          clearShaderClothe(r0_31, r1_31, "pee")
          clearShaderClothe(r0_31, r1_31, "ped")
          clearShaderClothe(r0_31, r1_31, "pernad5")
          clearShaderClothe(r0_31, r1_31, "pernae5")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/boot/3/" .. r4_31 .. ".png")
        elseif r3_31 == 7 then
          clearShaderClothe(r0_31, r1_31, "pee")
          clearShaderClothe(r0_31, r1_31, "ped")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/boot/4/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "mochila" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/backpack/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "brinco" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/ear/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "brincotrans" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/trans/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "mascara" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/mask/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "moletom" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/mask/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "relogio" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/clock/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "oculos" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/glasse/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "colete" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/vest/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "chapeu" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        clearShaderClothe(r0_31, r1_31, "cabelo")
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/hat/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "corrente" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/necklace/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_pernae1" or r2_31 == "tatto_pernae2" or r2_31 == "tatto_pernae3" or r2_31 == "tatto_pernae4" or r2_31 == "tatto_pernae5" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/legs_top/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_pernad1" or r2_31 == "tatto_pernad2" or r2_31 == "tatto_pernad3" or r2_31 == "tatto_pernad4" or r2_31 == "tatto_pernad5" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/legs_top/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_bracoe" or r2_31 == "tatto_bracod" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/arms/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_costas" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/torso_back/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_corpo" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/torso_chest/" .. r4_31 .. ".png")
      else
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/" .. r2_31 .. "/" .. r3_31 .. "/" .. r4_31 .. ".png")
      end
    elseif r1_31 == 9 then
      if r2_31 == "tatto_bracoe" or r2_31 == "tatto_bracod" or r2_31 == "tatto_pernae1" or r2_31 == "tatto_pernae2" or r2_31 == "tatto_pernae3" or r2_31 == "tatto_pernae4" or r2_31 == "tatto_pernae5" or r2_31 == "tatto_pernae6" or r2_31 == "tatto_pernad1" or r2_31 == "tatto_pernad2" or r2_31 == "tatto_pernad3" or r2_31 == "tatto_pernad4" or r2_31 == "tatto_pernad5" or r2_31 == "tatto_pernad6" or r2_31 == "tatto_ombroe" or r2_31 == "tatto_ombrod" or r2_31 == "tatto_costas" or r2_31 == "tatto_corpo" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
      end
      if r2_31 == "rosto" then
        clearShaderClothe(r0_31, r1_31, "barba")
        clearShaderClothe(r0_31, r1_31, "sobrancelha")
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/heads/" .. r4_31 .. ".png")
      elseif r2_31 == "torso1" or r2_31 == "torso2" or r2_31 == "torso3" or r2_31 == "torso4" or r2_31 == "mao" or r2_31 == "bracoe" or r2_31 == "ombroe" or r2_31 == "bracod" or r2_31 == "ombrod" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/torso/" .. r4_31 .. ".png")
      elseif r2_31 == "pernae1" or r2_31 == "pernae2" or r2_31 == "pernae3" or r2_31 == "pernae4" or r2_31 == "pernae5" or r2_31 == "pernae6" or r2_31 == "pernad1" or r2_31 == "pernad2" or r2_31 == "pernad3" or r2_31 == "pernad4" or r2_31 == "pernad5" or r2_31 == "pernad6" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/leg/" .. r4_31 .. ".png")
      elseif r2_31 == "pe1" or r2_31 == "pe2" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/feet/" .. r4_31 .. ".png")
      elseif r2_31 == "camisa" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        if r3_31 == 1 then
          setPlayerRoupa(r0_31, "torso1", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 then
          setPlayerRoupa(r0_31, "torso1", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "torso2")
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso4", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "tatto_costas2")
          clearShaderClothe(r0_31, r1_31, "tatto_costas3")
          clearShaderClothe(r0_31, r1_31, "tatto_corpo2")
          setPlayerRoupa(r0_31, "torso1", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso4")
          setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 5 then
          clearShaderClothe(r0_31, r1_31, "tatto_costas1")
          clearShaderClothe(r0_31, r1_31, "tatto_costas2")
          clearShaderClothe(r0_31, r1_31, "tatto_costas3")
          clearShaderClothe(r0_31, r1_31, "tatto_corpo1")
          clearShaderClothe(r0_31, r1_31, "tatto_corpo2")
          clearShaderClothe(r0_31, r1_31, "tatto_corpo3")
          clearShaderClothe(r0_31, r1_31, "tatto_corpo4")
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso3")
          clearShaderClothe(r0_31, r1_31, "torso4")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 6 then
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso3")
          clearShaderClothe(r0_31, r1_31, "torso4")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          clearShaderClothe(r0_31, r1_31, "bracod")
          clearShaderClothe(r0_31, r1_31, "bracoe")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        else
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "calca" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        if r3_31 == 1 then
          setPlayerRoupa(r0_31, "pernae1", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae6", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad1", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad6", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae5")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae6")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad5")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad6")
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          clearShaderClothe(r0_31, r1_31, "pernad4")
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad6")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          clearShaderClothe(r0_31, r1_31, "pernae4")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernae6")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae5")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae6")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad5")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad6")
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          clearShaderClothe(r0_31, r1_31, "pernad4")
          clearShaderClothe(r0_31, r1_31, "pernad5")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          clearShaderClothe(r0_31, r1_31, "pernae4")
          clearShaderClothe(r0_31, r1_31, "pernae5")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae6", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad6", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad6")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernae6")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 5 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae5")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad4")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad5")
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          clearShaderClothe(r0_31, r1_31, "pernad4")
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad6", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          clearShaderClothe(r0_31, r1_31, "pernae4")
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae6", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 6 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad1")
          setPlayerRoupa(r0_31, "pernad2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad6", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernae1")
          setPlayerRoupa(r0_31, "pernae2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae6", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        else
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "sapato" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        if r3_31 == 1 or r3_31 == 2 or r3_31 == 3 then
          setPlayerRoupa(r0_31, "pe1", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pe2", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/boot/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 or r3_31 == 5 or r3_31 == 6 then
          clearShaderClothe(r0_31, r1_31, "pe1")
          clearShaderClothe(r0_31, r1_31, "pe2")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/boot/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 7 then
          clearShaderClothe(r0_31, r1_31, "pe1")
          clearShaderClothe(r0_31, r1_31, "pe2")
          clearShaderClothe(r0_31, r1_31, "pernae5")
          clearShaderClothe(r0_31, r1_31, "pernad5")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/boot/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "mochila" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/backpack/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "brinco" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/ear/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "mascara" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/mask/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "relogio" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/clock/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "cabelo" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        r35_0 = { r3_31, r4_31 }
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/hair/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "sobrancelha" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/eyebrown/" .. r4_31 .. ".png")
      elseif r2_31 == "barba" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/beards/" .. r4_31 .. ".png")
      elseif r2_31 == "maquiagem" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/makeup/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_pernae1" or r2_31 == "tatto_pernae2" or r2_31 == "tatto_pernae3" or r2_31 == "tatto_pernae4" or r2_31 == "tatto_pernae5" or r2_31 == "tatto_pernae6" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/legs_top/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_pernad1" or r2_31 == "tatto_pernad2" or r2_31 == "tatto_pernad3" or r2_31 == "tatto_pernad4" or r2_31 == "tatto_pernad5" or r2_31 == "tatto_pernad6" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/legs_top/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_bracoe" or r2_31 == "tatto_bracod" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/tattoo/arms/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_costas1" or r2_31 == "tatto_costas2" or r2_31 == "tatto_costas3" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tattoo/torso_back_bottom/" .. r4_31 .. ".png")
      elseif r2_31 == "tatto_corpo1" or r2_31 == "tatto_corpo2" or r2_31 == "tatto_corpo3" or r2_31 == "tatto_corpo4" then
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/tattoo/torso_chest/" .. r4_31 .. ".png")
      else
        addNewItemToCart(r0_31, r2_31, "add", r3_31, r4_31)
        applyTexture(r0_31, r32_0[r0_31][r2_31], "files/roupas/" .. r2_31 .. "/" .. r3_31 .. "/" .. r4_31 .. ".png")
      end
    elseif r1_31 == 271 then
      r36_0[r0_31][r2_31] = { r2_31, r3_31, r4_31 }
      if r2_31 == "rosto" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/heads/" .. r4_31 .. ".png")
      elseif r2_31 == "torso1" or r2_31 == "torso2" or r2_31 == "torso3" or r2_31 == "mao" or r2_31 == "bracoe" or r2_31 == "ombroe" or r2_31 == "bracod" or r2_31 == "ombrod" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/torso/" .. r4_31 .. ".png")
      elseif r2_31 == "pernae1" or r2_31 == "pernae2" or r2_31 == "pernae3" or r2_31 == "pernae4" or r2_31 == "pernae5" or r2_31 == "pernad1" or r2_31 == "pernad2" or r2_31 == "pernad3" or r2_31 == "pernad4" or r2_31 == "pernad5" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/leg/" .. r4_31 .. ".png")
      elseif r2_31 == "pee" or r2_31 == "ped" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/feet/" .. r4_31 .. ".png")
      elseif r2_31 == "cueca" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/underwear/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "cabelo" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/hair/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "sobrancelha" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/eyebrown/" .. r4_31 .. ".png")
      elseif r2_31 == "barba" then applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/beards/" .. r4_31 .. ".png")
      elseif r2_31 == "camisa" then
        if r3_31 == 1 then
          clearShaderClothe(r0_31, r1_31, "tatto_corpo")
          clearShaderClothe(r0_31, r1_31, "tatto_costas")
          clearShaderClothe(r0_31, r1_31, "torso1")
          setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 or r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso3")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "ombroe")
          clearShaderClothe(r0_31, r1_31, "bracoe")
          clearShaderClothe(r0_31, r1_31, "bracod")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        else
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "calca" then
        if r3_31 == 1 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "cueca")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
        elseif r3_31 == 2 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "cueca")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          setPlayerRoupa(r0_31, "pernae2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad1")
          setPlayerRoupa(r0_31, "pernad2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
        end
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "sapato" then
        clearShaderClothe(r0_31, r1_31, "ped")
        clearShaderClothe(r0_31, r1_31, "pee")
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/boot/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "colete" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/vest/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "chapeu" then
        clearShaderClothe(r0_31, r1_31, "cabelo")
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/hat/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "cinto" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/271/belt/" .. r3_31 .. "/" .. r4_31 .. ".png")
      end
    elseif r1_31 == 272 then
      r36_0[r0_31][r2_31] = { r2_31, r3_31, r4_31 }
      if r2_31 == "rosto" then
        clearShaderClothe(r0_31, r1_31, "barba")
        clearShaderClothe(r0_31, r1_31, "sobrancelha")
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/7/heads/" .. r4_31 .. ".png")
      elseif r2_31 == "torso1" or r2_31 == "torso2" or r2_31 == "torso3" or r2_31 == "torso4" or r2_31 == "mao" or r2_31 == "bracoe" or r2_31 == "ombroe" or r2_31 == "bracod" or r2_31 == "ombrod" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/torso/" .. r4_31 .. ".png")
      elseif r2_31 == "pernae1" or r2_31 == "pernae2" or r2_31 == "pernae3" or r2_31 == "pernae4" or r2_31 == "pernae5" or r2_31 == "pernae6" or r2_31 == "pernad1" or r2_31 == "pernad2" or r2_31 == "pernad3" or r2_31 == "pernad4" or r2_31 == "pernad5" or r2_31 == "pernad6" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/leg/" .. r4_31 .. ".png")
      elseif r2_31 == "pe1" or r2_31 == "pe2" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/feet/" .. r4_31 .. ".png")
      elseif r2_31 == "cabelo" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/9/hair/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "camisa" then
        if r3_31 == 1 then
          setPlayerRoupa(r0_31, "ombrod", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "ombroe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso1", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso2", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "torso4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 or r3_31 == 3 then
          clearShaderClothe(r0_31, r1_31, "ombroe")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso3")
          clearShaderClothe(r0_31, r1_31, "torso4")
          setPlayerRoupa(r0_31, "bracoe", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "bracod", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 4 then
          clearShaderClothe(r0_31, r1_31, "ombroe")
          clearShaderClothe(r0_31, r1_31, "ombrod")
          clearShaderClothe(r0_31, r1_31, "torso1")
          clearShaderClothe(r0_31, r1_31, "torso2")
          clearShaderClothe(r0_31, r1_31, "torso3")
          clearShaderClothe(r0_31, r1_31, "torso4")
          clearShaderClothe(r0_31, r1_31, "bracoe")
          clearShaderClothe(r0_31, r1_31, "bracod")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/tshirts/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "calca" then
        if r3_31 == 1 then
          clearShaderClothe(r0_31, r1_31, "tatto_pernae1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernae3")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad1")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad2")
          clearShaderClothe(r0_31, r1_31, "tatto_pernad3")
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          clearShaderClothe(r0_31, r1_31, "pernad3")
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernad6")
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          clearShaderClothe(r0_31, r1_31, "pernae3")
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernae6")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 then
          clearShaderClothe(r0_31, r1_31, "pernad1")
          clearShaderClothe(r0_31, r1_31, "pernad2")
          setPlayerRoupa(r0_31, "pernad3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernad6", r11_0[r0_31][1], r11_0[r0_31][2])
          clearShaderClothe(r0_31, r1_31, "pernae1")
          clearShaderClothe(r0_31, r1_31, "pernae2")
          setPlayerRoupa(r0_31, "pernae3", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae4", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae5", r11_0[r0_31][1], r11_0[r0_31][2])
          setPlayerRoupa(r0_31, "pernae6", r11_0[r0_31][1], r11_0[r0_31][2])
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/pants/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "sapato" then
        if r3_31 == 1 then
          clearShaderClothe(r0_31, r1_31, "pe1")
          clearShaderClothe(r0_31, r1_31, "pe2")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/boot/" .. r3_31 .. "/" .. r4_31 .. ".png")
        elseif r3_31 == 2 then
          clearShaderClothe(r0_31, r1_31, "pe1")
          clearShaderClothe(r0_31, r1_31, "pe2")
          applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/boot/" .. r3_31 .. "/" .. r4_31 .. ".png")
        end
      elseif r2_31 == "colete" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/vest/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "chapeu" then
        clearShaderClothe(r0_31, r1_31, "cabelo")
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/hat/" .. r3_31 .. "/" .. r4_31 .. ".png")
      elseif r2_31 == "cinto" then
        applyTexture(r0_31, r32_0[r0_31][r2_31], "core/assets/clothes/272/belt/" .. r3_31 .. "/" .. r4_31 .. ".png")
      end
    end
  elseif r2_31 and r3_31 < 1 then
    clearShaderClothe(r0_31, r1_31, r2_31)
  end
end
function setPlayerRoupa(r0_32, r1_32, r2_32, r3_32)
  if r0_32 and r1_32 and r2_32 and r3_32 then
    if r1_32 == "mao" then
      r11_0[r0_32] = { r2_32, r3_32 }
    end
    if r1_32 == "rosto" then
      r12_0[r0_32] = { r2_32, r3_32 }
    end
    if getElementModel(r0_32) == 7 or getElementModel(r0_32) == 9 or getElementModel(r0_32) == 271 or getElementModel(r0_32) == 272 then
      setRoupa(r0_32, getElementModel(r0_32), "" .. r1_32 .. "", "" .. r2_32 .. "", "" .. r3_32 .. "")
    end
  end
end
addEvent("setPlayerRoupa", true)
addEventHandler("setPlayerRoupa", root, setPlayerRoupa)
addEvent("HG->setPlayerRoupaInit", true)
addEventHandler("HG->setPlayerRoupaInit", root, function(r0_33, r1_33, r2_33)
  local r3_33 = localPlayer
  if r0_33 == "mao" then
    r11_0[r3_33] = { r1_33, r2_33 }
  end
  if getElementModel(r3_33) == 7 or getElementModel(r3_33) == 9 or getElementModel(r3_33) == 271 or getElementModel(r3_33) == 272 then
    setRoupa(r3_33, getElementModel(r3_33), "" .. r0_33 .. "", "" .. r1_33 .. "", "" .. r2_33 .. "")
  end
end)
addEventHandler("onClientPlayerQuit", getRootElement(), function()
  if roupas_categorias[getElementModel(source)] then
    for r3_34, r4_34 in pairs(roupas_categorias[getElementModel(source)]) do
      clearShaderClothe(source, getElementModel(source), r3_34)
    end
    r32_0[source] = nil
  end
end)

addEvent("HG->confirmCreationClient", true)
addEventHandler("HG->confirmCreationClient", root, function(r0_35, ad, soyad, yas)
  triggerServerEvent("HG->confirmCharacterCreation", getLocalPlayer(), getLocalPlayer(), r17_0, r0_35, ad, soyad, yas)
end)

local r37_0 = dxCreateTexture("core/web-side/assets/clothes.png")
local r38_0 = dxCreateTexture("core/web-side/assets/barber.png")
local r39_0 = dxCreateTexture("core/web-side/assets/tattoo.png")
local r40_0 = dxCreateTexture("core/web-side/assets/Marcador.png")
local r41_0 = dxCreateTexture("core/web-side/assets/police.png")
local r42_0 = getTickCount()
addEventHandler("onClientRender", root, function()
  if not customOpenShop then
    local r0_36, r1_36 = interpolateBetween(0.4, 1.4, 0, 0.7, 1.7, 0, (getTickCount() - r42_0) / 1500, "SineCurve")
    local r2_36, r3_36, r4_36 = interpolateBetween(1.21, 1.2, 2.5, 1.22, 1.3, 2.6, (getTickCount() - r42_0) / 1500, "SineCurve")
    local r5_36 = { getElementPosition(localPlayer) }
    for r9_36 = 1, #clotheShops, 1 do
      if getElementData(localPlayer, "HG->shopInUse") == true then return end
      local r10_36 = clotheShops[r9_36]
      if getDistanceBetweenPoints3D(r5_36[1], r5_36[2], r5_36[3], r10_36[1], r10_36[2], r10_36[3]) <= 35 then
        local r11_36 = r10_36[1]
        local r12_36 = r10_36[2]
        local r13_36 = r10_36[3] - 1
        dxDrawMaterialLine3D(r11_36, r12_36, r13_36 + r1_36, r11_36, r12_36, r13_36 + r0_36, r37_0, 1, tocolor(markersColors[1].icon[1], markersColors[1].icon[2], markersColors[1].icon[3], markersColors[1].icon[4]))
        dxDrawMaterialLine3D(r11_36, r12_36 - r3_36, r13_36 + 0.03, r11_36, r12_36 + r2_36, r13_36 + 0.03, r40_0, r4_36, tocolor(markersColors[1].circle[1], markersColors[1].circle[2], markersColors[1].circle[3], markersColors[1].circle[4]), 0, 0, -1730900)
      end
    end
    for r9_36 = 1, #Barbers, 1 do
      local r10_36 = Barbers[r9_36]
      if getDistanceBetweenPoints3D(r5_36[1], r5_36[2], r5_36[3], r10_36.Entry[1], r10_36.Entry[2], r10_36.Entry[3]) <= 35 then
        l3 = r10_36.Entry[3] - 1
        l2 = r10_36.Entry[2]
        l1 = r10_36.Entry[1]
        dxDrawMaterialLine3D(l1, l2, l3 + r0_36, l1, l2, l3 + r1_36, r38_0, 1, tocolor(markersColors[1].icon[1], markersColors[1].icon[2], markersColors[1].icon[3], markersColors[1].icon[4]))
        dxDrawMaterialLine3D(l1, l2 - r2_36, l3 + 0.03, l1, l2 + r3_36, l3 + 0.03, r40_0, r4_36, tocolor(markersColors[1].circle[1], markersColors[1].circle[2], markersColors[1].circle[3], markersColors[1].circle[4]), 0, 0, -1730900)
      end
    end
    for r9_36 = 1, #TattoShops, 1 do
      if getElementData(localPlayer, "HG->inTattoShop") == true then return end
      local r10_36 = TattoShops[r9_36]
      if getDistanceBetweenPoints3D(r5_36[1], r5_36[2], r5_36[3], r10_36[1], r10_36[2], r10_36[3]) <= 35 then
        l3 = r10_36[3] - 1
        l2 = r10_36[2]
        l1 = r10_36[1]
        dxDrawMaterialLine3D(l1, l2, l3 + r0_36, l1, l2, l3 + r1_36, r39_0, 1, tocolor(markersColors[1].icon[1], markersColors[1].icon[2], markersColors[1].icon[3], markersColors[1].icon[4]))
        dxDrawMaterialLine3D(l1, l2 - r2_36, l3 + 0.03, l1, l2 + r3_36, l3 + 0.03, r40_0, r4_36, tocolor(markersColors[1].circle[1], markersColors[1].circle[2], markersColors[1].circle[3], markersColors[1].circle[4]), 0, 0, -1730900)
      end
    end
    for r9_36 = 1, #CorpsMarkers, 1 do
      if getElementData(localPlayer, "HG->inPoliceShop") == true then return end
      local r10_36 = CorpsMarkers[r9_36]
      if getDistanceBetweenPoints3D(r5_36[1], r5_36[2], r5_36[3], r10_36[2], r10_36[3], r10_36[4]) <= 35 then
        l3 = r10_36[4] - 1
        l2 = r10_36[3]
        l1 = r10_36[2]
        dxDrawMaterialLine3D(l1, l2, l3 + r1_36, l1, l2, l3 + r0_36, r41_0, 1, tocolor(markersColors[1].icon[1], markersColors[1].icon[2], markersColors[1].icon[3], markersColors[1].icon[4]))
        dxDrawMaterialLine3D(l1, l2 - r3_36, l3 + 0.03, l1, l2 + r2_36, l3 + 0.03, r40_0, r4_36, tocolor(markersColors[1].circle[1], markersColors[1].circle[2], markersColors[1].circle[3], markersColors[1].circle[4]), 0, 0, -1730900)
      end
    end
  end
end)

local r43_0 = {}
local r44_0 = 0
function isTableEmpty(r0_37)
  return next(r0_37) == nil
end
function setNewCartValue(r0_38)
  if getElementData(r0_38, "HG->shopInUse") == false then return end
  r44_0 = 0
  if not isTableEmpty(r43_0[r0_38]) then
    for r4_38, r5_38 in pairs(r43_0[r0_38]) do r44_0 = r44_0 + r5_38[1] end
    return executeBrowserJavascript(r20_0, "document.getElementById(\'Prices\').innerHTML = \'Total R$ " .. r44_0 .. "\';")
  else
    return executeBrowserJavascript(r20_0, "document.getElementById(\'Prices\').innerHTML = \'Total R$ 0\';")
  end
end
function addNewItemToCart(r0_39, r1_39, r2_39, r3_39, r4_39)
  if r2_39 == "add" then
    if not r43_0[r0_39] then r43_0[r0_39] = {} end
    if not r43_0[r0_39][r1_39] then
      r43_0[r0_39][r1_39] = { clotheprices[r1_39], r3_39, r4_39 }
      setNewCartValue(r0_39)
    end
    if r43_0[r0_39][r1_39] then
      r43_0[r0_39][r1_39] = { clotheprices[r1_39], r3_39, r4_39 }
      setNewCartValue(r0_39)
    end
  else
    if not r43_0[r0_39] then r43_0[r0_39] = {} end
    if not r43_0[r0_39][r1_39] then
      r43_0[r0_39][r1_39] = { 0, 0, 0 }
      setNewCartValue(r0_39)
    end
    if r43_0[r0_39][r1_39] then
      r43_0[r0_39][r1_39] = { 0, 0, 0 }
      setNewCartValue(r0_39)
    end
  end
end
function resetClothesPrice(r0_40)
  r43_0[r0_40] = {}
  r44_0 = 0
  executeBrowserJavascript(r20_0, "document.getElementById(\'Prices\').innerHTML = \'Total R$ 0\';")
end

local r45_0 = "http://mta/" .. getResourceName(getThisResource()) .. "/core/web-side/shop.html"
local r46_0 = false
function dxCustomCreateShop()
  dxDrawImage(0, 0, r6_0[1], r6_0[2], r20_0, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end
addEvent("HG->confirmBuyClothes", true)
addEventHandler("HG->confirmBuyClothes", root, function()
  triggerServerEvent("HG->confirmBuyClothes_S", getLocalPlayer(), getLocalPlayer(), r44_0, r43_0[getLocalPlayer()])
end)
addEvent("HG->customOpenShopMenu", true)
addEventHandler("HG->customOpenShopMenu", root, function(r0_43)
  if r46_0 then
    if r0_43 then triggerServerEvent("HG->resetClothes", getLocalPlayer(), getLocalPlayer()) end
    SendNUIMessage(r20_0, { showShopClothes = false, })
    removeEventHandler("onClientRender", root, dxCustomCreateShop)
    r46_0 = false
    if config.Global.ShowCursor then showCursor(false) end
    setCameraTarget(localPlayer)
    setElementDimension(localPlayer, 0)
    removeEventHandler("onClientKey", getRootElement(), onKeyHandler, true, "low-500")
    removeEventHandler("onClientPreRender", getRootElement(), onPreRenderHandler)
    setElementData(localPlayer, "HG->shopInUse", false)
  else
    loadBrowserURL(r20_0, r45_0)
    startCam()
    setTimer(function()
      local r0_44 = getElementModel(localPlayer)
      resetClothesPrice(getLocalPlayer())
      SendNUIMessage(r20_0, { showShopClothes = true, gen = r0_44, })
      r46_0 = true
      addEventHandler("onClientRender", root, dxCustomCreateShop)
      if config.Global.ShowCursor then showCursor(true) end
      executeBrowserJavascript(r20_0, "document.getElementById(\'Prices\').innerHTML = \'Total R$ 0\';")
    end, 800, 1)
  end
end)

local r47_0 = "http://mta/" .. getResourceName(getThisResource()) .. "/core/web-side/tatto.html"
local r48_0 = false
function dxCustomTatto()
  dxDrawImage(0, 0, r6_0[1], r6_0[2], r20_0, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end
addEvent("HG->onPlayerOpenTatto", true)
addEventHandler("HG->onPlayerOpenTatto", root, function(r0_46)
  if r48_0 then
    if r0_46 then triggerServerEvent("HG->resetClothes", getLocalPlayer(), getLocalPlayer()) end
    SendNUIMessage(r20_0, { showTatto = false, })
    removeEventHandler("onClientRender", root, dxCustomTatto)
    r48_0 = false
    if config.Global.ShowCursor then showCursor(false) end
    setCameraTarget(localPlayer)
    setElementDimension(localPlayer, 0)
    removeEventHandler("onClientKey", getRootElement(), onKeyHandler, true, "low-500")
    removeEventHandler("onClientPreRender", getRootElement(), onPreRenderHandler)
    setElementData(localPlayer, "HG->inTattoShop", false)
  else
    for r4_46, r5_46 in pairs(roupas_categorias[getElementModel(localPlayer)]) do
      triggerEvent("clearShaderClothe", localPlayer, localPlayer, getElementModel(localPlayer), r4_46)
    end
    if getElementModel(getLocalPlayer()) == 7 then
      setRoupa(localPlayer, 7, "torso1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "torso2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "torso3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "mao", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "bracoe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "ombroe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernae1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernae2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernae3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernae4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernae5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "bracod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "ombrod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernad1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernad2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernad3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernad4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pernad5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "pee", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "ped", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 7, "rosto", r12_0[localPlayer][1], r12_0[localPlayer][2])
      setRoupa(localPlayer, 7, "cueca", 1, 1)
    elseif getElementModel(getLocalPlayer()) == 9 then
      setRoupa(localPlayer, 9, "torso1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "torso2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "torso3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "torso4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "mao", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "bracoe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "ombroe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernae1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernae2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernae3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernae4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernae5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernae6", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "bracod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "ombrod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernad1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernad2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernad3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernad4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernad5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pernad6", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "pe1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 9, "rosto", r12_0[localPlayer][1], r12_0[localPlayer][2])
      setRoupa(localPlayer, 9, "calca", 1, 1)
      setRoupa(localPlayer, 9, "camisa", 1, 1)
    end
    loadBrowserURL(r20_0, r47_0)
    startCam()
    setTimer(function()
      local r0_47 = getElementModel(getLocalPlayer())
      resetClothesPrice(getLocalPlayer())
      SendNUIMessage(r20_0, { showTatto = true, gen = r0_47, })
      r48_0 = true
      addEventHandler("onClientRender", root, dxCustomTatto)
      if config.Global.ShowCursor then showCursor(true) end
      executeBrowserJavascript(r20_0, "document.getElementById(\'Prices\').innerHTML = \'Total R$ 0\';")
    end, 800, 1)
  end
end)

addEventHandler("onClientKey", root, function(r0_48, r1_48)
  if getElementData(localPlayer, "HG->shopInUse") == true and r0_48 == "backspace" then triggerEvent("HG->customOpenShopMenu", localPlayer, "sim") end
  if getElementData(localPlayer, "HG->inTattoShop") == true and r0_48 == "backspace" then triggerEvent("HG->onPlayerOpenTatto", localPlayer) end
  if getElementData(localPlayer, "HG->BlockBarberKeys") == true and r0_48 == "backspace" then triggerEvent("HG->onPlayerOpenBarber", localPlayer) end
  if getElementData(localPlayer, "HG->inPoliceShop") == true and r0_48 == "backspace" then triggerEvent("HG->onPlayerOpenPoliceShop", localPlayer, "sim") end
end)

local r49_0 = "http://mta/" .. getResourceName(getThisResource()) .. "/core/web-side/barber.html"
function dxCustomBarber()
  dxDrawImage(0, 0, r6_0[1], r6_0[2], r20_0, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end
local r50_0 = false
addEvent("HG->onPlayerOpenBarber", true)
addEventHandler("HG->onPlayerOpenBarber", root, function()
  local r0_50 = r50_0
  if r0_50 then
    r0_50 = getElementData(localPlayer, "HG->BarberChairElement")
    setPedAnimation(localPlayer, "HAIRCUTS", "BRB_Sit_Out", -1, false, false, false, true)
    setTimer(function()
      triggerServerEvent("HG->resetClothes", getLocalPlayer(), getLocalPlayer())
      setPedAnimation(localPlayer)
      setElementData(localPlayer, "HG->BlockBarberKeys", false)
      setElementData(r0_50, "HG->BarberChairUse", false)
      SendNUIMessage(browserB, { showBarber = false, })
      removeEventHandler("onClientRender", root, dxCustomBarber)
      r50_0 = false
      if config.Global.ShowCursor then showCursor(false) end
      setCameraTarget(localPlayer)
      setElementDimension(localPlayer, 0)
      removeEventHandler("onClientKey", getRootElement(), onKeyHandler, true, "low-500")
      removeEventHandler("onClientPreRender", getRootElement(), onPreRenderHandler)
    end, 3800, 1)
  else
    r0_50 = clearShaderClothe
    r0_50(localPlayer, getElementModel(getLocalPlayer()), "chapeu")
    r0_50 = clearShaderClothe
    r0_50(localPlayer, getElementModel(getLocalPlayer()), "oculos")
    r0_50 = loadBrowserURL
    r0_50(r20_0, r49_0)
    r0_50 = startCam
    r0_50()
    r0_50 = setTimer
    r0_50(function()
      local r0_52 = getElementModel(getLocalPlayer())
      resetClothesPrice(getLocalPlayer())
      SendNUIMessage(r20_0, { showBarber = true, gen = r0_52, head = r12_0[localPlayer][1], })
      r50_0 = true
      addEventHandler("onClientRender", root, dxCustomBarber)
      if config.Global.ShowCursor then showCursor(true) end
      executeBrowserJavascript(r20_0, "document.getElementById(\'Prices\').innerHTML = \'Total R$ 0\';")
    end, 800, 1)
  end
end)

local r51_0 = "http://mta/" .. getResourceName(getThisResource()) .. "/core/web-side/police.html"
function dxCustomPolice()
  dxDrawImage(0, 0, r6_0[1], r6_0[2], r20_0, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end
local r52_0 = false
addEvent("HG->onPlayerOpenPoliceShop", true)
addEventHandler("HG->onPlayerOpenPoliceShop", root, function(r0_54)
  if r52_0 then
    if r0_54 then triggerServerEvent("HG->resetClothes", getLocalPlayer(), getLocalPlayer()) end
    SendNUIMessage(r20_0, { showShopClothesPolice = false, })
    removeEventHandler("onClientRender", root, dxCustomPolice)
    r52_0 = false
    if config.Global.ShowCursor then showCursor(false) end
    setCameraTarget(localPlayer)
    setElementDimension(localPlayer, 0)
    removeEventHandler("onClientKey", getRootElement(), onKeyHandler, true, "low-500")
    removeEventHandler("onClientPreRender", getRootElement(), onPreRenderHandler)
    setElementData(localPlayer, "HG->inPoliceShop", false)
    if not r0_54 then triggerServerEvent("HG->saveLocalCorpClothes", localPlayer, localPlayer, r36_0[localPlayer]) end
  else
    if not r36_0[localPlayer] then r36_0[localPlayer] = {} end
    local r1_54 = getElementModel(getLocalPlayer())
    local r2_54 = 271
    if r1_54 == 7 then triggerServerEvent("HG->changeSkinID", getLocalPlayer(), 271); r2_54 = 271
    elseif r1_54 == 21 then triggerServerEvent("HG->changeSkinID", getLocalPlayer(), 271); r2_54 = 271
    elseif r1_54 == 9 then triggerServerEvent("HG->changeSkinID", getLocalPlayer(), 272); r2_54 = 272
    elseif r1_54 == 272 then triggerServerEvent("HG->changeSkinID", getLocalPlayer(), 272); r2_54 = 272 end
    
    if r1_54 == 7 or r1_54 == 271 then
      setRoupa(localPlayer, 271, "torso1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "torso2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "torso3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "mao", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "bracoe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "ombroe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernae1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernae2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernae3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernae4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernae5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "bracod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "ombrod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernad1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernad2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernad3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernad4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pernad5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "pee", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "ped", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 271, "rosto", r12_0[localPlayer][1], r12_0[localPlayer][2])
      setRoupa(localPlayer, 271, "cueca", 1, 1)
    elseif r1_54 == 9 or r1_54 == 272 then
      setRoupa(localPlayer, 272, "torso1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "torso2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "torso3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "torso4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "mao", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "bracoe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "ombroe", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernae1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernae2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernae3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernae4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernae5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernae6", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "bracod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "ombrod", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernad1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernad2", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernad3", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernad4", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernad5", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pernad6", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "pe1", r11_0[localPlayer][1], r11_0[localPlayer][2])
      setRoupa(localPlayer, 272, "rosto", r12_0[localPlayer][1], r12_0[localPlayer][2])
      setRoupa(localPlayer, 272, "calca", 2, 1)
      setRoupa(localPlayer, 272, "camisa", 1, 1)
    end
    loadBrowserURL(r20_0, r51_0)
    startCam()
    setTimer(function()
      SendNUIMessage(r20_0, { showShopClothesPolice = true, gen = r2_54, })
      r52_0 = true
      addEventHandler("onClientRender", root, dxCustomPolice)
      if config.Global.ShowCursor then showCursor(true) end
    end, 800, 1)
  end
end)

addEvent("HG->updateClothesCorps", true)
addEventHandler("HG->updateClothesCorps", root, function(r0_56, r1_56)
  if r0_56 and r1_56 then
    if not r36_0[r0_56] then r36_0[r0_56] = {} end
    r36_0[r0_56] = r1_56
  end
end)