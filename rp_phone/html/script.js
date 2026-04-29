let currentScreen = "home"; 

function updateClock() {
    const now = new Date();
    let hours = now.getHours().toString().padStart(2, '0');
    let minutes = now.getMinutes().toString().padStart(2, '0');
    document.getElementById('clock').innerText = `${hours}:${minutes}`;
}
setInterval(updateClock, 1000);
updateClock();

function openApp(appId) {
    // 1. KAMERA KONTROLÜ: Kameraya tıklandıysa HTML ekranı açma, Lua'ya FPS Kamera sinyali yolla!
    if (appId === 'camera-app') {
        mta.triggerEvent("cef:openNativeCamera");
        return; // İşlemi burada kes (Diğer kodları okumasına gerek yok)
    }

    // 2. GALERİ KONTROLÜ
    if (appId === 'gallery-app') {
        mta.triggerEvent("phone:requestPhotos");
    }

    if (appId === 'news-app') {
        mta.triggerEvent("phone:requestNews");
    }

    // openApp fonksiyonunun içine şunu ekle:
    if (appId === 'weather-app') {
        mta.triggerEvent("phone:requestWeather");
    }

    // 3. DİĞER UYGULAMALAR İÇİN STANDART EKRAN AÇILIŞ ANİMASYONU
    document.getElementById(appId).style.display = 'flex';
    document.getElementById('home-screen').style.opacity = '0'; 
    setTimeout(() => {
        document.getElementById('home-screen').style.display = 'none';
    }, 300);
    currentScreen = appId;
    
// ... openApp fonksiyonunun en alt kısımları:
    if (appId === 'contacts-app'){
        mta.triggerEvent("phone:requestContacts");
    }
    
    if (appId === 'sahibinden-app') {
        // ÇÖZÜM 2: Sahibinden'i açtığı an arka planda galeriyi de yükle, galeriyi açmaya gerek kalmasın!
        mta.triggerEvent("phone:requestPhotos"); 
        switchShbTab('ilanlar');
    }
}

function goHomeOrClose() {
    if (currentScreen !== "home") {
        document.getElementById('home-screen').style.display = 'block';
        setTimeout(() => {
            document.getElementById('home-screen').style.opacity = '1';
            document.getElementById(currentScreen).style.display = 'none';
            currentScreen = "home";
        }, 10);
    } else {
        closePhone();
    }
}

// =====================================
// BANKA VE CİHAZ BİLGİSİ
// =====================================
function loadBankApp(iban, balance, name) {
    document.getElementById('bank-user-name').innerText = name;
    document.getElementById('bank-iban').innerText = iban;
    document.getElementById('bank-balance').innerText = balance.toLocaleString('tr-TR');
}

function sendTransfer() {
    let targetIban = document.getElementById('targetIban').value.toUpperCase().trim();
    let amount = document.getElementById('transferAmount').value;
    if (targetIban.length < 5 || !targetIban.startsWith("TR")) { alert("Geçerli bir IBAN girin."); return; }
    if (amount === "" || amount <= 0) { alert("Miktar girin."); return; }
    mta.triggerEvent("cef:telefonTransfer", targetIban, amount);
    document.getElementById('targetIban').value = '';
    document.getElementById('transferAmount').value = '';
}

// YENİ: Kendi telefon numaramızı Ayarlar menüsüne yazdırma
function setMyNumber(num) {
    let numElement = document.getElementById('my-phone-number');
    if(numElement) numElement.innerText = num;
}

// =====================================
// REHBER
// =====================================
function addContact() {
    let name = document.getElementById('contactName').value.trim();
    let number = document.getElementById('contactNumber').value.trim();
    if(name.length < 3 || number.length < 5) { alert("Lütfen geçerli isim ve numara girin."); return; }
    mta.triggerEvent("phone:addContact", number, name);
    document.getElementById('contactName').value = '';
    document.getElementById('contactNumber').value = '';
}

