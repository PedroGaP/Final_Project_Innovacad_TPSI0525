/* @refresh reload */

import { type RouteDefinition, Router } from "@solidjs/router";
import { render } from "solid-js/web";
import "@/index.css";
import Footer from "@/components/Footer";
import Header from "@/components/Header";
import NotFound from "@/pages/NotFound";
import SignIn from "@/pages/SignIn";
import { ThemeProvider } from "@/providers/ThemeProvider";

const routes: RouteDefinition[] = [
	{ path: "/", component: SignIn },
	{ path: "**", component: NotFound },
];

render(
	() => (
		<ThemeProvider>
			<div class="flex flex-col min-h-screen bg-base-300 font-sans antialiased text-base-content">
				<Header />
				<main class="flex-grow flex flex-col items-center justify-center w-full">
					<Router>{routes}</Router>
				</main>
				<Footer />
			</div>
		</ThemeProvider>
	),
	document.getElementById("root")!,
);
