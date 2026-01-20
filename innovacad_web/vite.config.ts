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
  },
  build: {
    outDir: "build",
  },
});
