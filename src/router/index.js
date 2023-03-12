import { createRouter, createWebHistory } from 'vue-router'
import Suizino from '../views/SuizinoGame.vue'
import Home from '../views/Home.vue'
import Flipper from '../views/Flipper.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/zino',
      name: 'zino',
      component: Suizino
    },
    {
      path: '/flipper',
      name: 'flipper',
      component: Flipper
    },
    // {
    //   path: '/about',
    //   name: 'about',
    //   // route level code-splitting
    //   // this generates a separate chunk (About.[hash].js) for this route
    //   // which is lazy-loaded when the route is visited.
    //   component: () => import('../views/AboutView.vue')
    // }
  ]
})

export default router
