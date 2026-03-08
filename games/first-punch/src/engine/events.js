/**
 * Lightweight pub/sub event bus.
 * 
 * Standard game events:
 *   'enemy.hit'       → { enemy, damage, position }
 *   'enemy.died'      → { enemy, position }
 *   'player.hit'      → { damage }
 *   'player.attack'   → { type, combo }
 *   'wave.start'      → { waveIndex }
 *   'wave.clear'      → { waveIndex }
 *   'level.complete'  → {}
 */
export class EventBus {
    constructor() {
        this.listeners = new Map();
    }

    on(event, callback) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, []);
        }
        this.listeners.get(event).push(callback);
    }

    off(event, callback) {
        const cbs = this.listeners.get(event);
        if (!cbs) return;
        const idx = cbs.indexOf(callback);
        if (idx !== -1) cbs.splice(idx, 1);
    }

    emit(event, data) {
        const cbs = this.listeners.get(event);
        if (!cbs) return;
        // Iterate over a copy so handlers can safely unsubscribe mid-emit
        for (const cb of [...cbs]) {
            cb(data);
        }
    }

    once(event, callback) {
        const wrapper = (data) => {
            this.off(event, wrapper);
            callback(data);
        };
        this.on(event, wrapper);
    }
}
