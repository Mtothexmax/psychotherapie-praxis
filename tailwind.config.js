/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: ["./docs/index.html"],
  theme: {
    extend: {
      colors: {
        'sage': '#9BAE96',
        'sage-light': '#B5C6B1',
        'mint': '#D2DDD0',
        'cream': '#F9F6F0',
        'sage-dark': '#72836E',
        'boho-blush': '#E8D8D0',
        'text-dark': '#3D4035'
      },
      fontFamily: {
        'serif': ['"Cormorant Garamond"', 'Georgia', 'serif'],
        'sans': ['"Quicksand"', 'Helvetica', 'Arial', 'sans-serif']
      },
      borderRadius: {
        'organic-1': '60% 40% 30% 70% / 60% 30% 70% 40%',
        'organic-2': '30% 70% 70% 30% / 30% 30% 70% 70%',
        'organic-3': '50% 50% 20% 80% / 25% 80% 20% 75%'
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/container-queries'),
  ],
}