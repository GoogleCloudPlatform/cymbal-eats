const routes = [
  {
    path: '/',
    component: () => import('pages/StartPage.vue')
  },
  {
    path: '/carousel',
    component: () => import('pages/CarouselPage.vue')
  },
  {
    path: '/edit-order',
    component: () => import('pages/EditOrderPage.vue')
  },
  {
    path: '/rewards',
    component: () => import('pages/RewardsPage.vue')
  },
  {
    path: '/order-status/:orderNumber',
    component: () => import('pages/OrderStatusPage.vue')
  },
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/Error404.vue')
  }
]

export default routes
