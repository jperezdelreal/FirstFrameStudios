import { Enemy } from '../entities/enemy.js';

export class WaveManager {
    constructor(waveData) {
        this.waves = waveData.map(w => ({ ...w, spawned: false }));
    }

    /**
     * Check whether the player has reached a wave trigger.
     * Returns an array of newly spawned Enemy instances (empty if nothing spawned).
     */
    check(playerX, enemies) {
        const spawned = [];

        for (const wave of this.waves) {
            if (wave.spawned) continue;
            if (playerX < wave.x - 400) continue;

            wave.spawned = true;

            for (const def of wave.enemies) {
                spawned.push(new Enemy(def.x, def.y, def.variant));
            }
        }

        return spawned;
    }

    /** True once every wave has been triggered. */
    get allComplete() {
        return this.waves.every(w => w.spawned);
    }

    /** True if the most recently triggered wave still has a lock position. */
    get isLocked() {
        return this.waves.some(w => w.spawned && !w.cleared);
    }

    /** Return the lock-X of the most recently triggered (uncleared) wave, or null. */
    getLockX() {
        for (let i = this.waves.length - 1; i >= 0; i--) {
            if (this.waves[i].spawned) return this.waves[i].x;
        }
        return null;
    }
}
