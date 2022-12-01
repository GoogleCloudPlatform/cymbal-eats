import { store } from 'quasar/wrappers';
import { createStore } from 'vuex';
import * as Server from '../utils/Server.js';
import * as Firebase from '../utils/Firebase.js';

export default store(function () {
  const Store = createStore({
    state: {
      menuItems: [],
      orderItems: [],
      status : '',
      userName: '',
      userPhotoUrl: '',
      orders: []
    },
    getters: {
      userIsLoggedIn(state) {
        return state.userName != '';
      }
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
      setUser(state, {userName, userPhotoUrl}) {
        state.userName = userName;
        state.userPhotoUrl = userPhotoUrl;
      },
      setOrders(state, orders) {
        state.orders = orders;
      }
    },
    actions: {
      async loadMenu(context) {
        const menuItems = await Server.getMenuItems();
        context.commit('setMenuItems', menuItems);
        const inventoryCounts = await Server.getInventoryCounts();
        context.commit('setInventoryCounts', inventoryCounts);
      },
      async placeOrder(context, {name, email, address, city, state, zip}) {
        // TODO: Check if the user is logged in.
        const idToken = await Firebase.getToken();
        const orderNumber = await Server.placeOrder(
          idToken, name, email, address, city, state, zip, context.state.orderItems
        );
        return orderNumber;
      },
      async logIn(context) {
        try {
          const user = await Firebase.logIn();
          context.commit('setUser', {userName: user.displayName, userPhotoUrl: user.photoURL});
        }
        catch (ex) {
          console.log(ex)
        }
      },
      async logOut(context) {
        try {
          Firebase.logOut();
          context.commit('setUser', {userName: '', userPhotoUrl: ''});
        }
        catch (ex) {
          console.log(ex)
        }
      },
      async loadOrders(context) {
        const token = await Firebase.getToken();
        const orders = await Server.getOrders(token);
        context.commit('setOrders', orders);
      }
    },
    // enable strict mode (adds overhead!)
    // for dev mode and --debug builds only
    strict: process.env.DEBUGGING
  })

  return Store
})