function loadContacts(jsonContacts) {
    let contacts = JSON.parse(jsonContacts);
    let listContainer = document.getElementById('contact-list');
    listContainer.innerHTML = '';
    if(contacts.length === 0){
        listContainer.innerHTML = '<div class="contact-item"><span style="color:#888;">Rehberiniz boş.</span></div>';
        return;
    }
    contacts.forEach(contact => {
        listContainer.innerHTML += `
            <div class="contact-item" onclick="callContact('${contact.contact_number}', '${contact.contact_name}')">
                <span class="contact-item-name">${contact.contact_name}</span>
                <span class="contact-item-num">${contact.contact_number}</span>
            </div>
        `;
    });
}

// =====================================
// AYARLAR
// =====================================
function changeWallpaper(url) {
    document.getElementById('smartphone').style.backgroundImage = `url('${url}')`;
    mta.triggerEvent("phone:setWallpaper", url);
}
function setInitialWallpaper(url) {
    // Eğer gelen URL boşsa, hatalıysa veya eski jpg uzantılıysa wp1.png'ye zorla
    if(!url || url === "" || url.includes(".jpg")) {
        url = "wp1.png";
    }
    
    currentWallpaperUrl = url;
    document.getElementById('smartphone').style.backgroundImage = `url('${url}')`;
}
function changeRingtone(soundFile) {
    mta.triggerEvent("phone:setRingtone", soundFile);
}

// =====================================
// CASINO SİSTEMİ (Zamanlamalı & Kilitli)
// =====================================
let isSpinning = false;
let currentBet = 100;
let spinInterval;

// MTA'dan gelen casino bakiyesini günceller
function loadCasinoApp(casinoBalance) {
    document.getElementById('casino-balance').innerText = casinoBalance.toLocaleString('tr-TR');
}

function casinoDeposit() {
    let amt = document.getElementById('casinoAmount').value;
    if(amt > 0) mta.triggerEvent("casino:deposit", parseInt(amt));
}

function casinoWithdraw() {
    let amt = document.getElementById('casinoAmount').value;
    if(amt > 0) mta.triggerEvent("casino:withdraw", parseInt(amt));
}

// Bahis Miktarını Seçme
function setBet(amount, btnElement) {
    if(isSpinning) return;
    currentBet = amount;
    let btns = document.querySelectorAll('.bet-btn');
    btns.forEach(btn => btn.classList.remove('active'));
    btnElement.classList.add('active');
}

function spinSlot() {
    let balanceText = document.getElementById('casino-balance').innerText;
    let currentBal = parseInt(balanceText.replace(/\D/g, '')); 
    
    if (currentBal < currentBet) {
        alert("Yetersiz bakiye!");
        return;
    }

    if(isSpinning) return;
    isSpinning = true;

    // Butonu kilitle ve durumu güncelle
    const spinBtn = document.querySelector('.red-btn');
    spinBtn.disabled = true;
    spinBtn.innerText = "DÖNÜYOR...";
    document.getElementById('slot-message').innerText = "Şansın dönüyor...";

    let reels = [document.getElementById('reel1'), document.getElementById('reel2'), document.getElementById('reel3')];
    reels.forEach(r => {
        r.classList.remove('win-pop');
        r.classList.add('spinning');
    });

    // Görsel dönüş hızı
    spinInterval = setInterval(() => {
        const symbols = ['🍒', '💎', '🍋', '🔔', '🍇'];
        reels.forEach(r => r.innerText = symbols[Math.floor(Math.random() * symbols.length)]);
    }, 120);

    // Sunucuya isteği atıyoruz ama sonucu hemen göstermeyeceğiz
    mta.triggerEvent("casino:spinRequest", currentBet);

    window.stopSpin = function(r1, r2, r3, message, newBalance) {
        // En az 3 saniye dönmesini sağlıyoruz
        setTimeout(() => {
            clearInterval(spinInterval);
            reels.forEach(r => r.classList.remove('spinning'));

            reels[0].innerText = r1;
            reels[1].innerText = r2;
            reels[2].innerText = r3;
            
            let msgEl = document.getElementById('slot-message');
            msgEl.innerText = message;
            document.getElementById('casino-balance').innerText = newBalance.toLocaleString('tr-TR');
            
            if (r1 === r2 && r2 === r3) {
                msgEl.style.color = "#E4C000";
                reels.forEach(r => r.classList.add('win-pop'));
            } else {
                msgEl.style.color = "#ff4757";
            }

            // Kilidi aç
            isSpinning = false;
            spinBtn.disabled = false;
            spinBtn.innerText = "🎰 ÇEVİR";
        }, 3000); // 3000ms = 3 saniye
    };
}

