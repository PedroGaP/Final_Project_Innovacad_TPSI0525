import { Elysia } from "elysia";
import { API } from "@/utils/env";
import { cors, auth } from "@/modules/";

new Elysia()
  .get("/", () => null)
  .use(cors)
  .mount(auth.handler)
  .listen(API.PORT);
