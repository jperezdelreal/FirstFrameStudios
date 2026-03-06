/**
 * Springfield Background — SimpsonsKong
 * Owner: Boba (VFX/Art Specialist)
 *
 * Three-layer parallax Springfield scene:
 *   Far  (0.2×) — Power Plant, mountains, Burns billboard, Springfield sign
 *   Mid  (0.5×) — Kwik-E-Mart, Moe's, Android's Dungeon, Elementary,
 *                  Lard Lad, Leftorium, Jebediah statue, houses
 *   Near (1.0×) — Road, sidewalk, hydrants, street lamps, parked cars,
 *                  three-eyed fish puddle, nuclear sign
 *
 * Plus foreground parallax layer:
 *   Front (1.3×) — Lampposts, chain-link fence, fire hydrants (in front of entities)
 *
 * Easter eggs (AAA-V5): El Barto graffiti, Burns "Excellent" billboard,
 *   Itchy & Scratchy poster, Blinky three-eyed fish, Nuclear Plant
 *   accident sign, Springfield welcome sign
 *
 * INTEGRATION INSTRUCTIONS (for gameplay.js):
 * ──────────────────────────────────────────────────────────────────────────
 * Foreground layer draws IN FRONT of entities for depth. Call order:
 *   1. background.render(ctx, cameraX, screenWidth);   // behind entities
 *   2. ... render entities (player, enemies) ...
 *   3. background.renderForeground(ctx, cameraX, screenWidth); // in front
 * ──────────────────────────────────────────────────────────────────────────
 *
 * API: new Background(), background.render(ctx, cameraX, screenWidth),
 *      background.renderForeground(ctx, cameraX, screenWidth)
 */

// --- Layout constants ---
const HORIZON      = 400;   // y where ground begins (matches entity ground plane)
const CANVAS_H     = 720;
const OUTLINE      = '#222222';

// --- Parallax factors ---
const FAR_PARALLAX  = 0.8;  // world offset = cameraX * 0.8  → 0.2× scroll speed
const MID_PARALLAX  = 0.5;  // world offset = cameraX * 0.5  → 0.5× scroll speed

// --- Cloud data ---
const CLOUD_DRIFT_SPEED = 12; // px/s
const CLOUD_TILE = 1800;      // clouds repeat every N px

// --- Building pattern (mid layer) ---
const BUILDING_GAP   = 50;
const BUILDINGS = [
    { type: 'kwik',  w: 210, h: 140 },
    { type: 'house', w: 120, h: 100, color: '#E8C48A' },
    { type: 'moes',  w: 170, h: 125 },
    { type: 'android', w: 160, h: 130 },
    { type: 'house', w: 130, h: 110, color: '#C46B6B' },
    { type: 'elementary', w: 250, h: 155 },
    { type: 'house', w: 115, h: 95,  color: '#8FBC8F' },
    { type: 'lardlad', w: 140, h: 120 },
    { type: 'leftorium', w: 110, h: 105 },
    { type: 'statue', w: 80, h: 130 },
    { type: 'house', w: 125, h: 100, color: '#D4A574' },
];
// Pre-compute pattern width
const PATTERN_W = BUILDINGS.reduce((s, b) => s + b.w + BUILDING_GAP, 0);

// --- Power plant (far layer) ---
const PLANT_SPACING = 2200;

// --- Fire hydrant spacing ---
const HYDRANT_SPACING = 600;

// --- Foreground parallax (1.3× speed — scrolls faster, in front of entities) ---
const FRONT_PARALLAX = 1.3;
const LAMPPOST_SPACING = 500;
const FENCE_SECTION_W = 120;
const FENCE_SPACING = 700;
const FRONT_HYDRANT_SPACING = 900;

// --- Window lighting (seeded random for consistency across frames) ---
function seededRandom(seed) {
    let x = Math.sin(seed * 127.1 + 311.7) * 43758.5453;
    return x - Math.floor(x);
}

export class Background {
    constructor() {
        this._t0 = performance.now();
    }

    render(ctx, cameraX, screenWidth) {
        const elapsed = (performance.now() - this._t0) / 1000;
        const left = cameraX;
        const right = cameraX + screenWidth;

        this._sky(ctx, left, screenWidth);
        this._clouds(ctx, left, right, screenWidth, elapsed);
        this._farLayer(ctx, left, right);
        this._midLayer(ctx, left, right);
        this._ground(ctx, left, screenWidth);
    }

    // ── Sky gradient ─────────────────────────────────────────────────────

    _sky(ctx, left, w) {
        const grad = ctx.createLinearGradient(0, 0, 0, HORIZON);
        grad.addColorStop(0, '#5BADE2');     // deeper blue at top
        grad.addColorStop(0.5, '#87CEEB');   // classic sky blue
        grad.addColorStop(0.85, '#B0E0E6'); // powder blue near horizon
        grad.addColorStop(1, '#E0EEF0');     // very light at horizon line
        ctx.fillStyle = grad;
        ctx.fillRect(left, 0, w, HORIZON);
    }

    // ── Clouds ───────────────────────────────────────────────────────────

