/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#2563EB', // Le bleu des boutons sur tes images
        sidebar: '#0F172A', // Le fond sombre de la sidebar
      }
    },
  },
  plugins: [],
}