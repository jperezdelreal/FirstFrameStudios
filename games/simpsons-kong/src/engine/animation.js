/**
 * Frame-based animation controller.
 * Tracks which frame is active — does NOT render.
 * 
 * Usage:
 *   const anim = new AnimationController({
 *     idle: { frames: [0, 1], frameDuration: 0.5, loop: true },
 *     walk: { frames: [0, 1, 2, 3], frameDuration: 0.15, loop: true },
 *     punch: { frames: [0, 1, 2], frameDuration: 0.1, loop: false },
 *     hit: { frames: [0], frameDuration: 0.2, loop: false }
 *   });
 *   anim.play('walk');
 *   anim.update(dt);
 *   const frame = anim.getCurrentFrame();
 */
export class AnimationController {
    constructor(animations) {
        this.animations = animations;
        this.currentName = null;
        this.currentAnim = null;
        this.frameIndex = 0;
        this.frameTimer = 0;
        this.finished = false;
        this.frameEventCallbacks = [];
    }

    play(name) {
        if (name === this.currentName && !this.finished) return;
        const anim = this.animations[name];
        if (!anim) return;

        this.currentName = name;
        this.currentAnim = anim;
        this.frameIndex = 0;
        this.frameTimer = 0;
        this.finished = false;
    }

    update(dt) {
        if (!this.currentAnim || this.finished) return;

        this.frameTimer += dt;
        const { frames, frameDuration, loop } = this.currentAnim;

        while (this.frameTimer >= frameDuration) {
            this.frameTimer -= frameDuration;
            const prevIndex = this.frameIndex;
            this.frameIndex++;

            if (this.frameIndex >= frames.length) {
                if (loop) {
                    this.frameIndex = 0;
                } else {
                    this.frameIndex = frames.length - 1;
                    this.finished = true;
                    this._fireFrameEvents(this.frameIndex);
                    return;
                }
            }

            this._fireFrameEvents(this.frameIndex);
        }
    }

    getCurrentFrame() {
        if (!this.currentAnim) return null;
        return this.currentAnim.frames[this.frameIndex];
    }

    isFinished() {
        return this.finished;
    }

    onFrameEvent(callback) {
        this.frameEventCallbacks.push(callback);
    }

    _fireFrameEvents(frameIndex) {
        const name = this.currentName;
        for (const cb of this.frameEventCallbacks) {
            cb(name, frameIndex);
        }
    }
}
