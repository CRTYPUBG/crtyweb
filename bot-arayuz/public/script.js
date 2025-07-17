// /help butonuna tıklanınca sunucuya istek gönderir
function sendHelp() {
    alert('/help komutu gönderilemez. (Sadece demo arayüz)');
}
// Discord bot bilgilerini kontrol panelinde gösterir
function showBotInfo(bot) {
    const botInfoDiv = document.getElementById('bot-info');
    if (!bot) {
        botInfoDiv.innerHTML = '<span style="color:red">Bot bilgisi alınamadı.</span>';
        return;
    }
    // Avatar URL'si yoksa varsayılan avatarı kullan
    let avatarUrl = bot.avatar
        ? `https://cdn.discordapp.com/avatars/${bot.id}/${bot.avatar}.png`
        : `https://cdn.discordapp.com/embed/avatars/${parseInt(bot.discriminator) % 5}.png`;
    botInfoDiv.innerHTML = `
        <img src='${avatarUrl}' width='80' height='80' style='border-radius:50%;margin-bottom:10px;'>
        <br>
        <strong>Bot Adı:</strong> ${bot.username}#${bot.discriminator} <br>
        <strong>ID:</strong> ${bot.id} <br>
        <strong>Profil:</strong> <a href='${bot.profileUrl}' target='_blank'>${bot.profileUrl}</a> <br>
        <strong>Oluşturulma Tarihi:</strong> ${new Date(bot.createdAt).toLocaleString()} <br>
        <strong>Durum:</strong> ${bot.status} <br>
        <strong>Host:</strong> ${bot.host} <br>
        <strong>Ping:</strong> ${bot.ping} ms <br>
        <strong>Sunucu Sayısı:</strong> ${bot.guildCount} <br>
        <strong>Kanal Sayısı:</strong> ${bot.channelCount} <br>
        <strong>Bağlı Sunucular:</strong>
        <ul style='text-align:left;max-height:120px;overflow:auto;background:#23272a;padding:8px;border-radius:6px;'>
            ${bot.guilds.map(g => `<li><b>${g.name}</b> <span style='color:#aaa'>(ID: ${g.id}, Üye: ${g.memberCount})</span></li>`).join('')}
        </ul>
    `;
}
let token = null;

async function login() {
    const tokenInput = document.getElementById('token').value;
    const messageElement = document.getElementById('message');
    const dashboard = document.getElementById('dashboard');

    if (!tokenInput) {
        messageElement.textContent = 'Lütfen Discord bot tokenını girin!';
        return;
    }

    // Demo: Her zaman örnek bot bilgisi göster
    token = tokenInput;
    messageElement.textContent = '';
    document.getElementById('login-title').style.display = 'none';
    document.getElementById('token').style.display = 'none';
    document.getElementById('login-btn').style.display = 'none';
    dashboard.style.display = 'block';
    // Örnek bot bilgisi
    showBotInfo({
        id: '123456789012345678',
        username: 'DemoBot',
        discriminator: '0001',
        avatar: null,
        profileUrl: 'https://discord.com/users/123456789012345678',
        createdAt: Date.now(),
        status: 'online',
        host: 'github-pages',
        ping: 42,
        guildCount: 3,
        channelCount: 12,
        guilds: [
            { name: 'Demo Sunucu 1', id: '111', memberCount: 123 },
            { name: 'Demo Sunucu 2', id: '222', memberCount: 456 },
            { name: 'Demo Sunucu 3', id: '333', memberCount: 789 }
        ]
    });
}

async function fetchDashboard() {
    // Demo: Her zaman örnek bot bilgisi göster
    showBotInfo({
        id: '123456789012345678',
        username: 'DemoBot',
        discriminator: '0001',
        avatar: null,
        profileUrl: 'https://discord.com/users/123456789012345678',
        createdAt: Date.now(),
        status: 'online',
        host: 'github-pages',
        ping: 42,
        guildCount: 3,
        channelCount: 12,
        guilds: [
            { name: 'Demo Sunucu 1', id: '111', memberCount: 123 },
            { name: 'Demo Sunucu 2', id: '222', memberCount: 456 },
            { name: 'Demo Sunucu 3', id: '333', memberCount: 789 }
        ]
    });
}

function logout() {
    token = null;
    document.getElementById('login-title').style.display = 'block';
    document.getElementById('token').style.display = 'block';
    document.getElementById('login-btn').style.display = 'block';
    document.getElementById('dashboard').style.display = 'none';
    document.getElementById('message').style.color = 'green';
    document.getElementById('message').textContent = 'Çıkış yapıldı.';
    document.getElementById('bot-info').innerHTML = '';
}
