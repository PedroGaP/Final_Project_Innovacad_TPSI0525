export type SignInResponse = {
	token: string;
	id: string;
	name: string;
	username: string;
};

export type SignInData = {
	password: string;
	email?: string | undefined;
	username?: string | undefined;
};
