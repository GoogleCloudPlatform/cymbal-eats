const routes = [
  {
    path: '/',
    component: () => import('pages/MenuPage.vue')
  },
  {
    path: '/edit-order',
    component: () => import('pages/EditOrderPage.vue')
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
