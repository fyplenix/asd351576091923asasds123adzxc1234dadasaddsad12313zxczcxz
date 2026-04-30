// MTA'daki araç ID'leri, isimleri ve RP fiyatları
const vehicleList = [
    { id: 405, name: "Sentinel", class: "Sedan / Coupe", price: 85000 },
    { id: 560, name: "Sultan", class: "Spor Sedan", price: 110000 },
    { id: 415, name: "Cheetah", class: "Süper Spor", price: 250000 },
    { id: 411, name: "Mercedes AMG GT", class: "Süper Spor", price: 500000 }, 
    { id: 479, name: "BMW M5 F90", class: "Premium Spor", price: 650000 },
    { id: 507, name: "Volkswagen Passat", class: "Premium Sedan", price: 180000 },
    { id: 426, name: "Premier", class: "Standart Sedan", price: 35000 },
    { id: 479, name: "Bmw M5 F90", class: "Premium Sedan", price: 35000 },
    { id: 527, name: "Bmw M4 F82", class: "Coupe", price: 35000 },
    { id: 404, name: "Audi RS6", class: "Station Vagon", price: 35000 },
    { id: 490, name: "FBI Rancher", class: "Ağır SUV", price: 150000 }
];

let selectedVehicle = null;

// Sayfa yüklendiğinde araç listesini oluştur
window.onload = function() {
    const listContainer = document.getElementById('car-list');
    
    vehicleList.forEach((car, index) => {
        let carDiv = document.createElement('div');
        carDiv.className = 'car-item';
        carDiv.id = `car-${index}`;
        
        let formattedPrice = "$" + car.price.toLocaleString('en-US');
        
        carDiv.innerHTML = `
            <span class="car-item-name">${car.name}</span>
            <span class="car-item-price">${formattedPrice}</span>
        `;
        
        carDiv.onclick = () => selectCar(index, carDiv);
        listContainer.appendChild(carDiv);
    });
};

function selectCar(index, element) {
    document.querySelectorAll('.car-item').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    selectedVehicle = vehicleList[index];
    
    document.getElementById('selected-name').innerText = selectedVehicle.name;
    document.getElementById('selected-class').innerText = `Sınıf: ${selectedVehicle.class}`;
    document.getElementById('selected-price').innerText = "$" + selectedVehicle.price.toLocaleString('en-US');
    
    document.getElementById('customization-box').style.display = 'block';
}

function hexToRgb(hex) {
    let result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : { r: 255, g: 255, b: 255 }; 
}

// Hazır renk paletinden seçim yapma
function selectPresetColor(hexColor, element) {
    document.querySelectorAll('.color-swatch').forEach(el => el.classList.remove('swatch-selected'));
    element.classList.add('swatch-selected');
    
    document.getElementById('car-color').value = hexColor;
    document.getElementById('custom-color-preview').style.backgroundColor = hexColor;
}

// Özel renk seçiciden (Hue bar) seçim yapma
function updateCustomColor(hexColor) {
    document.querySelectorAll('.color-swatch').forEach(el => el.classList.remove('swatch-selected'));
    document.getElementById('custom-color-preview').style.backgroundColor = hexColor;
}

// Satın Alma Fonksiyonu (Donate ve Renk entegreli)
function buyVehicle() {
    if (!selectedVehicle) return;
    
    let hexColor = document.getElementById('car-color').value;
    let rgb = hexToRgb(hexColor);
    
    let customPlate = document.getElementById('custom-plate').value.trim().toUpperCase();
    
    mta.triggerEvent("cef:aracAl", selectedVehicle.id, selectedVehicle.price, rgb.r, rgb.g, rgb.b, customPlate);
}

function closeGallery() {
    mta.triggerEvent("cef:galeriKapat");
}

// MTA'dan (LUA) gelen Donate Cash bilgisini işler
function setPlayerDC(amount) {
    let displayBadge = document.getElementById('player-dc-display');
    let plateInput = document.getElementById('custom-plate');
    
    // Bakiyeyi ekrana yazdır
    displayBadge.innerText = `Mevcut: ${amount} DC`;
    
    // Eğer bakiye 500'den azsa, rengi kırmızı yap ve inputu kilitle
    if (amount < 500) {
        displayBadge.style.color = "#e74c3c";
        displayBadge.style.background = "rgba(231, 76, 60, 0.1)";
        displayBadge.style.borderColor = "rgba(231, 76, 60, 0.3)";
        
        plateInput.readOnly = true;
        plateInput.classList.add('disabled-input');
        plateInput.placeholder = "YETERSİZ BAKİYE";
        
        // Tıklanmaya çalışıldığında uyarı ver
        plateInput.onclick = function() {
            mta.triggerEvent("cef:galeriUyari", "Özel plaka almak için yeterli Donate Cash (DC) bakiyeniz bulunmuyor!");
        };
    } else {
        // Bakiye yetiyorsa normal (yeşil) kalsın ve input açık olsun
        displayBadge.style.color = "#2ecc71";
        displayBadge.style.background = "rgba(46, 204, 113, 0.1)";
        displayBadge.style.borderColor = "rgba(46, 204, 113, 0.3)";
        
        plateInput.readOnly = false;
        plateInput.classList.remove('disabled-input');
        plateInput.placeholder = "Örn: 34 FURKAN 01";
        plateInput.onclick = null;
    }
}