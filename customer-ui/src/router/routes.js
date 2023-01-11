/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
