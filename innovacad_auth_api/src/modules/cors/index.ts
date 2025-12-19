import cors from "@elysiajs/cors";
import Elysia from "elysia";

export default (app: Elysia) =>
  app.use(
    cors({
      origin: true,
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      credentials: true,
      allowedHeaders: ["Content-Type", "Authorization"],
    })
  );