// =====================================
// TELEFON ARAMA / GÖRÜŞME
// =====================================
let callTimer = null;
let seconds = 0;

function callContact(number, name) {
    mta.triggerEvent("phone:startCall", number);
    showCallScreen(name, "Aranıyor...", true);
}

function incomingCall(callerName) {
    showCallScreen(callerName, "Arama Geliyor...", false);
}

function showCallScreen(name, status, isCallingOut) {
    document.getElementById('call-screen').style.display = 'block';
    document.getElementById('caller-name').innerText = name;
    document.getElementById('call-status').innerText = status;
    document.getElementById('call-timer').style.display = 'none';
    
    if(isCallingOut) document.getElementById('btn-answer').style.display = 'none'; 
    else document.getElementById('btn-answer').style.display = 'block';
}

function answerCall() {
    mta.triggerEvent("phone:acceptCall");
    document.getElementById('btn-answer').style.display = 'none';
    document.getElementById('call-status').innerText = "Görüşülüyor";
    document.getElementById('call-timer').style.display = 'block';
    
    seconds = 0;
    callTimer = setInterval(() => {
        seconds++;
        let m = Math.floor(seconds / 60).toString().padStart(2, '0');
        let s = (seconds % 60).toString().padStart(2, '0');
        document.getElementById('call-timer').innerText = `${m}:${s}`;
    }, 1000);
}

function declineCall() {
    mta.triggerEvent("phone:endCall");
    closeCallScreen();
}

function closeCallScreen() {
    document.getElementById('call-screen').style.display = 'none';
    clearInterval(callTimer);
    document.getElementById('call-timer').innerText = "00:00";
}

// =====================================
// TELEFONU KAPATMA
// =====================================
function closePhone() {
    document.getElementById('smartphone').style.animation = "slideDown 0.4s ease-in forwards";
    let style = document.createElement('style');
    style.innerHTML = `@keyframes slideDown { 0% { transform: translateY(0); opacity: 1; } 100% { transform: translateY(100%); opacity: 0; } }`;
    document.head.appendChild(style);
    setTimeout(() => { mta.triggerEvent("cef:telefonKapat"); }, 350);
}




// =====================================
// KAMERA VE GALERİ SİSTEMİ
// =====================================
// =====================================
// KAMERA VE GALERİ SİSTEMİ
// =====================================
let myPhotos = [];
let currentWallpaperUrl = ""; 

function setInitialWallpaper(url) {
    if(url && url.length > 5) {
        currentWallpaperUrl = url;
        document.getElementById('smartphone').style.backgroundImage = `url('${url}')`;
    }
}
function changeWallpaper(url) {
    currentWallpaperUrl = url;
    document.getElementById('smartphone').style.backgroundImage = `url('${url}')`;
    mta.triggerEvent("phone:setWallpaper", url);
}

// Orijinal openApp fonksiyonunu yedekle
const originalOpenApp = openApp; 

// Yeni openApp (Kamerayı yakalar)
openApp = function(appId) {
    if(appId === 'camera-app') {
        // Gerçek GTA SA kamerasını açmak için MTA'ya sinyal yolla
        mta.triggerEvent("cef:openNativeCamera");
        return; // HTML ekranını değiştirme, olduğun yerde kal
    } else if(appId === 'gallery-app') {
        mta.triggerEvent("phone:requestPhotos");
    }
    originalOpenApp(appId);
}

const originalGoHome = goHomeOrClose;
goHomeOrClose = function() {
    originalGoHome();
    if(currentWallpaperUrl) {
        document.getElementById('smartphone').style.backgroundImage = `url('${currentWallpaperUrl}')`;
    } else {
        document.getElementById('smartphone').style.background = "#1a1a1a";
    }
}

