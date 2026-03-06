export class Renderer {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;
        this.cameraX = 0;
        this.cameraY = 0;
        this.shake = { x: 0, y: 0, duration: 0 };
        this.zoomLevel = 1.0;
    }

    clear() {
        this.ctx.fillStyle = '#87CEEB';
        this.ctx.fillRect(0, 0, this.width, this.height);
    }

    setCamera(x, y) {
        this.cameraX = x;
        this.cameraY = y;
    }

    screenShake(intensity = 3, duration = 0.1) {
        this.shake.x = (Math.random() - 0.5) * intensity * 2;
        this.shake.y = (Math.random() - 0.5) * intensity * 2;
        this.shake.duration = duration;
    }

    updateShake(dt) {
        if (this.shake.duration > 0) {
            this.shake.duration -= dt;
            if (this.shake.duration <= 0) {
                this.shake.x = 0;
                this.shake.y = 0;
            }
        }
    }

    save() {
        this.ctx.save();
        // AAA-V1: Apply zoom centered on canvas center
        if (this.zoomLevel !== 1.0) {
            const cx = this.canvas.width / 2;
            const cy = this.canvas.height / 2;
            this.ctx.translate(cx, cy);
            this.ctx.scale(this.zoomLevel, this.zoomLevel);
            this.ctx.translate(-cx, -cy);
        }
        this.ctx.translate(-this.cameraX + this.shake.x, -this.cameraY + this.shake.y);
    }

    restore() {
        this.ctx.restore();
    }

    fillRect(x, y, w, h, color) {
        this.ctx.fillStyle = color;
        this.ctx.fillRect(x, y, w, h);
    }

    strokeRect(x, y, w, h, color, lineWidth = 1) {
        this.ctx.strokeStyle = color;
        this.ctx.lineWidth = lineWidth;
        this.ctx.strokeRect(x, y, w, h);
    }

    fillCircle(x, y, radius, color) {
        this.ctx.fillStyle = color;
        this.ctx.beginPath();
        this.ctx.arc(x, y, radius, 0, Math.PI * 2);
        this.ctx.fill();
    }

    fillText(text, x, y, color, font = '20px Arial') {
        this.ctx.fillStyle = color;
        this.ctx.font = font;
        this.ctx.fillText(text, x, y);
    }

    fillTextCentered(text, x, y, color, font = '20px Arial') {
        this.ctx.fillStyle = color;
        this.ctx.font = font;
        this.ctx.textAlign = 'center';
        this.ctx.fillText(text, x, y);
        this.ctx.textAlign = 'left';
    }

    strokeText(text, x, y, color, strokeColor, font = '20px Arial', lineWidth = 2) {
        this.ctx.font = font;
        this.ctx.textAlign = 'center';
        this.ctx.lineWidth = lineWidth;
        this.ctx.strokeStyle = strokeColor;
        this.ctx.strokeText(text, x, y);
        this.ctx.fillStyle = color;
        this.ctx.fillText(text, x, y);
        this.ctx.textAlign = 'left';
    }
}
