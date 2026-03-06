export class Input {
    constructor() {
        this.keys = {};
        this.keysPressed = {};
        this.keysReleased = {};

        window.addEventListener('keydown', (e) => {
            if (!this.keys[e.code]) {
                this.keysPressed[e.code] = true;
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

    isJump() {
        return this.isPressed('Space');
    }

    isStart() {
        return this.isPressed('Enter');
    }
}
