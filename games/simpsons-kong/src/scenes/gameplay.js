import { Player } from '../entities/player.js';
import { Enemy } from '../entities/enemy.js';
import { Combat } from '../systems/combat.js';
import { AI } from '../systems/ai.js';
import { VFX } from '../systems/vfx.js';
import { Camera } from '../systems/camera.js';
import { WaveManager } from '../systems/wave-manager.js';
import { Background } from '../systems/background.js';
import { HUD } from '../ui/hud.js';
import { DebugOverlay } from '../debug/debug-overlay.js';
import { saveHighScore, getHighScore, isNewHighScore } from '../ui/highscore.js';
import { Music } from '../engine/music.js';
import { ParticleSystem, DUST_CLOUD, HIT_SPARKS, DEATH_DEBRIS } from '../engine/particles.js';
import { Destructible } from '../entities/destructible.js';
import { Hazard } from '../entities/hazard.js';
import { LEVEL_1 } from '../data/levels.js';

const WAVE_DATA = [
    { x: 800, enemies: [
        { x: 1000, y: 500, variant: 'normal' },
        { x: 1100, y: 470, variant: 'normal' }
    ]},
    { x: 1600, enemies: [
        { x: 1800, y: 480, variant: 'normal' },
        { x: 1850, y: 530, variant: 'normal' },
        { x: 1400, y: 500, variant: 'normal' },
        { x: 1900, y: 460, variant: 'fast' }
    ]},
    { x: 2800, enemies: [
        { x: 3000, y: 500, variant: 'normal' },
        { x: 3050, y: 460, variant: 'normal' },
        { x: 2600, y: 480, variant: 'normal' },
        { x: 3100, y: 520, variant: 'fast' },
        { x: 3150, y: 450, variant: 'fast' },
        { x: 3200, y: 500, variant: 'heavy' }
    ]},
    { x: 3500, enemies: [
        { x: 3800, y: 500, variant: 'boss' }
    ]}
];

export class GameplayScene {
    constructor(game, renderer, input, audio) {
        this.game = game;
        this.renderer = renderer;
        this.input = input;
        this.audio = audio;
        this.hud = new HUD(renderer);
        this.vfx = new VFX();
        this.particles = new ParticleSystem();
        this.debug = new DebugOverlay();
        this.background = new Background();
    }

    onEnter() {
        // Resume from options without reinitializing
        if (this.game._resumeScene) {
            this.game._resumeScene = false;
            this.paused = true;
            return;
        }

        this.player = new Player(200, 500);
        this.enemies = [];
        this.score = 0;
        this.levelWidth = 5000;
        this.gameOver = false;
        this.gameOverTimer = 0;
        this.paused = false;
        this.levelComplete = false;
        this.completeTimer = 0;
        this.prevJumpHeight = 0;
        this.highScoreSaved = false;

        // P2-17: Level intro state
        this.introActive = true;
        this.introTimer = 2.0;
        this.introElapsed = 0;

        this.camera = new Camera();
        this.waveManager = new WaveManager(WAVE_DATA);

        // AAA-L1: Create destructible objects from level data
        this.destructibles = LEVEL_1.destructibles.map(d => new Destructible(d.x, d.y, d.type));

        // AAA-L3: Create environmental hazards from level data
        this.hazards = LEVEL_1.hazards.map(h => new Hazard(h.x, h.y, h.type));

        // P1-12: Start procedural background music
        try {
            if (!this.music && this.audio.context && this.audio.musicBus) {
                this.music = new Music(this.audio.context, this.audio.musicBus);
            }
            if (this.music) {
                this.music.setIntensity(0);
                this.music.start();
            }
        } catch (e) {
            console.warn('Music init failed:', e);
            this.music = null;
        }

        // AAA-A2: Start environmental ambience
        try { this.audio.startAmbience(1); } catch (e) { /* ignore */ }
    }

    onExit() {
        // Suspend without cleanup when navigating to options
        if (this.game._suspendScene) {
            this.game._suspendScene = false;
            return;
        }
        // AAA-A2: Stop environmental ambience
        try { this.audio.stopAmbience(); } catch (e) { /* ignore */ }
        try { if (this.music) this.music.stop(); } catch (e) { /* ignore */ }
        this.debug.destroy();
    }

