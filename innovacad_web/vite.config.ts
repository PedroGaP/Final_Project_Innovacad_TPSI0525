import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import solid from "vite-plugin-solid";
import tsconfigPath from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [solid(), tailwindcss({ optimize: true }), tsconfigPath()],
  server: {
    host: "0.0.0.0",
    port: 5000,
    cors: true,
    proxy: {
      '^/(sign|trainees|trainers|classes|courses|grades|rooms|modules|enrollments|availabilities|schedules)': {
        target: "http://localhost:8080",
        changeOrigin: true,
        secure: false,
      },
    },
  },
  build: {
    outDir: "build",
  },
});
