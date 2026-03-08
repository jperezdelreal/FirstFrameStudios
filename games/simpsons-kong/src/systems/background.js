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
    { type: 'kwik',  w: 250, h: 180 },
    { type: 'house', w: 155, h: 150, color: '#E8C48A' },
    { type: 'moes',  w: 210, h: 165 },
    { type: 'android', w: 200, h: 170 },
    { type: 'house', w: 165, h: 155, color: '#C46B6B' },
    { type: 'elementary', w: 310, h: 220 },
    { type: 'house', w: 150, h: 145, color: '#8FBC8F' },
    { type: 'lardlad', w: 180, h: 165 },
    { type: 'leftorium', w: 155, h: 150 },
    { type: 'statue', w: 100, h: 160 },
    { type: 'house', w: 160, h: 150, color: '#D4A574' },
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
        // Billboard posts
        ctx.fillStyle = '#666666';
        ctx.fillRect(Math.round(x + 30), groundY - 130, 8, 130);
        ctx.fillRect(Math.round(x + 112), groundY - 130, 8, 130);

        // Billboard panel
        ctx.fillStyle = '#FFFFF0';
        ctx.fillRect(Math.round(x), Math.round(groundY - 190), 150, 70);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x), Math.round(groundY - 190), 150, 70);

        // "VOTE BURNS" text with background
        ctx.fillStyle = '#880000';
        ctx.fillRect(Math.round(x + 5), Math.round(groundY - 188), 140, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 16px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('VOTE BURNS', Math.round(x + 75), Math.round(groundY - 176));

        // Burns silhouette (simple hunched figure)
        ctx.fillStyle = '#333333';
        ctx.beginPath();
        ctx.arc(Math.round(x + 40), Math.round(groundY - 152), 8, 0, Math.PI * 2);
        ctx.fill();
        ctx.fillRect(Math.round(x + 35), Math.round(groundY - 144), 10, 16);

        // "Excellent" text
        ctx.fillStyle = '#333333';
        ctx.font = 'italic 12px sans-serif';
        ctx.fillText('"Excellent..."', Math.round(x + 100), Math.round(groundY - 144));
    }

    _drawSpringfieldSign(ctx, x, groundY) {
        // Sign posts
        ctx.fillStyle = '#8B4513';
        ctx.fillRect(Math.round(x + 5), groundY - 100, 7, 100);
        ctx.fillRect(Math.round(x + 148), groundY - 100, 7, 100);

        // Sign board
        ctx.fillStyle = '#228B22';
        ctx.fillRect(Math.round(x - 5), Math.round(groundY - 115), 170, 48);
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x - 2), Math.round(groundY - 112), 164, 42);

        // Sign text
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('WELCOME TO', Math.round(x + 80), Math.round(groundY - 98));
        ctx.font = 'bold 16px sans-serif';
        ctx.fillText('SPRINGFIELD', Math.round(x + 80), Math.round(groundY - 82));
    }

    _drawPowerPlant(ctx, x, groundY) {
        ctx.fillStyle = '#8A8A8A';
        // Cooling tower 1 — trapezoid (scaled up ~1.5×)
        ctx.beginPath();
        ctx.moveTo(x, groundY);
        ctx.lineTo(x + 45, groundY - 270);
        ctx.lineTo(x + 145, groundY - 270);
        ctx.lineTo(x + 190, groundY);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.stroke();

        // Steam circle on top
        ctx.fillStyle = '#B0B0B0';
        ctx.beginPath();
        ctx.arc(x + 95, groundY - 278, 40, 0, Math.PI * 2);
        ctx.fill();

        // Cooling tower 2 (shorter, offset)
        ctx.fillStyle = '#7A7A7A';
        ctx.beginPath();
        ctx.moveTo(x + 220, groundY);
        ctx.lineTo(x + 250, groundY - 210);
        ctx.lineTo(x + 340, groundY - 210);
        ctx.lineTo(x + 370, groundY);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.stroke();

        // Main building block
        ctx.fillStyle = '#9A9A9A';
        ctx.fillRect(x + 60, groundY - 130, 110, 130);
        ctx.strokeStyle = OUTLINE;
        ctx.strokeRect(x + 60, groundY - 130, 110, 130);

        // Windows on main building
        ctx.fillStyle = '#BFBFAA';
        for (let wy = 0; wy < 3; wy++) {
            for (let wx = 0; wx < 3; wx++) {
                ctx.fillRect(x + 70 + wx * 32, groundY - 120 + wy * 38, 20, 24);
            }
        }

        // Smokestack
        ctx.fillStyle = '#707070';
        ctx.fillRect(x + 390, groundY - 240, 24, 240);
        ctx.strokeStyle = OUTLINE;
        ctx.strokeRect(x + 390, groundY - 240, 24, 240);

        // Red warning stripes on smokestack
        ctx.fillStyle = '#CC3333';
        ctx.fillRect(x + 390, groundY - 240, 24, 14);
        ctx.fillRect(x + 390, groundY - 200, 24, 14);
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

        // Main building — desaturated teal (mid-layer muted)
        ctx.fillStyle = '#5A9A9A';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Horizontal siding lines
        ctx.strokeStyle = '#4A8A8A';
        ctx.lineWidth = 0.7;
        for (let sy = top + 20; sy < groundY; sy += 18) {
            ctx.beginPath();
            ctx.moveTo(x, sy);
            ctx.lineTo(x + b.w, sy);
            ctx.stroke();
        }

        // Red awning
        ctx.fillStyle = '#CC2222';
        ctx.beginPath();
        ctx.moveTo(x - 5, top + 45);
        ctx.lineTo(x + b.w + 5, top + 45);
        ctx.lineTo(x + b.w, top + 28);
        ctx.lineTo(x, top + 28);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.stroke();

        // Sign text background
        ctx.fillStyle = '#3A7A7A';
        ctx.fillRect(Math.round(x + 20), Math.round(top + 4), b.w - 40, 22);
        // Sign text
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.strokeText('KWIK-E-MART', Math.round(x + b.w / 2), Math.round(top + 14));
        ctx.fillText('KWIK-E-MART', Math.round(x + b.w / 2), Math.round(top + 14));

        // Door — character height (~80px)
        ctx.fillStyle = '#4A9A9A';
        ctx.fillRect(Math.round(x + b.w / 2 - 20), groundY - 80, 40, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + b.w / 2 - 20), groundY - 80, 40, 80);
        // Door frame
        ctx.strokeStyle = '#3A7A7A';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 22), groundY - 82, 44, 82);
        // Door handle
        ctx.fillStyle = '#888888';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 14), groundY - 40, 3, 0, Math.PI * 2);
        ctx.fill();

        // Windows with frames (~30×30)
        ctx.fillStyle = '#ADE8F4';
        const wl = Math.round(x + 18);
        const wr = Math.round(x + b.w - 52);
        const wy = Math.round(top + 55);
        ctx.fillRect(wl, wy, 35, 32);
        ctx.fillRect(wr, wy, 35, 32);
        // Window frames
        ctx.strokeStyle = '#3A7A7A';
        ctx.lineWidth = 2;
        ctx.strokeRect(wl - 2, wy - 2, 39, 36);
        ctx.strokeRect(wr - 2, wy - 2, 39, 36);
        // Window cross bars
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(wl + 17, wy); ctx.lineTo(wl + 17, wy + 32);
        ctx.moveTo(wl, wy + 16); ctx.lineTo(wl + 35, wy + 16);
        ctx.moveTo(wr + 17, wy); ctx.lineTo(wr + 17, wy + 32);
        ctx.moveTo(wr, wy + 16); ctx.lineTo(wr + 35, wy + 16);
        ctx.stroke();
    }

    _drawMoes(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — muted dark brown
        ctx.fillStyle = '#6A4A31';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Horizontal wood plank lines
        ctx.strokeStyle = '#5A3A21';
        ctx.lineWidth = 0.7;
        for (let sy = top + 15; sy < groundY; sy += 16) {
            ctx.beginPath();
            ctx.moveTo(x, sy);
            ctx.lineTo(x + b.w, sy);
            ctx.stroke();
        }

        // Neon sign background
        ctx.fillStyle = '#3A2211';
        ctx.fillRect(Math.round(x + 25), Math.round(top + 10), b.w - 50, 34);
        ctx.strokeStyle = '#FF4444';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + 25), Math.round(top + 10), b.w - 50, 34);

        // Neon "MOE'S" text
        ctx.fillStyle = '#FF6666';
        ctx.font = 'bold 18px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText("MOE'S", Math.round(x + b.w / 2), Math.round(top + 27));

        // Door — character height
        ctx.fillStyle = '#3A1F0D';
        ctx.fillRect(Math.round(x + b.w / 2 - 18), groundY - 80, 36, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + b.w / 2 - 18), groundY - 80, 36, 80);
        // Door frame
        ctx.strokeStyle = '#4A2F1D';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 20), groundY - 82, 40, 82);
        // Door handle
        ctx.fillStyle = '#AA8833';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 12), groundY - 40, 3, 0, Math.PI * 2);
        ctx.fill();

        // Small grimy window — occasionally lit with warm glow
        const moeLit = seededRandom(x * 1.13 + 53) > 0.4;
        ctx.fillStyle = moeLit ? '#DDAA44' : '#8B7355';
        ctx.fillRect(Math.round(x + 22), Math.round(top + 58), 35, 30);
        if (moeLit) {
            ctx.save();
            ctx.globalAlpha = 0.2;
            ctx.fillStyle = '#FFD700';
            ctx.fillRect(Math.round(x + 20), Math.round(top + 56), 39, 34);
            ctx.restore();
        }
        // Window frame
        ctx.strokeStyle = '#4A2F1D';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + 20), Math.round(top + 56), 39, 34);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + 22), Math.round(top + 58), 35, 30);

        // Second window on right side
        const rightLit = seededRandom(x * 0.87 + 67) > 0.5;
        ctx.fillStyle = rightLit ? '#DDAA44' : '#8B7355';
        ctx.fillRect(Math.round(x + b.w - 60), Math.round(top + 58), 35, 30);
        ctx.strokeStyle = '#4A2F1D';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w - 62), Math.round(top + 56), 39, 34);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + b.w - 60), Math.round(top + 58), 35, 30);

        // "El Barto" graffiti on wall (easter egg AAA-V5)
        if (seededRandom(x * 0.63 + 41) > 0.5) {
            ctx.save();
            ctx.fillStyle = '#CC3333';
            ctx.font = 'italic bold 12px sans-serif';
            ctx.textAlign = 'left';
            ctx.fillText('EL BARTO', Math.round(x + b.w - 80), Math.round(groundY - 10));
            ctx.restore();
        }
    }

    _drawHouse(ctx, x, groundY, b) {
        const wallTop = groundY - b.h;
        const roofPeak = wallTop - 45;

        // Walls
        ctx.fillStyle = b.color;
        ctx.fillRect(x, wallTop, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, wallTop, b.w, b.h);

        // Horizontal siding lines
        ctx.strokeStyle = '#00000015';
        ctx.lineWidth = 0.6;
        for (let sy = wallTop + 10; sy < groundY; sy += 12) {
            ctx.beginPath();
            ctx.moveTo(x, sy);
            ctx.lineTo(x + b.w, sy);
            ctx.stroke();
        }

        // Triangle roof
        ctx.fillStyle = '#8B4513';
        ctx.beginPath();
        ctx.moveTo(x - 10, wallTop);
        ctx.lineTo(x + b.w / 2, roofPeak);
        ctx.lineTo(x + b.w + 10, wallTop);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.stroke();

        // Roof shingle lines
        ctx.strokeStyle = '#6A2A0A';
        ctx.lineWidth = 0.5;
        const roofSteps = 4;
        for (let rs = 1; rs < roofSteps; rs++) {
            const t = rs / roofSteps;
            const ly = roofPeak + t * (wallTop - roofPeak);
            const lxl = x - 10 + t * (b.w / 2 + 10);
            const lxr = x + b.w + 10 - t * (b.w / 2 + 10);
            ctx.beginPath();
            ctx.moveTo(lxl - (1 - t) * 5, ly);
            ctx.lineTo(lxr + (1 - t) * 5, ly);
            ctx.stroke();
        }

        // Windows (2, ~30×30)
        const winW = 30, winH = 30;
        const winY = wallTop + 25;

        const leftLit = seededRandom(x * 0.73 + 17) > 0.55;
        const rightLit = seededRandom(x * 0.91 + 31) > 0.55;

        // Left window
        ctx.fillStyle = leftLit ? '#FFE566' : '#ADE8F4';
        ctx.fillRect(Math.round(x + 18), winY, winW, winH);
        if (leftLit) {
            ctx.save();
            ctx.globalAlpha = 0.25;
            ctx.fillStyle = '#FFD700';
            ctx.fillRect(Math.round(x + 16), winY - 2, winW + 4, winH + 4);
            ctx.restore();
        }

        // Right window
        ctx.fillStyle = rightLit ? '#FFE566' : '#ADE8F4';
        ctx.fillRect(Math.round(x + b.w - 18 - winW), winY, winW, winH);
        if (rightLit) {
            ctx.save();
            ctx.globalAlpha = 0.25;
            ctx.fillStyle = '#FFD700';
            ctx.fillRect(Math.round(x + b.w - 18 - winW - 2), winY - 2, winW + 4, winH + 4);
            ctx.restore();
        }

        // Window frames
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + 16), winY - 2, winW + 4, winH + 4);
        ctx.strokeRect(Math.round(x + b.w - 20 - winW), winY - 2, winW + 4, winH + 4);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + 18), winY, winW, winH);
        ctx.strokeRect(Math.round(x + b.w - 18 - winW), winY, winW, winH);
        // Window cross bars
        ctx.beginPath();
        ctx.moveTo(Math.round(x + 18 + winW / 2), winY);
        ctx.lineTo(Math.round(x + 18 + winW / 2), winY + winH);
        ctx.moveTo(Math.round(x + 18), winY + winH / 2);
        ctx.lineTo(Math.round(x + 18 + winW), winY + winH / 2);
        ctx.moveTo(Math.round(x + b.w - 18 - winW / 2), winY);
        ctx.lineTo(Math.round(x + b.w - 18 - winW / 2), winY + winH);
        ctx.moveTo(Math.round(x + b.w - 18 - winW), winY + winH / 2);
        ctx.lineTo(Math.round(x + b.w - 18), winY + winH / 2);
        ctx.stroke();

        // Door — character height (~80px)
        ctx.fillStyle = '#6B3A1F';
        ctx.fillRect(Math.round(x + b.w / 2 - 15), groundY - 80, 30, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.strokeRect(Math.round(x + b.w / 2 - 15), groundY - 80, 30, 80);
        // Door frame
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 17), groundY - 82, 34, 82);
        // Doorknob
        ctx.fillStyle = '#CCAA44';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 10), groundY - 40, 3, 0, Math.PI * 2);
        ctx.fill();
    }

    // ── Android's Dungeon (Comic Book Guy's shop) ──────────────────────

    _drawAndroidsDungeon(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — muted green
        ctx.fillStyle = '#5A8A5A';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Flat roof cap (parapet)
        ctx.fillStyle = '#3A6A3A';
        ctx.fillRect(x - 3, top - 6, b.w + 6, 8);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(x - 3, top - 6, b.w + 6, 8);

        // Sign background
        ctx.fillStyle = '#2A4A2A';
        ctx.fillRect(Math.round(x + 12), Math.round(top + 8), b.w - 24, 36);
        ctx.strokeStyle = '#FFD700';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + 12), Math.round(top + 8), b.w - 24, 36);

        // Sign text
        ctx.fillStyle = '#FFD700';
        ctx.font = 'bold 14px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText("ANDROID'S", Math.round(x + b.w / 2), Math.round(top + 20));
        ctx.font = 'bold 12px sans-serif';
        ctx.fillText('DUNGEON', Math.round(x + b.w / 2), Math.round(top + 35));

        // Display window (large, showing comic poster inside)
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(Math.round(x + 18), Math.round(top + 55), b.w - 36, 50);
        // Window frame
        ctx.strokeStyle = '#3A6A3A';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + 16), Math.round(top + 53), b.w - 32, 54);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + 18), Math.round(top + 55), b.w - 36, 50);

        // Itchy & Scratchy poster in window (easter egg AAA-V5)
        ctx.fillStyle = '#FF4444';
        ctx.fillRect(Math.round(x + 26), Math.round(top + 60), 26, 36);
        ctx.fillStyle = '#4444FF';
        ctx.fillRect(Math.round(x + 56), Math.round(top + 60), 26, 36);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('I&S', Math.round(x + 54), Math.round(top + 100));

        // Door — character height
        ctx.fillStyle = '#2A4A2A';
        ctx.fillRect(Math.round(x + b.w / 2 - 18), groundY - 80, 36, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + b.w / 2 - 18), groundY - 80, 36, 80);
        // Door frame
        ctx.strokeStyle = '#3A6A3A';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 20), groundY - 82, 40, 82);
        // Door handle
        ctx.fillStyle = '#AA8833';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 12), groundY - 40, 3, 0, Math.PI * 2);
        ctx.fill();

        // "El Barto" graffiti on side wall (easter egg AAA-V5)
        if (seededRandom(x * 0.47 + 91) > 0.4) {
            ctx.save();
            ctx.fillStyle = '#CC3333';
            ctx.font = 'italic bold 12px sans-serif';
            ctx.textAlign = 'left';
            ctx.fillText('EL BARTO', Math.round(x + b.w - 75), Math.round(groundY - 12));
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
        ctx.lineWidth = 1;
        for (let by = top + 14; by < groundY; by += 14) {
            ctx.beginPath();
            ctx.moveTo(x, by);
            ctx.lineTo(x + b.w, by);
            ctx.stroke();
            const offset = ((by - top) / 14) % 2 === 0 ? 0 : 20;
            ctx.lineWidth = 0.7;
            for (let bx = x + offset; bx < x + b.w; bx += 40) {
                ctx.beginPath();
                ctx.moveTo(bx, by);
                ctx.lineTo(bx, by + 14);
                ctx.stroke();
            }
            ctx.lineWidth = 1;
        }

        // Clock tower (scaled up)
        const towerW = 50, towerH = 65;
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
        ctx.moveTo(towerX - 4, towerTop);
        ctx.lineTo(towerX + towerW / 2, towerTop - 28);
        ctx.lineTo(towerX + towerW + 4, towerTop);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();

        // Clock face
        ctx.fillStyle = '#FFFFF0';
        ctx.beginPath();
        ctx.arc(towerX + towerW / 2, towerTop + 28, 15, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.stroke();
        // Clock hands
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(towerX + towerW / 2, towerTop + 28);
        ctx.lineTo(towerX + towerW / 2, towerTop + 16);
        ctx.moveTo(towerX + towerW / 2, towerTop + 28);
        ctx.lineTo(towerX + towerW / 2 + 9, towerTop + 28);
        ctx.stroke();

        // "SCHOOL" sign background
        ctx.fillStyle = '#8A4A10';
        ctx.fillRect(Math.round(x + b.w / 2 - 50), Math.round(top + 6), 100, 26);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.strokeText('SCHOOL', Math.round(x + b.w / 2), Math.round(top + 19));
        ctx.fillText('SCHOOL', Math.round(x + b.w / 2), Math.round(top + 19));

        // Double doors — character height
        ctx.fillStyle = '#6B3A1F';
        ctx.fillRect(Math.round(x + b.w / 2 - 26), groundY - 80, 24, 80);
        ctx.fillRect(Math.round(x + b.w / 2 + 2), groundY - 80, 24, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + b.w / 2 - 26), groundY - 80, 24, 80);
        ctx.strokeRect(Math.round(x + b.w / 2 + 2), groundY - 80, 24, 80);
        // Door frame
        ctx.strokeStyle = '#8A4A10';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 28), groundY - 85, 56, 85);
        // Door handles
        ctx.fillStyle = '#CCAA44';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 - 6), groundY - 40, 2.5, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 6), groundY - 40, 2.5, 0, Math.PI * 2);
        ctx.fill();

        // Row of windows (~35×32 with frames)
        ctx.fillStyle = '#ADE8F4';
        for (let i = 0; i < 5; i++) {
            const wx = Math.round(x + 22 + i * 58);
            if (wx + 35 < x + b.w - 12) {
                ctx.fillRect(wx, Math.round(top + 55), 35, 32);
                // Window frame
                ctx.strokeStyle = '#8A4A10';
                ctx.lineWidth = 2;
                ctx.strokeRect(wx - 2, Math.round(top + 53), 39, 36);
                ctx.strokeStyle = OUTLINE;
                ctx.lineWidth = 1;
                ctx.strokeRect(wx, Math.round(top + 55), 35, 32);
                // Cross bars
                ctx.beginPath();
                ctx.moveTo(wx + 17, Math.round(top + 55));
                ctx.lineTo(wx + 17, Math.round(top + 87));
                ctx.moveTo(wx, Math.round(top + 71));
                ctx.lineTo(wx + 35, Math.round(top + 71));
                ctx.stroke();
            }
        }

        // Second row of windows for taller building
        for (let i = 0; i < 5; i++) {
            const wx = Math.round(x + 22 + i * 58);
            if (wx + 35 < x + b.w - 12) {
                ctx.fillStyle = '#ADE8F4';
                ctx.fillRect(wx, Math.round(top + 105), 35, 32);
                ctx.strokeStyle = OUTLINE;
                ctx.lineWidth = 1;
                ctx.strokeRect(wx, Math.round(top + 105), 35, 32);
                ctx.beginPath();
                ctx.moveTo(wx + 17, Math.round(top + 105));
                ctx.lineTo(wx + 17, Math.round(top + 137));
                ctx.moveTo(wx, Math.round(top + 121));
                ctx.lineTo(wx + 35, Math.round(top + 121));
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

        // Horizontal siding lines
        ctx.strokeStyle = '#C0A07A';
        ctx.lineWidth = 0.6;
        for (let sy = top + 15; sy < groundY; sy += 14) {
            ctx.beginPath();
            ctx.moveTo(x, sy);
            ctx.lineTo(x + b.w, sy);
            ctx.stroke();
        }

        // Sign background
        ctx.fillStyle = '#8B4513';
        ctx.fillRect(Math.round(x + 12), Math.round(top + 10), b.w - 24, 28);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('LARD LAD', Math.round(x + b.w / 2), Math.round(top + 24));

        // Giant donut on roof — pink with sprinkles (scaled up)
        const donutCX = Math.round(x + b.w / 2);
        const donutCY = Math.round(top - 28);
        const donutR = 34;
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
        for (let i = 0; i < 12; i++) {
            const angle = (i / 12) * Math.PI * 2 + 0.3;
            const dist = donutR * 0.55 + seededRandom(x + i * 7) * donutR * 0.3;
            const sx = donutCX + Math.cos(angle) * dist;
            const sy = donutCY + Math.sin(angle) * dist;
            ctx.fillStyle = sprinkleColors[i % sprinkleColors.length];
            ctx.fillRect(Math.round(sx - 2), Math.round(sy - 1), 6, 2);
        }

        // Display window with frame
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(Math.round(x + 18), Math.round(top + 48), b.w - 36, 45);
        ctx.strokeStyle = '#B09070';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + 16), Math.round(top + 46), b.w - 32, 49);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + 18), Math.round(top + 48), b.w - 36, 45);

        // Door — character height
        ctx.fillStyle = '#8B6914';
        ctx.fillRect(Math.round(x + b.w / 2 - 16), groundY - 80, 32, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + b.w / 2 - 16), groundY - 80, 32, 80);
        // Door frame
        ctx.strokeStyle = '#B09070';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 18), groundY - 82, 36, 82);
        // Door handle
        ctx.fillStyle = '#CCAA44';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 10), groundY - 40, 3, 0, Math.PI * 2);
        ctx.fill();
    }

    // ── The Leftorium ───────────────────────────────────────────────────

    _drawLeftorium(ctx, x, groundY, b) {
        const top = groundY - b.h;

        // Main building — muted light blue
        ctx.fillStyle = '#7AB0CD';
        ctx.fillRect(x, top, b.w, b.h);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.strokeRect(x, top, b.w, b.h);

        // Awning — green striped
        ctx.fillStyle = '#228B22';
        ctx.beginPath();
        ctx.moveTo(x - 4, top + 38);
        ctx.lineTo(x + b.w + 4, top + 38);
        ctx.lineTo(x + b.w, top + 22);
        ctx.lineTo(x, top + 22);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 2;
        ctx.stroke();
        // Awning scallop detail
        ctx.strokeStyle = '#1A7A1A';
        ctx.lineWidth = 1;
        for (let ax = x; ax < x + b.w; ax += 15) {
            ctx.beginPath();
            ctx.arc(ax + 7, top + 38, 4, 0, Math.PI);
            ctx.stroke();
        }

        // Sign background
        ctx.fillStyle = '#5A90AD';
        ctx.fillRect(Math.round(x + 10), Math.round(top + 4), b.w - 20, 16);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 13px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.lineJoin = 'round';
        ctx.strokeText('LEFTORIUM', Math.round(x + b.w / 2), Math.round(top + 12));
        ctx.fillText('LEFTORIUM', Math.round(x + b.w / 2), Math.round(top + 12));

        // Window with frame
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(Math.round(x + 15), Math.round(top + 48), b.w - 30, 36);
        ctx.strokeStyle = '#5A90AD';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + 13), Math.round(top + 46), b.w - 26, 40);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x + 15), Math.round(top + 48), b.w - 30, 36);

        // Left-hand scissors displayed in window
        ctx.strokeStyle = '#FFD700';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(Math.round(x + 35), Math.round(top + 54));
        ctx.lineTo(Math.round(x + 60), Math.round(top + 74));
        ctx.moveTo(Math.round(x + 60), Math.round(top + 54));
        ctx.lineTo(Math.round(x + 35), Math.round(top + 74));
        ctx.stroke();

        // Door — character height
        ctx.fillStyle = '#3A6A9A';
        ctx.fillRect(Math.round(x + b.w / 2 - 15), groundY - 80, 30, 80);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x + b.w / 2 - 15), groundY - 80, 30, 80);
        // Door frame
        ctx.strokeStyle = '#5A90AD';
        ctx.lineWidth = 2;
        ctx.strokeRect(Math.round(x + b.w / 2 - 17), groundY - 82, 34, 82);
        // Door handle
        ctx.fillStyle = '#CCAA44';
        ctx.beginPath();
        ctx.arc(Math.round(x + b.w / 2 + 10), groundY - 40, 3, 0, Math.PI * 2);
        ctx.fill();
    }

    // ── Jebediah Springfield Statue ─────────────────────────────────────

    _drawJebediahStatue(ctx, x, groundY, b) {
        // Stone pedestal (larger)
        const pedW = 60, pedH = 50;
        const pedX = x + b.w / 2 - pedW / 2;
        ctx.fillStyle = '#A0A0A0';
        ctx.fillRect(pedX, groundY - pedH, pedW, pedH);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(pedX, groundY - pedH, pedW, pedH);
        // Pedestal step
        ctx.fillStyle = '#909090';
        ctx.fillRect(pedX - 5, groundY - 8, pedW + 10, 8);
        ctx.strokeRect(pedX - 5, groundY - 8, pedW + 10, 8);

        // Pedestal plaque with background
        ctx.fillStyle = '#8B7355';
        ctx.fillRect(Math.round(pedX + 8), Math.round(groundY - pedH + 12), pedW - 16, 18);
        ctx.strokeStyle = '#6A5335';
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(pedX + 8), Math.round(groundY - pedH + 12), pedW - 16, 18);
        ctx.fillStyle = '#FFD700';
        ctx.font = 'bold 10px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('JEBEDIAH', Math.round(pedX + pedW / 2), Math.round(groundY - pedH + 21));

        // Statue figure — bronze/green patina (scaled up)
        const figX = x + b.w / 2;
        const figBase = groundY - pedH;

        // Body (rectangle torso)
        ctx.fillStyle = '#6B8E6B';
        ctx.fillRect(figX - 12, figBase - 65, 24, 48);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(figX - 12, figBase - 65, 24, 48);

        // Head (circle)
        ctx.fillStyle = '#6B8E6B';
        ctx.beginPath();
        ctx.arc(figX, figBase - 78, 13, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = OUTLINE;
        ctx.stroke();

        // Hat (wide brim)
        ctx.fillStyle = '#5A7A5A';
        ctx.fillRect(figX - 18, figBase - 93, 36, 6);
        ctx.fillRect(figX - 10, figBase - 103, 20, 11);

        // Extended arm pointing forward
        ctx.strokeStyle = '#6B8E6B';
        ctx.lineWidth = 5;
        ctx.beginPath();
        ctx.moveTo(figX + 12, figBase - 58);
        ctx.lineTo(figX + 30, figBase - 66);
        ctx.stroke();

        // Legs
        ctx.fillStyle = '#6B8E6B';
        ctx.fillRect(figX - 10, figBase - 17, 9, 17);
        ctx.fillRect(figX + 1, figBase - 17, 9, 17);
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
        ctx.fillRect(left, HORIZON, w, 22);

        // Grey sidewalk with slight color variation
        ctx.fillStyle = '#B0B0A8';
        ctx.fillRect(left, HORIZON + 22, w, 18);
        // Subtle sidewalk color variation bands
        ctx.save();
        ctx.globalAlpha = 0.06;
        const bandStart = left - (left % 120);
        for (let bx = bandStart; bx < right; bx += 120) {
            if (seededRandom(bx * 0.23 + 11) > 0.5) {
                ctx.fillStyle = '#888880';
                ctx.fillRect(bx, HORIZON + 22, 120, 18);
            }
        }
        ctx.restore();

        // Sidewalk expansion joints
        ctx.strokeStyle = '#9A9A92';
        ctx.lineWidth = 1;
        const sidewalkJointStart = left - (left % 55);
        for (let sx = sidewalkJointStart; sx < right; sx += 55) {
            ctx.beginPath();
            ctx.moveTo(Math.round(sx), HORIZON + 22);
            ctx.lineTo(Math.round(sx), HORIZON + 40);
            ctx.stroke();
        }
        // Horizontal center line on sidewalk
        ctx.strokeStyle = '#A0A098';
        ctx.beginPath();
        ctx.moveTo(left, HORIZON + 31);
        ctx.lineTo(left + w, HORIZON + 31);
        ctx.stroke();

        // Curb (raised edge between sidewalk and road)
        ctx.fillStyle = '#C0C0B8';
        ctx.fillRect(left, HORIZON + 40, w, 5);
        ctx.strokeStyle = '#888880';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(left, HORIZON + 40);
        ctx.lineTo(right, HORIZON + 40);
        ctx.stroke();
        // Curb shadow
        ctx.fillStyle = '#707068';
        ctx.fillRect(left, HORIZON + 45, w, 2);

        // Road
        ctx.fillStyle = '#606060';
        ctx.fillRect(left, HORIZON + 47, w, 100);

        // Road white edge lines
        ctx.fillStyle = '#DDDDDD';
        const edgeStart = left - (left % 60);
        for (let ex = edgeStart; ex < right; ex += 60) {
            ctx.fillRect(Math.round(ex), HORIZON + 49, 40, 3);
            ctx.fillRect(Math.round(ex), HORIZON + 142, 40, 3);
        }

        // Road yellow center dashes
        ctx.fillStyle = '#FFDD00';
        const dashStart = left - (left % 100);
        for (let dx = dashStart; dx < right; dx += 100) {
            ctx.fillRect(Math.round(dx), HORIZON + 92, 50, 6);
        }

        // Bottom ground fill
        ctx.fillStyle = '#555550';
        ctx.fillRect(left, HORIZON + 147, w, CANVAS_H - HORIZON - 147);

        // Fire hydrants on sidewalk
        const hydrantStart = Math.floor(left / HYDRANT_SPACING) * HYDRANT_SPACING;
        for (let hx = hydrantStart; hx < right; hx += HYDRANT_SPACING) {
            if (hx + 18 >= left && hx <= right) {
                this._drawHydrant(ctx, hx, HORIZON + 7);
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
            if (cx + 100 >= left && cx <= right) {
                const carColor = ['#CC3333', '#3366CC', '#33AA33', '#EEEE33', '#AA33AA'][
                    Math.abs(Math.floor(seededRandom(cx * 0.31 + 7) * 5))
                ];
                this._drawParkedCar(ctx, cx, HORIZON + 55, carColor);
            }
        }

        // Three-eyed fish puddle (easter egg, every 1800px)
        const PUDDLE_SPACING = 1800;
        const puddleStart = Math.floor(left / PUDDLE_SPACING) * PUDDLE_SPACING + 300;
        for (let px = puddleStart; px < right; px += PUDDLE_SPACING) {
            if (px + 40 >= left && px <= right) {
                this._drawThreeEyedFishPuddle(ctx, px, HORIZON + 17);
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
        // Body (scaled to ~30px tall — waist height)
        ctx.fillStyle = '#DD2222';
        ctx.fillRect(Math.round(x), Math.round(y), 18, 30);
        // Cap
        ctx.fillStyle = '#CC1111';
        ctx.fillRect(Math.round(x - 2), Math.round(y - 4), 22, 6);
        // Top nub
        ctx.fillRect(Math.round(x + 5), Math.round(y - 9), 8, 6);
        // Side nozzles
        ctx.fillRect(Math.round(x - 5), Math.round(y + 10), 7, 6);
        ctx.fillRect(Math.round(x + 16), Math.round(y + 10), 7, 6);
        // Outline
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1;
        ctx.strokeRect(Math.round(x), Math.round(y), 18, 30);
    }

    _drawStreetLamp(ctx, x, groundY) {
        // Thin pole (~120px tall)
        ctx.fillStyle = '#444444';
        ctx.fillRect(Math.round(x + 2), groundY - 120, 5, 120);

        // Lamp arm
        ctx.fillRect(Math.round(x), groundY - 120, 16, 4);

        // Warm glowing light bulb
        ctx.fillStyle = '#FFE87C';
        ctx.beginPath();
        ctx.arc(Math.round(x + 8), groundY - 122, 7, 0, Math.PI * 2);
        ctx.fill();

        // Glow halo
        ctx.save();
        ctx.globalAlpha = 0.12;
        ctx.fillStyle = '#FFD700';
        ctx.beginPath();
        ctx.arc(Math.round(x + 8), groundY - 122, 18, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Base
        ctx.fillStyle = '#444444';
        ctx.fillRect(Math.round(x - 2), groundY - 4, 12, 6);
    }

    _drawParkedCar(ctx, x, y, color) {
        // Car body (~100px long, ~35px tall)
        ctx.fillStyle = color;
        ctx.fillRect(Math.round(x), Math.round(y), 100, 35);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x), Math.round(y), 100, 35);

        // Roof / cabin
        ctx.fillStyle = color;
        ctx.fillRect(Math.round(x + 22), Math.round(y - 20), 52, 22);
        ctx.strokeRect(Math.round(x + 22), Math.round(y - 20), 52, 22);

        // Windshield
        ctx.fillStyle = '#ADE8F4';
        ctx.fillRect(Math.round(x + 25), Math.round(y - 17), 20, 17);
        // Rear window
        ctx.fillRect(Math.round(x + 50), Math.round(y - 17), 18, 17);

        // Headlight
        ctx.fillStyle = '#FFEE88';
        ctx.fillRect(Math.round(x + 95), Math.round(y + 5), 5, 8);
        // Taillight
        ctx.fillStyle = '#FF3333';
        ctx.fillRect(Math.round(x), Math.round(y + 5), 4, 8);

        // Wheels
        ctx.fillStyle = '#222222';
        ctx.beginPath();
        ctx.arc(Math.round(x + 22), Math.round(y + 35), 8, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(Math.round(x + 78), Math.round(y + 35), 8, 0, Math.PI * 2);
        ctx.fill();

        // Hubcaps
        ctx.fillStyle = '#888888';
        ctx.beginPath();
        ctx.arc(Math.round(x + 22), Math.round(y + 35), 3, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(Math.round(x + 78), Math.round(y + 35), 3, 0, Math.PI * 2);
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
        ctx.fillRect(Math.round(x + 42), y, 6, 35);

        // Sign board (larger)
        ctx.fillStyle = '#FFDD00';
        ctx.fillRect(Math.round(x), Math.round(y - 40), 90, 40);
        ctx.strokeStyle = OUTLINE;
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x), Math.round(y - 40), 90, 40);

        // Text with readable sizes
        ctx.fillStyle = '#222222';
        ctx.font = 'bold 12px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('NUCLEAR PLANT', Math.round(x + 45), Math.round(y - 30));
        const days = Math.floor(seededRandom(x * 0.17 + 3) * 10);
        ctx.font = 'bold 14px sans-serif';
        ctx.fillText(days + ' DAYS', Math.round(x + 45), Math.round(y - 16));
        ctx.font = 'bold 10px sans-serif';
        ctx.fillText('WITHOUT INCIDENT', Math.round(x + 45), Math.round(y - 5));
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
        ctx.globalAlpha = 0.5; // semi-transparent so gameplay is visible

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
        // Tall thin dark pole (~150px)
        ctx.fillStyle = '#333333';
        ctx.fillRect(Math.round(x - 3), groundY - 150, 6, 150);

        // Lamp arm (horizontal bracket)
        ctx.fillRect(Math.round(x - 1), groundY - 150, 18, 4);

        // Light fixture (circle at top)
        ctx.fillStyle = '#FFE87C';
        ctx.beginPath();
        ctx.arc(Math.round(x + 16), groundY - 148, 8, 0, Math.PI * 2);
        ctx.fill();

        // Warm glow halo
        ctx.save();
        ctx.globalAlpha = 0.15;
        ctx.fillStyle = '#FFD700';
        ctx.beginPath();
        ctx.arc(Math.round(x + 16), groundY - 148, 22, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Base plate
        ctx.fillStyle = '#333333';
        ctx.fillRect(Math.round(x - 7), groundY - 3, 14, 5);
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
        // Larger foreground hydrant for depth (~36px tall)
        ctx.fillStyle = '#CC2222';
        ctx.fillRect(Math.round(x), Math.round(y), 22, 36);
        ctx.fillStyle = '#BB1111';
        ctx.fillRect(Math.round(x - 3), Math.round(y - 4), 28, 7);
        ctx.fillRect(Math.round(x + 6), Math.round(y - 10), 10, 8);
        ctx.fillRect(Math.round(x - 6), Math.round(y + 12), 9, 8);
        ctx.fillRect(Math.round(x + 19), Math.round(y + 12), 9, 8);
        ctx.strokeStyle = '#333333';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(Math.round(x), Math.round(y), 22, 36);
    }
}