    _clouds(ctx, left, right, screenWidth, elapsed) {
        const drift = elapsed * CLOUD_DRIFT_SPEED;
        const shapes = [
            { baseX: 150,  y: 90,  s: 1.0,  type: 'puffy' },
            { baseX: 650,  y: 55,  s: 1.35, type: 'puffy' },
            { baseX: 1200, y: 110, s: 0.85, type: 'puffy' },
            { baseX: 400,  y: 130, s: 0.6,  type: 'wisp' },
            { baseX: 900,  y: 40,  s: 1.5,  type: 'puffy' },
            { baseX: 1500, y: 75,  s: 0.7,  type: 'wisp' },
            { baseX: 350,  y: 35,  s: 0.5,  type: 'small' },
            { baseX: 1050, y: 145, s: 0.45, type: 'small' },
        ];

        for (const c of shapes) {
            let wx = ((c.baseX + drift * (c.type === 'wisp' ? 0.7 : 1.0)) % CLOUD_TILE);
            if (wx < 0) wx += CLOUD_TILE;

            const startTile = Math.floor((left - CLOUD_TILE) / CLOUD_TILE);
            const endTile   = Math.floor((right + CLOUD_TILE) / CLOUD_TILE);
            for (let t = startTile; t <= endTile; t++) {
                const cx = wx + t * CLOUD_TILE;
                if (cx + 80 * c.s < left || cx - 80 * c.s > right) continue;
                if (c.type === 'wisp') {
                    this._drawWispCloud(ctx, cx, c.y, c.s);
                } else if (c.type === 'small') {
                    this._drawSmallCloud(ctx, cx, c.y, c.s);
                } else {
                    this._drawCloud(ctx, cx, c.y, c.s);
                }
            }
        }
    }

    _drawCloud(ctx, cx, cy, scale) {
        ctx.fillStyle = '#FFFFFF';
        ctx.globalAlpha = 0.85;
        const r = 28 * scale;
        // Overlapping circles for puffy shape
        const blobs = [
            { dx: 0,       dy: 0,     r: r * 1.1 },
            { dx: -r * 1,  dy: r * 0.15, r: r * 0.85 },
            { dx: r * 1,   dy: r * 0.1,  r: r * 0.9 },
            { dx: -r * 0.5, dy: -r * 0.4, r: r * 0.7 },
            { dx: r * 0.4,  dy: -r * 0.45, r: r * 0.65 },
        ];
        for (const b of blobs) {
            ctx.beginPath();
            ctx.arc(cx + b.dx, cy + b.dy, b.r, 0, Math.PI * 2);
            ctx.fill();
        }
        ctx.globalAlpha = 1;
    }

