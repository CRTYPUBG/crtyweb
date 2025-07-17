// ...existing code...
const express = require('express');
const { startBot, getBotInfo, stopBot } = require('./bot');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const app = express();
const port = 3000;
const secretKey = 'gizli-anahtar-123'; // Gerçek uygulamada çevresel değişken kullan!

app.use(express.static('public'));
app.use(express.json());

// Giriş endpoint'i
app.post('/login', async (req, res) => {
    const { token } = req.body;
    if (!token) {
        return res.status(400).json({ error: 'Token gerekli!' });
    }
    try {
        startBot(token);
        // Botun hazır olmasını beklemek için kısa bir gecikme
        setTimeout(() => {
            const botInfo = getBotInfo();
            if (botInfo) {
                res.json({ message: 'Bot başarıyla başlatıldı!', bot: botInfo });
            } else {
                res.status(401).json({ error: 'Bot başlatılamadı! Token geçersiz veya bot devre dışı.' });
            }
        }, 3000);
    } catch (error) {
        res.status(500).json({ error: 'Bot başlatma hatası!', details: error.message });
    }
});

// Korumalı endpoint (örnek: bot kontrol paneli)
app.get('/dashboard', (req, res) => {
    const botInfo = getBotInfo();
    if (botInfo) {
        res.json({ message: `Hoş geldin, ${botInfo.username}!`, bot: botInfo });
    } else {
        res.status(403).json({ error: 'Bot aktif değil veya token geçersiz!' });
    }
});

// Sunucuyu başlat
app.post('/logout', (req, res) => {
    stopBot();
    res.json({ message: 'Bot durduruldu.' });
});

app.listen(port, () => {
    // /send-help endpointi: bot belirli bir kanala /help mesajı gönderir
    app.post('/send-help', async (req, res) => {
        const { channelId } = req.body;
        if (!channelId) {
            return res.status(400).json({ error: 'Kanal ID gerekli!' });
        }
        try {
            const { botClient } = require('./bot');
            if (!botClient || !botClient.channels) {
                return res.status(400).json({ error: 'Bot aktif değil!' });
            }
            const channel = botClient.channels.cache.get(channelId);
            if (!channel) {
                return res.status(404).json({ error: 'Kanal bulunamadı!' });
            }
            await channel.send('/help');
            res.json({ message: 'Mesaj gönderildi!' });
        } catch (error) {
            res.status(500).json({ error: 'Mesaj gönderilemedi!', details: error.message });
        }
    });
    console.log(`Sunucu http://localhost:${port} adresinde çalışıyor`);
});