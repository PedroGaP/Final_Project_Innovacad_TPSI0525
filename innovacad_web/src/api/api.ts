import type { SignInData } from "@/types/auth";
import { Trainee, Trainer, type User } from "@/types/user";

const headers = {
	"Content-Type": "application/json",
};

const baseUrl = "http://localhost:8080";

export const signIn = async (data: SignInData): Promise<User | undefined> => {
	if (data.email === undefined && data.username === undefined)
		throw "The provided parameters are undefined.";

	const res = await fetch(`${baseUrl}/sign/in`, {
		headers,
		method: "POST",
		body: JSON.stringify({
			email: data.email,
			username: data.username,
			password: data.password,
		}),
	});

	const resData = await res.json();

	if (res.status !== 200) {
		console.log(`[SIGN IN] > ${resData}`);
		throw "Couldn't sign-in with this credentials";
	}

	var user: User | undefined;

	console.log(`[DATA] > ${JSON.stringify(resData)}`);

	if (resData.trainer_id) {
		user = new Trainer(resData, resData.trainer_id);
	} else if (resData.trainee_id) {
		user = new Trainee(resData, resData.trainee_id);
	} else {
		throw "Account has no associated profile.";
	}

	return user;
};
