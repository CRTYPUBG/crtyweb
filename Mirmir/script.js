const API_URL = 'http://91.132.49.137:3000';
let autoRefreshInterval = null;

// Tab değiştirme fonksiyonu
function showTab(tabName) {
    // Tüm tabları ve panelleri gizle
    document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(panel => panel.classList.remove('active'));
    
    // Seçili tab ve paneli göster
    event.target.classList.add('active');
    document.getElementById(tabName + '-panel').classList.add('active');
}

// Alert gösterme fonksiyonu
function showAlert(containerId, message, type = 'info') {
    const container = document.getElementById(containerId);
    container.innerHTML = `<div class="alert alert-${type}">${message}</div>`;
    setTimeout(() => {
        container.innerHTML = '';
    }, 5000);
}

// Loading gösterme/gizleme
function toggleLoading(loadingId, show) {
    document.getElementById(loadingId).style.display = show ? 'block' : 'none';
}

// API istek fonksiyonu
async function makeRequest(endpoint, data = null, method = 'GET') {
    try {
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            }
        };
        
        if (data) {
            options.body = JSON.stringify(data);
        }

        const response = await fetch(`${API_URL}${endpoint}`, options);
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        return { success: false, error: 'Bağlantı hatası! Lütfen API sunucusunun çalıştığından emin olun.' };
    }
}

// Bot oluşturma
document.getElementById('create-form').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    toggleLoading('create-loading', true);
    
    const formData = {
        code: document.getElementById('auth-code').value,
        options: {
            server: {
                host: document.getElementById('server-host').value,
                port: parseInt(document.getElementById('server-port').value),
                username: document.getElementById('username').value,
                version: document.getElementById('version').value
            },
            password: document.getElementById('password').value
        }
    };

    const result = await makeRequest('/create', formData, 'POST');
    
    toggleLoading('create-loading', false);
    
    if (result.success) {
        showAlert('create-alert', 
            `Bot başarıyla oluşturuldu! Bot ID: ${result.data.id || result.data || result}`, 'success');
        document.getElementById('create-form').reset();
    } else {
        showAlert('create-alert', result.error, 'error');
    }
});

// Bot yönetim fonksiyonları
async function performBotAction(action) {
    const id = document.getElementById('manage-id').value;
    const password = document.getElementById('manage-password').value;
    
    if (!id || !password) {
        showAlert('manage-alert', 'Bot ID ve şifre gerekli!', 'error');
        return;
    }

    toggleLoading('manage-loading', true);
    
    const result = await makeRequest(`/${action}`, { id, password }, 'POST');
    
    toggleLoading('manage-loading', false);
    
    if (result.success) {
        showAlert('manage-alert', `Bot ${action} işlemi başarılı!`, 'success');
    } else {
        showAlert('manage-alert', result.error, 'error');
    }
}

function startBot() {
    performBotAction('start');
}

function restartBot() {
    performBotAction('restart');
}

function stopBot() {
    performBotAction('stop');
}

// Mesaj gönderme
async function sendMessage() {
    const id = document.getElementById('manage-id').value;
    const password = document.getElementById('manage-password').value;
    const message = document.getElementById('message-input').value;
    
    if (!id || !password || !message) {
        showAlert('manage-alert', 'Tüm alanlar gerekli!', 'error');
        return;
    }

    toggleLoading('manage-loading', true);
    
    const result = await makeRequest('/send', { id, password, message }, 'POST');
    
    toggleLoading('manage-loading', false);
    
    if (result.success) {
        showAlert('manage-alert', 'Mesaj başarıyla gönderildi!', 'success');
        document.getElementById('message-input').value = '';
    } else {
        showAlert('manage-alert', result.error, 'error');
    }
}

// Bot durumu kontrolü
async function getBotInfo() {
    const id = document.getElementById('status-id').value;
    const password = document.getElementById('status-password').value;
    
    if (!id || !password) {
        showAlert('status-alert', 'Bot ID ve şifre gerekli!', 'error');
        return;
    }

    toggleLoading('status-loading', true);
    
    const result = await makeRequest('/info', { id, password }, 'POST');
    
    toggleLoading('status-loading', false);
    
    if (result.success) {
        updateBotStatus(result.data);
        showAlert('status-alert', 'Bot durumu güncellendi!', 'success');
    } else {
        showAlert('status-alert', result.error, 'error');
        document.getElementById('bot-status').style.display = 'none';
    }
}

// Bot durumu güncelleme
function updateBotStatus(data) {
    document.getElementById('bot-status').style.display = 'block';
    document.getElementById('bot-active').textContent = data.active;
    document.getElementById('message-count').textContent = data.messages.length;
    document.getElementById('last-update').textContent = new Date().toLocaleTimeString('tr-TR');
    
    // Durum kartı rengini güncelle
    const statusCard = document.getElementById('bot-status');
    statusCard.className = 'status-card ' + (data.active === 'Açık' ? 'status-online' : 'status-offline');
    
    // Mesajları güncelle
    const messagesContainer = document.getElementById('messages-container');
    if (data.messages.length > 0) {
        messagesContainer.innerHTML = data.messages.map(msg => 
            `<div class="message">${msg}</div>`
        ).join('');
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    } else {
        messagesContainer.innerHTML = '<p style="text-align: center; color: #666;">Henüz mesaj yok</p>';
    }
}

// Otomatik yenileme
function startAutoRefresh() {
    if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
    }
    
    autoRefreshInterval = setInterval(() => {
        const id = document.getElementById('status-id').value;
        const password = document.getElementById('status-password').value;
        
        if (id && password) {
            getBotInfo();
        }
    }, 5000); // 5 saniyede bir yenile
    
    showAlert('status-alert', 'Otomatik yenileme başlatıldı (5 saniye)', 'info');
}

function stopAutoRefresh() {
    if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
        autoRefreshInterval = null;
        showAlert('status-alert', 'Otomatik yenileme durduruldu', 'info');
    }
}

// Sayfa yüklendiğinde API'yi test et
window.addEventListener('load', async function() {
    const result = await makeRequest('/api');
    if (!result.message) {
        showAlert('create-alert', 'API sunucusuna bağlanılamıyor! Lütfen sunucunun çalıştığından emin olun.', 'error');
    }
});