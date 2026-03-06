import { Player } from '../entities/player.js';
import { Combat } from '../systems/combat.js';
import { AI } from '../systems/ai.js';
import { VFX } from '../systems/vfx.js';
import { Camera } from '../systems/camera.js';
import { WaveManager } from '../systems/wave-manager.js';
import { Background } from '../systems/background.js';
import { HUD } from '../ui/hud.js';
import { DebugOverlay } from '../debug/debug-overlay.js';
import { saveHighScore, getHighScore, isNewHighScore } from '../ui/highscore.js';

const WAVE_DATA = [
    { x: 800, enemies: [
        { x: 1000, y: 500, variant: 'normal' },
        { x: 1100, y: 450, variant: 'normal' },
        { x: 1050, y: 550, variant: 'normal' }
    ]},
    { x: 1600, enemies: [
        { x: 1800, y: 480, variant: 'normal' },
        { x: 1850, y: 530, variant: 'normal' },
        { x: 1400, y: 500, variant: 'normal' },
        { x: 1450, y: 450, variant: 'normal' }
    ]},
    { x: 2800, enemies: [
        { x: 3000, y: 500, variant: 'normal' },
        { x: 3050, y: 460, variant: 'normal' },
        { x: 3100, y: 520, variant: 'normal' },
        { x: 2600, y: 480, variant: 'normal' },
        { x: 3150, y: 500, variant: 'tough' }
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
        this.debug = new DebugOverlay();
        this.background = new Background();
    }

    onEnter() {
        this.player = new Player(200, 500);
        this.enemies = [];
        this.score = 0;
        this.levelWidth = 4000;
        this.gameOver = false;
        this.levelComplete = false;
        this.completeTimer = 0;
        this.prevJumpHeight = 0;
        this.highScoreSaved = false;

        this.camera = new Camera();
        this.waveManager = new WaveManager(WAVE_DATA);
    }

    onExit() {
        this.debug.destroy();
    }

    updateDuringHitlag(dt) {
        this.renderer.updateShake(dt);
        this.vfx.update(dt);
    }

    update(dt) {
        this.renderer.updateShake(dt);
        this.vfx.update(dt);
        
        if (this.levelComplete) {
            this.completeTimer += dt;
            if (this.completeTimer > 3) {
                this.game.switchScene('title');
            }
            this.input.clearFrameState();
            return;
        }
        
        if (this.gameOver) {
            if (this.input.isStart()) {
                this.game.switchScene('title');
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
        }

        // Update HUD (combo display timing)
        this.hud.update(dt, this.player);
        
        // Detect jump start
        if (this.prevJumpHeight === 0 && this.player.jumpHeight > 0) {
            this.audio.playJump();
        }
        this.prevJumpHeight = this.player.jumpHeight;
        
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
        }
        
        // Update enemies
        for (const enemy of this.enemies) {
            enemy.update(dt);
            AI.updateEnemy(enemy, this.player, dt);
        }
        
        // Enemy attacks
        const healthBeforeEnemyAttacks = this.player.health;
        Combat.handleEnemyAttacks(this.enemies, this.player, this.audio);
        if (this.player.health < healthBeforeEnemyAttacks) {
            this.game.addHitlag(2);
        }
        
        // KO effects for enemies about to be removed
        for (const enemy of this.enemies) {
            if (enemy.state === 'dead' && enemy.deathTime > 0.5) {
                this.vfx.addEffect(VFX.createKOEffect(
                    enemy.x + enemy.width / 2,
                    enemy.y + enemy.height / 2
                ));
            }
        }
        
        // Cleanup dead enemies
        const enemiesBeforeCleanup = this.enemies.length;
        this.enemies = Combat.cleanupDeadEnemies(this.enemies);
        const killedCount = enemiesBeforeCleanup - this.enemies.length;
        this.score += killedCount * 50;
        
        // Wave spawning
        const newEnemies = this.waveManager.check(this.player.x, this.enemies);
        if (newEnemies.length > 0) {
            this.enemies.push(...newEnemies);
            this.camera.lock(this.waveManager.getLockX());
        }

        // Unlock camera when wave is cleared
        if (this.camera.isLocked && this.enemies.length === 0) {
            this.camera.unlock();
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
            if (!this.highScoreSaved) {
                this.highScoreSaved = true;
                this.newHighScore = saveHighScore(this.score);
            }
        }
        
        this.debug.update(dt, this.player, this.enemies, this.vfx);
        this.input.clearFrameState();
    }

    render() {
        this.renderer.clear();
        
        this.renderer.save();
        
        // Render background
        this.background.render(this.renderer.ctx, this.renderer.cameraX, this.renderer.width);
        
        // Sort entities by Y position for depth
        const allEntities = [this.player, ...this.enemies];
        allEntities.sort((a, b) => (a.y + a.height) - (b.y + b.height));
        
        // Render entities
        for (const entity of allEntities) {
            entity.render(this.renderer.ctx);
        }
        
        // VFX layer (after entities, before HUD)
        this.vfx.render(this.renderer.ctx);
        
        this.renderer.restore();
        
        // Render HUD
        this.hud.render(this.player, this.score);
        
        // Game over message
        if (this.gameOver) {
            this.renderer.strokeText(
                'GAME OVER',
                this.renderer.width / 2,
                this.renderer.height / 2,
                '#FF0000',
                '#000000',
                'bold 64px Arial',
                4
            );
            this.renderer.fillTextCentered(
                `Score: ${this.score}`,
                this.renderer.width / 2,
                this.renderer.height / 2 + 50,
                '#FFFFFF',
                'bold 28px Arial'
            );
            this.renderer.fillTextCentered(
                `HIGH SCORE: ${getHighScore()}`,
                this.renderer.width / 2,
                this.renderer.height / 2 + 85,
                '#FED90F',
                'bold 22px Arial'
            );
            this.renderer.fillTextCentered(
                'Press ENTER to return to title',
                this.renderer.width / 2,
                this.renderer.height / 2 + 120,
                '#FFFFFF',
                '24px Arial'
            );
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
        
        // Debug overlay (renders last, on top of everything)
        this.debug.render(this.renderer.ctx, this.renderer.cameraX, this.player, this.enemies, this.vfx);
    }

}
