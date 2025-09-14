// Theme Toggle Functionality
const themeToggle = document.getElementById('themeToggle');
const themeIcon = document.getElementById('themeIcon');
const themeText = document.getElementById('themeText');
const body = document.body;

// Check for saved theme preference or default to dark theme
const currentTheme = localStorage.getItem('theme') || 'dark';
if (currentTheme === 'light') {
    body.classList.add('light-theme');
    themeIcon.className = 'fas fa-moon';
    themeText.textContent = 'Dark';
}

themeToggle.addEventListener('click', () => {
    body.classList.toggle('light-theme');
    
    if (body.classList.contains('light-theme')) {
        themeIcon.className = 'fas fa-moon';
        themeText.textContent = 'Dark';
        localStorage.setItem('theme', 'light');
    } else {
        themeIcon.className = 'fas fa-sun';
        themeText.textContent = 'Light';
        localStorage.setItem('theme', 'dark');
    }
});

// Mobile Navigation Toggle
const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');

hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    navMenu.classList.toggle('active');
});

// Close mobile menu when clicking on a link
document.querySelectorAll('.nav-menu a').forEach(n => n.addEventListener('click', () => {
    hamburger.classList.remove('active');
    navMenu.classList.remove('active');
}));

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Header background change is now handled in the optimized scroll function above

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all service cards and tool cards
document.querySelectorAll('.service-card, .tool-card').forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(30px)';
    card.style.transition = 'all 0.6s ease';
    observer.observe(card);
});

// Contact form handling
const contactForm = document.querySelector('.contact-form form');
if (contactForm) {
    contactForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get form data
        const name = this.querySelector('input[type="text"]').value;
        const email = this.querySelector('input[type="email"]').value;
        const message = this.querySelector('textarea').value;
        
        // Simple validation
        if (!name || !email || !message) {
            alert('Lütfen tüm alanları doldurun!');
            return;
        }
        
        // Show success message
        alert('Mesajınız alındı! En kısa sürede size dönüş yapacağım.');
        
        // Reset form
        this.reset();
    });
}

// Add loading animation to buttons
document.querySelectorAll('.btn').forEach(btn => {
    btn.addEventListener('click', function() {
        if (!this.href || this.href.includes('#')) return;
        
        const originalText = this.innerHTML;
        this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Yükleniyor...';
        
        setTimeout(() => {
            this.innerHTML = originalText;
        }, 1000);
    });
});

// Optimized scroll handling with throttling
let ticking = false;

function updateScrollEffects() {
    const scrolled = window.pageYOffset;
    const header = document.querySelector('.header');
    const isLightTheme = document.body.classList.contains('light-theme');
    
    // Header background change
    if (scrolled > 100) {
        if (isLightTheme) {
            header.style.background = 'rgba(255, 255, 255, 0.98)';
        } else {
            header.style.background = 'rgba(10, 10, 15, 0.98)';
        }
    } else {
        if (isLightTheme) {
            header.style.background = 'rgba(255, 255, 255, 0.95)';
        } else {
            header.style.background = 'rgba(10, 10, 15, 0.95)';
        }
    }
    
    ticking = false;
}

function requestTick() {
    if (!ticking) {
        requestAnimationFrame(updateScrollEffects);
        ticking = true;
    }
}

window.addEventListener('scroll', requestTick, { passive: true });

// Simple and smooth typing effect
function simpleTypeWriter(element, text) {
    let i = 0;
    element.innerHTML = '<span class="typing-cursor">|</span>';
    
    function type() {
        if (i < text.length) {
            const currentText = text.substring(0, i + 1);
            element.innerHTML = currentText + '<span class="typing-cursor">|</span>';
            i++;
            
            // Variable typing speed for more natural feel
            let speed = 90;
            if (text.charAt(i - 1) === ' ') {
                speed = 150; // Pause at spaces
            }
            
            setTimeout(type, speed);
        } else {
            // Remove cursor after typing is done
            setTimeout(() => {
                element.innerHTML = text;
            }, 800); // Longer pause before removing cursor
        }
    }
    
    setTimeout(type, 800); // Start with a nice pause
}

// Initialize typing effect when page loads
window.addEventListener('load', () => {
    const heroTitle = document.querySelector('.hero-content h1');
    if (heroTitle) {
        const originalText = heroTitle.textContent;
        simpleTypeWriter(heroTitle, originalText);
    }
});