function takePhoto() {
    // Çekim Animasyonu (Flaş)
    let flash = document.getElementById('camera-flash');
    flash.style.opacity = "1";
    setTimeout(() => { flash.style.opacity = "0"; }, 150);
    
    // MTA'ya ekran görüntüsü almasını söyle
    mta.triggerEvent("cef:takePhoto");
}

// MTA'dan fotoğrafın Base64 verisi geldiğinde (Hata Giderildi)
function loadGallery(photosJson) {
    let parsedData = JSON.parse(photosJson);
    
    // MTA toJSON veriyi [ [ {veri} ] ] şeklinde gönderdiği için 0. indexi alıyoruz!
    myPhotos = parsedData[0] || []; 
    
    renderGallery();
}

function renderGallery() {
    let container = document.getElementById('gallery-container');
    container.innerHTML = '';
    
    if(myPhotos.length === 0) {
        container.innerHTML = '<p style="color:#888; text-align:center; width:100%; margin-top:20px;">Galerin bomboş.</p>';
        return;
    }
    
    // Sondan başa doğru (En yeni fotoğraf en üstte)
    for(let i = myPhotos.length - 1; i >= 0; i--) {
        let photo = myPhotos[i];
        container.innerHTML += `<div class="gallery-item" style="background-image: url('${photo.photo_data}');" onclick="viewPhoto(${photo.id}, '${photo.photo_data}')"></div>`;
    }
}

let viewingPhotoId = null;
function viewPhoto(id, base64data) {
    viewingPhotoId = id;
    document.getElementById('viewer-img').src = base64data;
    document.getElementById('photo-viewer').style.display = "flex";
}

function closePhotoViewer() {
    document.getElementById('photo-viewer').style.display = "none";
    viewingPhotoId = null;
}

function deleteCurrentPhoto() {
    if(viewingPhotoId != null) {
        // Sunucuya silme emrini gönder, gerisini sunucu halledip bize taze listeyi yollayacak
        mta.triggerEvent("phone:deletePhoto", viewingPhotoId);
        
        // Sadece tam ekran fotoğraf görüntüleyiciyi kapat
        closePhotoViewer(); 
    }
}







// AÇILIŞA GALERİ YÜKLEMESİ EKLENDİ (Mevcut openApp fonksiyonundaki sahibinden kısmını böyle güncelle)
// if (appId === 'sahibinden-app') {
//     mta.triggerEvent("phone:requestPhotos"); // Arka planda galeriyi hazırla!
//     switchShbTab('ilanlar');
// }


// =====================================
// SAHİBİNDEN SİSTEMİ (Fotoğraflı & Hata Giderildi)
// =====================================
let myVehiclesData = [];
let selectedAdPhoto = ""; // Seçilen fotoğrafın verisi burada tutulacak

function switchShbTab(tabName) {
    document.getElementById('tab-ilanlar').classList.remove('active');
    document.getElementById('tab-ilanlarim').classList.remove('active');
    document.getElementById('tab-' + tabName).classList.add('active');
    
    document.getElementById('shb-content').innerHTML = '<p style="text-align:center; color:#888; margin-top:20px;">Yükleniyor...</p>';
    
    if (tabName === 'ilanlar') { mta.triggerEvent("phone:shbRequestAllAds"); } 
    else { mta.triggerEvent("phone:shbRequestMyAd"); }
}

