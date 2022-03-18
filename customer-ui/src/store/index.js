import { store } from 'quasar/wrappers';
import { createStore } from 'vuex';
import * as Server from '../utils/Server.js';

export default store(function () {
  const Store = createStore({
    state: {
      menuItems: [],
      orderItems: [],
      status : ''
    },
    getters: {
    },
    mutations: {
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
      addDishToOrder(state, dishId) {
        const dish = state.menuItems.find(d => d.id==dishId);
        if (dish) {
          state.orderItems.push({...dish, quantity: 1});
        }
      },
      deleteItem(state, index) {
        state.orderItems.splice(index, 1);
      },
      setOrder(state, {orderItems, status}) {
        state.orderItems = orderItems.splice(0);
        state.status = status;
      },
    },
    actions: {
      async loadMenu(context) {
        const menuItems = await Server.getMenuItems();
        console.log(menuItems);
        context.commit('setMenuItems', menuItems);
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
