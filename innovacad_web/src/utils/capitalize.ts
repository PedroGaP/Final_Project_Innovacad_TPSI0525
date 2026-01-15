export default function capitalize(str: string) {
  if (!str) return str;

  const stripped = str.split(" ");

  const capitalized = stripped.map((s) =>
    !!s ? s.at(0)?.toUpperCase() + s.substring(1) : null
  );

  return capitalized.filter((s) => !!s).join(" ");
}