// 1. TÜM İLANLARI GÖSTER (FOTOĞRAFLI VE ARAMA BUTONLU)
function loadShbAllAds(adsJson) {
    let ads = JSON.parse(adsJson || "[]");
    
    if (ads.length > 0 && Array.isArray(ads[0])) ads = ads[0]; 
    
    let content = document.getElementById('shb-content');
    content.innerHTML = '';
    
    if (ads.length === 0 || !ads[0].title) {
        content.innerHTML = '<p style="text-align:center; color:#888; margin-top:20px;">Henüz hiç ilan yok.</p>';
        return;
    }
    
    ads.forEach(ad => {
        let photoHtml = ad.photo_data && ad.photo_data.length > 10 ? `<div class="ad-photo" style="background-image: url('${ad.photo_data}');"></div>` : '';
        
        // Numara yoksa hata vermemesi için koruma
        let sellerNumber = ad.seller_number && ad.seller_number !== "Bilinmiyor" ? ad.seller_number : "00000";
        
        content.innerHTML += `
            <div class="ad-card">
                ${photoHtml}
                <div style="display:flex; justify-content:space-between;">
                    <span class="ad-title">${ad.title}</span>
                    <span class="ad-price">$${parseInt(ad.price).toLocaleString()}</span>
                </div>
                <span style="font-size:12px; color:#555;">${ad.veh_name} (KM: ${ad.km})</span>
                
                <div class="ad-details" style="align-items: center; margin-top: 10px; border-top: 1px solid #eee; padding-top: 8px;">
                    <div>
                        <span style="display:block; color:#333; font-weight:bold;">👤 ${ad.seller_name}</span>
                        <span style="display:block; font-size:10px;">🕒 ${ad.post_date}</span>
                    </div>
                    
                    <button class="action-btn msg-bg" style="margin:0; width:auto; padding:8px 15px; border-radius:5px; font-size:12px; color:white; display:flex; gap:5px; align-items:center;" onclick="callContact('${sellerNumber}', '${ad.seller_name}')">
                        📞 Ara
                    </button>
                </div>
            </div>`;
    });
}

// 2. KENDİ İLANIMI / ARAÇLARIMI GÖSTER (HATA GİDERİLDİ)
function loadShbMyAd(myAdJson, myCarsJson) {
    let myAd = [];
    let myVehiclesData = [];
    
    // Gelen veriyi güvenlice oku (Hatalıysa boş bırak)
    try { myAd = JSON.parse(myAdJson || "[]"); } catch(e) {}
    try { myVehiclesData = JSON.parse(myCarsJson || "[]"); } catch(e) {}
    
    // ÇÖZÜM: Gelen veri Dizi (Array) değilse zorla Diziye çevir (Çökmeyi %100 engeller)
    if (!Array.isArray(myAd)) myAd = [];
    if (!Array.isArray(myVehiclesData)) myVehiclesData = [];
    
    if (myAd.length > 0 && Array.isArray(myAd[0])) myAd = myAd[0];
    if (myVehiclesData.length > 0 && Array.isArray(myVehiclesData[0])) myVehiclesData = myVehiclesData[0];
    
    let content = document.getElementById('shb-content');
    
    if (myAd.length > 0 && myAd[0].title) {
        let ad = myAd[0];
        let photoHtml = ad.photo_data && ad.photo_data.length > 10 ? `<div class="ad-photo" style="background-image: url('${ad.photo_data}'); height: 100px;"></div>` : '';
        
        content.innerHTML = `
            <div style="background:white; padding:15px; border-radius:8px; border:1px solid #ddd;">
                <h3 style="margin:0 0 10px 0; color:#333;">Mevcut İlanın</h3>
                ${photoHtml}
                <div class="shb-form-group">
                    <label>İlan Başlığı (Max 15 Karakter)</label>
                    <input type="text" id="edit-ad-title" class="shb-input" maxlength="15" value="${ad.title}">
                </div>
                <div class="shb-form-group">
                    <label>Fiyat ($)</label>
                    <input type="number" id="edit-ad-price" class="shb-input" value="${ad.price}">
                </div>
                <p style="font-size:11px; color:#888;">Araç: ${ad.veh_name} | KM: ${ad.km}</p>
                <div style="display:flex; gap:10px; margin-top:15px;">
                    <button class="action-btn blue-btn" style="flex:1; margin:0;" onclick="updateMyAd()">Kaydet</button>
                    <button class="action-btn red-btn" style="flex:1; margin:0;" onclick="deleteMyAd()">İlanı Sil</button>
                </div>
            </div>`;
    } else {
        selectedAdPhoto = ""; 
        
        // 1. ÇÖZÜM: Hatalı <select> yerine kendi div listemizi oluşturuyoruz
        let carOptions = '';
        if (myVehiclesData.length === 0) {
            carOptions = '<div style="padding:10px; font-size:12px; color:#888; text-align:center;">Üzerinize kayıtlı araç bulunamadı.</div>';
        } else {
            myVehiclesData.forEach(v => { 
                carOptions += `<div class="custom-select-item" onclick="selectAdCar('${v.id}', '${v.veh_name}', '${v.plate}', '${v.km}', '${v.color}')">${v.veh_name} (Plaka: ${v.plate})</div>`; 
            });
        }

        content.innerHTML = `
            <div style="background:white; padding:15px; border-radius:8px; border:1px solid #ddd;">
                <h3 style="margin:0 0 10px 0; color:#333;">Yeni İlan Ver</h3>
                <div class="shb-photo-preview" id="ad-photo-preview" onclick="openGalleryPicker()">📷 Galeriden Fotoğraf Seç</div>
                
                <div class="shb-form-group">
                    <label>Aracınız</label>
                    <div style="position: relative;">
                        <div id="custom-select-btn" class="shb-input" style="cursor:pointer; display:flex; justify-content:space-between; align-items:center;" onclick="toggleCarSelect()">
                            <span id="selected-car-text">Satılacak Aracı Seçin</span>
                            <span style="font-size:10px; color:#888;">▼</span>
                        </div>
                        
                        <div id="custom-select-list" style="display:none; position:absolute; top:100%; left:0; width:100%; background:white; border:1px solid #ddd; border-radius:5px; margin-top:2px; z-index:100; max-height:150px; overflow-y:auto; box-shadow:0 5px 15px rgba(0,0,0,0.1);">
                            ${carOptions}
                        </div>
                    </div>
                    <input type="hidden" id="new-ad-veh" value="">
                </div>

                <div style="display:flex; gap:10px;">
                    <div class="shb-form-group" style="flex:1;">
                        <label>Kilometre (Otomatik)</label>
                        <input type="text" id="auto-km" class="shb-input" disabled placeholder="-">
                    </div>
                    <div class="shb-form-group" style="flex:1;">
                        <label>Renk (Otomatik)</label>
                        <input type="text" id="auto-color" class="shb-input" disabled placeholder="-">
                    </div>
                </div>
                <div class="shb-form-group">
                    <label>İlan Başlığı (Max 15 Karakter)</label>
                    <input type="text" id="new-ad-title" class="shb-input" maxlength="15" placeholder="Örn: Acil Satılık!">
                </div>
                <div class="shb-form-group">
                    <label>Fiyat ($)</label>
                    <input type="number" id="new-ad-price" class="shb-input" placeholder="Fiyat girin">
                </div>
                <button class="action-btn blue-btn" style="width:100%; margin-top:10px;" onclick="postNewAd()">İlanı Yayınla</button>
            </div>`;
    }
}

