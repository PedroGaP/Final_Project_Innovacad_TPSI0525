import { Elysia } from "elysia";
import { auth, cors } from "@/modules/";
import { API } from "@/utils/env";

new Elysia()
	.get("/", () => null)
	.use(cors)
	.mount(auth.handler)
	.listen(API.PORT);
