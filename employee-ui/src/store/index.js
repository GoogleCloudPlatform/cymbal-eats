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
