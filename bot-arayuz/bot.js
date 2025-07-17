const { Client, GatewayIntentBits } = require('discord.js');

let botClient = null;
module.exports.botClient = botClient;

function startBot(token) {
    if (botClient) {
        botClient.destroy();
        botClient = null;
    }
    botClient = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages] });
    module.exports.botClient = botClient;
    botClient.once('ready', () => {
        console.log(`Bot aktif: ${botClient.user.tag}`);
    });
    botClient.on('error', err => {
        console.error('Bot hata:', err);
    });
    botClient.login(token).catch(err => {
        console.error('Giriş hatası:', err);
    });
}

function getBotInfo() {
    if (botClient && botClient.user) {
        const guilds = botClient.guilds.cache.map(guild => ({
            name: guild.name,
            id: guild.id,
            memberCount: guild.memberCount
        }));
        const channels = botClient.channels.cache.size;
        const os = require('os');
        return {
            username: botClient.user.username,
            discriminator: botClient.user.discriminator,
            id: botClient.user.id,
            avatar: botClient.user.avatar,
            createdAt: botClient.user.createdAt,
            status: botClient.user.presence ? botClient.user.presence.status : 'online',
            guildCount: botClient.guilds.cache.size,
            channelCount: channels,
            guilds: guilds,
            host: os.hostname(),
            profileUrl: `https://discord.com/users/${botClient.user.id}`,
            ping: botClient.ws.ping
        };
    }
    return null;
}

function stopBot() {
    if (botClient) {
        botClient.destroy();
        botClient = null;
    }
}

module.exports = { startBot, getBotInfo, stopBot };
