// === LOGİN İŞLEMLERİ ===
function attemptLogin() {
    let u = document.getElementById('log_user').value;
    let p = document.getElementById('log_pass').value;
    mta.triggerEvent("cef:girisYap", u, p);
}

function attemptRegister() {
    let u = document.getElementById('reg_user').value;
    let p = document.getElementById('reg_pass').value;
    mta.triggerEvent("cef:kayitOl", u, p);
}

// === KARAKTER OLUŞTURMA İŞLEMLERİ ===
function submitCharacter() {
    const fn = document.getElementById('firstname').value.trim();
    const ln = document.getElementById('lastname').value.trim();
    const age = parseInt(document.getElementById('age').value);
    const height = parseInt(document.getElementById('height').value);
    const weight = parseInt(document.getElementById('weight').value);
    const race = document.getElementById('race').value;
    
    // YENİ: Cinsiyet verisini (Erkek: 7, Kadın: 9) alıyoruz
    const gender = parseInt(document.getElementById('gender').value);

    // Sadece Türkçe ve İngilizce Harf Kontrolü
    const letterRegex = /^[a-zA-ZğüşıöçĞÜŞİÖÇ]+$/;
    
    if (!letterRegex.test(fn) || !letterRegex.test(ln)) {
        alert("HATA: Ad ve Soyad içerisinde SAYI, BOŞLUK veya ÖZEL KARAKTER (*, /, - vb.) kullanılamaz! Lütfen sadece harf girin.");
        return;
    }

    if (fn.length < 2 || ln.length < 2) {
        alert("Lütfen geçerli bir ad ve soyad girin. (En az 2 harf)");
        return;
    }
    
    if (!age || age < 18) { alert("Sunucuya girebilmek için yaşınız minimum 18 olmalıdır!"); return; }
    if (!height || height < 150) { alert("Boyunuz minimum 150 cm olmalıdır!"); return; }
    if (!weight || weight < 45) { alert("Kilonuz minimum 45 kg olmalıdır!"); return; }

    // Seçilen cinsiyet ID'si (gender) Lua'ya Skin verisi olarak gönderiliyor!
    mta.triggerEvent("cef:karakteriKaydet", fn, ln, gender, age, height, weight, race);
}

function loadCharacters(dataStr) {
    const parsed = JSON.parse(dataStr);
    const chars = parsed[0]; 
    
    const list = document.getElementById('character-list');
    if(!list) return;
    
    list.innerHTML = ''; 
    
    chars.forEach(char => {
        let cleanName = char.character_name.replace('_', ' ');
        list.innerHTML += `
            <div class="character-card">
                <div class="char-info">
                    <div class="char-name">${cleanName}</div>
                    <div class="char-details">Yaş: ${char.age} | Irk: ${char.race}</div>
                </div>
                <button class="play-btn" onclick="selectCharacter(${char.id})">Oyna</button>
            </div>
        `;
    });
}

function selectCharacter(id) {
    mta.triggerEvent("cef:karakterSecildi", id);
}

function createNewChar() {
    mta.triggerEvent("cef:yeniKarakterEkrani");
}