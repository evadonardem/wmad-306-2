import React from 'react'
import { createRoot } from 'react-dom/client'
import { createInertiaApp } from '@inertiajs/react'

createInertiaApp({
  id: 'app',

  resolve: name => {
    const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true })

    const page =
      pages[`./Pages/${name}.jsx`] ||
      pages[`./Pages/${name}/index.jsx`]

    if (!page) {
      throw new Error(`Page not found: ${name}`)
    }

    return page
  },

  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
