import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import solid from "vite-plugin-solid";
import tsconfigPath from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [solid(), tailwindcss({ optimize: true }), tsconfigPath()],
  server: {
    host: "0.0.0.0",
    port: 5000,
    proxy: {
      "/sign": "http://localhost:8080", // Forward login requests
      "/trainees": "http://localhost:8080", // Forward trainee requests
      "/trainers": "http://localhost:8080", // Forward trainer requests
    },
  },
  build: {
    outDir: "build",
  },
});
