// PWA Install Prompt Handler for Integrity Tools
// Captures beforeinstallprompt event and shows custom install UI

let deferredPrompt;
let installButton;

// Track visit count for showing install prompt
function incrementVisitCount() {
  const visits = parseInt(localStorage.getItem('pwa_visit_count') || '0');
  localStorage.setItem('pwa_visit_count', (visits + 1).toString());
  return visits + 1;
}

function hasUserDismissedInstall() {
  return localStorage.getItem('pwa_install_dismissed') === 'true';
}

function hasUserInstalledApp() {
  return localStorage.getItem('pwa_installed') === 'true';
}

function markInstallDismissed() {
  localStorage.setItem('pwa_install_dismissed', 'true');
}

function markAppInstalled() {
  localStorage.setItem('pwa_installed', 'true');
}

// Create and show install banner
function showInstallBanner() {
  // Don't show if already dismissed or installed
  if (hasUserDismissedInstall() || hasUserInstalledApp()) {
    return;
  }

  // Create banner element
  const banner = document.createElement('div');
  banner.id = 'pwa-install-banner';
  banner.style.cssText = `
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%);
    background: #2A313B;
    color: #EDF9FF;
    padding: 24px;
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.05);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
    z-index: 10000;
    max-width: 90%;
    width: 480px;
    font-family: 'Noto Sans', sans-serif;
    animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  `;

  banner.innerHTML = `
    <style>
      @keyframes slideUp {
        from {
          transform: translateX(-50%) translateY(100px);
          opacity: 0;
        }
        to {
          transform: translateX(-50%) translateY(0);
          opacity: 1;
        }
      }
      #pwa-install-banner button {
        border: none;
        padding: 12px 24px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        font-family: 'Noto Sans', sans-serif;
      }
      #pwa-install-banner button:hover {
        transform: translateY(-1px);
      }
      #pwa-install-banner .install-btn {
        background: #6C5BFF;
        color: white;
        margin-right: 10px;
        box-shadow: 0 4px 12px rgba(108, 91, 255, 0.3);
      }
      #pwa-install-banner .install-btn:hover {
        background: #5a4fcf;
        box-shadow: 0 6px 16px rgba(108, 91, 255, 0.4);
      }
      #pwa-install-banner .dismiss-btn {
        background: transparent;
        color: #AEBBC8;
        border: 1.5px solid rgba(108, 91, 255, 0.3);
      }
      #pwa-install-banner .dismiss-btn:hover {
        background: rgba(108, 91, 255, 0.08);
        border-color: rgba(108, 91, 255, 0.5);
      }
      #pwa-install-banner .icon-container {
        background: rgba(108, 91, 255, 0.15);
        border-radius: 12px;
        padding: 12px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
      }
    </style>
    <div style="display: flex; align-items: flex-start; gap: 18px;">
      <div class="icon-container">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#6C5BFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
          <line x1="12" y1="18" x2="12.01" y2="18"></line>
        </svg>
      </div>
      <div style="flex: 1;">
        <div style="font-size: 18px; font-weight: 700; margin-bottom: 6px; color: #EDF9FF; letter-spacing: -0.2px;">
          Install App
        </div>
        <div style="font-size: 14px; color: #AEBBC8; line-height: 1.5; margin-bottom: 18px;">
          Get faster access, offline support, and a native app experience
        </div>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
          <button class="install-btn" id="pwa-install-btn">Install Now</button>
          <button class="dismiss-btn" id="pwa-dismiss-btn">Maybe Later</button>
        </div>
      </div>
    </div>
  `;

  document.body.appendChild(banner);

  // Add event listeners
  installButton = document.getElementById('pwa-install-btn');
  const dismissButton = document.getElementById('pwa-dismiss-btn');

  installButton.addEventListener('click', async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      
      // Log analytics event
      if (window.firebase && window.firebase.analytics) {
        const { logEvent } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-analytics.js');
        logEvent(window.firebase.analytics, 'pwa_install_prompt_action', {
          action: 'accepted',
          outcome: outcome
        });
      }

      if (outcome === 'accepted') {
        console.log('User accepted the install prompt');
        markAppInstalled();
      } else {
        console.log('User dismissed the install prompt');
      }
      
      deferredPrompt = null;
      banner.remove();
    }
  });

  dismissButton.addEventListener('click', () => {
    markInstallDismissed();
    banner.remove();
    
    // Log analytics event
    if (window.firebase && window.firebase.analytics) {
      import('https://www.gstatic.com/firebasejs/10.8.0/firebase-analytics.js').then(({ logEvent }) => {
        logEvent(window.firebase.analytics, 'pwa_install_prompt_action', {
          action: 'dismissed'
        });
      });
    }
  });

  // Log analytics event for banner shown
  if (window.firebase && window.firebase.analytics) {
    import('https://www.gstatic.com/firebasejs/10.8.0/firebase-analytics.js').then(({ logEvent }) => {
      logEvent(window.firebase.analytics, 'pwa_install_prompt_shown', {
        visit_count: localStorage.getItem('pwa_visit_count') || '1'
      });
    });
  }
}

// Listen for beforeinstallprompt event
window.addEventListener('beforeinstallprompt', (e) => {
  console.log('beforeinstallprompt event fired');
  
  // Prevent the default install prompt
  e.preventDefault();
  
  // Stash the event for later use
  deferredPrompt = e;
  
  // Check if we should show the install banner
  const visitCount = incrementVisitCount();
  console.log('Visit count:', visitCount);
  
  // Show install banner on first visit
  if (visitCount >= 1) {
    // Wait a bit for the page to load before showing
    setTimeout(showInstallBanner, 2000);
  }
});

// Listen for successful app installation
window.addEventListener('appinstalled', (e) => {
  console.log('PWA was installed successfully');
  markAppInstalled();
  
  // Remove banner if it exists
  const banner = document.getElementById('pwa-install-banner');
  if (banner) {
    banner.remove();
  }
  
  // Log analytics event
  if (window.firebase && window.firebase.analytics) {
    import('https://www.gstatic.com/firebasejs/10.8.0/firebase-analytics.js').then(({ logEvent }) => {
      logEvent(window.firebase.analytics, 'pwa_installed', {
        platform: navigator.platform,
        user_agent: navigator.userAgent
      });
    });
  }
  
  deferredPrompt = null;
});

// Check if app is already installed (running in standalone mode)
if (window.matchMedia('(display-mode: standalone)').matches || 
    window.navigator.standalone === true) {
  console.log('App is running in standalone mode');
  markAppInstalled();
  
  // Log analytics event on app launch
  if (window.firebase && window.firebase.analytics) {
    import('https://www.gstatic.com/firebasejs/10.8.0/firebase-analytics.js').then(({ logEvent }) => {
      logEvent(window.firebase.analytics, 'pwa_launched', {
        display_mode: 'standalone'
      });
    });
  }
}

console.log('Install prompt handler loaded');
