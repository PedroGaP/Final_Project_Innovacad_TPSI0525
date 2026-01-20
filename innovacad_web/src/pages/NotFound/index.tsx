import { useNavigate } from "@solidjs/router";
import { AiFillCaretLeft, AiTwotoneHome } from "solid-icons/ai";

const NotFound = () => {
	const navigate = useNavigate();

	return (
		<div class="hero">
			<div class="hero-content text-center">
				<div class="max-w-md">
					<div class="relative">
						<h1 class="text-9xl font-black opacity-10 select-none">404</h1>
						<p class="absolute inset-0 flex items-center justify-center text-4xl font-bold">
							Are you lost ?
						</p>
					</div>

					<div class="py-6">
						<h2 class="text-2xl font-bold italic border-b-2 border-primary w-fit mx-auto mb-4">
							Oops! Page not found.
						</h2>
						<p class="text-base-content/60 italic">
							"Not all those who wander are lost... but you definitely are !"
						</p>
					</div>

					<div class="flex flex-col sm:flex-row gap-4 justify-center">
						<button
							class="btn btn-primary shadow-lg"
							onClick={() => navigate("/")}
						>
							<AiTwotoneHome size={20} />
							Return Home
						</button>
						<button
							class="btn btn-ghost border-base-content/20"
							onClick={() => navigate(-1)}
						>
							<AiFillCaretLeft size={20} />
							Go Back
						</button>
					</div>
				</div>
			</div>
		</div>
	);
};

export default NotFound;
