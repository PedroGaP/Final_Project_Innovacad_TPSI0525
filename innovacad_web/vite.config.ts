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
    /*proxy: {
      "/sign": "https://api.innovacad.grod.ovh",
      "/trainees": "https://api.innovacad.grod.ovh",
      "/trainers": "https://api.innovacad.grod.ovh",
    },*/
    /*proxy: {
      "/sign": "https://localhost:8080",
      "/trainees": "https://localhost:8080",
      "/trainers": "https://localhost:8080",
    },*/
  },
  build: {
    outDir: "build",
  },
});
