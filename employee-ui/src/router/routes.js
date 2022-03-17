const routes = [
  {
    path: '/',
    component: () => import('pages/WelcomePage.vue')
  },
  {
    path: '/kitchen',
    component: () => import('layouts/KitchenLayout.vue')
  },
  {
    path: '/add-menu-item',
    component: () => import('pages/AddMenuItemPage1.vue')
  },
  {
    path: '/add-menu-item2',
    component: () => import('pages/AddMenuItemPage2.vue')
  },
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/Error404.vue')
  }
]

export default routes
