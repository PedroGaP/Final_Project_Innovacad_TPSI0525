import useI18n from "@/hooks/useL18N";
import i18next from "i18next";

const PTFlag = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 600 400"
    class="w-6 h-4 border border-black/10 shadow-sm"
  >
    <rect width="600" height="400" fill="#ff0000" />
    <rect width="240" height="400" fill="#006600" />
    <circle cx="240" cy="200" r="80" fill="#ffff00" />
    <circle cx="240" cy="200" r="70" fill="#ff0000" />
    <rect width="60" height="74" x="210" y="163" fill="#ffffff" />
    <path d="M210 163v50c0 15 15 24 30 24s30-9 30-24v-50h-60z" fill="#ffffff" />
    <path
      d="M216 169v18h12v-18h-12zm18 0v18h12v-18h-12zm-9 22v18h12v-18h-12zm18 0v18h12v-18h-12zm-27 0v18h12v-18h-12z"
      fill="#00008b"
    />
  </svg>
);

const USFlag = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 741 390"
    class="w-6 h-4 border border-black/10 shadow-sm"
  >
    <rect width="741" height="390" fill="#bf0a30" />
    <path
      d="M0 30h741M0 90h741M0 150h741M0 210h741M0 270h741M0 330h741"
      stroke="#fff"
      stroke-width="30"
    />
    <rect width="296.4" height="210" fill="#002868" />
    <g fill="#fff">
      <g id="s18">
        <g id="s9">
          <g id="s5">
            <g id="s1">
              <path
                id="st"
                d="M24.7 15l5.5 16.7h17.5L33.5 42l5.4 16.6-14.2-10.3-14.2 10.3 5.4-16.6L1.7 31.7h17.5z"
              />
            </g>
            <use href="#st" x="49.4" />
            <use href="#st" x="98.8" />
            <use href="#st" x="148.2" />
            <use href="#st" x="197.6" />
          </g>
          <use href="#s1" x="24.7" y="21" />
          <use href="#s1" x="74.1" y="21" />
          <use href="#s1" x="123.5" y="21" />
          <use href="#s1" x="172.9" y="21" />
        </g>
        <use href="#s9" y="42" />
        <use href="#s9" y="84" />
      </g>
      <use href="#s5" y="126" />
      <use href="#s1" x="24.7" y="147" />
      <use href="#s1" x="74.1" y="147" />
      <use href="#s1" x="123.5" y="147" />
      <use href="#s1" x="172.9" y="147" />
      <use href="#s5" y="168" />
    </g>
  </svg>
);

const ChangeLanguage = () => {
  const { currentLang } = useI18n();

  const toggleLanguage = () => {
    const newLang = currentLang() === "en-EN" ? "pt-PT" : "en-EN";
    i18next.changeLanguage(newLang);
  };

  return (
    <div
      class="tooltip tooltip-bottom"
      data-tip={
        currentLang() === "en-EN" ? "Mudar para Português" : "Change to English"
      }
    >
      <label class="btn btn-ghost swap swap-rotate ">
        <input
          type="checkbox"
          onChange={toggleLanguage}
          checked={currentLang() === "en-EN"}
        />

        <div class="swap-on flex items-center justify-center">
          <USFlag />
        </div>

        <div class="swap-off flex items-center justify-center">
          <PTFlag />
        </div>
      </label>
    </div>
  );
};

export default ChangeLanguage;