let galleryPickerMode = 'sahibinden'; 
let selectedNewsPhoto = "";

function openGalleryPicker(mode = 'sahibinden') {
    galleryPickerMode = mode;
    document.getElementById('gallery-picker-modal').style.display = 'flex';
    let container = document.getElementById('gallery-picker-container');
    container.innerHTML = '';
    
    if(myPhotos.length === 0) {
        container.innerHTML = '<p style="color:#888; text-align:center; grid-column: span 3; margin-top:20px;">Galerinizde fotoğraf yok. Önce kamerayla çekin!</p>';
        return;
    }
    
    for(let i = myPhotos.length - 1; i >= 0; i--) {
        let p = myPhotos[i];
        // Sahibinden için selectAdPhoto, Haberler için ise selectNewsPhoto fonksiyonunu ayırıyoruz.
        let clickEvent = galleryPickerMode === 'sahibinden' ? `selectAdPhoto('${p.photo_data}')` : `selectNewsPhoto('${p.photo_data}')`;
        
        container.innerHTML += `<div style="width: 100%; aspect-ratio: 1/1; background-image:url('${p.photo_data}'); background-size:cover; background-position:center; border-radius:5px; cursor:pointer; border:1px solid #444;" onclick="${clickEvent}"></div>`;
    }
}

