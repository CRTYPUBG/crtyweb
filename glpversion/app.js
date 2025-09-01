// -------------------- MÜZİK OTOMATİK --------------------
const music = new Audio("blo.mp3");
music.loop = true;

const musicOverlay = document.createElement("div");
musicOverlay.id = "musicOverlay";
musicOverlay.className = "fixed inset-0 bg-black bg-opacity-80 flex flex-col items-center justify-center text-center z-50";
musicOverlay.innerHTML = `
  <p class="text-white text-2xl mb-4">Devam etmek için tıklayın ve müzik çalsın</p>
  <button id="playMusicBtn" class="px-6 py-3 bg-green-600 rounded-lg text-white font-bold hover:bg-green-500">Tıkla</button>
`;
document.body.appendChild(musicOverlay);

const playBtn = document.getElementById("playMusicBtn");

// Otomatik çalma denemesi
music.play().catch(() => {
  musicOverlay.style.display = "flex";
});

// Kullanıcı tıklarsa müzik başlat
playBtn.addEventListener("click", () => {
  music.play();
  musicOverlay.style.display = "none";
});

// -------------------- LİNKLER --------------------
const links = [
  { name: "GameLoop Resmi 32-bit", url: "https://down.gameloop.com/channel/3/16412/GLP_installer_1000218456_market.exe", source: "official" },
  { name: "GameLoop Resmi 64-bit", url: "https://down.gameloop.com/installer/GLP_installer_1000242496_market.exe", source: "official" },
  { name: "Softonic Sürüm", url: "https://gameloop.en.softonic.com/", source: "softonic" },
  { name: "FileHippo Sürüm", url: "https://filehippo.com/download_gameloop/", source: "filehippo" },
  { name: "GameLoop.ir", url: "https://gameloop.ir", source: "gameloopir" }
];

const container = document.getElementById("linksContainer");
const searchInput = document.getElementById("searchInput");
const sourceFilter = document.getElementById("sourceFilter");
const openSelected = document.getElementById("openSelected");
const selectVisible = document.getElementById("selectVisible");
const clearSelection = document.getElementById("clearSelection");
const modal = document.getElementById("modal");
const modalLinks = document.getElementById("modalLinks");
const closeModal = document.getElementById("closeModal");
const copyAll = document.getElementById("copyAll");
const toast = document.getElementById("toast");

let selected = new Set();

// Linkleri render et
function renderLinks() {
  container.innerHTML = "";
  const query = searchInput.value.toLowerCase();
  const filter = sourceFilter.value;

  links.forEach((link, index) => {
    if ((filter === "all" || link.source === filter) &&
        (link.name.toLowerCase().includes(query))) {
      
      const item = document.createElement("div");
      item.className = "flex justify-between items-center bg-gray-800 p-4 rounded-lg shadow-md animate-fade-in";
      item.innerHTML = `
        <label class="flex items-center gap-2">
          <input type="checkbox" data-index="${index}" ${selected.has(index) ? "checked" : ""}>
          <span>${link.name}</span>
        </label>
        <div class="flex gap-2">
          <a href="${link.url}" target="_blank" class="btn-secondary">Aç</a>
          <button data-copy="${link.url}" class="btn-primary">Kopyala</button>
        </div>
      `;
      container.appendChild(item);
    }
  });
  updateCounter();
}

// Sayaç güncelle
function updateCounter() {
  openSelected.textContent = `Seçilenleri Aç (${selected.size})`;
}

// Tümünü aç
openSelected.addEventListener("click", () => {
  const toOpen = [...selected].map(i => links[i].url);
  if (!toOpen.length) return;

  let blocked = [];
  toOpen.forEach(url => {
    let newWin = window.open("about:blank", "_blank");
    if (newWin) {
      newWin.location.href = url;
    } else {
      blocked.push(url);
    }
  });

  if (blocked.length) {
    modal.classList.remove("hidden");
    modalLinks.innerHTML = blocked.map(u => `<a href="${u}" target="_blank" class="block text-blue-400 underline">${u}</a>`).join("");
  }
});

// Görünürünü seç
selectVisible.addEventListener("click", () => {
  const checkboxes = container.querySelectorAll("input[type=checkbox]");
  checkboxes.forEach(cb => selected.add(Number(cb.dataset.index)));
  renderLinks();
});

// Temizle
clearSelection.addEventListener("click", () => {
  selected.clear();
  renderLinks();
});

// Modal kapat
closeModal.addEventListener("click", () => modal.classList.add("hidden"));

// Tümünü kopyala
copyAll.addEventListener("click", () => {
  const texts = [...modalLinks.querySelectorAll("a")].map(a => a.href).join("\n");
  navigator.clipboard.writeText(texts).then(showToast);
});

// Kopyalama ve checkbox
document.addEventListener("click", e => {
  if (e.target.dataset.copy) {
    navigator.clipboard.writeText(e.target.dataset.copy).then(showToast);
  }
  if (e.target.type === "checkbox") {
    const i = Number(e.target.dataset.index);
    if (e.target.checked) selected.add(i);
    else selected.delete(i);
    updateCounter();
  }
});

// Toast
function showToast() {
  toast.classList.remove("hidden");
  setTimeout(() => toast.classList.add("hidden"), 2000);
}

// Filtre / arama
searchInput.addEventListener("input", renderLinks);
sourceFilter.addEventListener("change", renderLinks);

// İlk yükleme
renderLinks();
