export class Background {
    render(ctx, cameraX, screenWidth) {
        // Sky
        ctx.fillStyle = '#87CEEB';
        ctx.fillRect(cameraX, 0, screenWidth, 400);

        // Ground
        ctx.fillStyle = '#7CFC00';
        ctx.fillRect(cameraX, 400, screenWidth, 200);

        // Road
        ctx.fillStyle = '#808080';
        ctx.fillRect(cameraX, 600, screenWidth, 120);

        // Road lines
        ctx.fillStyle = '#FFFF00';
        for (let x = cameraX - (cameraX % 100); x < cameraX + screenWidth; x += 100) {
            ctx.fillRect(x, 655, 50, 10);
        }

        // Buildings (parallax — scroll at 0.3× camera speed)
        for (let i = 0; i < 10; i++) {
            const bx = i * 400 + cameraX * 0.7;
            if (bx + 200 < cameraX || bx > cameraX + screenWidth) continue;

            ctx.fillStyle = i % 2 === 0 ? '#CD853F' : '#DEB887';
            ctx.fillRect(bx, 200, 180, 200);

            // Windows
            ctx.fillStyle = '#4169E1';
            for (let wy = 220; wy < 380; wy += 40) {
                for (let wx = 0; wx < 3; wx++) {
                    ctx.fillRect(bx + 20 + wx * 50, wy, 30, 30);
                }
            }
        }
    }
}
