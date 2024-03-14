// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "../lib/*_web/components/layouts/*.*heex",
    "../lib/*_web/components/components/*.*ex",    
  ],
  theme: {
    extend: {
      colors: {
        transparent: 'transparent',
        brand: "#6a43b8",
        background: "#0700",
        accent: "#200e46",
        highlight: "#6944b8",
        contrast: "#d6c3ff",
        gold: {100: '#bf9936',
        200: '#f7ef8a',
        300: '#d0aa45',
        400: '#ebc766',},
      }
    },
  },

  safelist: [
    'text-slate-600', 'bg-slate-100', 'text-lime-600', 'bg-lime-100', 'text-amber-600', 'bg-amber-100',  
    'bg-violet-200', 'border-violet-500', `bg-lime-200`, `border-lime-500`, `bg-amber-200`, 'border-amber-500',
    'bg-white', 'rounded-full', 'cursor-pointer', 'opacity-50 grayscale',
    'hero-home-solid', 'hero-user-solid', 'hero-globe-americas-solid'
  ],
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}