function selectNewsPhoto(b64Data) {
    selectedNewsPhoto = b64Data;
    let preview = document.getElementById('news-photo-preview');
    preview.style.backgroundImage = `url('${b64Data}')`;
    preview.innerText = '';
    preview.style.border = 'none';
    closeGalleryPicker();
}

function closeGalleryPicker() { document.getElementById('gallery-picker-modal').style.display = 'none'; }

function selectAdPhoto(b64Data) {
    selectedAdPhoto = b64Data;
    let preview = document.getElementById('ad-photo-preview');
    preview.style.backgroundImage = `url('${b64Data}')`;
    preview.innerText = '';
    preview.style.border = 'none';
    closeGalleryPicker();
}

function fillCarDetails() {
    let vehId = document.getElementById('new-ad-veh').value;
    let selectedCar = myVehiclesData.find(v => String(v.id) === String(vehId));
    
    if (selectedCar) {
        document.getElementById('auto-km').value = selectedCar.km;
        document.getElementById('auto-color').value = "Boya: " + selectedCar.color;
    } else {
        document.getElementById('auto-km').value = "";
        document.getElementById('auto-color').value = "";
    }
}

function postNewAd() {
    let vehId = document.getElementById('new-ad-veh').value;
    let title = document.getElementById('new-ad-title').value;
    let price = document.getElementById('new-ad-price').value;
    
    if(!vehId || !title || !price) { alert("Lütfen tüm alanları doldurun!"); return; }
    
    // Fotoğraf seçimi ile birlikte sunucuya gönder
    mta.triggerEvent("phone:shbPostAd", vehId, title, price, selectedAdPhoto);
}

function updateMyAd() {
    let title = document.getElementById('edit-ad-title').value;
    let price = document.getElementById('edit-ad-price').value;
    if(!title || !price) return;
    mta.triggerEvent("phone:shbUpdateAd", title, price);
}

function deleteMyAd() {
    mta.triggerEvent("phone:shbDeleteAd");
}



// =====================================
// AKILLI AÇILIR MENÜ (ARAÇ SEÇİMİ) KONTROLLERİ
// =====================================
function toggleCarSelect() {
    let list = document.getElementById('custom-select-list');
    list.style.display = list.style.display === 'none' ? 'block' : 'none';
}

function selectAdCar(id, name, plate, km, color) {
    // Tıklanan aracın verilerini sisteme ve ekrana yerleştir
    document.getElementById('new-ad-veh').value = id;
    document.getElementById('selected-car-text').innerText = `${name} (${plate})`;
    
    // Menüyü geri kapat
    document.getElementById('custom-select-list').style.display = 'none';
    
    // KM ve Boya otomatik doldurma
    document.getElementById('auto-km').value = km;
    document.getElementById('auto-color').value = "Boya: " + color;
}




// =====================================
// HESAP MAKİNESİ MANTIĞI
// =====================================
let calcInput = "";
function updateCalc() { document.getElementById('calc-display').innerText = calcInput || "0"; }
function appendNumber(n) { calcInput += n; updateCalc(); }
function appendSymbol(s) { if(calcInput !== "") { calcInput += s; updateCalc(); } }
function calcClear() { calcInput = ""; updateCalc(); }
function calcDelete() { calcInput = calcInput.slice(0, -1); updateCalc(); }
function calculateResult() {
    try {
        calcInput = eval(calcInput).toString();
        updateCalc();
    } catch {
        calcInput = "";
        document.getElementById('calc-display').innerText = "Hata";
    }
}

