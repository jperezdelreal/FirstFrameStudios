export class Input {
    constructor() {
        this.keys = {};
        this.keysPressed = {};
        this.keysReleased = {};

        // AAA-C9: Attack input buffer
        this.bufferedAction = null;
        this.bufferTimer = 0;

        window.addEventListener('keydown', (e) => {
            if (!this.keys[e.code]) {
                this.keysPressed[e.code] = true;
                // Auto-buffer attack keys on press
                if (e.code === 'KeyJ' || e.code === 'KeyZ') {
                    this.bufferedAction = 'punch';
                    this.bufferTimer = 0;
                } else if (e.code === 'KeyK' || e.code === 'KeyX') {
                    this.bufferedAction = 'kick';
                    this.bufferTimer = 0;
                }
            }
            this.keys[e.code] = true;
        });

        window.addEventListener('keyup', (e) => {
            this.keys[e.code] = false;
            this.keysReleased[e.code] = true;
        });
    }

    isDown(keyCode) {
        return this.keys[keyCode] || false;
    }

    isPressed(keyCode) {
        return this.keysPressed[keyCode] || false;
    }

    isReleased(keyCode) {
        return this.keysReleased[keyCode] || false;
    }

    clearFrameState() {
        this.keysPressed = {};
        this.keysReleased = {};
    }

    // AAA-C9: Buffer methods
    updateBuffer(dt) {
        if (this.bufferedAction) {
            this.bufferTimer += dt;
            if (this.bufferTimer > 0.15) {
                this.bufferedAction = null;
                this.bufferTimer = 0;
            }
        }
    }

    consumeBuffer() {
        if (this.bufferedAction && this.bufferTimer <= 0.15) {
            const action = this.bufferedAction;
            this.bufferedAction = null;
            this.bufferTimer = 0;
            return action;
        }
        return null;
    }

    clearBuffer() {
        this.bufferedAction = null;
        this.bufferTimer = 0;
    }

    // Helper methods for common controls
    isLeft() {
        return this.isDown('KeyA') || this.isDown('ArrowLeft');
    }

    isRight() {
        return this.isDown('KeyD') || this.isDown('ArrowRight');
    }

    isUp() {
        return this.isDown('KeyW') || this.isDown('ArrowUp');
    }

    isMovingDown() {
        return this.isDown('KeyS') || this.isDown('ArrowDown');
    }

    isPunch() {
        return this.isPressed('KeyJ') || this.isPressed('KeyZ');
    }

    isKick() {
        return this.isPressed('KeyK') || this.isPressed('KeyX');
    }

    isGrab() {
        return this.isPressed('KeyG') || this.isPressed('KeyC');
    }

    isDodge() {
        return this.isPressed('KeyL') || this.isPressed('ShiftLeft') || this.isPressed('ShiftRight');
    }

    isJump() {
        return this.isPressed('Space');
    }

    isStart() {
        return this.isPressed('Enter');
    }

    isPause() {
        return this.isPressed('Escape');
    }

    isQuit() {
        return this.isPressed('KeyQ');
    }

    isOptions() {
        return this.isPressed('KeyO');
    }
}
