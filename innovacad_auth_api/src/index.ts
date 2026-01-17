import { Elysia } from "elysia";
import { auth, cors, seedAdmin } from "@/modules/";
import { API } from "@/utils/env";

console.log("[BETTER AUTH] Server running and listening on port " + API.PORT);
console.log(API.GOOGLE.CLIENT_ID);
console.log(API.GOOGLE.CLIENT_SECRET);

new Elysia()
  .get("/", () => null)
  .use(cors)
  .mount(auth.handler)
  .listen(API.PORT);

(async () => await seedAdmin())();