// =====================================
// HAVA DURUMU GÜNCELLEME (Hata Giderildi)
// =====================================
function loadWeather(temp, desc, low, high, summary, hourlyJson, dailyJson) {
    document.getElementById('w-temp').innerText = temp + "°";
    document.getElementById('w-desc').innerText = desc;
    document.getElementById('w-range').innerText = `Y:${high}° D:${low}°`;
    document.getElementById('w-summary').innerText = summary;
    
    // JSON Çevirisi ve MTA Array Koruması
    let hourly = JSON.parse(hourlyJson || "[]");
    let daily = JSON.parse(dailyJson || "[]");
    
    if (hourly.length > 0 && Array.isArray(hourly[0])) hourly = hourly[0]; // Çift array koruması
    if (daily.length > 0 && Array.isArray(daily[0])) daily = daily[0];

    // SAATLİK TAHMİN
    let hList = document.getElementById('weather-hourly-list');
    hList.innerHTML = "";
    hourly.forEach((h, index) => {
        let timeText = index === 0 ? "Şu An" : h.hour;
        hList.innerHTML += `
            <div class="hourly-item">
                <span class="hourly-time">${timeText}</span>
                <span class="hourly-icon">${h.icon}</span>
                <span class="hourly-temp">${h.temp}°</span>
            </div>`;
    });

    // 3 GÜNLÜK TAHMİN
    let dList = document.getElementById('weather-daily-list');
    dList.innerHTML = "";
    daily.forEach((d, index) => {
        let dayText = index === 0 ? "Bugün" : d.day;
        
        // Bar Hesaplaması
        let minLimit = 5, maxLimit = 35; 
        let leftPct = Math.max(0, ((d.low - minLimit) / (maxLimit - minLimit)) * 100);
        let widthPct = Math.min(100, ((d.high - d.low) / (maxLimit - minLimit)) * 100);
        
        dList.innerHTML += `
            <div class="daily-item">
                <span class="daily-day">${dayText}</span>
                <span class="daily-icon">${d.icon}</span>
                <span class="daily-low">${d.low}°</span>
                <div class="daily-bar">
                    <div class="daily-bar-fill" style="left: ${leftPct}%; width: ${widthPct}%;"></div>
                </div>
                <span class="daily-high">${d.high}°</span>
            </div>`;
    });
}



// =====================================
// HABERLER UYGULAMASI (Faction 5)
// =====================================
function loadNewsData(jsonStr, isReporter) {
    let newsData = [];
    try { newsData = JSON.parse(jsonStr || "[]"); } catch(e){}
    
    if (newsData.length > 0 && Array.isArray(newsData[0])) newsData = newsData[0];
    
    let container = document.getElementById('news-content');
    container.innerHTML = '';
    
    // Faction 5 kontrolü HTML butonunu gizle/göster
    let panel = document.getElementById('news-reporter-panel');
    panel.style.display = isReporter ? 'block' : 'none';
    
    if (newsData.length === 0 || !newsData[0].title) {
        container.innerHTML = '<p style="text-align:center; color:#888; margin-top:50px;">Bülten şu an sessiz...</p>';
        return;
    }
    
    newsData.forEach(n => {
        let imgHtml = (n.photo_data && n.photo_data.length > 10) ? `<img src="${n.photo_data}">` : '';
        // CSS Sınıflarını Senin Style.css'e Göre Kodladım!
        container.innerHTML += `
            <div class="news-card">
                <div class="news-author">👤 ${n.author} | 🕒 ${n.post_date}</div>
                <div class="news-title">${n.title}</div>
                <div class="news-content">${n.description.replace(/\n/g, '<br>')}</div>
                ${imgHtml}
            </div>
        `;
    });
}

function openNewsForm() {
    document.getElementById('news-form-screen').style.display = 'flex';
    mta.triggerEvent("phone:requestPhotos"); // Galeriyi foto seçimi için önbelleğe al
}

function closeNewsForm() {
    document.getElementById('news-form-screen').style.display = 'none';
    // Formu sıfırla
    document.getElementById('news-title-input').value = '';
    document.getElementById('news-desc-input').value = '';
    selectedNewsPhoto = '';
    let preview = document.getElementById('news-photo-preview');
    preview.style.backgroundImage = 'none';
    preview.innerText = '📷 Galeriden Fotoğraf Seç';
    preview.style.border = '2px dashed #ccc';
}

function submitNews() {
    let title = document.getElementById('news-title-input').value.trim();
    let desc = document.getElementById('news-desc-input').value.trim();
    
    if(!title || !desc) { alert("Lütfen haberin başlığını ve detaylarını yazın!"); return; }
    
    mta.triggerEvent("phone:postNews", title, desc, selectedNewsPhoto);
    closeNewsForm();
    // Yüklendiğinde ekran MTA event'i tarafından otomatik yenilenir.
}