    _drawWispCloud(ctx, cx, cy, scale) {
        ctx.fillStyle = '#D0D0D0';
        ctx.globalAlpha = 0.35;
        const r = 18 * scale;
        // Elongated wispy shape — stretched horizontally
        ctx.beginPath();
        ctx.ellipse(cx, cy, r * 2.5, r * 0.5, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.ellipse(cx + r, cy - r * 0.2, r * 1.2, r * 0.35, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.globalAlpha = 1;
    }

    _drawSmallCloud(ctx, cx, cy, scale) {
        ctx.fillStyle = '#FFFFFF';
        ctx.globalAlpha = 0.7;
        const r = 14 * scale;
        ctx.beginPath();
        ctx.arc(cx, cy, r, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(cx + r * 0.7, cy + r * 0.15, r * 0.7, 0, Math.PI * 2);
        ctx.fill();
        ctx.globalAlpha = 1;
    }

    // ── Far layer: Power Plant (0.2× parallax) ──────────────────────────

    _farLayer(ctx, left, right) {
        // Mountain range silhouette behind everything
        this._drawMountains(ctx, left, right);

        const startI = Math.floor((left * 0.2) / PLANT_SPACING) - 1;
        const endI   = Math.ceil((right * 0.2) / PLANT_SPACING) + 1;

        for (let i = startI; i <= endI; i++) {
            const wx = i * PLANT_SPACING + left * FAR_PARALLAX;
            if (wx + 300 < left || wx > right) continue;
            this._drawPowerPlant(ctx, wx, HORIZON);

            // Burns billboard near every other plant
            if (i % 2 === 0) {
                this._drawBurnsBillboard(ctx, wx + 400, HORIZON);
            }

            // Springfield sign near every 3rd plant
            if (i % 3 === 0) {
                this._drawSpringfieldSign(ctx, wx + 600, HORIZON);
            }
        }
    }

    _drawMountains(ctx, left, right) {
        ctx.save();
        ctx.globalAlpha = 0.3;
        const mOffset = left * 0.1; // very slow parallax for distant mountains
        ctx.fillStyle = '#6A7B8A';

        // Generate a jagged mountain range across the visible area
        ctx.beginPath();
        ctx.moveTo(left, HORIZON);
        const step = 60;
        const startX = left - (left % step) - step;
        for (let mx = startX; mx <= right + step; mx += step) {
            const worldX = mx + mOffset;
            const peak = HORIZON - 50 - seededRandom(Math.floor(worldX / step) * 0.37 + 5) * 80;
            ctx.lineTo(mx, peak);
        }
        ctx.lineTo(right + step, HORIZON);
        ctx.closePath();
        ctx.fill();

        // Second, lighter mountain layer
        ctx.fillStyle = '#8A9BAA';
        ctx.globalAlpha = 0.2;
        ctx.beginPath();
        ctx.moveTo(left, HORIZON);
        for (let mx = startX; mx <= right + step; mx += step) {
            const worldX = mx + mOffset;
            const peak = HORIZON - 30 - seededRandom(Math.floor(worldX / step) * 0.83 + 19) * 55;
            ctx.lineTo(mx, peak);
        }
        ctx.lineTo(right + step, HORIZON);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
    }

    _drawBurnsBillboard(ctx, x, groundY) {
        // Billboard post
        ctx.fillStyle = '#666666';
        ctx.fillRect(x + 25, groundY - 100, 6, 100);
        ctx.fillRect(x + 75, groundY - 100, 6, 100);

        // Billboard panel
        ctx.fillStyle = '#FFFFF0';
        ctx.fillRect(x, groundY - 150, 110, 55);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, groundY - 150, 110, 55);

        // "VOTE BURNS" text
        ctx.fillStyle = '#CC0000';
        ctx.font = 'bold 11px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('VOTE BURNS', x + 55, groundY - 132);

        // Burns silhouette (simple hunched figure)
        ctx.fillStyle = '#333333';
        ctx.beginPath();
        ctx.arc(x + 30, groundY - 118, 6, 0, Math.PI * 2);
        ctx.fill();
        ctx.fillRect(x + 26, groundY - 112, 8, 12);

        // "Excellent" text
        ctx.fillStyle = '#333333';
        ctx.font = 'italic 8px sans-serif';
        ctx.fillText('"Excellent..."', x + 70, groundY - 112);
    }

    _drawSpringfieldSign(ctx, x, groundY) {
        // Sign posts
        ctx.fillStyle = '#8B4513';
        ctx.fillRect(x, groundY - 80, 5, 80);
        ctx.fillRect(x + 115, groundY - 80, 5, 80);

        // Sign board
        ctx.fillStyle = '#228B22';
        ctx.fillRect(x - 5, groundY - 90, 130, 35);
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.strokeRect(x - 3, groundY - 88, 126, 31);

        // Sign text
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 9px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('WELCOME TO', x + 60, groundY - 80);
        ctx.font = 'bold 11px sans-serif';
        ctx.fillText('SPRINGFIELD', x + 60, groundY - 67);
    }

    _drawPowerPlant(ctx, x, groundY) {
        ctx.fillStyle = '#8A8A8A';
        // Cooling tower 1 — trapezoid
        ctx.beginPath();
        ctx.moveTo(x, groundY);
        ctx.lineTo(x + 30, groundY - 180);
        ctx.lineTo(x + 100, groundY - 180);
        ctx.lineTo(x + 130, groundY);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = '#6A6A6A';
        ctx.lineWidth = 2;
        ctx.stroke();

        // Steam circle on top
        ctx.fillStyle = '#B0B0B0';
        ctx.beginPath();
        ctx.arc(x + 65, groundY - 185, 30, 0, Math.PI * 2);
        ctx.fill();

        // Cooling tower 2 (shorter, offset)
        ctx.fillStyle = '#7A7A7A';
        ctx.beginPath();
        ctx.moveTo(x + 150, groundY);
        ctx.lineTo(x + 175, groundY - 140);
        ctx.lineTo(x + 235, groundY - 140);
        ctx.lineTo(x + 260, groundY);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = '#6A6A6A';
        ctx.stroke();

        // Main building block
        ctx.fillStyle = '#9A9A9A';
        ctx.fillRect(x + 40, groundY - 90, 80, 90);
        ctx.strokeStyle = '#6A6A6A';
        ctx.strokeRect(x + 40, groundY - 90, 80, 90);

        // Smokestack
        ctx.fillStyle = '#707070';
        ctx.fillRect(x + 270, groundY - 160, 18, 160);
        ctx.strokeStyle = '#555555';
        ctx.strokeRect(x + 270, groundY - 160, 18, 160);

        // Red warning stripes on smokestack
        ctx.fillStyle = '#CC3333';
        ctx.fillRect(x + 270, groundY - 160, 18, 10);
        ctx.fillRect(x + 270, groundY - 130, 18, 10);
    }

    // ── Mid layer: Springfield buildings (0.5× parallax) ─────────────────

    _midLayer(ctx, left, right) {
        // Determine which pattern tiles are visible
        const startTile = Math.floor((left * 0.5 - PATTERN_W) / PATTERN_W) - 1;
        const endTile   = Math.ceil((right * 0.5 + PATTERN_W) / PATTERN_W) + 1;

        for (let tile = startTile; tile <= endTile; tile++) {
            let bx = tile * PATTERN_W;
            for (const b of BUILDINGS) {
                const wx = bx + left * MID_PARALLAX;
                if (wx + b.w >= left && wx <= right) {
                    this._drawBuilding(ctx, wx, HORIZON, b);
                }
                bx += b.w + BUILDING_GAP;
            }
        }
    }

    _drawBuilding(ctx, x, groundY, b) {
        switch (b.type) {
            case 'kwik':        this._drawKwikEMart(ctx, x, groundY, b); break;
            case 'moes':        this._drawMoes(ctx, x, groundY, b);      break;
            case 'android':     this._drawAndroidsDungeon(ctx, x, groundY, b); break;
            case 'elementary':  this._drawElementary(ctx, x, groundY, b); break;
            case 'lardlad':     this._drawLardLad(ctx, x, groundY, b); break;
            case 'leftorium':   this._drawLeftorium(ctx, x, groundY, b); break;
            case 'statue':      this._drawJebediahStatue(ctx, x, groundY, b); break;
            default:            this._drawHouse(ctx, x, groundY, b);     break;
        }
    }

    _drawKwikEMart(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — teal
        ctx.fillStyle = '#2E8B8B';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Red awning
        ctx.fillStyle = '#CC2222';
        ctx.beginPath();
        ctx.moveTo(x - 5, top + 35);
        ctx.lineTo(x + b.w + 5, top + 35);
        ctx.lineTo(x + b.w, top + 20);
        ctx.lineTo(x, top + 20);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.stroke();

        // Sign text
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.strokeText('KWIK-E-MART', x + b.w / 2, top + 10);
        ctx.fillText('KWIK-E-MART', x + b.w / 2, top + 10);

        // Door
        ctx.fillStyle = '#4A9A9A';
        ctx.fillRect(x + b.w / 2 - 18, groundY - 55, 36, 55);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + b.w / 2 - 18, groundY - 55, 36, 55);

        // Windows
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(x + 15, top + 45, 35, 30);
        ctx.fillRect(x + b.w - 50, top + 45, 35, 30);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + 15, top + 45, 35, 30);
        ctx.strokeRect(x + b.w - 50, top + 45, 35, 30);
    }

    _drawMoes(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — dark brown
        ctx.fillStyle = '#5C3A21';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Neon sign background
        ctx.fillStyle = '#3A2211';
        ctx.fillRect(x + 20, top + 8, b.w - 40, 28);
        ctx.strokeStyle = '#FF4444';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + 20, top + 8, b.w - 40, 28);

