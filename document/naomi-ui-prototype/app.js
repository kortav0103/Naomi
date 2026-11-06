let activeProtoFrame = 'S02';
let preloadTimer = null;

function switchMode(mode) {
  document.querySelectorAll('.studio-view').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.st-tab').forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('data-tab') === mode);
  });
  const target = document.getElementById(`mode-${mode}`);
  if (target) target.classList.add('active');
  if (mode === 'prototype') {
    renderProto(activeProtoFrame);
  }
}

function openProtoAt(frameId) {
  activeProtoFrame = frameId;
  switchMode('prototype');
}

function renderProto(frameId) {
  if (preloadTimer) {
    clearTimeout(preloadTimer);
    preloadTimer = null;
  }
  activeProtoFrame = frameId;
  document.querySelectorAll('#protoNavButtons .pn-btn').forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('data-target') === frameId);
  });

  const sourceFrame = document.getElementById(`frame-${frameId}`);
  const mount = document.getElementById('protoStageMount');
  if (!sourceFrame || !mount) return;

  mount.innerHTML = '';
  const clone = sourceFrame.cloneNode(true);
  clone.id = `proto-live-${frameId}`;
  mount.appendChild(clone);

  // Automatic smooth transition from S10 (Full Chapter Preload) -> S05 (Full Screen Reader)
  if (frameId === 'S10') {
    preloadTimer = setTimeout(() => {
      if (activeProtoFrame === 'S10' && document.getElementById('mode-prototype')?.classList.contains('active')) {
        renderProto('S05');
      }
    }, 1600);
  }
}

