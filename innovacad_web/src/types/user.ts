export type UserResponseData = {
	id: string | undefined;
	name: string | undefined;
	username: string | undefined;
	token: string | undefined;
};

class User {
	id: string | undefined;
	name: string | undefined;
	username: string | undefined;
	token: string | undefined;

	constructor(data: UserResponseData) {
		this.id = data.id;
		this.name = data.name;
		this.username = data.username;
		this.token = data.token;
	}

	toJson() {
		return {
			id: this.id,
			name: this.name,
			username: this.username,
			token: this.token,
		};
	}
}

class Trainee extends User {
	traineeId: string | undefined;

	constructor(data: UserResponseData, traineeId: string) {
		super(data);
		this.traineeId = traineeId;
	}
}

class Trainer extends User {
	trainerId: string | undefined;

	constructor(data: UserResponseData, trainerId: string) {
		super(data);
		this.trainerId = trainerId;
	}
}

export { User, Trainer, Trainee };