    updateDuringHitlag(dt) {
        this.renderer.updateShake(dt);
        this.vfx.update(dt);
        this.particles.update(dt);
    }

    update(dt) {
        this.renderer.updateShake(dt);
        this.vfx.update(dt);
        this.particles.update(dt);
        this.input.updateBuffer(dt);

        // P2-17: Level intro countdown — skip entity updates
        if (this.introActive) {
            this.introElapsed += dt;
            if (this.introElapsed >= this.introTimer) {
                this.introActive = false;
            }
            this.input.clearFrameState();
            return;
        }
        
        if (this.levelComplete) {
            this.completeTimer += dt;
            if (this.completeTimer > 3) {
                this.game.switchScene('title');
            }
            this.input.clearFrameState();
            return;
        }
        
        if (this.gameOver) {
            this.gameOverTimer += dt;
            if (this.gameOverTimer > 0.5 && this.input.isStart()) {
                this.game.switchScene('title');
            }
            this.input.clearFrameState();
            return;
        }

        // Pause toggle (before consuming other input)
        if (this.input.isPause()) {
            this.paused = !this.paused;
            this.input.clearFrameState();
            return;
        }

        // While paused: accept Q to quit, O for options
        if (this.paused) {
            if (this.input.isQuit()) {
                this.game.switchScene('title');
            }
            if (this.input.isOptions()) {
                this.game._suspendScene = true;
                this.game._optionsReturn = 'gameplay';
                this.game.switchScene('options');
            }
            this.input.clearFrameState();
            return;
        }
        
        // Update player
        const attackResult = this.player.update(dt, this.input);
        if (attackResult) {
            if (attackResult.type === 'kick' || attackResult.type === 'jump_kick') {
                this.audio.playKick();
            } else {
                this.audio.playPunch();
            }

            // Motion trails on attack start
            if (typeof VFX.createMotionTrail === 'function') {
                const hitbox = this.player.getAttackHitbox();
                if (hitbox) {
                    const tx = hitbox.x + hitbox.width / 2;
                    const ty = hitbox.y + hitbox.height / 2;
                    const f = this.player.facing;
                    switch (attackResult.type) {
                        case 'punch':
                        case 'jump_punch':
                            VFX.createMotionTrail(this.vfx, tx, ty, 40, 20, f * Math.PI * 0.3, '#FFFFCC');
                            break;
                        case 'kick':
                        case 'jump_kick':
                            VFX.createMotionTrail(this.vfx, tx, ty, 55, 25, -f * Math.PI * 0.2, '#FFFFCC');
                            break;
                        case 'belly_bump':
                            VFX.createMotionTrail(this.vfx, tx, ty, 70, 35, f * Math.PI * 0.15, '#FFFFCC');
                            break;
                        case 'ground_slam':
                            VFX.createMotionTrail(this.vfx, tx, ty, 80, 40, Math.PI * 0.5, '#FFFFCC');
                            break;
                    }
                }
            }

            // Vocal sounds on attack
            if (attackResult.type === 'belly_bump' || attackResult.type === 'ground_slam') {
                this.audio.playExertion();
                // AAA-V1: Zoom on power hits
                this.game.triggerZoom(1.15, 0.2);
            } else if (Math.random() < 0.3) {
                this.audio.playGrunt();
            }
        }

        // Update HUD (combo display timing)
        this.hud.update(dt, this.player);
        
        // Detect jump start
        if (this.prevJumpHeight === 0 && this.player.jumpHeight > 0) {
            this.audio.playJump();
        }
        // Detect landing — play sound + dust particles
        if (this.prevJumpHeight > 0 && this.player.jumpHeight === 0) {
            this.audio.playLanding();
            this.particles.emit(
                this.player.x + this.player.width / 2,
                this.player.y + this.player.height,
                DUST_CLOUD
            );
        }
        this.prevJumpHeight = this.player.jumpHeight;

        // AAA-L1: Update destructibles
        this.destructibles.forEach(d => d.update(dt));
        // AAA-L3: Update hazards
        this.hazards.forEach(h => h.update(dt));

        // Track combo count before combat for Woohoo trigger
        const comboCountBefore = this.player.comboCount;
        
        // Handle player attacks every frame
        const combatResult = Combat.handlePlayerAttack(
            this.player,
            this.enemies,
            this.audio,
            this.renderer
        );
        this.score += combatResult.score;
        if (combatResult.score > 0) {
            this.game.addHitlag(3);
        }
        for (const hit of combatResult.hits) {
            this.vfx.addEffect(VFX.createHitEffect(hit.x, hit.y, hit.intensity));
            VFX.createDamageNumber(this.vfx, hit.x, hit.y, hit.damage, this.player.comboCount > 2);
            this.particles.emit(hit.x, hit.y, HIT_SPARKS);
            // AAA-V1: Zoom on combo finishers (5+ combo)
            if (hit.intensity === 'heavy') {
                this.game.triggerZoom(1.15, 0.2);
            }
        }

        // AAA-V5: Screen flash on heavy hits
        if (typeof VFX.createScreenFlash === 'function') {
            if (combatResult.hits.some(h => h.intensity === 'heavy')) {
                VFX.createScreenFlash(this.vfx, '#FFFFFF', 0.15);
            }
        }

        // AAA-L1: Player attacks vs destructibles
        const playerAttackBox = this.player.getAttackHitbox();
        if (playerAttackBox) {
            const atkDmgTable = { punch: 10, kick: 15, jump_punch: 10, jump_kick: 20, belly_bump: 25, ground_slam: 20, back_attack: 12 };
            const atkDmg = atkDmgTable[this.player.state] || 10;
            for (const d of this.destructibles) {
                if (!d.broken && Combat.checkCollision(playerAttackBox, d.getHurtbox()) && !this.player.attackHitList.has(d)) {
                    const drop = d.takeDamage(atkDmg);
                    this.player.attackHitList.add(d);
                    if (drop) {
                        if (drop.type === 'health') this.player.health = Math.min(this.player.maxHealth, this.player.health + 10);
                        if (drop.type === 'score') this.score += 100;
                    }
                }
            }
        }

        // AAA-A3: Woohoo on reaching 5+ combo
        if (comboCountBefore < 5 && this.player.comboCount >= 5) {
            try { this.audio.playWoohoo(); } catch (e) { /* ignore */ }
        }
        
        // Update enemies
        for (const enemy of this.enemies) {
            const prevState = enemy.state;
            enemy.update(dt);
            AI.updateEnemy(enemy, this.player, dt);
            // AAA-V3: Telegraph VFX when enemy enters windup
            if (typeof VFX.createTelegraph === 'function') {
                const isWindup = enemy.state === 'windup' || enemy.state === 'charge_windup' || enemy.state === 'slam_windup';
                const wasWindup = prevState === 'windup' || prevState === 'charge_windup' || prevState === 'slam_windup';
                if (isWindup && !wasWindup) {
                    VFX.createTelegraph(this.vfx, enemy.x + enemy.width / 2, enemy.y, 0.3);
                }
            }
        }

        // Boss phase add spawns
        const addSpawns = [];
        for (const enemy of this.enemies) {
            if (enemy.variant === 'boss' && enemy.pendingAdds > 0) {
                const count = enemy.pendingAdds;
                enemy.pendingAdds = 0;
                for (let i = 0; i < count; i++) {
                    const offsetX = i % 2 === 0 ? -140 : 140;
                    const offsetY = i === 0 ? -30 : 30;
                    addSpawns.push(new Enemy(enemy.x + offsetX, enemy.y + offsetY, 'normal'));
                }
            }
        }
        if (addSpawns.length > 0) {
            this.enemies.push(...addSpawns);
            this.audio.playWaveStart();
            if (typeof VFX.createSpawnEffect === 'function') {
                for (const enemy of addSpawns) {
                    VFX.createSpawnEffect(this.vfx, enemy.x + enemy.width / 2, enemy.y + enemy.height);
                }
            }
        }
        
        // Enemy attacks
        const healthBeforeEnemyAttacks = this.player.health;
        Combat.handleEnemyAttacks(this.enemies, this.player, this.audio);
        if (this.player.health < healthBeforeEnemyAttacks) {
            this.game.addHitlag(2);
            this.audio.playOof();
            // Reset style meter on damage
            this.player.styleTypes.clear();
            // AAA-A3: Voice bark on player damage (30% chance)
            if (Math.random() < 0.3) {
                try { this.audio.playDoh(); } catch (e) { /* ignore */ }
            }
        }

        // AAA-L3: Hazard damage zones
        for (const h of this.hazards) {
            const playerResult = h.checkDamage(this.player);
            if (playerResult) {
                const kbx = playerResult.knockback ? playerResult.knockback.vx : 0;
                const kby = playerResult.knockback ? playerResult.knockback.vy : 0;
                this.player.takeDamage(playerResult.damage, kbx, kby);
            }
            for (const enemy of this.enemies) {
                if (enemy.state === 'dead') continue;
                const enemyResult = h.checkDamage(enemy);
                if (enemyResult) {
                    const kbx = enemyResult.knockback ? enemyResult.knockback.vx : 0;
                    const kby = enemyResult.knockback ? enemyResult.knockback.vy : 0;
                    enemy.takeDamage(enemyResult.damage, kbx, kby);
                }
            }
        }
        
        // KO effects for enemies about to be removed
        for (const enemy of this.enemies) {
            if (enemy.state === 'dead' && enemy.deathTime > 0.5) {
                const cx = enemy.x + enemy.width / 2;
                const cy = enemy.y + enemy.height / 2;
                this.vfx.addEffect(VFX.createKOEffect(cx, cy));
                VFX.createKOText(this.vfx, cx, cy - 30);
                this.particles.emit(cx, cy, DEATH_DEBRIS);
            }
        }
        
        // Cleanup dead enemies
        const enemiesBeforeCleanup = this.enemies.length;
        this.enemies = Combat.cleanupDeadEnemies(this.enemies);
        const killedCount = enemiesBeforeCleanup - this.enemies.length;
        this.score += killedCount * 50;

        // AAA-V2: Slow-mo on last enemy kill in active wave
        if (killedCount > 0 && this.enemies.length === 0 && this.camera.isLocked) {
            this.game.triggerSlowMo(0.3, 0.5);
            this.game.triggerZoom(1.15, 0.3);
            if (this.music) {
                try { this.music.setTimeScale(0.3); } catch (e) { /* ignore */ }
            }
        }
        
        // Wave spawning
        const newEnemies = this.waveManager.check(this.player.x, this.enemies);
        if (newEnemies.length > 0) {
            this.enemies.push(...newEnemies);
            this.camera.lock(this.waveManager.getLockX());
            this.audio.playWaveStart();
            if (typeof VFX.createSpawnEffect === 'function') {
                for (const enemy of newEnemies) {
                    VFX.createSpawnEffect(this.vfx, enemy.x + enemy.width / 2, enemy.y + enemy.height);
                }
            }
            // AAA-V4: Boss intro VFX when boss spawns
            if (typeof VFX.createBossIntro === 'function') {
                for (const enemy of newEnemies) {
                    if (enemy.variant === 'boss') {
                        VFX.createBossIntro(this.vfx, 'NELSON', 'Ha-Ha!', 3.0);
                    }
                }
            }
        }

        // Unlock camera when wave is cleared
        if (this.camera.isLocked && this.enemies.length === 0) {
            this.camera.unlock();
            this.audio.playWaveClear();
            // Restore music pitch after slow-mo wave clear
            if (this.music) {
                try { this.music.setTimeScale(1.0); } catch (e) { /* ignore */ }
            }
        }

        // Update camera
        this.camera.update(
            this.player.x + this.player.width / 2,
            this.levelWidth,
            this.renderer.width
        );
        this.renderer.setCamera(this.camera.x, 0);

        // Clamp player inside visible area
        if (this.camera.isLocked) {
            const maxPlayerX = this.camera.x + this.renderer.width - this.player.width - 50;
            if (this.player.x > maxPlayerX) this.player.x = maxPlayerX;
        }
        if (this.player.x < this.camera.x + 10) {
            this.player.x = this.camera.x + 10;
        }
        
        // Check game over
        if (this.player.health <= 0) {
            this.gameOver = true;
            if (!this.highScoreSaved) {
                this.highScoreSaved = true;
                this.newHighScore = saveHighScore(this.score);
            }
        }
        
        // Check level complete
        if (this.waveManager.allComplete && this.enemies.length === 0 && !this.levelComplete) {
            this.levelComplete = true;
            this.audio.playLevelComplete();
            // AAA-V2: Slow-mo on final boss kill
            this.game.triggerSlowMo(0.3, 0.5);
            this.game.triggerZoom(1.15, 0.3);
            if (this.music) {
                try { this.music.setTimeScale(0.3); } catch (e) { /* ignore */ }
            }
            if (!this.highScoreSaved) {
                this.highScoreSaved = true;
                this.newHighScore = saveHighScore(this.score);
            }
        }
        
        // P1-12: Update music intensity based on game state
        if (this.music) {
            try {
                if (this.enemies.length === 0 && !this.camera.isLocked) {
                    this.music.setIntensity(0);
                } else if (this.enemies.some(e => e.state === 'attack')) {
                    this.music.setIntensity(2);
                } else {
                    this.music.setIntensity(1);
                }
            } catch (e) { /* music context lost — ignore */ }
        }

        this.debug.update(dt, this.player, this.enemies, this.vfx);
        this.input.clearFrameState();
    }

