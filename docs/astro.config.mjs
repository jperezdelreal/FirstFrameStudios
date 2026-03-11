// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://jperezdelreal.github.io',
  base: '/FirstFrameStudios/',
  output: 'static',
  vite: {
    plugins: [tailwindcss()],
  },
});