function generateFigmaEditableSvg() {
  const frames = [
    {
      id: 'S01_Sign_In', title: 'S01 — Sign In', bg: '#F8F8FC', dark: false,
      body: `
        <text x="195" y="250" text-anchor="middle" fill="#7066A6" font-family="Inter" font-size="30" font-weight="700" letter-spacing="2">NAOMI</text>
        <text x="28" y="320" fill="#757588" font-family="Inter" font-size="13" font-weight="500">Email</text>
        <rect x="28" y="330" width="334" height="48" rx="12" fill="#FFFFFF" stroke="#E6E6F0"/>
        <text x="44" y="359" fill="#1C1C26" font-family="Inter" font-size="14">name@example.com</text>
        <text x="28" y="404" fill="#757588" font-family="Inter" font-size="13" font-weight="500">Password</text>
        <rect x="28" y="414" width="334" height="48" rx="12" fill="#FFFFFF" stroke="#E6E6F0"/>
        <text x="44" y="443" fill="#1C1C26" font-family="Inter" font-size="14">••••••••</text>
        <rect x="28" y="486" width="334" height="48" rx="12" fill="#7066A6"/>
        <text x="195" y="515" text-anchor="middle" fill="#FFFFFF" font-family="Inter" font-size="15" font-weight="600">Sign In</text>
        <text x="28" y="562" fill="#7066A6" font-family="Inter" font-size="13" font-weight="600">Sign Up</text>
        <text x="362" y="562" text-anchor="end" fill="#757588" font-family="Inter" font-size="13">Forgot Password?</text>
      `
    },
    {
      id: 'S02_Home', title: 'S02 — Home', bg: '#F8F8FC', dark: false, nav: 'Home',
      body: `
        <rect x="20" y="64" width="350" height="140" rx="16" fill="#F0EFF8"/>
        <rect x="36" y="80" width="72" height="108" rx="10" fill="#D8D4F2"/>
        <text x="122" y="102" fill="#1C1C26" font-family="Inter" font-size="15" font-weight="700">Frieren: Beyond Journey's End</text>
        <text x="122" y="124" fill="#757588" font-family="Inter" font-size="12.5">Ch. 24 · Page 18/42 (43%)</text>
        <rect x="122" y="136" width="220" height="5" rx="2.5" fill="#DFDCF2"/>
        <rect x="122" y="136" width="95" height="5" rx="2.5" fill="#7066A6"/>
        <rect x="122" y="154" width="96" height="32" rx="10" fill="#7066A6"/>
        <text x="170" y="175" text-anchor="middle" fill="#FFFFFF" font-family="Inter" font-size="12.5" font-weight="600">Continue ▶</text>
        <text x="20" y="238" fill="#1C1C26" font-family="Inter" font-size="16" font-weight="700">Recent</text>
        <rect x="20" y="252" width="110" height="160" rx="12" fill="#EFEFF4"/>
        <text x="20" y="430" fill="#1C1C26" font-family="Inter" font-size="12.5" font-weight="600">Delicious in Dungeon</text>
        <rect x="142" y="252" width="110" height="160" rx="12" fill="#EFEFF4"/>
        <text x="142" y="430" fill="#1C1C26" font-family="Inter" font-size="12.5" font-weight="600">Yokohama Kaidashi</text>
        <rect x="264" y="252" width="110" height="160" rx="12" fill="#EFEFF4"/>
        <text x="264" y="430" fill="#1C1C26" font-family="Inter" font-size="12.5" font-weight="600">Witch Hat Atelier</text>
        <text x="20" y="476" fill="#1C1C26" font-family="Inter" font-size="16" font-weight="700">Recommended</text>
        <rect x="20" y="490" width="110" height="160" rx="12" fill="#EFEFF4"/>
        <text x="20" y="668" fill="#1C1C26" font-family="Inter" font-size="12.5" font-weight="600">Apothecary Diaries</text>
        <rect x="142" y="490" width="110" height="160" rx="12" fill="#EFEFF4"/>
        <text x="142" y="668" fill="#1C1C26" font-family="Inter" font-size="12.5" font-weight="600">Mushishi</text>
      `
    },
    {
      id: 'S03_Discover', title: 'S03 — Discover', bg: '#F8F8FC', dark: false, nav: 'Discover',
      body: `
        <rect x="20" y="64" width="350" height="46" rx="12" fill="#FFFFFF" stroke="#E6E6F0"/>
        <text x="44" y="92" fill="#757588" font-family="Inter" font-size="13.5">Search titles, authors...</text>
        <rect x="328" y="70" width="34" height="34" rx="9" fill="#F0EFF8"/>
        <text x="20" y="144" fill="#1C1C26" font-family="Inter" font-size="16" font-weight="700">Trending</text>
        <rect x="342" y="124" width="28" height="28" rx="8" fill="#EFEFF4"/>
        <text x="356" y="143" text-anchor="middle" fill="#757588" font-family="Inter" font-size="16" font-weight="700">›</text>
        <rect x="20" y="158" width="110" height="156" rx="12" fill="#EFEFF4"/>
        <rect x="142" y="158" width="110" height="156" rx="12" fill="#EFEFF4"/>
        <rect x="264" y="158" width="110" height="156" rx="12" fill="#EFEFF4"/>
        <text x="20" y="362" fill="#1C1C26" font-family="Inter" font-size="16" font-weight="700">Fantasy</text>
        <rect x="342" y="342" width="28" height="28" rx="8" fill="#EFEFF4"/>
        <text x="356" y="361" text-anchor="middle" fill="#757588" font-family="Inter" font-size="16" font-weight="700">›</text>
        <rect x="20" y="376" width="110" height="156" rx="12" fill="#EFEFF4"/>
        <rect x="142" y="376" width="110" height="156" rx="12" fill="#EFEFF4"/>
        <rect x="264" y="376" width="110" height="156" rx="12" fill="#EFEFF4"/>
      `
    },
    {
      id: 'S03b_Expanded_List', title: 'S03b — Expanded List', bg: '#F8F8FC', dark: false,
      body: `
        <rect x="20" y="64" width="36" height="36" rx="10" fill="#EFEFF4"/>
        <text x="38" y="87" text-anchor="middle" fill="#1C1C26" font-family="Inter" font-size="15" font-weight="700">←</text>
        <text x="68" y="88" fill="#1C1C26" font-family="Inter" font-size="18" font-weight="700">Trending</text>
        <rect x="20" y="118" width="168" height="230" rx="12" fill="#EFEFF4"/>
        <text x="20" y="366" fill="#1C1C26" font-family="Inter" font-size="13" font-weight="600">Frieren: Beyond Journey's End</text>
        <rect x="202" y="118" width="168" height="230" rx="12" fill="#EFEFF4"/>
        <text x="202" y="366" fill="#1C1C26" font-family="Inter" font-size="13" font-weight="600">Delicious in Dungeon</text>
        <rect x="20" y="400" width="168" height="230" rx="12" fill="#EFEFF4"/>
        <text x="20" y="648" fill="#1C1C26" font-family="Inter" font-size="13" font-weight="600">Witch Hat Atelier</text>
        <rect x="202" y="400" width="168" height="230" rx="12" fill="#EFEFF4"/>
        <text x="202" y="648" fill="#1C1C26" font-family="Inter" font-size="13" font-weight="600">The Apothecary Diaries</text>
      `
    },
    {
      id: 'S04_Manga_Detail', title: 'S04 — Manga Detail', bg: '#F8F8FC', dark: false,
      body: `
        <rect x="20" y="64" width="36" height="36" rx="10" fill="#EFEFF4"/>
        <text x="38" y="87" text-anchor="middle" fill="#1C1C26" font-family="Inter" font-size="15" font-weight="700">←</text>
        <text x="68" y="88" fill="#1C1C26" font-family="Inter" font-size="18" font-weight="700">Details</text>
        <rect x="20" y="116" width="108" height="158" rx="12" fill="#D8D4F2"/>
        <text x="142" y="138" fill="#1C1C26" font-family="Inter" font-size="16" font-weight="700">Frieren: Beyond Journey</text>
        <text x="142" y="160" fill="#757588" font-family="Inter" font-size="12">Kanehito Yamada · Tsukasa Abe</text>
        <text x="142" y="182" fill="#1C1C26" font-family="Inter" font-size="12" font-weight="600">★ 4.9 · Fantasy, Adventure</text>
        <rect x="20" y="292" width="170" height="40" rx="12" fill="#7066A6"/>
        <text x="105" y="317" text-anchor="middle" fill="#FFFFFF" font-family="Inter" font-size="13" font-weight="600">Read First</text>
        <rect x="200" y="292" width="170" height="40" rx="12" fill="#7066A6"/>
        <text x="285" y="317" text-anchor="middle" fill="#FFFFFF" font-family="Inter" font-size="13" font-weight="600">Read Latest</text>
        <rect x="20" y="340" width="170" height="40" rx="12" fill="#EFEFF4"/>
        <text x="105" y="365" text-anchor="middle" fill="#E05353" font-family="Inter" font-size="13" font-weight="600">♥ Favorite</text>
        <rect x="200" y="340" width="170" height="40" rx="12" fill="#EFEFF4"/>
        <text x="285" y="365" text-anchor="middle" fill="#1C1C26" font-family="Inter" font-size="13" font-weight="600">⬇ Download</text>
        <text x="20" y="412" fill="#1C1C26" font-family="Inter" font-size="15" font-weight="700">Chapters</text>
        <rect x="20" y="426" width="350" height="58" rx="12" fill="#FFFFFF" stroke="#E6E6F0"/>
        <text x="36" y="451" fill="#1C1C26" font-family="Inter" font-size="13.5" font-weight="600">Ch. 24 — The Journey Back</text>
        <text x="354" y="459" text-anchor="end" fill="#34A853" font-family="Inter" font-size="12" font-weight="600">Saved</text>
        <rect x="20" y="492" width="350" height="58" rx="12" fill="#FFFFFF" stroke="#E6E6F0"/>
        <text x="36" y="517" fill="#1C1C26" font-family="Inter" font-size="13.5" font-weight="600">Ch. 23 — Before Winter</text>
        <text x="354" y="525" text-anchor="end" fill="#34A853" font-family="Inter" font-size="12" font-weight="600">Saved</text>
      `
    },
    {
      id: 'S10_Full_Chapter_Preload', title: 'S10 — Full Chapter Preload', bg: '#111116', dark: true,
      body: `
        <rect x="153" y="260" width="84" height="124" rx="12" fill="#2A2A35"/>
        <text x="195" y="418" text-anchor="middle" fill="#EEEEF4" font-family="Inter" font-size="16" font-weight="600">Loading full chapter...</text>
        <rect x="85" y="438" width="220" height="6" rx="3" fill="#2A2A35"/>
        <rect x="85" y="438" width="220" height="6" rx="3" fill="#7066A6"/>
        <text x="195" y="468" text-anchor="middle" fill="#EEEEF4" font-family="Inter" font-size="13" font-weight="600">42 / 42 pages ready (100%)</text>
        <text x="195" y="494" text-anchor="middle" fill="#757588" font-family="Inter" font-size="12">Pre-buffering all pages for instant scrolling.</text>
      `
    },
    {
      id: 'S05_Full_Screen_Reader', title: 'S05 — Full Screen Reader', bg: '#111116', dark: true,
      body: `
        <rect x="0" y="44" width="390" height="760" fill="#181820"/>
        <rect x="12" y="48" width="366" height="48" rx="16" fill="#16161C" stroke="#2A2A35"/>
        <text x="32" y="77" fill="#EEEEF4" font-family="Inter" font-size="16" font-weight="700">‹</text>
        <text x="135" y="77" fill="#EEEEF4" font-family="Inter" font-size="13" font-weight="600">‹  Ch. 24 ▾  ›</text>
        <text x="242" y="77" fill="#EEEEF4" font-family="Inter" font-size="14">🎵  🎯  🌐  ✨  🔄</text>
      `
    },
    {
      id: 'S06_Audio_Sheet', title: 'S06 — Audio Sheet', bg: '#111116', dark: true,
      body: `
        <rect x="12" y="48" width="366" height="48" rx="16" fill="#16161C"/>
        <text x="135" y="77" fill="#EEEEF4" font-family="Inter" font-size="13" font-weight="600">‹  Ch. 24 ▾  ›</text>
        <rect x="0" y="520" width="390" height="324" rx="20" fill="#1A1A22"/>
        <rect x="177" y="532" width="36" height="4" rx="2" fill="#444452"/>
        <text x="24" y="576" fill="#EEEEF4" font-family="Inter" font-size="14.5" font-weight="600">Winds of Aureole (Instrumental)</text>
        <circle cx="344" cy="570" r="22" fill="#7066A6"/>
        <text x="344" y="575" text-anchor="middle" fill="#FFFFFF" font-family="Inter" font-size="12" font-weight="700">❚❚</text>
        <rect x="48" y="616" width="294" height="4" rx="2" fill="#2E2E3A"/>
        <rect x="48" y="616" width="110" height="4" rx="2" fill="#7066A6"/>
        <circle cx="158" cy="618" r="6" fill="#FFFFFF"/>
        <rect x="20" y="644" width="350" height="38" rx="10" fill="#262438"/>
        <text x="34" y="668" fill="#EEEEF4" font-family="Inter" font-size="13" font-weight="600">1. Winds of Aureole (Instrumental)</text>
        <text x="34" y="708" fill="#9E9EB0" font-family="Inter" font-size="13">2. Quiet Campfire Piano</text>
        <text x="34" y="744" fill="#9E9EB0" font-family="Inter" font-size="13">3. Distant Elven Forest</text>
      `
    },
    {
      id: 'S07_Library', title: 'S07 — Library', bg: '#F8F8FC', dark: false, nav: 'Library',
      body: `
        <text x="20" y="88" fill="#1C1C26" font-family="Inter" font-size="24" font-weight="700">Library</text>
        <rect x="20" y="116" width="350" height="100" rx="20" fill="#FFFFFF" stroke="#E6E6F0"/>
        <rect x="40" y="140" width="52" height="52" rx="16" fill="#FCECEC"/>
        <text x="66" y="173" text-anchor="middle" fill="#E05353" font-family="Inter" font-size="20">♥</text>
        <text x="108" y="162" fill="#1C1C26" font-family="Inter" font-size="17" font-weight="700">Favorites</text>
        <text x="108" y="184" fill="#757588" font-family="Inter" font-size="13">12 stories marked</text>
        <rect x="20" y="232" width="350" height="100" rx="20" fill="#FFFFFF" stroke="#E6E6F0"/>
        <rect x="40" y="256" width="52" height="52" rx="16" fill="#EAF6ED"/>
        <text x="66" y="289" text-anchor="middle" fill="#34A853" font-family="Inter" font-size="20">⬇</text>
        <text x="108" y="278" fill="#1C1C26" font-family="Inter" font-size="17" font-weight="700">Offline Reading</text>
        <text x="108" y="300" fill="#757588" font-family="Inter" font-size="13">8 chapters saved · 280 MB</text>
      `
    },
    {
      id: 'S08_Profile', title: 'S08 — Profile & Settings', bg: '#F8F8FC', dark: false, nav: 'Profile',
      body: `
        <text x="20" y="88" fill="#1C1C26" font-family="Inter" font-size="24" font-weight="700">Profile</text>
        <rect x="20" y="112" width="350" height="84" rx="16" fill="#FFFFFF" stroke="#E6E6F0"/>
        <circle cx="62" cy="154" r="26" fill="#F0EFF8"/>
        <text x="62" y="160" text-anchor="middle" fill="#7066A6" font-family="Inter" font-size="15" font-weight="700">KN</text>
        <text x="102" y="150" fill="#1C1C26" font-family="Inter" font-size="16" font-weight="700">Kiet Nguyen</text>
        <text x="102" y="170" fill="#757588" font-family="Inter" font-size="13">reader.kiet@gmail.com</text>
        <rect x="20" y="216" width="350" height="200" rx="16" fill="#FFFFFF" stroke="#E6E6F0"/>
        <text x="36" y="250" fill="#1C1C26" font-family="Inter" font-size="14" font-weight="500">Appearance</text>
        <text x="354" y="250" text-anchor="end" fill="#757588" font-family="Inter" font-size="13">System / Light / Dark</text>
        <text x="36" y="300" fill="#1C1C26" font-family="Inter" font-size="14" font-weight="500">Language</text>
        <text x="354" y="300" text-anchor="end" fill="#757588" font-family="Inter" font-size="13">English</text>
        <text x="36" y="350" fill="#1C1C26" font-family="Inter" font-size="14" font-weight="500">Storage &amp; Cache (142 MB)</text>
        <text x="354" y="350" text-anchor="end" fill="#7066A6" font-family="Inter" font-size="12" font-weight="600">Clear Cache</text>
        <text x="36" y="396" fill="#1C1C26" font-family="Inter" font-size="14" font-weight="500">Notifications</text>
        <rect x="20" y="436" width="350" height="46" rx="12" fill="#FCECEC"/>
        <text x="195" y="464" text-anchor="middle" fill="#E05353" font-family="Inter" font-size="14" font-weight="600">Sign Out</text>
      `
    },
    {
      id: 'S09_Offline_Error', title: 'S09 — Offline Error State', bg: '#F8F8FC', dark: false,
      body: `
        <circle cx="195" cy="330" r="44" fill="#FEF3C7"/>
        <text x="195" y="338" text-anchor="middle" fill="#D97706" font-family="Inter" font-size="28">☁️</text>
        <text x="195" y="410" text-anchor="middle" fill="#1C1C26" font-family="Inter" font-size="19" font-weight="700">Oops! No internet connection</text>
        <text x="195" y="438" text-anchor="middle" fill="#757588" font-family="Inter" font-size="13">This chapter is not downloaded yet.</text>
        <rect x="45" y="468" width="300" height="48" rx="12" fill="#7066A6"/>
        <text x="195" y="497" text-anchor="middle" fill="#FFFFFF" font-family="Inter" font-size="15" font-weight="600">Go to Offline Library</text>
      `
    },
    {
      id: 'S11_Download_Progress', title: 'S11 — Download in Progress', bg: '#F8F8FC', dark: false,
      body: `
        <text x="20" y="88" fill="#1C1C26" font-family="Inter" font-size="18" font-weight="700">←  Details</text>
        <text x="20" y="136" fill="#1C1C26" font-family="Inter" font-size="15" font-weight="700">Chapters</text>
        <rect x="20" y="152" width="350" height="76" rx="12" fill="#FFFFFF" stroke="#34A853" stroke-width="1.5"/>
        <text x="36" y="178" fill="#1C1C26" font-family="Inter" font-size="13.5" font-weight="600">Ch. 24 — The Journey Back</text>
        <text x="36" y="198" fill="#34A853" font-family="Inter" font-size="11.5" font-weight="500">Downloading... 24.5 MB / 36 MB</text>
        <rect x="36" y="210" width="260" height="4" rx="2" fill="#EFEFF4"/>
        <rect x="36" y="210" width="176" height="4" rx="2" fill="#34A853"/>
        <text x="354" y="194" text-anchor="end" fill="#34A853" font-family="Inter" font-size="13" font-weight="700">68%</text>
        <rect x="20" y="756" width="350" height="44" rx="12" fill="#1C1C26"/>
        <text x="195" y="783" text-anchor="middle" fill="#EEEEF4" font-family="Inter" font-size="12.5">Downloading Chapter 24 for offline reading...</text>
      `
    }
  ];

  const cols = 4;
  const w = 390;
  const h = 844;
  const gapX = 60;
  const gapY = 80;
  const totalW = cols * w + (cols - 1) * gapX + 120;
  const totalH = 3 * h + 2 * gapY + 140;

  let groups = '';
  frames.forEach((f, i) => {
    const col = i % cols;
    const row = Math.floor(i / cols);
    const x = 60 + col * (w + gapX);
    const y = 70 + row * (h + gapY);
    const textCol = f.dark ? '#EEEEF4' : '#1C1C26';

    const bottomNavSvg = f.nav ? `
      <rect x="0" y="772" width="390" height="72" fill="#FFFFFF" stroke="#E6E6F0"/>
      <text x="55" y="812" text-anchor="middle" fill="${f.nav === 'Home' ? '#7066A6' : '#757588'}" font-family="Inter" font-size="11" font-weight="600">Home</text>
      <text x="148" y="812" text-anchor="middle" fill="${f.nav === 'Discover' ? '#7066A6' : '#757588'}" font-family="Inter" font-size="11" font-weight="600">Discover</text>
      <text x="242" y="812" text-anchor="middle" fill="${f.nav === 'Library' ? '#7066A6' : '#757588'}" font-family="Inter" font-size="11" font-weight="600">Library</text>
      <text x="335" y="812" text-anchor="middle" fill="${f.nav === 'Profile' ? '#7066A6' : '#757588'}" font-family="Inter" font-size="11" font-weight="600">Profile</text>
    ` : '';

    groups += `
      <g id="${f.id}" transform="translate(${x}, ${y})">
        <text x="0" y="-16" fill="#1C1C26" font-family="Inter, sans-serif" font-size="15" font-weight="700">${f.title}</text>
        <rect width="${w}" height="${h}" rx="32" fill="${f.bg}" stroke="${f.dark ? '#2A2A35' : '#E6E6F0'}" stroke-width="2"/>
        <text x="28" y="30" fill="${textCol}" font-family="Inter, sans-serif" font-size="13" font-weight="600">9:41</text>
        ${f.body}
        ${bottomNavSvg}
        <rect x="128" y="828" width="134" height="5" rx="2.5" fill="${f.dark ? '#444452' : '#C8C8D6'}"/>
      </g>
    `;
  });

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${totalW}" height="${totalH}" viewBox="0 0 ${totalW} ${totalH}" fill="none">${groups}</svg>`;
}

async function copyAllFramesSvg() {
  const svg = generateFigmaEditableSvg();
  const label = document.getElementById('copySvgLabel');
  try {
    await navigator.clipboard.writeText(svg);
    if (label) {
      label.textContent = 'Copied! Paste (Ctrl+V) in Figma';
      setTimeout(() => { label.textContent = 'Copy Editable SVG for Figma'; }, 3000);
    }
  } catch (err) {
    const blob = new Blob([svg], { type: 'image/svg+xml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'naomi-12-frames-figma.svg';
    a.click();
    URL.revokeObjectURL(url);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  renderProto('S02');
});