        // Neon "MOE'S" text
        ctx.fillStyle = '#FF6666';
        ctx.font = 'bold 16px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText("MOE'S", x + b.w / 2, top + 22);

        // Door
        ctx.fillStyle = '#3A1F0D';
        ctx.fillRect(x + b.w / 2 - 16, groundY - 50, 32, 50);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + b.w / 2 - 16, groundY - 50, 32, 50);

        // Small grimy window — occasionally lit with warm glow
        const moeLit = seededRandom(x * 1.13 + 53) > 0.4; // Moe's is often lit
        ctx.fillStyle = moeLit ? '#DDAA44' : '#8B7355';
        ctx.fillRect(x + 20, top + 50, 30, 25);
        if (moeLit) {
            ctx.save();
            ctx.globalAlpha = 0.2;
            ctx.fillStyle = '#FFD700';
            ctx.fillRect(x + 18, top + 48, 34, 29);
            ctx.restore();
        }
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + 20, top + 50, 30, 25);

        // "El Barto" graffiti on wall (easter egg AAA-V5)
        if (seededRandom(x * 0.63 + 41) > 0.5) {
            ctx.save();
            ctx.fillStyle = '#CC3333';
            ctx.font = 'italic bold 8px sans-serif';
            ctx.textAlign = 'left';
            ctx.fillText('EL BARTO', x + b.w - 60, groundY - 8);
            ctx.restore();
        }
    }

    _drawHouse(ctx, x, groundY, b) {
        const wallTop = groundY - b.h;
        const roofPeak = wallTop - 35;

        // Walls
        ctx.fillStyle = b.color;
        ctx.fillRect(x, wallTop, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, wallTop, b.w, b.h);

        // Triangle roof
        ctx.fillStyle = '#8B4513';
        ctx.beginPath();
        ctx.moveTo(x - 8, wallTop);
        ctx.lineTo(x + b.w / 2, roofPeak);
        ctx.lineTo(x + b.w + 8, wallTop);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.stroke();

        // Windows (2 on each house)
        ctx.fillStyle = '#ADE8F4';
        const winW = 22, winH = 22;
        const winY = wallTop + 20;

        // Occasionally lit windows (seeded by position for frame-stable randomness)
        const leftLit = seededRandom(x * 0.73 + 17) > 0.55;
        const rightLit = seededRandom(x * 0.91 + 31) > 0.55;

        // Left window
        ctx.fillStyle = leftLit ? '#FFE566' : '#ADE8F4';
        ctx.fillRect(x + 15, winY, winW, winH);
        if (leftLit) {
            // Warm glow around lit window
            ctx.save();
            ctx.globalAlpha = 0.25;
            ctx.fillStyle = '#FFD700';
            ctx.fillRect(x + 13, winY - 2, winW + 4, winH + 4);
            ctx.restore();
        }

        // Right window
        ctx.fillStyle = rightLit ? '#FFE566' : '#ADE8F4';
        ctx.fillRect(x + b.w - 15 - winW, winY, winW, winH);
        if (rightLit) {
            ctx.save();
            ctx.globalAlpha = 0.25;
            ctx.fillStyle = '#FFD700';
            ctx.fillRect(x + b.w - 15 - winW - 2, winY - 2, winW + 4, winH + 4);
            ctx.restore();
        }

        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + 15, winY, winW, winH);
        ctx.strokeRect(x + b.w - 15 - winW, winY, winW, winH);
        // Window cross bars
        ctx.beginPath();
        ctx.moveTo(x + 15 + winW / 2, winY);
        ctx.lineTo(x + 15 + winW / 2, winY + winH);
        ctx.moveTo(x + 15, winY + winH / 2);
        ctx.lineTo(x + 15 + winW, winY + winH / 2);
        ctx.moveTo(x + b.w - 15 - winW / 2, winY);
        ctx.lineTo(x + b.w - 15 - winW / 2, winY + winH);
        ctx.moveTo(x + b.w - 15 - winW, winY + winH / 2);
        ctx.lineTo(x + b.w - 15, winY + winH / 2);
        ctx.stroke();

        // Door
        ctx.fillStyle = '#6B3A1F';
        ctx.fillRect(x + b.w / 2 - 12, groundY - 40, 24, 40);
        ctx.strokeStyle = OUTLINE;
        ctx.strokeRect(x + b.w / 2 - 12, groundY - 40, 24, 40);
    }

    // ── Android's Dungeon (Comic Book Guy's shop) ──────────────────────

    _drawAndroidsDungeon(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — green
        ctx.fillStyle = '#4A7A4A';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Sign background
        ctx.fillStyle = '#2A4A2A';
        ctx.fillRect(x + 10, top + 6, b.w - 20, 30);
        ctx.strokeStyle = '#FFD700';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + 10, top + 6, b.w - 20, 30);

        // Sign text
        ctx.fillStyle = '#FFD700';
        ctx.font = 'bold 10px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText("ANDROID'S", x + b.w / 2, top + 16);
        ctx.font = 'bold 9px sans-serif';
        ctx.fillText('DUNGEON', x + b.w / 2, top + 28);

        // Display window (large, showing comic poster inside)
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(x + 15, top + 45, b.w - 30, 40);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + 15, top + 45, b.w - 30, 40);

        // Itchy & Scratchy poster in window (easter egg AAA-V5)
        ctx.fillStyle = '#FF4444';
        ctx.fillRect(x + 22, top + 50, 20, 28);
        ctx.fillStyle = '#4444FF';
        ctx.fillRect(x + 44, top + 50, 20, 28);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '5px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('I&S', x + 42, top + 82);

        // Door
        ctx.fillStyle = '#2A4A2A';
        ctx.fillRect(x + b.w / 2 - 16, groundY - 52, 32, 52);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + b.w / 2 - 16, groundY - 52, 32, 52);

        // "El Barto" graffiti on side wall (easter egg AAA-V5)
        if (seededRandom(x * 0.47 + 91) > 0.4) {
            ctx.save();
            ctx.fillStyle = '#CC3333';
            ctx.font = 'italic bold 9px sans-serif';
            ctx.textAlign = 'left';
            ctx.fillText('EL BARTO', x + b.w - 55, groundY - 12);
            ctx.restore();
        }
    }

    // ── Springfield Elementary ───────────────────────────────────────────

    _drawElementary(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main brick building
        ctx.fillStyle = '#B5651D';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Brick lines
        ctx.strokeStyle = '#8B4513';
        ctx.lineWidth = 0.5;
        for (let by = top + 12; by < groundY; by += 12) {
            ctx.beginPath();
            ctx.moveTo(x, by);
            ctx.lineTo(x + b.w, by);
            ctx.stroke();
            const offset = ((by - top) / 12) % 2 === 0 ? 0 : 18;
            for (let bx = x + offset; bx < x + b.w; bx += 36) {
                ctx.beginPath();
                ctx.moveTo(bx, by);
                ctx.lineTo(bx, by + 12);
                ctx.stroke();
            }
        }

        // Clock tower
        const towerW = 40, towerH = 50;
        const towerX = x + b.w / 2 - towerW / 2;
        const towerTop = top - towerH;
        ctx.fillStyle = '#A0522D';
        ctx.fillRect(towerX, towerTop, towerW, towerH);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(towerX, towerTop, towerW, towerH);

        // Tower pointed roof
        ctx.fillStyle = '#6B3A1F';
        ctx.beginPath();
        ctx.moveTo(towerX - 3, towerTop);
        ctx.lineTo(towerX + towerW / 2, towerTop - 20);
        ctx.lineTo(towerX + towerW + 3, towerTop);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();

        // Clock face
        ctx.fillStyle = '#FFFFF0';
        ctx.beginPath();
        ctx.arc(towerX + towerW / 2, towerTop + 22, 12, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.stroke();
        // Clock hands
        ctx.beginPath();
        ctx.moveTo(towerX + towerW / 2, towerTop + 22);
        ctx.lineTo(towerX + towerW / 2, towerTop + 13);
        ctx.moveTo(towerX + towerW / 2, towerTop + 22);
        ctx.lineTo(towerX + towerW / 2 + 7, towerTop + 22);
        ctx.stroke();

        // "SCHOOL" sign
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 13px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.strokeText('SCHOOL', x + b.w / 2, top + 18);
        ctx.fillText('SCHOOL', x + b.w / 2, top + 18);

        // Double doors
        ctx.fillStyle = '#6B3A1F';
        ctx.fillRect(x + b.w / 2 - 22, groundY - 55, 20, 55);
        ctx.fillRect(x + b.w / 2 + 2, groundY - 55, 20, 55);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + b.w / 2 - 22, groundY - 55, 20, 55);
        ctx.strokeRect(x + b.w / 2 + 2, groundY - 55, 20, 55);

        // Row of windows
        ctx.fillStyle = '#ADE8F4';
        for (let i = 0; i < 4; i++) {
            const wx = x + 20 + i * 55;
            if (wx + 30 < x + b.w - 10) {
                ctx.fillRect(wx, top + 50, 30, 28);
                ctx.strokeStyle = OUTLINE;
                ctx.lineWidth = 1;
                ctx.strokeRect(wx, top + 50, 30, 28);
                // Cross bars
                ctx.beginPath();
                ctx.moveTo(wx + 15, top + 50);
                ctx.lineTo(wx + 15, top + 78);
                ctx.moveTo(wx, top + 64);
                ctx.lineTo(wx + 30, top + 64);
                ctx.stroke();
            }
        }
    }

    // ── Lard Lad Donut ──────────────────────────────────────────────────

    _drawLardLad(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — beige/tan
        ctx.fillStyle = '#D2B48C';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Sign
        ctx.fillStyle = '#8B4513';
        ctx.fillRect(x + 10, top + 8, b.w - 20, 22);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('LARD LAD', x + b.w / 2, top + 19);

        // Giant donut on roof — pink with sprinkles
        const donutCX = x + b.w / 2;
        const donutCY = top - 22;
        const donutR = 26;
        // Outer donut ring
        ctx.fillStyle = '#FF69B4';
        ctx.beginPath();
        ctx.arc(donutCX, donutCY, donutR, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.stroke();
        // Donut hole
        ctx.fillStyle = '#D2B48C';
        ctx.beginPath();
        ctx.arc(donutCX, donutCY, donutR * 0.35, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.stroke();
        // Sprinkles
        const sprinkleColors = ['#FF0000', '#00FF00', '#FFFF00', '#FF8800', '#FFFFFF'];
        for (let i = 0; i < 10; i++) {
            const angle = (i / 10) * Math.PI * 2 + 0.3;
            const dist = donutR * 0.55 + seededRandom(x + i * 7) * donutR * 0.3;
            const sx = donutCX + Math.cos(angle) * dist;
            const sy = donutCY + Math.sin(angle) * dist;
            ctx.fillStyle = sprinkleColors[i % sprinkleColors.length];
            ctx.fillRect(sx - 2, sy - 1, 5, 2);
        }

        // Display window
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(x + 15, top + 40, b.w - 30, 35);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + 15, top + 40, b.w - 30, 35);

        // Door
        ctx.fillStyle = '#8B6914';
        ctx.fillRect(x + b.w / 2 - 14, groundY - 48, 28, 48);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + b.w / 2 - 14, groundY - 48, 28, 48);
    }

    // ── The Leftorium ───────────────────────────────────────────────────

    _drawLeftorium(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — light blue
        ctx.fillStyle = '#6CA6CD';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Awning — green striped
        ctx.fillStyle = '#228B22';
        ctx.beginPath();
        ctx.moveTo(x - 3, top + 30);
        ctx.lineTo(x + b.w + 3, top + 30);
        ctx.lineTo(x + b.w, top + 18);
        ctx.lineTo(x, top + 18);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.stroke();

        // Sign
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.lineJoin = 'round';
        ctx.strokeText('LEFTORIUM', x + b.w / 2, top + 10);
        ctx.fillText('LEFTORIUM', x + b.w / 2, top + 10);

        // Window
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(x + 12, top + 40, b.w - 24, 30);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x + 12, top + 40, b.w - 24, 30);

        // Left-hand scissors displayed in window
        ctx.strokeStyle = '#FFD700';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(x + 30, top + 48);
        ctx.lineTo(x + 50, top + 62);
        ctx.moveTo(x + 50, top + 48);
        ctx.lineTo(x + 30, top + 62);
        ctx.stroke();

        // Door
        ctx.fillStyle = '#3A6A9A';
        ctx.fillRect(x + b.w / 2 - 13, groundY - 45, 26, 45);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x + b.w / 2 - 13, groundY - 45, 26, 45);
    }

    // ── Jebediah Springfield Statue ─────────────────────────────────────

    _drawJebediahStatue(ctx, x, groundY, b) {
        // Stone pedestal
        const pedW = 50, pedH = 40;
        const pedX = x + b.w / 2 - pedW / 2;
        ctx.fillStyle = '#A0A0A0';
        ctx.fillRect(pedX, groundY - pedH, pedW, pedH);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(pedX, groundY - pedH, pedW, pedH);

        // Pedestal plaque
        ctx.fillStyle = '#8B7355';
        ctx.fillRect(pedX + 8, groundY - pedH + 10, pedW - 16, 14);
        ctx.fillStyle = '#FFD700';
        ctx.font = '5px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('JEBEDIAH', pedX + pedW / 2, groundY - pedH + 17);

        // Statue figure — bronze/green patina
        const figX = x + b.w / 2;
        const figBase = groundY - pedH;

        // Body (rectangle torso)
        ctx.fillStyle = '#6B8E6B';
        ctx.fillRect(figX - 10, figBase - 55, 20, 40);
        ctx.strokeStyle = '#4A6A4A';
        ctx.lineWidth = 1;
        ctx.strokeRect(figX - 10, figBase - 55, 20, 40);

        // Head (circle)
        ctx.fillStyle = '#6B8E6B';
        ctx.beginPath();
        ctx.arc(figX, figBase - 65, 10, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = '#4A6A4A';
        ctx.stroke();

        // Hat (wide brim)
        ctx.fillStyle = '#5A7A5A';
        ctx.fillRect(figX - 14, figBase - 77, 28, 5);
        ctx.fillRect(figX - 8, figBase - 85, 16, 9);

        // Extended arm pointing forward
        ctx.strokeStyle = '#6B8E6B';
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.moveTo(figX + 10, figBase - 48);
        ctx.lineTo(figX + 25, figBase - 55);
        ctx.stroke();

        // Legs
        ctx.fillStyle = '#6B8E6B';
        ctx.fillRect(figX - 8, figBase - 15, 7, 15);
        ctx.fillRect(figX + 1, figBase - 15, 7, 15);
    }

    // ── Easter eggs (drawn on select buildings) ─────────────────────────

    _drawEasterEggs(ctx, x, groundY, tileIndex) {
        // Burns billboard — appears every 3rd tile on far layer
        // (called from _farLayer)
    }

    // ── Ground / street level ────────────────────────────────────────────

    _ground(ctx, left, w) {
        const right = left + w;

        // Green sidewalk strip
        ctx.fillStyle = '#6DBE45';
        ctx.fillRect(left, HORIZON, w, 20);

        // Grey sidewalk
        ctx.fillStyle = '#B0B0A8';
        ctx.fillRect(left, HORIZON + 20, w, 15);

        // Sidewalk detail lines (darker cracks/joints)
        ctx.strokeStyle = '#9A9A92';
        ctx.lineWidth = 1;
        const sidewalkJointStart = left - (left % 60);
        for (let sx = sidewalkJointStart; sx < right; sx += 60) {
            ctx.beginPath();
            ctx.moveTo(sx, HORIZON + 20);
            ctx.lineTo(sx, HORIZON + 35);
            ctx.stroke();
        }
        // Horizontal edge line on sidewalk
        ctx.strokeStyle = '#A0A098';
        ctx.beginPath();
        ctx.moveTo(left, HORIZON + 27);
        ctx.lineTo(left + w, HORIZON + 27);
        ctx.stroke();

        // Road
        ctx.fillStyle = '#606060';
        ctx.fillRect(left, HORIZON + 35, w, 100);

        // Road yellow center dashes
        ctx.fillStyle = '#FFDD00';
        const dashStart = left - (left % 100);
        for (let dx = dashStart; dx < right; dx += 100) {
            ctx.fillRect(dx, HORIZON + 80, 50, 6);
        }

        // Curb line (top of road)
        ctx.fillStyle = '#888880';
        ctx.fillRect(left, HORIZON + 35, w, 3);

        // Bottom ground fill
        ctx.fillStyle = '#555550';
        ctx.fillRect(left, HORIZON + 135, w, CANVAS_H - HORIZON - 135);

        // Fire hydrants on sidewalk
        const hydrantStart = Math.floor(left / HYDRANT_SPACING) * HYDRANT_SPACING;
        for (let hx = hydrantStart; hx < right; hx += HYDRANT_SPACING) {
            if (hx + 14 >= left && hx <= right) {
                this._drawHydrant(ctx, hx, HORIZON + 5);
            }
        }

        // Street lamps along sidewalk
        const STREET_LAMP_SPACING = 400;
        const lampStart2 = Math.floor(left / STREET_LAMP_SPACING) * STREET_LAMP_SPACING;
        for (let lx = lampStart2; lx < right; lx += STREET_LAMP_SPACING) {
            if (lx + 20 >= left && lx <= right) {
                this._drawStreetLamp(ctx, lx, HORIZON);
            }
        }

        // Parked cars along the road
        const CAR_SPACING = 550;
        const carStart = Math.floor(left / CAR_SPACING) * CAR_SPACING + 150;
        for (let cx = carStart; cx < right; cx += CAR_SPACING) {
            if (cx + 60 >= left && cx <= right) {
                const carColor = ['#CC3333', '#3366CC', '#33AA33', '#EEEE33', '#AA33AA'][
                    Math.abs(Math.floor(seededRandom(cx * 0.31 + 7) * 5))
                ];
                this._drawParkedCar(ctx, cx, HORIZON + 40, carColor);
            }
        }

        // Three-eyed fish puddle (easter egg, every 1800px)
        const PUDDLE_SPACING = 1800;
        const puddleStart = Math.floor(left / PUDDLE_SPACING) * PUDDLE_SPACING + 300;
        for (let px = puddleStart; px < right; px += PUDDLE_SPACING) {
            if (px + 40 >= left && px <= right) {
                this._drawThreeEyedFishPuddle(ctx, px, HORIZON + 15);
            }
        }

        // Nuclear Plant accident sign (easter egg, every 2400px)
        const NSIGN_SPACING = 2400;
        const nsignStart = Math.floor(left / NSIGN_SPACING) * NSIGN_SPACING + 500;
        for (let nx = nsignStart; nx < right; nx += NSIGN_SPACING) {
            if (nx + 80 >= left && nx <= right) {
                this._drawNuclearSign(ctx, nx, HORIZON - 5);
            }
        }
    }

    _drawHydrant(ctx, x, y) {
        // Body
        ctx.fillStyle = '#DD2222';
        ctx.fillRect(x, y, 14, 22);
        // Cap
        ctx.fillStyle = '#CC1111';
        ctx.fillRect(x - 2, y - 3, 18, 5);
        // Top nub
        ctx.fillRect(x + 4, y - 7, 6, 5);
        // Side nozzles
        ctx.fillRect(x - 4, y + 8, 6, 5);
        ctx.fillRect(x + 12, y + 8, 6, 5);
        // Outline
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x, y, 14, 22);
    }

    _drawStreetLamp(ctx, x, groundY) {
        // Thin pole
        ctx.fillStyle = '#444444';
        ctx.fillRect(x + 2, groundY - 95, 4, 95);

        // Lamp arm
        ctx.fillRect(x, groundY - 95, 14, 3);

        // Warm glowing light bulb
        ctx.fillStyle = '#FFE87C';
        ctx.beginPath();
        ctx.arc(x + 7, groundY - 97, 6, 0, Math.PI * 2);
        ctx.fill();

        // Glow halo
        ctx.save();
        ctx.globalAlpha = 0.12;
        ctx.fillStyle = '#FFD700';
        ctx.beginPath();
        ctx.arc(x + 7, groundY - 97, 16, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Base
        ctx.fillStyle = '#444444';
        ctx.fillRect(x - 1, groundY - 3, 10, 5);
    }

    _drawParkedCar(ctx, x, y, color) {
        // Car body (rectangle)
        ctx.fillStyle = color;
        ctx.fillRect(x, y, 55, 18);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x, y, 55, 18);

        // Roof / cabin
        ctx.fillStyle = color;
        ctx.fillRect(x + 12, y - 10, 28, 12);
        ctx.strokeRect(x + 12, y - 10, 28, 12);

        // Windshield
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(x + 14, y - 8, 11, 9);
        // Rear window
        ctx.fillRect(x + 28, y - 8, 10, 9);

        // Wheels
        ctx.fillStyle = '#222222';
        ctx.beginPath();
        ctx.arc(x + 12, y + 18, 5, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(x + 43, y + 18, 5, 0, Math.PI * 2);
        ctx.fill();

        // Hubcaps
        ctx.fillStyle = '#888888';
        ctx.beginPath();
        ctx.arc(x + 12, y + 18, 2, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(x + 43, y + 18, 2, 0, Math.PI * 2);
        ctx.fill();
    }

    _drawThreeEyedFishPuddle(ctx, x, y) {
        // Small puddle (ellipse)
        ctx.save();
        ctx.fillStyle = '#5588AA';
        ctx.globalAlpha = 0.5;
        ctx.beginPath();
        ctx.ellipse(x + 18, y + 5, 22, 7, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Tiny three-eyed fish (Blinky)
        ctx.fillStyle = '#FF8C00';
        // Body
        ctx.beginPath();
        ctx.ellipse(x + 18, y + 4, 7, 4, 0, 0, Math.PI * 2);
        ctx.fill();
        // Tail
        ctx.beginPath();
        ctx.moveTo(x + 11, y + 4);
        ctx.lineTo(x + 7, y + 0);
        ctx.lineTo(x + 7, y + 8);
        ctx.closePath();
        ctx.fill();
        // Three eyes
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.arc(x + 21, y + 2, 2, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(x + 23, y + 5, 2, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(x + 20, y + 5, 2, 0, Math.PI * 2);
        ctx.fill();
        // Pupils
        ctx.fillStyle = '#000000';
        ctx.beginPath();
        ctx.arc(x + 21, y + 2, 0.8, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(x + 23, y + 5, 0.8, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(x + 20, y + 5, 0.8, 0, Math.PI * 2);
        ctx.fill();
    }

    _drawNuclearSign(ctx, x, y) {
        // Post
        ctx.fillStyle = '#8B8B8B';
        ctx.fillRect(x + 35, y, 4, 30);

        // Sign board
        ctx.fillStyle = '#FFDD00';
        ctx.fillRect(x, y - 30, 75, 30);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(x, y - 30, 75, 30);

        // Text
        ctx.fillStyle = '#222222';
        ctx.font = 'bold 6px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('NUCLEAR PLANT', x + 37, y - 22);
        const days = Math.floor(seededRandom(x * 0.17 + 3) * 10);
        ctx.font = 'bold 8px sans-serif';
        ctx.fillText(days + ' DAYS', x + 37, y - 12);
        ctx.font = '5px sans-serif';
        ctx.fillText('WITHOUT INCIDENT', x + 37, y - 5);
    }

    // ── Foreground Parallax Layer (1.3× speed, in FRONT of entities) ─────

    /**
     * Renders foreground elements that scroll faster than the camera (1.3×)
     * and appear IN FRONT of the action for depth layering.
     * Call AFTER entity rendering in gameplay.js.
     *
     * @param {CanvasRenderingContext2D} ctx
     * @param {number} cameraX  Current camera X offset
     * @param {number} screenWidth  Visible screen width
     */
    renderForeground(ctx, cameraX, screenWidth) {
        const left = cameraX;
        const right = cameraX + screenWidth;

        ctx.save();
        ctx.globalAlpha = 0.3; // semi-transparent so gameplay is visible

        // Foreground offset: elements scroll at 1.3× camera speed
        const fgOffset = cameraX * (FRONT_PARALLAX - 1.0); // extra scroll beyond camera

        // Lampposts
        const lampStart = Math.floor((left + fgOffset - LAMPPOST_SPACING) / LAMPPOST_SPACING) * LAMPPOST_SPACING;
        for (let lx = lampStart; lx < right + fgOffset + LAMPPOST_SPACING; lx += LAMPPOST_SPACING) {
            const screenX = lx - fgOffset;
            if (screenX + 20 >= left && screenX - 20 <= right) {
                this._drawLamppost(ctx, screenX, HORIZON - 5);
            }
        }

        // Chain-link fence sections
        const fenceStart = Math.floor((left + fgOffset - FENCE_SPACING) / FENCE_SPACING) * FENCE_SPACING;
        for (let fx = fenceStart; fx < right + fgOffset + FENCE_SPACING; fx += FENCE_SPACING) {
            const screenX = fx - fgOffset;
            if (screenX + FENCE_SECTION_W >= left && screenX <= right) {
                this._drawFenceSection(ctx, screenX, HORIZON + 2);
            }
        }

        // Foreground fire hydrants (different spacing from background ones)
        const fhStart = Math.floor((left + fgOffset - FRONT_HYDRANT_SPACING) / FRONT_HYDRANT_SPACING) * FRONT_HYDRANT_SPACING;
        for (let hx = fhStart; hx < right + fgOffset + FRONT_HYDRANT_SPACING; hx += FRONT_HYDRANT_SPACING) {
            const screenX = hx - fgOffset;
            if (screenX + 18 >= left && screenX - 4 <= right) {
                this._drawFgHydrant(ctx, screenX, HORIZON + 18);
            }
        }

        ctx.restore();
    }

    _drawLamppost(ctx, x, groundY) {
        // Tall thin dark pole
        ctx.fillStyle = '#333333';
        ctx.fillRect(x - 3, groundY - 130, 6, 130);

        // Lamp arm (horizontal bracket)
        ctx.fillRect(x - 1, groundY - 130, 16, 4);

        // Light fixture (circle at top)
        ctx.fillStyle = '#FFE87C';
        ctx.beginPath();
        ctx.arc(x + 14, groundY - 128, 7, 0, Math.PI * 2);
        ctx.fill();

        // Warm glow halo
        ctx.save();
        ctx.globalAlpha = 0.15;
        ctx.fillStyle = '#FFD700';
        ctx.beginPath();
        ctx.arc(x + 14, groundY - 128, 18, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Base plate
        ctx.fillStyle = '#333333';
        ctx.fillRect(x - 6, groundY - 3, 12, 5);
    }

    _drawFenceSection(ctx, x, groundY) {
        const fenceH = 45;
        const top = groundY - fenceH;

        // Vertical posts
        ctx.fillStyle = '#555555';
        ctx.fillRect(x, top, 3, fenceH);
        ctx.fillRect(x + FENCE_SECTION_W - 3, top, 3, fenceH);

        // Horizontal rails
        ctx.strokeStyle = '#666666';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(x, top + 5);
        ctx.lineTo(x + FENCE_SECTION_W, top + 5);
        ctx.moveTo(x, top + fenceH - 5);
        ctx.lineTo(x + FENCE_SECTION_W, top + fenceH - 5);
        ctx.stroke();

        // Diamond mesh pattern
        ctx.strokeStyle = '#777777';
        ctx.lineWidth = 0.8;
        const meshSize = 10;
        for (let mx = x + 5; mx < x + FENCE_SECTION_W - 5; mx += meshSize) {
            ctx.beginPath();
            ctx.moveTo(mx, top + 5);
            ctx.lineTo(mx + meshSize / 2, top + fenceH - 5);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(mx + meshSize, top + 5);
            ctx.lineTo(mx + meshSize / 2, top + fenceH - 5);
            ctx.stroke();
        }
    }

    _drawFgHydrant(ctx, x, y) {
        // Slightly larger foreground hydrant for depth
        ctx.fillStyle = '#CC2222';
        ctx.fillRect(x, y, 16, 26);
        ctx.fillStyle = '#BB1111';
        ctx.fillRect(x - 2, y - 3, 20, 5);
        ctx.fillRect(x + 5, y - 8, 6, 6);
        ctx.fillRect(x - 5, y + 9, 7, 6);
        ctx.fillRect(x + 14, y + 9, 7, 6);
        ctx.strokeStyle = '#333333';
        ctx.lineWidth = 1.2;
        ctx.strokeRect(x, y, 16, 26);
    }
}