// Optimized particle effect for hero section
function createParticles() {
    const hero = document.querySelector('.hero');
    const particleCount = 30; // Reduced for better performance
    
    for (let i = 0; i < particleCount; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.cssText = `
            position: absolute;
            width: 2px;
            height: 2px;
            background: rgba(0, 255, 255, 0.3);
            border-radius: 50%;
            pointer-events: none;
            left: ${Math.random() * 100}%;
            top: ${Math.random() * 100}%;
            animation: float ${3 + Math.random() * 4}s ease-in-out infinite;
            animation-delay: ${Math.random() * 2}s;
            will-change: transform;
        `;
        hero.appendChild(particle);
    }
}

// Initialize particles
createParticles();

// 3D Logo Mouse Interaction
function init3DLogo() {
    const logo3D = document.querySelector('.logo-3d');
    const logoImg = document.querySelector('.logo-3d-img');
    
    if (!logo3D || !logoImg) {
        console.log('3D Logo elements not found!');
        return;
    }
    
    // Check if image loads
    logoImg.addEventListener('load', () => {
        console.log('Logo image loaded successfully!');
    });
    
    logoImg.addEventListener('error', () => {
        console.log('Logo image failed to load!');
        // Fallback: show a colored circle
        logoImg.style.background = 'linear-gradient(45deg, #00ffff, #0080ff)';
        logoImg.alt = 'RAMBO';
    });
    
    logo3D.addEventListener('mousemove', (e) => {
        const rect = logo3D.getBoundingClientRect();
        const centerX = rect.left + rect.width / 2;
        const centerY = rect.top + rect.height / 2;
        
        const mouseX = e.clientX - centerX;
        const mouseY = e.clientY - centerY;
        
        const rotateX = (mouseY / rect.height) * 30;
        const rotateY = (mouseX / rect.width) * 30;
        
        logoImg.style.transform = `rotateX(${-rotateX}deg) rotateY(${rotateY}deg) scale(1.05)`;
    });
    
    logo3D.addEventListener('mouseleave', () => {
        logoImg.style.transform = '';
    });
    
    // Space Journey Click Effect
    logo3D.addEventListener('click', () => {
        console.log('Logo clicked!'); // Debug
        simpleSpaceEffect();
    });
}

// Simple Space Effect
function simpleSpaceEffect() {
    console.log('Starting space effect...'); // Debug
    
    // Create simple overlay
    const overlay = document.createElement('div');
    overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(45deg, #000033, #000066, #000033);
        z-index: 9999;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        opacity: 0;
        transition: opacity 0.5s ease;
    `;
    
    // Add content
    overlay.innerHTML = `
        <div style="text-align: center;">
            <img src="Logo.jpg" style="
                width: 200px;
                height: 200px;
                border-radius: 50%;
                border: 3px solid #00ffff;
                box-shadow: 0 0 50px #00ffff;
                animation: spin 2s linear infinite;
                margin-bottom: 2rem;
            ">
            <div style="
                font-size: 2rem;
                color: #00ffff;
                text-shadow: 0 0 20px #00ffff;
                font-weight: bold;
            ">🚀 UZAY YOLCULUĞU! 🚀</div>
        </div>
    `;
    
    document.body.appendChild(overlay);
    
    // Show overlay
    setTimeout(() => {
        overlay.style.opacity = '1';
    }, 100);
    
    // Remove after 3 seconds
    setTimeout(() => {
        overlay.style.opacity = '0';
        setTimeout(() => {
            overlay.remove();
            showWelcomeBack();
        }, 500);
    }, 3000);
}

// Removed unused functions

function showWelcomeBack() {
    const welcomeDiv = document.createElement('div');
    welcomeDiv.className = 'welcome-back';
    welcomeDiv.innerHTML = '🚀 UZAY YOLCULUĞU TAMAMLANDI! 🚀';
    document.body.appendChild(welcomeDiv);
    
    setTimeout(() => {
        welcomeDiv.remove();
    }, 3000);
}

// Initialize 3D logo
window.addEventListener('load', () => {
    console.log('Page loaded, initializing logo...');
    init3DLogo();
});

// Optimized scroll progress indicator
function addScrollProgress() {
    const progressBar = document.createElement('div');
    progressBar.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 0%;
        height: 3px;
        background: linear-gradient(90deg, #00ffff, #0080ff, #8000ff);
        z-index: 9999;
        will-change: width;
    `;
    document.body.appendChild(progressBar);
    
    let progressTicking = false;
    
    function updateProgress() {
        const scrollPercent = (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100;
        progressBar.style.width = Math.min(100, Math.max(0, scrollPercent)) + '%';
        progressTicking = false;
    }
    
    window.addEventListener('scroll', () => {
        if (!progressTicking) {
            requestAnimationFrame(updateProgress);
            progressTicking = true;
        }
    }, { passive: true });
}

// Initialize scroll progress
addScrollProgress();