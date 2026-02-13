import { createSignal } from "solid-js";
import { useI18n } from "@/hooks/useL18N";

export default function Home() {
	const [count, setCount] = createSignal(0);
	const { t } = useI18n();

	return (
		<section class="bg-gray-100 text-gray-700 p-8">
			<h1 class="text-2xl font-bold">{t("home.title")}</h1>
			<p class="mt-4">{t("home.desc")}</p>

			<div class="flex items-center space-x-2">
				<button
					type="button"
					class="border rounded-lg px-2 border-gray-900"
					onClick={() => setCount(count() - 1)}
				>
					-
				</button>

				<output class="p-10px">{t("home.count", { count: count() })}</output>

				<button
					type="button"
					class="border rounded-lg px-2 border-gray-900"
					onClick={() => setCount(count() + 1)}
				>
					+
				</button>
			</div>
		</section>
	);
}
