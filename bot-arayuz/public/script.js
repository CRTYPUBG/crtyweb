// /help butonuna tıklanınca sunucuya istek gönderir
function sendHelp() {
    const channelId = prompt('Mesaj göndermek istediğiniz kanal ID’sini girin:');
    if (!channelId) return;
    fetch('/send-help', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channelId })
    })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                alert('Hata: ' + data.error);
            } else {
                alert('Mesaj gönderildi!');
            }
        })
        .catch(() => alert('Bir hata oluştu!'));
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

    try {
        const response = await fetch('/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ token: tokenInput })
        });
        const data = await response.json();

        if (data.error) {
            messageElement.style.color = 'red';
            messageElement.textContent = data.error;
        } else {
            token = tokenInput;
            messageElement.textContent = '';
            document.getElementById('login-title').style.display = 'none';
            document.getElementById('token').style.display = 'none';
            document.getElementById('login-btn').style.display = 'none';
            dashboard.style.display = 'block';
            showBotInfo(data.bot);
        }
    } catch (error) {
        messageElement.style.color = 'red';
        messageElement.textContent = 'Bir hata oluştu!';
        console.error(error);
    }
}

async function fetchDashboard() {
    try {
        const response = await fetch('/dashboard', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await response.json();
        if (data.error) {
            document.getElementById('bot-info').innerHTML = `<span style='color:red'>${data.error}</span>`;
        } else {
            showBotInfo(data.bot);
        }
    } catch (error) {
        document.getElementById('bot-info').innerHTML = `<span style='color:red'>Bir hata oluştu!</span>`;
        console.error(error);
    }
    // ...
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