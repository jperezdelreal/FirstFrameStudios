// ===========================
// Come Rosquillas - Homer's Donut Quest
// A Pac-Man game deeply themed on The Simpsons
// ===========================

(function () {
    'use strict';

    // ==================== CONSTANTS ====================
    const TILE = 24;
    const COLS = 28;
    const ROWS = 31;
    const CANVAS_W = COLS * TILE;
    const CANVAS_H = ROWS * TILE;

    // Cell types
    const WALL = 0, DOT = 1, EMPTY = 2, POWER = 3, GHOST_HOUSE = 4, GHOST_DOOR = 5;

    // Directions
    const UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3;
    const DX = [0, 1, 0, -1];
    const DY = [-1, 0, 1, 0];
    const OPP = [DOWN, LEFT, UP, RIGHT];

    // Game states
    const ST_START = 0, ST_READY = 1, ST_PLAYING = 2, ST_DYING = 3,
        ST_LEVEL_DONE = 4, ST_GAME_OVER = 5, ST_PAUSED = 6;

    // Ghost modes
    const GM_SCATTER = 0, GM_CHASE = 1, GM_FRIGHTENED = 2, GM_EATEN = 3;

    // ==================== SIMPSONS QUOTES ====================
    const HOMER_DEATH_QUOTES = ["D'OH!", "¡D'OH!", "Why you little...!", "Mmm... floor."];
    const HOMER_POWER_QUOTES = ["Mmm... Duff!", "Woohoo!", "¡Cerveza!", "In pizza we trust!"];
    const HOMER_WIN_QUOTES = ["Woohoo!", "¡Ño ño ño!", "Donuts... is there anything they can't do?"];
    const GAME_OVER_QUOTES = [
        "To alcohol! The cause of, and solution to, all of life's problems.",
        "Trying is the first step toward failure.",
        "Kids, you tried your best and you failed miserably.",
        "Mmm... game over."
    ];
    const GHOST_NAMES = ['Sr. Burns', 'Bob Patiño', 'Nelson', 'Snake'];

    // ==================== MAZE ====================
    const MAZE_TEMPLATE = [
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0],
        [0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0],
        [0,3,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,3,0],
        [0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0],
        [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],
        [0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,1,0],
        [0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,1,0],
        [0,1,1,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,1,1,0],
        [0,0,0,0,0,0,1,0,0,0,0,0,2,0,0,2,0,0,0,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,0,0,0,2,0,0,2,0,0,0,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,2,2,2,2,2,2,2,2,2,2,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,2,0,0,0,5,5,0,0,0,2,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,2,2,2,0,4,4,4,4,4,4,0,2,2,2,1,0,0,0,0,0,0],
        [2,2,2,2,2,2,1,0,0,2,0,4,4,4,4,4,4,0,2,0,0,1,2,2,2,2,2,2],
        [0,0,0,0,0,0,1,0,0,2,0,4,4,4,4,4,4,0,2,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,2,0,0,0,0,0,0,0,0,2,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,2,2,2,2,2,2,2,2,2,2,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,2,0,0,0,0,0,0,0,0,2,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,0,0,2,0,0,0,0,0,0,0,0,2,0,0,1,0,0,0,0,0,0],
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0],
        [0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0],
        [0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0],
        [0,3,1,1,0,0,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,0,0,1,1,3,0],
        [0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0],
        [0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0],
        [0,1,1,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,1,1,0],
        [0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0],
        [0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0],
        [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    ];

    // Homer start position
    const HOMER_START = { x: 14, y: 23 };

    // Ghost configs - Simpsons villains
    const GHOST_CFG = [
        { name: 'Sr. Burns',   color: '#ffd800', skinColor: '#f5e6a0', startX: 14, startY: 11, scatterX: 25, scatterY: 0,  homeX: 14, homeY: 14, exitDelay: 0 },
        { name: 'Bob Patiño',  color: '#ff4444', skinColor: '#f5d0a0', startX: 12, startY: 14, scatterX: 2,  scatterY: 0,  homeX: 12, homeY: 14, exitDelay: 50 },
        { name: 'Nelson',      color: '#ff8c00', skinColor: '#ffd800', startX: 14, startY: 14, scatterX: 27, scatterY: 30, homeX: 14, homeY: 14, exitDelay: 100 },
        { name: 'Snake',       color: '#44bb44', skinColor: '#f5d0a0', startX: 16, startY: 14, scatterX: 0,  scatterY: 30, homeX: 16, homeY: 14, exitDelay: 150 }
    ];

    // Ghost mode timers (in frames at 60fps)
    const MODE_TIMERS = [180, 1200, 300, 1200, 300, 1200, 300, -1];
    const FRIGHT_TIME = 360;
    const FRIGHT_FLASH_TIME = 120;

    const BASE_SPEED = 1.8;

    // ==================== SIMPSONS COLOR PALETTE ====================
    const COLORS = {
        simpsonYellow: '#ffd800',
        simpsonSkin: '#fcd667',
        homerWhite: '#ffffff',
        donutPink: '#ff69b4',
        donutDarkPink: '#ff1493',
        donutBrown: '#a0522d',
        donutDarkBrown: '#8b4513',
        sprinkle1: '#ff0000',
        sprinkle2: '#00ff00',
        sprinkle3: '#0088ff',
        sprinkle4: '#ffff00',
        sprinkle5: '#ff8800',
        duffRed: '#cc0000',
        duffGold: '#ffd700',
        wallBlue: '#2244aa',
        wallBlueDark: '#1a3388',
        wallBlueLight: '#3366cc',
        wallBorder: '#5577ee',
        pathDark: '#0a0a1a',
        skyBlue: '#87ceeb',
        springfieldGreen: '#2d8b2d',
        krustyPurple: '#6a0dad',
        burnsGreen: '#556b2f',
    };

    // ==================== SOUND MANAGER ====================
    class SoundManager {
        constructor() {
            try {
                this.ctx = new (window.AudioContext || window.webkitAudioContext)();
            } catch (e) {
                this.ctx = null;
            }
        }
        play(type) {
            if (!this.ctx) return;
            const now = this.ctx.currentTime;

            switch (type) {
                case 'chomp': this._donut(now); break;
                case 'power': this._duff(now); break;
                case 'eatGhost': this._eatGhost(now); break;
                case 'die': this._doh(now); break;
                case 'start': this._simpsonsJingle(now); break;
                case 'levelComplete': this._woohoo(now); break;
                case 'extraLife': this._extraLife(now); break;
            }
        }
        _osc(type, freq, start, end, vol) {
            const o = this.ctx.createOscillator();
            const g = this.ctx.createGain();
            o.type = type; o.connect(g); g.connect(this.ctx.destination);
            g.gain.value = vol || 0.12;
            if (typeof freq === 'number') {
                o.frequency.value = freq;
            } else {
                freq.forEach(([f, t]) => o.frequency.setValueAtTime(f, start + t));
            }
            g.gain.linearRampToValueAtTime(0, end);
            o.start(start); o.stop(end);
        }
        _donut(t) {
            // Homer munching sound
            this._osc('sawtooth', [[300, 0], [150, 0.04], [250, 0.06]], t, t + 0.1, 0.1);
        }
        _duff(t) {
            // Beer gulp + burp
            this._osc('sine', [[120, 0], [80, 0.1], [60, 0.2]], t, t + 0.3, 0.15);
            this._osc('sawtooth', [[80, 0], [40, 0.15]], t + 0.25, t + 0.5, 0.08);
        }
        _eatGhost(t) {
            // Triumphant ascending
            this._osc('square', [[400, 0], [600, 0.05], [800, 0.1], [1000, 0.15]], t, t + 0.3, 0.1);
        }
        _doh(t) {
            // Homer's D'oh - descending tone
            this._osc('sawtooth', [[400, 0], [350, 0.1], [200, 0.4], [100, 0.8]], t, t + 1.2, 0.15);
            this._osc('square', [[300, 0], [250, 0.15], [150, 0.5]], t + 0.05, t + 1.0, 0.05);
        }
        _simpsonsJingle(t) {
            // Approximation of the Simpsons theme opening notes
            const notes = [
                [659, 0], [659, 0.15], [659, 0.3], // E E E
                [587, 0.45], [698, 0.55], // D F
                [784, 0.7], [880, 0.85], // G A
                [784, 1.0], [698, 1.1], [659, 1.2], // G F E
                [587, 1.35], [523, 1.5] // D C
            ];
            this._osc('square', notes, t, t + 1.8, 0.12);
            // Bass
            this._osc('sine', [[131, 0], [147, 0.45], [165, 0.9], [131, 1.35]], t, t + 1.8, 0.08);
        }
        _woohoo(t) {
            // Homer Woohoo ascending
            this._osc('sine', [[300, 0], [500, 0.1], [800, 0.2], [1200, 0.3]], t, t + 0.6, 0.15);
            this._osc('square', [[250, 0], [400, 0.15]], t + 0.05, t + 0.5, 0.05);
        }
        _extraLife(t) {
            this._osc('sine', [[523, 0], [659, 0.08], [784, 0.16], [1047, 0.24], [784, 0.32], [1047, 0.4]], t, t + 0.6, 0.12);
        }

        // ---- Background Music (looping Simpsons-inspired melody) ----
        startMusic() {
            if (!this.ctx || this._musicPlaying) return;
            this._musicPlaying = true;
            this._musicMuted = false;
            this._musicGain = this.ctx.createGain();
            this._musicGain.gain.value = 0.07;
            this._musicGain.connect(this.ctx.destination);
            this._scheduleMusic();
        }
        _scheduleMusic() {
            if (!this._musicPlaying) return;
            const now = this.ctx.currentTime;
            // Simpsons-inspired looping bass + melody pattern (~4 seconds per loop)
            const melody = [
                [330, 0], [330, 0.2], [392, 0.4], [440, 0.6],
                [392, 0.8], [330, 1.0], [294, 1.2], [262, 1.4],
                [294, 1.6], [330, 1.8], [392, 2.0], [440, 2.2],
                [494, 2.4], [440, 2.6], [392, 2.8], [330, 3.0],
                [294, 3.2], [262, 3.4], [294, 3.6], [330, 3.8]
            ];
            const bass = [
                [131, 0], [131, 0.4], [147, 0.8], [165, 1.2],
                [131, 1.6], [131, 2.0], [110, 2.4], [131, 2.8],
                [147, 3.2], [131, 3.6]
            ];
            const loopDur = 4.0;
            // Melody voice
            const oM = this.ctx.createOscillator();
            const gM = this.ctx.createGain();
            oM.type = 'square';
            oM.connect(gM);
            gM.connect(this._musicGain);
            gM.gain.value = 0.5;
            melody.forEach(([f, t]) => oM.frequency.setValueAtTime(f, now + t));
            gM.gain.setValueAtTime(0.5, now + loopDur - 0.05);
            gM.gain.linearRampToValueAtTime(0, now + loopDur);
            oM.start(now);
            oM.stop(now + loopDur);
            // Bass voice
            const oB = this.ctx.createOscillator();
            const gB = this.ctx.createGain();
            oB.type = 'sine';
            oB.connect(gB);
            gB.connect(this._musicGain);
            gB.gain.value = 0.6;
            bass.forEach(([f, t]) => oB.frequency.setValueAtTime(f, now + t));
            gB.gain.setValueAtTime(0.6, now + loopDur - 0.05);
            gB.gain.linearRampToValueAtTime(0, now + loopDur);
            oB.start(now);
            oB.stop(now + loopDur);
            // Schedule next loop
            this._musicTimeout = setTimeout(() => this._scheduleMusic(), (loopDur - 0.1) * 1000);
        }
        stopMusic() {
            this._musicPlaying = false;
            if (this._musicTimeout) { clearTimeout(this._musicTimeout); this._musicTimeout = null; }
            if (this._musicGain) {
                try { this._musicGain.gain.linearRampToValueAtTime(0, this.ctx.currentTime + 0.1); } catch(e) {}
            }
        }
        toggleMute() {
            if (!this._musicGain) return;
            this._musicMuted = !this._musicMuted;
            this._musicGain.gain.value = this._musicMuted ? 0 : 0.07;
            return this._musicMuted;
        }

        resume() {
            if (this.ctx && this.ctx.state === 'suspended') this.ctx.resume();
        }
    }

    // ==================== SPRITE RENDERER ====================
    class Sprites {

        // ---- HOMER (detailed) ----
        static drawHomer(ctx, x, y, dir, mouthAngle, size) {
            const cx = x + size / 2;
            const cy = y + size / 2;
            const r = size / 2 - 1;
            const angles = [Math.PI * 1.5, 0, Math.PI * 0.5, Math.PI];
            const a = angles[dir];

            // Head shape (yellow)
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.beginPath();
            ctx.arc(cx, cy, r, a + mouthAngle, a + Math.PI * 2 - mouthAngle);
            ctx.lineTo(cx, cy);
            ctx.closePath();
            ctx.fill();

            // Outline
            ctx.strokeStyle = '#b8a000';
            ctx.lineWidth = 0.8;
            ctx.beginPath();
            ctx.arc(cx, cy, r, a + mouthAngle, a + Math.PI * 2 - mouthAngle);
            ctx.stroke();

            // Hair (two strands on top) - M-shaped
            const hairBase = cy - r + 1;
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.strokeStyle = '#b8a000';
            ctx.lineWidth = 1;
            for (let i = -1; i <= 1; i += 2) {
                ctx.beginPath();
                ctx.moveTo(cx + i * 2, hairBase);
                ctx.lineTo(cx + i * 4, hairBase - 4);
                ctx.lineTo(cx + i * 1, hairBase - 1);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();
            }

            // Eye (big white Simpson eye)
            const eyeDist = r * 0.35;
            const eyeAngle = a - 0.4;
            const eyeX = cx + Math.cos(eyeAngle) * eyeDist;
            const eyeY = cy + Math.sin(eyeAngle) * eyeDist;
            // White
            ctx.fillStyle = '#fff';
            ctx.beginPath();
            ctx.ellipse(eyeX, eyeY, 4.5, 5.5, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = '#000';
            ctx.lineWidth = 0.5;
            ctx.stroke();
            // Pupil
            ctx.fillStyle = '#000';
            ctx.beginPath();
            ctx.arc(eyeX + Math.cos(a) * 1.5, eyeY + Math.sin(a) * 1.5, 1.8, 0, Math.PI * 2);
            ctx.fill();

            // 5 o'clock shadow (blue dots around mouth area)
            ctx.fillStyle = '#c8b850';
            const stubbleAngle = a + 0.6;
            for (let i = 0; i < 3; i++) {
                const sa = stubbleAngle + i * 0.25;
                const sx = cx + Math.cos(sa) * r * 0.55;
                const sy = cy + Math.sin(sa) * r * 0.55;
                ctx.beginPath();
                ctx.arc(sx, sy, 0.7, 0, Math.PI * 2);
                ctx.fill();
            }

            // Mouth interior (darker for depth)
            if (mouthAngle > 0.1) {
                ctx.fillStyle = '#8B0000';
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.arc(cx, cy, r * 0.6, a - mouthAngle * 0.5, a + mouthAngle * 0.5);
                ctx.closePath();
                ctx.fill();
            }

            // Ear (small bump)
            const earAngle = a + Math.PI * 0.75;
            const earX = cx + Math.cos(earAngle) * (r - 2);
            const earY = cy + Math.sin(earAngle) * (r - 2);
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.beginPath();
            ctx.arc(earX, earY, 2, 0, Math.PI * 2);
            ctx.fill();
        }

        // ---- HOMER DYING ----
        static drawHomerDying(ctx, x, y, progress, size) {
            const cx = x + size / 2;
            const cy = y + size / 2;
            const r = (size / 2 - 1) * (1 - progress);
            ctx.globalAlpha = 1 - progress * 0.8;

            // Spinning shrink with stars
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.beginPath();
            ctx.arc(cx, cy, r, progress * Math.PI * 2, Math.PI * 4 - progress * Math.PI * 2);
            ctx.lineTo(cx, cy);
            ctx.closePath();
            ctx.fill();

            // Stars around head
            if (progress > 0.2 && progress < 0.8) {
                ctx.fillStyle = '#ffd800';
                for (let i = 0; i < 5; i++) {
                    const sa = (progress * 6 + i * Math.PI * 2 / 5);
                    const sr = r + 8 + progress * 10;
                    const sx = cx + Math.cos(sa) * sr;
                    const sy = cy + Math.sin(sa) * sr;
                    Sprites._drawStar(ctx, sx, sy, 3);
                }
            }

            ctx.globalAlpha = 1;
        }

        static _drawStar(ctx, x, y, r) {
            ctx.beginPath();
            for (let i = 0; i < 5; i++) {
                const a1 = (i * Math.PI * 2 / 5) - Math.PI / 2;
                const a2 = a1 + Math.PI / 5;
                ctx.lineTo(x + Math.cos(a1) * r, y + Math.sin(a1) * r);
                ctx.lineTo(x + Math.cos(a2) * r * 0.4, y + Math.sin(a2) * r * 0.4);
            }
            ctx.closePath();
            ctx.fill();
        }

        // ---- MINI HOMER (lives indicator) ----
        static drawMiniHomer(ctx, x, y) {
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.beginPath();
            ctx.arc(x, y, 8, 0.25, Math.PI * 2 - 0.25);
            ctx.lineTo(x, y);
            ctx.closePath();
            ctx.fill();
            // Eye
            ctx.fillStyle = '#fff';
            ctx.beginPath();
            ctx.arc(x + 2, y - 3, 2.5, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = '#000';
            ctx.beginPath();
            ctx.arc(x + 3, y - 3, 1, 0, Math.PI * 2);
            ctx.fill();
            // Hair
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.strokeStyle = '#b8a000';
            ctx.lineWidth = 0.5;
            ctx.beginPath();
            ctx.moveTo(x, y - 7);
            ctx.lineTo(x + 1, y - 11);
            ctx.lineTo(x + 2, y - 8);
            ctx.closePath();
            ctx.fill(); ctx.stroke();
        }

        // ---- DONUT ----
        static drawDonut(ctx, x, y, animFrame) {
            const r = 4;
            // Donut body
            ctx.fillStyle = COLORS.donutBrown;
            ctx.beginPath();
            ctx.arc(x, y, r, 0, Math.PI * 2);
            ctx.fill();
            // Pink frosting (top half with drips)
            ctx.fillStyle = COLORS.donutPink;
            ctx.beginPath();
            ctx.arc(x, y, r, Math.PI * 1.1, Math.PI * -0.1);
            ctx.fill();
            // Frosting drips
            ctx.fillStyle = COLORS.donutDarkPink;
            ctx.beginPath();
            ctx.ellipse(x - 2, y + 1, 1, 2, 0.2, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.ellipse(x + 2.5, y + 0.5, 0.8, 1.5, -0.2, 0, Math.PI * 2);
            ctx.fill();
            // Hole
            ctx.fillStyle = '#0a0a1a';
            ctx.beginPath();
            ctx.arc(x, y, 1.2, 0, Math.PI * 2);
            ctx.fill();
            // Sprinkles (rotate slowly)
            const phase = animFrame * 0.02;
            const sprinkleColors = [COLORS.sprinkle1, COLORS.sprinkle2, COLORS.sprinkle3, COLORS.sprinkle4, COLORS.sprinkle5];
            for (let i = 0; i < 5; i++) {
                const sa = phase + i * Math.PI * 2 / 5;
                const sx = x + Math.cos(sa) * (r - 1.5);
                const sy = y - 1 + Math.sin(sa) * 1.2;
                if (sy < y) { // Only on frosting
                    ctx.fillStyle = sprinkleColors[i];
                    ctx.fillRect(sx - 0.5, sy - 0.5, 2, 1);
                }
            }
        }

        // ---- DUFF BEER (power pellet) ----
        static drawDuff(ctx, x, y, animFrame) {
            const pulse = Math.sin(animFrame * 0.08) * 1.5;
            const r = 7 + pulse;
            // Can body
            ctx.fillStyle = COLORS.duffRed;
            ctx.beginPath();
            ctx.roundRect(x - r * 0.7, y - r, r * 1.4, r * 2, 2);
            ctx.fill();
            // Duff label (white band)
            ctx.fillStyle = '#fff';
            ctx.fillRect(x - r * 0.65, y - 3, r * 1.3, 7);
            // "DUFF" text
            ctx.fillStyle = COLORS.duffRed;
            ctx.font = 'bold 6px Arial';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText('DUFF', x, y + 1);
            // Top of can (silver)
            ctx.fillStyle = '#c0c0c0';
            ctx.beginPath();
            ctx.ellipse(x, y - r + 1, r * 0.6, 2, 0, 0, Math.PI * 2);
            ctx.fill();
            // Glow effect
            ctx.strokeStyle = `rgba(255, 215, 0, ${0.3 + Math.sin(animFrame * 0.08) * 0.2})`;
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(x, y, r + 3, 0, Math.PI * 2);
            ctx.stroke();
        }

        // ---- GHOSTS AS SIMPSONS CHARACTERS ----
        static drawGhost(ctx, ghost, animFrame, frightTimer) {
            const cx = ghost.x + TILE / 2;
            const cy = ghost.y + TILE / 2;
            const r = TILE / 2 - 1;

            if (ghost.mode === GM_EATEN) {
                Sprites._drawGhostEyes(ctx, cx, cy, ghost.dir);
                return;
            }

            if (ghost.mode === GM_FRIGHTENED) {
                Sprites._drawFrightenedGhost(ctx, cx, cy, r, animFrame, frightTimer);
                return;
            }

            // Draw character-specific ghost
            switch (ghost.idx) {
                case 0: Sprites._drawBurns(ctx, cx, cy, r, ghost.dir, animFrame); break;
                case 1: Sprites._drawSideshowBob(ctx, cx, cy, r, ghost.dir, animFrame); break;
                case 2: Sprites._drawNelson(ctx, cx, cy, r, ghost.dir, animFrame); break;
                case 3: Sprites._drawSnake(ctx, cx, cy, r, ghost.dir, animFrame); break;
            }
        }

        // -- Mr. Burns --
        static _drawBurns(ctx, cx, cy, r, dir, frame) {
            const wave = frame % 20 < 10 ? 1 : -1;

            // Body (sickly yellow-green suit)
            ctx.fillStyle = '#9acd32';
            ctx.beginPath();
            ctx.arc(cx, cy - 2, r, Math.PI, 0);
            ctx.lineTo(cx + r, cy + r);
            for (let i = 3; i >= 0; i--) {
                ctx.lineTo(cx - r + (i * 2 * r / 3), cy + r + (i % 2 === 0 ? wave * 3 : -wave * 3));
            }
            ctx.closePath();
            ctx.fill();

            // Head (yellowish, bald)
            ctx.fillStyle = '#f5e6a0';
            ctx.beginPath();
            ctx.arc(cx, cy - 3, r * 0.85, Math.PI, 0);
            ctx.fill();

            // Hunched posture line
            ctx.strokeStyle = '#8fbc3f';
            ctx.lineWidth = 0.5;
            ctx.beginPath();
            ctx.arc(cx, cy - 1, r * 0.5, 0, Math.PI);
            ctx.stroke();

            // Eyes - droopy, menacing
            for (const ox of [-4, 4]) {
                ctx.fillStyle = '#fff';
                ctx.beginPath();
                ctx.ellipse(cx + ox, cy - 5, 3.5, 4, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = '#556b2f'; // Green pupils (Burns' evil eyes)
                ctx.beginPath();
                ctx.arc(cx + ox + DX[dir] * 1.5, cy - 5 + DY[dir] * 1.5, 1.8, 0, Math.PI * 2);
                ctx.fill();
            }

            // Menacing eyebrows (very pronounced)
            ctx.strokeStyle = '#666';
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(cx - 8, cy - 7);
            ctx.quadraticCurveTo(cx - 4, cy - 12, cx - 1, cy - 8);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(cx + 1, cy - 8);
            ctx.quadraticCurveTo(cx + 4, cy - 12, cx + 8, cy - 7);
            ctx.stroke();

            // Pointy nose
            ctx.fillStyle = '#f5e6a0';
            ctx.beginPath();
            ctx.moveTo(cx, cy - 3);
            ctx.lineTo(cx + 3, cy - 1);
            ctx.lineTo(cx, cy);
            ctx.closePath();
            ctx.fill();

            // Evil grin
            ctx.strokeStyle = '#333';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.arc(cx, cy + 1, 4, 0.1, Math.PI - 0.1);
            ctx.stroke();

            // "Excellent" fingers (steepled)
            ctx.strokeStyle = '#f5e6a0';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(cx - 3, cy + 5);
            ctx.lineTo(cx, cy + 2);
            ctx.lineTo(cx + 3, cy + 5);
            ctx.stroke();
        }

        // -- Sideshow Bob --
        static _drawSideshowBob(ctx, cx, cy, r, dir, frame) {
            const wave = frame % 20 < 10 ? 1 : -1;

            // Body (teal/green prison suit or his outfit)
            ctx.fillStyle = '#228b8b';
            ctx.beginPath();
            ctx.arc(cx, cy - 2, r, Math.PI, 0);
            ctx.lineTo(cx + r, cy + r);
            for (let i = 3; i >= 0; i--) {
                ctx.lineTo(cx - r + (i * 2 * r / 3), cy + r + (i % 2 === 0 ? wave * 3 : -wave * 3));
            }
            ctx.closePath();
            ctx.fill();

            // HUGE palm tree hair (Bob's most iconic feature)
            ctx.fillStyle = '#cc2200';
            // Main hair mass
            for (let i = -3; i <= 3; i++) {
                const hx = cx + i * 3;
                const spread = Math.abs(i) * 1.5;
                ctx.beginPath();
                ctx.ellipse(hx, cy - r - 5 - spread, 3, 7 + spread, i * 0.15, 0, Math.PI * 2);
                ctx.fill();
            }
            // Extra wild strands
            for (let i = -2; i <= 2; i++) {
                ctx.beginPath();
                ctx.ellipse(cx + i * 5, cy - r - 10, 2, 5, i * 0.3, 0, Math.PI * 2);
                ctx.fill();
            }

            // Face
            ctx.fillStyle = '#f5d0a0';
            ctx.beginPath();
            ctx.arc(cx, cy - 2, r * 0.75, Math.PI * 0.1, Math.PI * 0.9);
            ctx.fill();

            // Eyes
            for (const ox of [-4, 3]) {
                ctx.fillStyle = '#fff';
                ctx.beginPath();
                ctx.ellipse(cx + ox, cy - 4, 3, 4, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = '#2244aa';
                ctx.beginPath();
                ctx.arc(cx + ox + DX[dir] * 1.5, cy - 4 + DY[dir] * 1.5, 1.5, 0, Math.PI * 2);
                ctx.fill();
            }

            // Long nose
            ctx.fillStyle = '#f5d0a0';
            ctx.beginPath();
            ctx.moveTo(cx - 1, cy - 3);
            ctx.lineTo(cx + 4, cy);
            ctx.lineTo(cx - 1, cy + 1);
            ctx.closePath();
            ctx.fill();

            // Sinister smile
            ctx.strokeStyle = '#8b0000';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.arc(cx, cy + 2, 5, 0, Math.PI);
            ctx.stroke();

            // Big feet (Bob's huge feet!)
            ctx.fillStyle = '#ffd800';
            ctx.beginPath();
            ctx.ellipse(cx - 5, cy + r + 2, 5, 2.5, -0.2, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.ellipse(cx + 5, cy + r + 2, 5, 2.5, 0.2, 0, Math.PI * 2);
            ctx.fill();
        }

        // -- Nelson Muntz --
        static _drawNelson(ctx, cx, cy, r, dir, frame) {
            const wave = frame % 20 < 10 ? 1 : -1;

            // Body (pink/salmon shirt + blue vest)
            ctx.fillStyle = '#ff8c69'; // Salmon/orange shirt
            ctx.beginPath();
            ctx.arc(cx, cy - 2, r, Math.PI, 0);
            ctx.lineTo(cx + r, cy + r);
            for (let i = 3; i >= 0; i--) {
                ctx.lineTo(cx - r + (i * 2 * r / 3), cy + r + (i % 2 === 0 ? wave * 3 : -wave * 3));
            }
            ctx.closePath();
            ctx.fill();

            // Vest
            ctx.fillStyle = '#4169e1';
            ctx.beginPath();
            ctx.moveTo(cx - 4, cy - 1);
            ctx.lineTo(cx - 6, cy + r);
            ctx.lineTo(cx - 2, cy + r);
            ctx.lineTo(cx - 2, cy);
            ctx.closePath();
            ctx.fill();
            ctx.beginPath();
            ctx.moveTo(cx + 4, cy - 1);
            ctx.lineTo(cx + 6, cy + r);
            ctx.lineTo(cx + 2, cy + r);
            ctx.lineTo(cx + 2, cy);
            ctx.closePath();
            ctx.fill();

            // Head (yellow Simpson skin)
            ctx.fillStyle = COLORS.simpsonYellow;
            ctx.beginPath();
            ctx.arc(cx, cy - 3, r * 0.8, Math.PI * 0.15, Math.PI * 0.85);
            ctx.fill();

            // Buzz cut hair (flat top spiky)
            ctx.fillStyle = '#c8a800';
            ctx.fillRect(cx - 6, cy - r - 1, 12, 4);
            // Buzz spikes
            for (let i = -2; i <= 2; i++) {
                ctx.beginPath();
                ctx.moveTo(cx + i * 3 - 1, cy - r + 2);
                ctx.lineTo(cx + i * 3, cy - r - 2);
                ctx.lineTo(cx + i * 3 + 1, cy - r + 2);
                ctx.closePath();
                ctx.fill();
            }

            // Eyes (narrowed, tough look)
            for (const ox of [-4, 4]) {
                ctx.fillStyle = '#fff';
                ctx.beginPath();
                ctx.ellipse(cx + ox, cy - 4, 3, 2.5, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = '#000';
                ctx.beginPath();
                ctx.arc(cx + ox + DX[dir] * 1.5, cy - 4 + DY[dir] * 1, 1.5, 0, Math.PI * 2);
                ctx.fill();
            }

            // Angry eyebrows
            ctx.strokeStyle = '#8b7000';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(cx - 7, cy - 4);
            ctx.lineTo(cx - 2, cy - 6);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(cx + 2, cy - 6);
            ctx.lineTo(cx + 7, cy - 4);
            ctx.stroke();

            // Mean grin
            ctx.strokeStyle = '#333';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(cx - 4, cy + 1);
            ctx.lineTo(cx + 4, cy + 2);
            ctx.stroke();

            // "HA-HA!" text when chasing
            if (frame % 60 < 30) {
                ctx.fillStyle = '#ffd800';
                ctx.font = 'bold 7px Arial';
                ctx.textAlign = 'center';
                ctx.fillText('HA-HA!', cx, cy - r - 5);
            }
        }

        // -- Snake Jailbird --
        static _drawSnake(ctx, cx, cy, r, dir, frame) {
            const wave = frame % 20 < 10 ? 1 : -1;

            // Body (orange prison jumpsuit)
            ctx.fillStyle = '#ff6600';
            ctx.beginPath();
            ctx.arc(cx, cy - 2, r, Math.PI, 0);
            ctx.lineTo(cx + r, cy + r);
            for (let i = 3; i >= 0; i--) {
                ctx.lineTo(cx - r + (i * 2 * r / 3), cy + r + (i % 2 === 0 ? wave * 3 : -wave * 3));
            }
            ctx.closePath();
            ctx.fill();

            // Prison number
            ctx.fillStyle = '#fff';
            ctx.font = 'bold 5px Arial';
            ctx.textAlign = 'center';
            ctx.fillText('7F20', cx, cy + 6);

            // Head
            ctx.fillStyle = '#f5d0a0';
            ctx.beginPath();
            ctx.arc(cx, cy - 3, r * 0.75, Math.PI * 0.15, Math.PI * 0.85);
            ctx.fill();

            // Long flowing hair (Snake's mullet)
            ctx.fillStyle = '#333';
            // Main hair
            ctx.beginPath();
            ctx.ellipse(cx, cy - r + 1, r * 0.8, 4, 0, Math.PI, 0);
            ctx.fill();
            // Flowing back
            ctx.beginPath();
            ctx.moveTo(cx + r * 0.6, cy - r + 3);
            ctx.quadraticCurveTo(cx + r + 2, cy - 3, cx + r, cy + 3);
            ctx.quadraticCurveTo(cx + r - 2, cy + 2, cx + r * 0.5, cy - r + 5);
            ctx.fill();
            // Left side
            ctx.beginPath();
            ctx.moveTo(cx - r * 0.6, cy - r + 3);
            ctx.quadraticCurveTo(cx - r - 1, cy - 3, cx - r + 1, cy + 2);
            ctx.quadraticCurveTo(cx - r + 2, cy, cx - r * 0.5, cy - r + 5);
            ctx.fill();

            // Eyes
            for (const ox of [-4, 4]) {
                ctx.fillStyle = '#fff';
                ctx.beginPath();
                ctx.ellipse(cx + ox, cy - 4, 3, 3.5, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = '#333';
                ctx.beginPath();
                ctx.arc(cx + ox + DX[dir] * 1.5, cy - 4 + DY[dir] * 1.5, 1.5, 0, Math.PI * 2);
                ctx.fill();
            }

            // Goatee
            ctx.fillStyle = '#333';
            ctx.beginPath();
            ctx.ellipse(cx, cy + 3, 2, 3, 0, 0, Math.PI);
            ctx.fill();

            // Tattoo (small on arm area)
            ctx.strokeStyle = '#006600';
            ctx.lineWidth = 0.8;
            ctx.beginPath();
            ctx.moveTo(cx - 6, cy + 2);
            ctx.lineTo(cx - 8, cy);
            ctx.lineTo(cx - 6, cy - 1);
            ctx.stroke();
        }

        // -- Frightened Ghost (Simpsons-style scared face) --
        static _drawFrightenedGhost(ctx, cx, cy, r, frame, frightTimer) {
            const wave = frame % 20 < 10 ? 1 : -1;
            const flashing = frightTimer < FRIGHT_FLASH_TIME && frame % 16 < 8;
            const color = flashing ? '#ffffff' : '#5555ff';

            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.arc(cx, cy - 2, r, Math.PI, 0);
            ctx.lineTo(cx + r, cy + r);
            for (let i = 3; i >= 0; i--) {
                ctx.lineTo(cx - r + (i * 2 * r / 3), cy + r + (i % 2 === 0 ? wave * 3 : -wave * 3));
            }
            ctx.closePath();
            ctx.fill();

            // Scared face - swirly eyes (like Simpsons dizzy)
            const eyeColor = flashing ? '#555' : '#fff';
            ctx.strokeStyle = eyeColor;
            ctx.lineWidth = 1.2;
            for (const ox of [-4, 4]) {
                ctx.beginPath();
                ctx.arc(cx + ox, cy - 3, 3, 0, Math.PI * 1.5);
                ctx.stroke();
                // Dot center
                ctx.fillStyle = eyeColor;
                ctx.beginPath();
                ctx.arc(cx + ox, cy - 3, 1, 0, Math.PI * 2);
                ctx.fill();
            }

            // Wavy mouth (terrified)
            ctx.strokeStyle = eyeColor;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(cx - 6, cy + 3);
            for (let i = 0; i < 7; i++) {
                ctx.lineTo(cx - 6 + i * 2, cy + 3 + (i % 2 === 0 ? -2 : 2));
            }
            ctx.stroke();

            // Sweat drops
            if (frame % 30 < 15) {
                ctx.fillStyle = '#88ccff';
                ctx.beginPath();
                ctx.ellipse(cx + r - 1, cy - 1, 1, 2, 0.3, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        // -- Ghost eyes only (eaten state) --
        static _drawGhostEyes(ctx, cx, cy, dir) {
            for (const ox of [-4, 4]) {
                ctx.fillStyle = '#fff';
                ctx.beginPath();
                ctx.ellipse(cx + ox, cy - 3, 4, 5, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = '#2244cc';
                ctx.beginPath();
                ctx.arc(cx + ox + DX[dir] * 2, cy - 3 + DY[dir] * 2, 2, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        // ---- BONUS FRUIT (Springfield items by level) ----
        static drawBonusItem(ctx, x, y, level, frame) {
            switch ((level - 1) % 5) {
                case 0: // Krusty Burger
                    ctx.fillStyle = '#daa520';
                    ctx.beginPath();
                    ctx.arc(x, y, 6, Math.PI, 0);
                    ctx.fill();
                    ctx.fillStyle = '#8b4513';
                    ctx.fillRect(x - 5, y - 1, 10, 2);  // patty
                    ctx.fillStyle = '#228b22';
                    ctx.fillRect(x - 5, y + 1, 10, 1);  // lettuce
                    ctx.fillStyle = '#daa520';
                    ctx.beginPath();
                    ctx.arc(x, y + 2, 6, 0, Math.PI);
                    ctx.fill();
                    break;
                case 1: // Squishee
                    ctx.fillStyle = '#00bfff';
                    ctx.beginPath();
                    ctx.moveTo(x - 4, y - 6);
                    ctx.lineTo(x + 4, y - 6);
                    ctx.lineTo(x + 3, y + 4);
                    ctx.lineTo(x - 3, y + 4);
                    ctx.closePath();
                    ctx.fill();
                    // Straw
                    ctx.strokeStyle = '#ff0000';
                    ctx.lineWidth = 1;
                    ctx.beginPath();
                    ctx.moveTo(x + 1, y - 6);
                    ctx.lineTo(x + 3, y - 10);
                    ctx.stroke();
                    break;
                case 2: // Buzz Cola
                    ctx.fillStyle = '#8b0000';
                    ctx.beginPath();
                    ctx.roundRect(x - 3, y - 6, 6, 12, 2);
                    ctx.fill();
                    ctx.fillStyle = '#fff';
                    ctx.font = 'bold 4px Arial';
                    ctx.textAlign = 'center';
                    ctx.fillText('BC', x, y + 1);
                    break;
                case 3: // Radioactive donut
                    ctx.fillStyle = '#00ff00';
                    ctx.beginPath();
                    ctx.arc(x, y, 6, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.fillStyle = '#000';
                    ctx.beginPath();
                    ctx.arc(x, y, 2, 0, Math.PI * 2);
                    ctx.fill();
                    // Glow
                    ctx.strokeStyle = `rgba(0, 255, 0, ${0.3 + Math.sin(frame * 0.1) * 0.2})`;
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.arc(x, y, 8, 0, Math.PI * 2);
                    ctx.stroke();
                    break;
                case 4: // Saxophone (Lisa's)
                    ctx.strokeStyle = '#daa520';
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.moveTo(x, y - 7);
                    ctx.quadraticCurveTo(x + 5, y, x + 3, y + 5);
                    ctx.quadraticCurveTo(x, y + 8, x - 2, y + 6);
                    ctx.stroke();
                    ctx.fillStyle = '#daa520';
                    ctx.beginPath();
                    ctx.arc(x - 2, y + 6, 2, 0, Math.PI * 2);
                    ctx.fill();
                    break;
            }
        }
    }

    // ==================== GAME ====================
    class Game {
        constructor() {
            this.canvas = document.getElementById('gameCanvas');
            this.canvas.width = CANVAS_W;
            this.canvas.height = CANVAS_H;
            this.ctx = this.canvas.getContext('2d');
            this.sound = new SoundManager();

            this.scoreEl = document.getElementById('scoreDisplay');
            this.levelEl = document.getElementById('levelDisplay');
            this.livesIconsEl = document.getElementById('livesIcons');
            this.msgEl = document.getElementById('message');

            this.keys = {};
            this.state = ST_START;
            this.score = 0;
            this.lives = 3;
            this.level = 1;
            this.ghostsEaten = 0;
            this.extraLifeGiven = false;
            this.animFrame = 0;
            this.stateTimer = 0;
            this.floatingTexts = [];
            this.particles = [];

            // Pre-render some decorations
            this.cloudOffset = 0;

            this.maze = MAZE_TEMPLATE.map(row => [...row]);

            this.setupInput();
            this.showStartScreen();
            this.updateHUD();
            this.loop();
        }

        // ---- INPUT ----
        setupInput() {
            document.addEventListener('keydown', (e) => {
                this.keys[e.code] = true;
                this.sound.resume();

                if (this.state === ST_START && (e.code === 'Enter' || e.code === 'Space')) {
                    e.preventDefault();
                    this.startNewGame();
                } else if (this.state === ST_GAME_OVER && (e.code === 'Enter' || e.code === 'Space')) {
                    e.preventDefault();
                    this.state = ST_START;
                    this.maze = MAZE_TEMPLATE.map(row => [...row]);
                    this.showStartScreen();
                } else if (this.state === ST_PLAYING && e.code === 'KeyP') {
                    this.state = ST_PAUSED;
                    this.sound.stopMusic();
                    this.showMessage('PAUSA', '¡Ay, caramba!<br>Press P to continue');
                } else if (this.state === ST_PAUSED && e.code === 'KeyP') {
                    this.state = ST_PLAYING;
                    this.sound.startMusic();
                    this.hideMessage();
                } else if (e.code === 'KeyM') {
                    const muted = this.sound.toggleMute();
                    if (muted !== undefined) {
                        this.addFloatingText(CANVAS_W / 2, 40, muted ? '🔇 MUTED' : '🔊 MUSIC ON', '#ffd800');
                    }
                }

                if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Space'].includes(e.code)) {
                    e.preventDefault();
                }
            });
            document.addEventListener('keyup', (e) => {
                this.keys[e.code] = false;
            });
        }

        // ---- SCREENS ----
        showStartScreen() {
            this.msgEl.innerHTML = `
                <div class="title-large">&#127849; Come Rosquillas!</div>
                <div class="catchphrase">"Mmm... donuts"</div>
                <div class="subtitle">
                    Homer's Donut Quest through Springfield<br><br>
                    &#127850; Eat all the donuts<br>
                    &#127866; Grab a Duff to chase the bad guys<br>
                    &#128123; Beware of Sr. Burns, Bob Patiño, Nelson & Snake!<br><br>
                    P = Pause &nbsp; M = Mute music<br><br>
                    Press ENTER or SPACE to start
                </div>`;
            this.msgEl.style.display = 'block';
        }

        showMessage(title, subtitle) {
            this.msgEl.innerHTML = `<div class="title-large">${title}</div>${subtitle ? `<div class="subtitle">${subtitle}</div>` : ''}`;
            this.msgEl.style.display = 'block';
        }
        hideMessage() {
            this.msgEl.style.display = 'none';
        }

        // ---- GAME INIT ----
        startNewGame() {
            this.score = 0;
            this.lives = 3;
            this.level = 1;
            this.extraLifeGiven = false;
            this.floatingTexts = [];
            this.particles = [];
            this.initLevel();
            this.state = ST_READY;
            this.stateTimer = 150;
            this.sound.play('start');
            this.showMessage('&#127849; READY!', `Springfield - Level ${this.level}`);
            this.updateHUD();
        }

        initLevel() {
            this.maze = MAZE_TEMPLATE.map(row => [...row]);
            this.totalDots = 0;
            this.dotsEaten = 0;
            for (let r = 0; r < ROWS; r++) {
                for (let c = 0; c < COLS; c++) {
                    if (this.maze[r][c] === DOT || this.maze[r][c] === POWER) this.totalDots++;
                }
            }
            this.initEntities();
            this.modeIndex = 0;
            this.modeTimer = MODE_TIMERS[0];
            this.globalMode = GM_SCATTER;
            this.frightTimer = 0;
            this.bonusActive = false;
            this.bonusTimer = 0;
            this.bonusPos = null;
        }

        initEntities() {
            this.homer = {
                x: HOMER_START.x * TILE,
                y: HOMER_START.y * TILE,
                dir: LEFT,
                nextDir: LEFT,
                mouthAngle: 0,
                mouthOpen: true,
                speed: this.getSpeed('homer')
            };
            this.ghosts = GHOST_CFG.map((cfg, i) => ({
                x: cfg.startX * TILE,
                y: cfg.startY * TILE,
                dir: UP,
                mode: GM_SCATTER,
                color: cfg.color,
                name: cfg.name,
                scatterX: cfg.scatterX,
                scatterY: cfg.scatterY,
                homeX: cfg.homeX * TILE,
                homeY: cfg.homeY * TILE,
                speed: this.getSpeed('ghost'),
                inHouse: i > 0,
                exitTimer: cfg.exitDelay,
                idx: i,
                _lastDecisionTile: -1
            }));
        }

        getSpeed(type) {
            const lvl = this.level;
            if (type === 'homer') return BASE_SPEED * (1 + (lvl - 1) * 0.05);
            if (type === 'ghost') return BASE_SPEED * (0.9 + (lvl - 1) * 0.05);
            if (type === 'frightGhost') return BASE_SPEED * 0.5;
            if (type === 'eatenGhost') return BASE_SPEED * 2;
            return BASE_SPEED;
        }

        // ---- MAZE HELPERS ----
        isWalkable(col, row, isGhost) {
            if (col < 0 || col >= COLS) return row === 14;
            if (row < 0 || row >= ROWS) return false;
            const cell = this.maze[row][col];
            if (cell === WALL) return false;
            if (cell === GHOST_DOOR || cell === GHOST_HOUSE) return !!isGhost;
            return true;
        }

        tileAt(px, py) {
            return { col: Math.floor(px / TILE), row: Math.floor(py / TILE) };
        }

        centerOfTile(col, row) {
            return { x: col * TILE + TILE / 2, y: row * TILE + TILE / 2 };
        }

        // ---- FLOATING TEXT & PARTICLES ----
        addFloatingText(x, y, text, color) {
            this.floatingTexts.push({ x, y, text, color, life: 60, startY: y });
        }

        addParticles(x, y, color, count) {
            for (let i = 0; i < count; i++) {
                this.particles.push({
                    x, y,
                    vx: (Math.random() - 0.5) * 3,
                    vy: (Math.random() - 0.5) * 3,
                    life: 30 + Math.random() * 20,
                    color, size: 1 + Math.random() * 2
                });
            }
        }

        // ---- UPDATE ----
        update() {
            this.animFrame++;
            this.cloudOffset += 0.3;

            // Update floating texts
            this.floatingTexts = this.floatingTexts.filter(t => {
                t.life--;
                t.y -= 0.8;
                return t.life > 0;
            });

            // Update particles
            this.particles = this.particles.filter(p => {
                p.life--;
                p.x += p.vx;
                p.y += p.vy;
                p.vy += 0.05;
                return p.life > 0;
            });

            if (this.state === ST_READY) {
                this.stateTimer--;
                if (this.stateTimer <= 0) {
                    this.state = ST_PLAYING;
                    this.sound.startMusic();
                    this.hideMessage();
                }
                return;
            }

            if (this.state === ST_DYING) {
                this.stateTimer--;
                if (this.stateTimer <= 0) {
                    this.lives--;
                    this.updateHUD();
                    if (this.lives <= 0) {
                        this.state = ST_GAME_OVER;
                        const quote = GAME_OVER_QUOTES[Math.floor(Math.random() * GAME_OVER_QUOTES.length)];
                        this.showMessage("D'OH!", `Game Over!<br>Score: ${this.score}<br><br>"${quote}"<br><br>Press ENTER to try again`);
                    } else {
                        this.initEntities();
                        this.state = ST_READY;
                        this.stateTimer = 120;
                        const quote = HOMER_DEATH_QUOTES[Math.floor(Math.random() * HOMER_DEATH_QUOTES.length)];
                        this.showMessage(quote, `Lives: ${this.lives}`);
                    }
                }
                return;
            }

            if (this.state === ST_LEVEL_DONE) {
                this.stateTimer--;
                if (this.stateTimer <= 0) {
                    this.level++;
                    this.initLevel();
                    this.state = ST_READY;
                    this.stateTimer = 150;
                    this.showMessage(`Springfield - Level ${this.level}`, HOMER_WIN_QUOTES[Math.floor(Math.random() * HOMER_WIN_QUOTES.length)]);
                    this.updateHUD();
                }
                return;
            }

            if (this.state !== ST_PLAYING) return;

            this.updateGhostMode();
            this.moveHomer();
            this.checkDots();
            this.updateBonus();
            for (const ghost of this.ghosts) this.moveGhost(ghost);
            this.checkCollisions();

            // Mouth animation
            if (this.animFrame % 4 === 0) {
                this.homer.mouthAngle += this.homer.mouthOpen ? 0.15 : -0.15;
                if (this.homer.mouthAngle >= 0.6) this.homer.mouthOpen = false;
                if (this.homer.mouthAngle <= 0) this.homer.mouthOpen = true;
            }
        }

        updateGhostMode() {
            if (this.frightTimer > 0) {
                this.frightTimer--;
                if (this.frightTimer <= 0) {
                    for (const g of this.ghosts) {
                        if (g.mode === GM_FRIGHTENED) {
                            g.mode = this.globalMode;
                            g.speed = this.getSpeed('ghost');
                            g._lastDecisionTile = -1;
                        }
                    }
                    this.ghostsEaten = 0;
                }
                return;
            }
            if (this.modeIndex < MODE_TIMERS.length) {
                this.modeTimer--;
                if (this.modeTimer <= 0) {
                    this.modeIndex++;
                    if (this.modeIndex < MODE_TIMERS.length) {
                        this.modeTimer = MODE_TIMERS[this.modeIndex];
                        this.globalMode = this.modeIndex % 2 === 0 ? GM_SCATTER : GM_CHASE;
                        for (const g of this.ghosts) {
                            if (g.mode !== GM_FRIGHTENED && g.mode !== GM_EATEN) {
                                g.dir = OPP[g.dir];
                                g.mode = this.globalMode;
                                g._lastDecisionTile = -1;
                            }
                        }
                    }
                }
            }
        }

        moveHomer() {
            const h = this.homer;
            if (this.keys['ArrowUp']) h.nextDir = UP;
            else if (this.keys['ArrowRight']) h.nextDir = RIGHT;
            else if (this.keys['ArrowDown']) h.nextDir = DOWN;
            else if (this.keys['ArrowLeft']) h.nextDir = LEFT;

            const cx = h.x + TILE / 2;
            const cy = h.y + TILE / 2;
            const tile = this.tileAt(cx, cy);
            const center = this.centerOfTile(tile.col, tile.row);
            const distToCenter = Math.abs(cx - center.x) + Math.abs(cy - center.y);

            if (distToCenter < h.speed + 1) {
                const nextCol = tile.col + DX[h.nextDir];
                const nextRow = tile.row + DY[h.nextDir];
                if (this.isWalkable(nextCol, nextRow, false)) {
                    h.dir = h.nextDir;
                    if (h.dir === UP || h.dir === DOWN) h.x = center.x - TILE / 2;
                    else h.y = center.y - TILE / 2;
                }
            }

            const aheadCol = tile.col + DX[h.dir];
            const aheadRow = tile.row + DY[h.dir];
            const canMove = this.isWalkable(aheadCol, aheadRow, false) || distToCenter > h.speed + 1;

            if (canMove) {
                h.x += DX[h.dir] * h.speed;
                h.y += DY[h.dir] * h.speed;
            } else {
                h.x = center.x - TILE / 2;
                h.y = center.y - TILE / 2;
            }

            if (h.x < -TILE) h.x = COLS * TILE;
            if (h.x > COLS * TILE) h.x = -TILE;
        }

        checkDots() {
            const cx = this.homer.x + TILE / 2;
            const cy = this.homer.y + TILE / 2;
            const tile = this.tileAt(cx, cy);
            if (tile.col < 0 || tile.col >= COLS || tile.row < 0 || tile.row >= ROWS) return;

            const cell = this.maze[tile.row][tile.col];
            if (cell === DOT) {
                this.maze[tile.row][tile.col] = EMPTY;
                this.score += 10;
                this.dotsEaten++;
                if (this.animFrame % 2 === 0) this.sound.play('chomp');
                this.addParticles(cx, cy, COLORS.donutPink, 3);
                this.checkExtraLife();
                this.updateHUD();
                // Spawn bonus at 70 and 170 dots
                if (this.dotsEaten === 70 || this.dotsEaten === 170) this.spawnBonus();
            } else if (cell === POWER) {
                this.maze[tile.row][tile.col] = EMPTY;
                this.score += 50;
                this.dotsEaten++;
                this.ghostsEaten = 0;
                this.frightTimer = FRIGHT_TIME;
                this.sound.play('power');
                const quote = HOMER_POWER_QUOTES[Math.floor(Math.random() * HOMER_POWER_QUOTES.length)];
                this.addFloatingText(cx, cy - 10, quote, COLORS.duffGold);
                this.addParticles(cx, cy, COLORS.duffGold, 8);
                for (const g of this.ghosts) {
                    if (g.mode !== GM_EATEN) {
                        g.mode = GM_FRIGHTENED;
                        g.dir = OPP[g.dir];
                        g.speed = this.getSpeed('frightGhost');
                        g._lastDecisionTile = -1;
                    }
                }
                this.checkExtraLife();
                this.updateHUD();
            }

            if (this.dotsEaten >= this.totalDots) {
                this.state = ST_LEVEL_DONE;
                this.stateTimer = 150;
                this.sound.stopMusic();
                this.sound.play('levelComplete');
                const quote = HOMER_WIN_QUOTES[Math.floor(Math.random() * HOMER_WIN_QUOTES.length)];
                this.showMessage('WOOHOO!', `${quote}<br>Level ${this.level} Complete!`);
            }
        }

        spawnBonus() {
            this.bonusActive = true;
            this.bonusTimer = 600; // 10 seconds
            this.bonusPos = { x: 14 * TILE, y: 17 * TILE };
        }

        updateBonus() {
            if (this.bonusActive) {
                this.bonusTimer--;
                if (this.bonusTimer <= 0) {
                    this.bonusActive = false;
                    return;
                }
                const dx = (this.homer.x + TILE / 2) - (this.bonusPos.x + TILE / 2);
                const dy = (this.homer.y + TILE / 2) - (this.bonusPos.y + TILE / 2);
                if (Math.sqrt(dx * dx + dy * dy) < TILE * 0.8) {
                    const points = [100, 300, 500, 700, 1000][(this.level - 1) % 5];
                    this.score += points;
                    this.addFloatingText(this.bonusPos.x + TILE / 2, this.bonusPos.y, `${points}`, '#00ff00');
                    this.addParticles(this.bonusPos.x + TILE / 2, this.bonusPos.y + TILE / 2, '#ffd700', 10);
                    this.bonusActive = false;
                    this.updateHUD();
                }
            }
        }

        checkExtraLife() {
            if (!this.extraLifeGiven && this.score >= 10000) {
                this.extraLifeGiven = true;
                this.lives++;
                this.sound.play('extraLife');
                this.addFloatingText(this.homer.x + TILE / 2, this.homer.y - 10, 'EXTRA LIFE!', '#00ff00');
                this.updateHUD();
            }
        }

        // ---- GHOST AI ----
        moveGhost(g) {
            if (g.inHouse) {
                g.exitTimer--;
                if (g.exitTimer <= 0) {
                    const doorX = 14 * TILE;
                    const doorY = 11 * TILE;
                    const dx = doorX - g.x;
                    const dy = doorY - g.y;
                    const dist = Math.sqrt(dx * dx + dy * dy);
                    if (dist < g.speed + 2) {
                        g.x = doorX; g.y = doorY;
                        g.inHouse = false; g.dir = LEFT;
                    } else {
                        g.x += (dx / dist) * g.speed;
                        g.y += (dy / dist) * g.speed;
                    }
                }
                return;
            }

            const cx = g.x + TILE / 2;
            const cy = g.y + TILE / 2;
            const tile = this.tileAt(cx, cy);
            const tileKey = tile.col + tile.row * COLS;
            const center = this.centerOfTile(tile.col, tile.row);
            const distToCenter = Math.abs(cx - center.x) + Math.abs(cy - center.y);

            // Only make a direction decision once per tile
            if (tileKey !== g._lastDecisionTile && distToCenter < g.speed + 1) {
                g._lastDecisionTile = tileKey;
                // Snap to tile center
                g.x = center.x - TILE / 2;
                g.y = center.y - TILE / 2;

                let target;
                if (g.mode === GM_EATEN) {
                    target = { x: 14, y: 12 };
                    if (Math.abs(tile.col - target.x) + Math.abs(tile.row - target.y) <= 1) {
                        g.mode = this.frightTimer > 0 ? GM_FRIGHTENED : this.globalMode;
                        g.speed = g.mode === GM_FRIGHTENED ? this.getSpeed('frightGhost') : this.getSpeed('ghost');
                        g.inHouse = true;
                        g.exitTimer = 0;
                        g.x = 14 * TILE;
                        g.y = 14 * TILE;
                        g._lastDecisionTile = -1;
                        return;
                    }
                } else if (g.mode === GM_FRIGHTENED) {
                    target = null;
                } else if (g.mode === GM_SCATTER) {
                    target = { x: g.scatterX, y: g.scatterY };
                } else {
                    target = this.getChaseTarget(g);
                }

                const possible = [];
                for (let d = 0; d < 4; d++) {
                    if (d === OPP[g.dir]) continue;
                    const nc = tile.col + DX[d];
                    const nr = tile.row + DY[d];
                    if (this.isWalkable(nc, nr, g.mode === GM_EATEN)) {
                        possible.push(d);
                    }
                }

                if (possible.length === 0) {
                    g.dir = OPP[g.dir];
                } else if (possible.length === 1) {
                    g.dir = possible[0];
                } else if (g.mode === GM_FRIGHTENED) {
                    g.dir = possible[Math.floor(Math.random() * possible.length)];
                } else if (target) {
                    let bestDist = Infinity, bestDir = possible[0];
                    for (const d of possible) {
                        const nc = tile.col + DX[d];
                        const nr = tile.row + DY[d];
                        const dist = (nc - target.x) ** 2 + (nr - target.y) ** 2;
                        if (dist < bestDist) { bestDist = dist; bestDir = d; }
                    }
                    g.dir = bestDir;
                } else {
                    g.dir = possible[0];
                }
            }

            g.x += DX[g.dir] * g.speed;
            g.y += DY[g.dir] * g.speed;
            if (g.x < -TILE) g.x = COLS * TILE;
            if (g.x > COLS * TILE) g.x = -TILE;
        }

        getChaseTarget(g) {
            const hTile = this.tileAt(this.homer.x + TILE / 2, this.homer.y + TILE / 2);
            switch (g.idx) {
                case 0: return { x: hTile.col, y: hTile.row };
                case 1: return { x: hTile.col + DX[this.homer.dir] * 4, y: hTile.row + DY[this.homer.dir] * 4 };
                case 2: {
                    const ahead = { x: hTile.col + DX[this.homer.dir] * 2, y: hTile.row + DY[this.homer.dir] * 2 };
                    const blinky = this.tileAt(this.ghosts[0].x + TILE / 2, this.ghosts[0].y + TILE / 2);
                    return { x: ahead.x + (ahead.x - blinky.col), y: ahead.y + (ahead.y - blinky.row) };
                }
                case 3: {
                    const dist = Math.abs(g.x / TILE - hTile.col) + Math.abs(g.y / TILE - hTile.row);
                    return dist > 8 ? { x: hTile.col, y: hTile.row } : { x: g.scatterX, y: g.scatterY };
                }
                default: return { x: hTile.col, y: hTile.row };
            }
        }

        checkCollisions() {
            for (const g of this.ghosts) {
                if (g.inHouse) continue;
                const dx = (this.homer.x + TILE / 2) - (g.x + TILE / 2);
                const dy = (this.homer.y + TILE / 2) - (g.y + TILE / 2);
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < TILE * 0.8) {
                    if (g.mode === GM_FRIGHTENED) {
                        g.mode = GM_EATEN;
                        g.speed = this.getSpeed('eatenGhost');
                        this.ghostsEaten++;
                        const pts = 200 * Math.pow(2, this.ghostsEaten - 1);
                        this.score += pts;
                        this.sound.play('eatGhost');
                        this.addFloatingText(g.x + TILE / 2, g.y, `${pts}`, '#00ffff');
                        this.addParticles(g.x + TILE / 2, g.y + TILE / 2, g.color, 6);
                        this.updateHUD();
                    } else if (g.mode !== GM_EATEN) {
                        this.state = ST_DYING;
                        this.stateTimer = 90;
                        this.sound.stopMusic();
                        this.sound.play('die');
                        return;
                    }
                }
            }
        }

        updateHUD() {
            this.scoreEl.textContent = this.score;
            this.levelEl.textContent = this.level;
            // Render donut icons for lives
            let html = '';
            for (let i = 0; i < this.lives; i++) {
                html += '<span class="donut-icon"></span> ';
            }
            this.livesIconsEl.innerHTML = html;
        }

        // ==================== RENDERING ====================
        draw() {
            const ctx = this.ctx;
            ctx.fillStyle = COLORS.pathDark;
            ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

            // Subtle starfield background for non-wall cells
            if (!this._stars) {
                this._stars = [];
                for (let i = 0; i < 50; i++) {
                    this._stars.push({ x: Math.random() * CANVAS_W, y: Math.random() * CANVAS_H, s: 0.5 + Math.random() * 1.5 });
                }
            }
            ctx.fillStyle = 'rgba(255,255,255,0.15)';
            for (const star of this._stars) {
                const twinkle = 0.5 + Math.sin(this.animFrame * 0.03 + star.x) * 0.5;
                ctx.globalAlpha = twinkle * 0.3;
                ctx.beginPath();
                ctx.arc(star.x, star.y, star.s, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;

            this.drawMaze(ctx);
            this.drawDots(ctx);

            // Bonus item
            if (this.bonusActive && this.bonusPos) {
                Sprites.drawBonusItem(ctx, this.bonusPos.x + TILE / 2, this.bonusPos.y + TILE / 2, this.level, this.animFrame);
            }

            // Homer
            if (this.state === ST_DYING) {
                Sprites.drawHomerDying(ctx, this.homer.x, this.homer.y, 1 - this.stateTimer / 90, TILE);
            } else if (this.state !== ST_GAME_OVER && this.state !== ST_START) {
                // Shadow under Homer
                ctx.fillStyle = 'rgba(0,0,0,0.3)';
                ctx.beginPath();
                ctx.ellipse(this.homer.x + TILE / 2, this.homer.y + TILE - 2, TILE / 3, 3, 0, 0, Math.PI * 2);
                ctx.fill();
                Sprites.drawHomer(ctx, this.homer.x, this.homer.y, this.homer.dir, this.homer.mouthAngle, TILE);
            }

            // Ghosts
            if (this.state === ST_PLAYING || this.state === ST_READY) {
                for (const g of this.ghosts) {
                    // Ghost shadow
                    ctx.fillStyle = 'rgba(0,0,0,0.25)';
                    ctx.beginPath();
                    ctx.ellipse(g.x + TILE / 2, g.y + TILE - 1, TILE / 3, 2.5, 0, 0, Math.PI * 2);
                    ctx.fill();
                    // Ghost glow (subtle color aura)
                    if (g.mode !== GM_EATEN) {
                        const glowColor = g.mode === GM_FRIGHTENED ? 'rgba(80,80,255,0.15)' :
                            `rgba(${parseInt(g.color.slice(1,3),16)},${parseInt(g.color.slice(3,5),16)},${parseInt(g.color.slice(5,7),16)},0.15)`;
                        ctx.fillStyle = glowColor;
                        ctx.beginPath();
                        ctx.arc(g.x + TILE / 2, g.y + TILE / 2, TILE * 0.7, 0, Math.PI * 2);
                        ctx.fill();
                    }
                    Sprites.drawGhost(ctx, g, this.animFrame, this.frightTimer);
                }
            }

            // Floating texts
            for (const t of this.floatingTexts) {
                const alpha = t.life / 60;
                const scale = 1 + (1 - alpha) * 0.3;
                ctx.save();
                ctx.globalAlpha = alpha;
                ctx.translate(t.x, t.y);
                ctx.scale(scale, scale);
                // Text shadow
                ctx.fillStyle = '#000';
                ctx.font = 'bold 12px "Bangers", Arial';
                ctx.textAlign = 'center';
                ctx.fillText(t.text, 1, 1);
                // Main text
                ctx.fillStyle = t.color;
                ctx.fillText(t.text, 0, 0);
                ctx.restore();
            }

            // Particles
            for (const p of this.particles) {
                ctx.globalAlpha = p.life / 50;
                ctx.fillStyle = p.color;
                ctx.fillRect(p.x, p.y, p.size, p.size);
            }
            ctx.globalAlpha = 1;

            // Lives mini-Homers at bottom
            for (let i = 0; i < this.lives - 1; i++) {
                Sprites.drawMiniHomer(ctx, 20 + i * 28, CANVAS_H - 16);
            }

            // Ghost names display (bottom right)
            if (this.state === ST_START || this.state === ST_READY) {
                this.drawGhostLegend(ctx);
            }
        }

        drawMaze(ctx) {
            const flash = this.state === ST_LEVEL_DONE && this.stateTimer % 20 < 10;

            for (let r = 0; r < ROWS; r++) {
                for (let c = 0; c < COLS; c++) {
                    const cell = MAZE_TEMPLATE[r][c];
                    if (cell === WALL) {
                        const wallColor1 = flash ? '#ffd800' : COLORS.wallBlue;
                        const wallColor2 = flash ? '#b8a000' : COLORS.wallBlueDark;
                        const borderColor = flash ? '#ffd800' : COLORS.wallBorder;
                        const highlightColor = flash ? '#ffe866' : COLORS.wallBlueLight;

                        // Main wall fill
                        ctx.fillStyle = wallColor1;
                        ctx.fillRect(c * TILE, r * TILE, TILE, TILE);
                        // Inner darker area with slight gradient feel
                        ctx.fillStyle = wallColor2;
                        ctx.fillRect(c * TILE + 2, r * TILE + 2, TILE - 4, TILE - 4);
                        // Top-left highlight for 3D bevel effect
                        ctx.fillStyle = highlightColor;
                        ctx.globalAlpha = 0.15;
                        ctx.fillRect(c * TILE, r * TILE, TILE, 2);
                        ctx.fillRect(c * TILE, r * TILE, 2, TILE);
                        ctx.globalAlpha = 1;

                        // Border lines on exposed edges
                        ctx.strokeStyle = borderColor;
                        ctx.lineWidth = 1;
                        const top = r > 0 && MAZE_TEMPLATE[r - 1][c] !== WALL;
                        const bot = r < ROWS - 1 && MAZE_TEMPLATE[r + 1][c] !== WALL;
                        const lft = c > 0 && MAZE_TEMPLATE[r][c - 1] !== WALL;
                        const rgt = c < COLS - 1 && MAZE_TEMPLATE[r][c + 1] !== WALL;

                        if (top) { ctx.beginPath(); ctx.moveTo(c * TILE, r * TILE + 1); ctx.lineTo((c + 1) * TILE, r * TILE + 1); ctx.stroke(); }
                        if (bot) { ctx.beginPath(); ctx.moveTo(c * TILE, (r + 1) * TILE - 1); ctx.lineTo((c + 1) * TILE, (r + 1) * TILE - 1); ctx.stroke(); }
                        if (lft) { ctx.beginPath(); ctx.moveTo(c * TILE + 1, r * TILE); ctx.lineTo(c * TILE + 1, (r + 1) * TILE); ctx.stroke(); }
                        if (rgt) { ctx.beginPath(); ctx.moveTo((c + 1) * TILE - 1, r * TILE); ctx.lineTo((c + 1) * TILE - 1, (r + 1) * TILE); ctx.stroke(); }

                    } else if (cell === GHOST_DOOR) {
                        // Nuclear Plant entrance door (animated green glow)
                        const glowIntensity = 0.5 + Math.sin(this.animFrame * 0.06) * 0.3;
                        ctx.fillStyle = `rgba(68, 255, 68, ${glowIntensity})`;
                        ctx.shadowColor = '#00ff00';
                        ctx.shadowBlur = 6 + Math.sin(this.animFrame * 0.06) * 3;
                        ctx.fillRect(c * TILE, r * TILE + TILE / 2 - 2, TILE, 4);
                        ctx.shadowBlur = 0;
                    }
                }
            }

            // Ghost house label - "Planta Nuclear" sign with glow
            const signGlow = 0.25 + Math.sin(this.animFrame * 0.04) * 0.1;
            ctx.fillStyle = `rgba(0, 255, 0, ${signGlow})`;
            ctx.font = 'bold 7px Arial';
            ctx.textAlign = 'center';
            ctx.fillText('☢ Planta Nuclear', 14 * TILE, 13 * TILE - 2);
        }

        drawDots(ctx) {
            for (let r = 0; r < ROWS; r++) {
                for (let c = 0; c < COLS; c++) {
                    const cell = this.maze[r][c];
                    const cx = c * TILE + TILE / 2;
                    const cy = r * TILE + TILE / 2;

                    if (cell === DOT) {
                        Sprites.drawDonut(ctx, cx, cy, this.animFrame);
                    } else if (cell === POWER) {
                        Sprites.drawDuff(ctx, cx, cy, this.animFrame);
                    }
                }
            }
        }

        drawGhostLegend(ctx) {
            const x = CANVAS_W - 120;
            const y = CANVAS_H - 70;
            ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            ctx.fillRect(x - 5, y - 12, 120, 65);
            ctx.font = 'bold 9px Arial';
            ctx.textAlign = 'left';
            GHOST_CFG.forEach((ghost, i) => {
                ctx.fillStyle = ghost.color;
                ctx.fillRect(x, y + i * 14, 8, 8);
                ctx.fillStyle = '#fff';
                ctx.fillText(ghost.name, x + 12, y + i * 14 + 7);
            });
        }

        // ==================== GAME LOOP ====================
        loop() {
            this.update();
            this.draw();
            requestAnimationFrame(() => this.loop());
        }
    }

    // ==================== START ====================
    window.addEventListener('load', () => { new Game(); });
})();
