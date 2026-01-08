import { Elysia } from "elysia";
import { auth, cors, seedAdmin } from "@/modules/";
import { API } from "@/utils/env";

new Elysia()
	.get("/", () => null)
	.use(cors)
	.mount(auth.handler)
	.listen(API.PORT);

await seedAdmin();