    render() {
        this.renderer.clear();
        
        this.renderer.save();
        
        // Render background
        this.background.render(this.renderer.ctx, this.renderer.cameraX, this.renderer.width);
        
        // AAA-L3: Render hazards (before entities for depth)
        this.hazards.forEach(h => h.render(this.renderer.ctx, this.renderer.cameraX));
        // AAA-L1: Render destructibles (before entities for depth)
        this.destructibles.forEach(d => d.render(this.renderer.ctx, this.renderer.cameraX));
        
        // Sort entities by Y position for depth
        const allEntities = [this.player, ...this.enemies];
        allEntities.sort((a, b) => (a.y + a.height) - (b.y + b.height));
        
        // Render entities
        for (const entity of allEntities) {
            entity.render(this.renderer.ctx);
        }
        
        // Foreground parallax layer (in front of entities for depth)
        this.background.renderForeground(this.renderer.ctx, this.renderer.cameraX, this.renderer.width);

        // VFX layer (after entities + foreground, before HUD)
        this.vfx.render(this.renderer.ctx);
        this.particles.render(this.renderer.ctx);
        
        this.renderer.restore();
        
        // Compute wave progress for HUD
        const waves = this.waveManager.waves;
        let lastSpawned = -1;
        for (let i = 0; i < waves.length; i++) {
            if (waves[i].spawned) lastSpawned = i;
        }
        const waveInfo = {
            total: waves.length,
            completed: this.enemies.length === 0 && lastSpawned >= 0 ? lastSpawned + 1 : Math.max(0, lastSpawned),
            current: lastSpawned
        };

        // Render HUD
        this.hud.render(this.player, this.score, this.enemies, this.renderer.cameraX, waveInfo);
        
        // P2-17: Stage intro overlay
        if (this.introActive) {
            const ctx = this.renderer.ctx;
            const w = this.renderer.width;
            const h = this.renderer.height;
            const fadeIn = 0.3;
            const fadeOut = 0.3;
            const t = this.introElapsed;
            const total = this.introTimer;
            let alpha = 1;
            if (t < fadeIn) {
                alpha = t / fadeIn;
            } else if (t > total - fadeOut) {
                alpha = Math.max(0, (total - t) / fadeOut);
            }

            ctx.save();
            ctx.globalAlpha = 1;
            ctx.fillStyle = 'rgba(0, 0, 0, 0.8)';
            ctx.fillRect(0, 0, w, h);

            ctx.globalAlpha = alpha;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';

            ctx.font = 'bold 72px Arial';
            ctx.strokeStyle = '#000000';
            ctx.lineWidth = 5;
            ctx.strokeText('STAGE 1', w / 2, h / 2 - 30);
            ctx.fillStyle = '#FED90F';
            ctx.fillText('STAGE 1', w / 2, h / 2 - 30);

            ctx.font = 'bold 28px Arial';
            ctx.strokeStyle = '#000000';
            ctx.lineWidth = 3;
            ctx.strokeText('SPRINGFIELD DOWNTOWN', w / 2, h / 2 + 30);
            ctx.fillStyle = '#FFFFFF';
            ctx.fillText('SPRINGFIELD DOWNTOWN', w / 2, h / 2 + 30);

            ctx.restore();
        }

        // Game over overlay
        if (this.gameOver) {
            const ctx = this.renderer.ctx;
            const w = this.renderer.width;
            const h = this.renderer.height;
            const cy = h / 2;

            // Dark overlay
            ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            ctx.fillRect(0, 0, w, h);

            this.renderer.strokeText(
                'GAME OVER',
                w / 2, cy - 40,
                '#FF0000', '#000000',
                'bold 64px Arial', 4
            );

            if (this.newHighScore) {
                this.renderer.fillTextCentered(
                    'NEW HIGH SCORE!',
                    w / 2, cy + 20,
                    '#FED90F', 'bold 28px Arial'
                );
            }

            this.renderer.fillTextCentered(
                `Score: ${this.score}`,
                w / 2, cy + 55,
                '#FFFFFF', 'bold 28px Arial'
            );
            this.renderer.fillTextCentered(
                `HIGH SCORE: ${getHighScore()}`,
                w / 2, cy + 90,
                '#FED90F', 'bold 22px Arial'
            );

            if (this.gameOverTimer > 0.5) {
                this.renderer.fillTextCentered(
                    'Press ENTER to return to title',
                    w / 2, cy + 130,
                    '#FFFFFF', '24px Arial'
                );
            }
        }
        
        // Level complete message
        if (this.levelComplete) {
            this.renderer.strokeText(
                'LEVEL COMPLETE!',
                this.renderer.width / 2,
                this.renderer.height / 2,
                '#FFD700',
                '#000000',
                'bold 56px Arial',
                4
            );
            this.renderer.fillTextCentered(
                `Final Score: ${this.score}`,
                this.renderer.width / 2,
                this.renderer.height / 2 + 60,
                '#FFFFFF',
                'bold 32px Arial'
            );
            if (this.newHighScore) {
                this.renderer.fillTextCentered(
                    'NEW HIGH SCORE!',
                    this.renderer.width / 2,
                    this.renderer.height / 2 + 100,
                    '#FED90F',
                    'bold 28px Arial'
                );
            } else {
                this.renderer.fillTextCentered(
                    `HIGH SCORE: ${getHighScore()}`,
                    this.renderer.width / 2,
                    this.renderer.height / 2 + 100,
                    '#FED90F',
                    'bold 22px Arial'
                );
            }
        }

        // Pause overlay
        if (this.paused) {
            const ctx = this.renderer.ctx;
            const w = this.renderer.width;
            const h = this.renderer.height;

            ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
            ctx.fillRect(0, 0, w, h);

            this.renderer.strokeText(
                'PAUSED',
                w / 2, h / 2 - 30,
                '#FED90F', '#000000',
                'bold 64px Arial', 4
            );
            this.renderer.fillTextCentered(
                'Press ESC to Resume',
                w / 2, h / 2 + 30,
                '#FFFFFF', 'bold 24px Arial'
            );
            this.renderer.fillTextCentered(
                'Press Q to Quit',
                w / 2, h / 2 + 65,
                '#FFFFFF', '22px Arial'
            );
            this.renderer.fillTextCentered(
                'Press O for Options',
                w / 2, h / 2 + 100,
                '#FFFFFF', '22px Arial'
            );
        }
        
        // Debug overlay (renders last, on top of everything)
        this.debug.render(this.renderer.ctx, this.renderer.cameraX, this.player, this.enemies, this.vfx);
    }

}
