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

import { store } from 'quasar/wrappers';
import { createStore } from 'vuex';
import * as Server from '../utils/Server.js';

export default store(function () {
  const Store = createStore({
    state: {
      menuItems: [],
      menuItemId: ''
    },
    getters: {
    },
    mutations: {
      setMenuItemId(state, id) {
        state.menuItemId = id;
      },
      setMenuItems(state, menuItems) {
        state.menuItems = menuItems;
      },
      setInventoryCounts(state, inventoryCounts) {
        const newMenuItems = JSON.parse(JSON.stringify(state.menuItems));
        for (let inventoryCount of inventoryCounts) {
          const menuItem = newMenuItems.find(m => m.id == inventoryCount.id);
          if (menuItem) {
            menuItem.inventory = inventoryCount.inventory;
          }
        }
        state.menuItems = newMenuItems;
      },
    },
    actions: {
      async loadMenu(context) {
        const menuItems = await Server.getAllMenuItems();
        context.commit('setMenuItems', menuItems);
        const inventoryCounts = await Server.getInventoryCounts();
        context.commit('setInventoryCounts', inventoryCounts);
      },
      async updateInventoryCount(context, params) {
        let inventoryChange = params.inventoryCount;
        await Server.updateInventoryCount(params.dishId, inventoryChange);
        const inventoryCounts = await Server.getInventoryCounts();
        context.commit('setInventoryCounts', inventoryCounts);
      }
    },
    // enable strict mode (adds overhead!)
    // for dev mode and --debug builds only
    strict: process.env.DEBUGGING
  })

  return Store
})
