// Counter functionality
let counter = 0;
const counterButton = document.getElementById("counterButton");
const counterSpan = document.getElementById("counter");

// Initialize celebration animation style once
const celebrationStyle = document.createElement("style");
celebrationStyle.textContent = `
    @keyframes celebrate {
        0% { transform: translate(-50%, -50%) scale(0); opacity: 1; }
        50% { transform: translate(-50%, -50%) scale(1.2); opacity: 1; }
        100% { transform: translate(-50%, -50%) scale(1.5); opacity: 0; }
    }
`;
document.head.appendChild(celebrationStyle);

counterButton.addEventListener("click", function () {
  counter++;
  counterSpan.textContent = counter;

  // Add some visual feedback
  counterButton.style.transform = "scale(0.95)";
  setTimeout(() => {
    counterButton.style.transform = "scale(1)";
  }, 100);

  // Show celebration at milestones
  if (counter % 10 === 0) {
    showCelebration();
  }
});

// Theme toggle functionality
const colorButton = document.getElementById("colorButton");
let isDarkTheme = false;

colorButton.addEventListener("click", function () {
  isDarkTheme = !isDarkTheme;
  document.body.classList.toggle("dark-theme");

  colorButton.textContent = isDarkTheme ? "Light Theme" : "Dark Theme";

  // Save preference to localStorage
  localStorage.setItem("darkTheme", isDarkTheme);
});

// Load saved theme preference
document.addEventListener("DOMContentLoaded", function () {
  const savedTheme = localStorage.getItem("darkTheme");
  if (savedTheme === "true") {
    isDarkTheme = true;
    document.body.classList.add("dark-theme");
    colorButton.textContent = "Light Theme";
  }

  // Animate elements on page load
  animateOnLoad();

  // Update status periodically
  updateStatus();
  setInterval(updateStatus, 5000);
});

// Animation on page load
function animateOnLoad() {
  const cards = document.querySelectorAll(".feature-card");
  cards.forEach((card, index) => {
    card.style.opacity = "0";
    card.style.transform = "translateY(20px)";

    setTimeout(() => {
      card.style.transition = "all 0.6s ease";
      card.style.opacity = "1";
      card.style.transform = "translateY(0)";
    }, index * 200);
  });
}

// Celebration effect - optimized with reusable style
function showCelebration() {
  const celebration = document.createElement("div");
  celebration.innerHTML = "🎉";
  celebration.setAttribute("role", "status");
  celebration.setAttribute("aria-live", "polite");
  celebration.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 4rem;
        pointer-events: none;
        z-index: 1000;
        animation: celebrate 1s ease-out forwards;
    `;

  document.body.appendChild(celebration);

  setTimeout(() => {
    document.body.removeChild(celebration);
  }, 1000);
}

// Status updates
function updateStatus() {
  const statuses = ["Active", "Optimized", "Secure", "Fast"];
  const statusElement = document.getElementById("status");
  const randomStatus = statuses[Math.floor(Math.random() * statuses.length)];

  statusElement.style.opacity = "0.5";
  setTimeout(() => {
    statusElement.textContent = randomStatus;
    statusElement.style.opacity = "1";
  }, 300);
}

// Add some interactive hover effects
document.addEventListener("DOMContentLoaded", function () {
  const featureCards = document.querySelectorAll(".feature-card");

  featureCards.forEach((card) => {
    card.addEventListener("mouseenter", function () {
      this.style.transform = "translateY(-10px) scale(1.02)";
    });

    card.addEventListener("mouseleave", function () {
      this.style.transform = "translateY(0) scale(1)";
    });
  });
});

// Add keyboard navigation with visual feedback
const keyboardHints = document.createElement("div");
keyboardHints.className = "keyboard-hints";
keyboardHints.innerHTML = "<kbd>Space</kbd> Counter · <kbd>T</kbd> Theme";
keyboardHints.style.cssText = `
    position: fixed;
    bottom: 1rem;
    right: 1rem;
    background: var(--card-bg, #f9fafb);
    padding: 0.5rem 1rem;
    border-radius: 8px;
    font-size: 0.875rem;
    color: var(--text-light, #6b7280);
    box-shadow: var(--shadow, 0 4px 6px -1px rgba(0, 0, 0, 0.1));
    opacity: 0;
    transition: opacity 0.3s ease;
`;
document.body.appendChild(keyboardHints);

// Show hints on first load, then fade
setTimeout(() => {
  keyboardHints.style.opacity = "1";
  setTimeout(() => {
    keyboardHints.style.opacity = "0.7";
  }, 3000);
}, 1500);

document.addEventListener("keydown", function (e) {
  if (e.key === " " || e.key === "Spacebar") {
    e.preventDefault();
    counterButton.click();
  } else if (e.key === "t" || e.key === "T") {
    colorButton.click();
  }
});

// Performance monitoring - only in development
if (
  window.location.hostname === "localhost" ||
  window.location.hostname === "127.0.0.1"
) {
  window.addEventListener("load", function () {
    const loadTime =
      window.performance.timing.loadEventEnd -
      window.performance.timing.navigationStart;
    console.log(`Page loaded in ${loadTime}ms`);
  });
}
