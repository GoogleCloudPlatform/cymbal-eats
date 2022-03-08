const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue')
  },
  {
    path: '/edit-order',
    component: () => import('layouts/EditOrderLayout.vue')
  },
  {
    path: '/place-order',
    component: () => import('layouts/PlaceOrderLayout.vue')
  },
  {
    path: '/order-status/:orderNumber',
    component: () => import('layouts/OrderStatusLayout.vue')
  },
  {
    path: '/kitchen',
    component: () => import('layouts/KitchenLayout.vue')
  },
  {
    path: '/add-menu-item',
    component: () => import('pages/AddMenuItemPage.vue')
  },
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/Error404.vue')
  }
]

export default routes
