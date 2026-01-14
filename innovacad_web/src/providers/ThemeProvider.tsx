import {
	createContext,
	createEffect,
	createSignal,
	type JSX,
	useContext,
} from "solid-js";
import type { ThemeContextType } from "@/types/theme";

const ThemeContext = createContext<ThemeContextType>();

export const ThemeProvider = (props: { children: JSX.Element }) => {
	const initialTheme = localStorage.getItem("theme") || "dark";

	const [theme, setTheme] = createSignal<string>(initialTheme);

	createEffect(() => {
		const root = document.documentElement;
		const currentTheme = theme();
		root.setAttribute("data-theme", currentTheme);
		localStorage.setItem("theme", currentTheme);
	});

	const toggleTheme = () => {
		setTheme((prev: string) => (prev === "dark" ? "light" : "dark"));
	};

	return (
		<ThemeContext.Provider value={{ theme, toggleTheme }}>
			{props.children}
		</ThemeContext.Provider>
	);
};

export const useTheme = () => useContext<ThemeContextType>(ThemeContext);
