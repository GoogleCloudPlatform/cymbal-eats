import { store } from 'quasar/wrappers'
import { createStore } from 'vuex'
import dishesFile from '../assets/dishes.json';

export default store(function () {
  const Store = createStore({
    state: {
      orderItems: [],
      status : '',
    },
    getters: {
      orderTotal: state => {
        let retVal = 0;
        for (const item of state.orderItems) {
          retVal += parseFloat(item.price);
        }
        return retVal.toFixed(2);
      }
    },
    mutations: {
      addDishToOrder(state, dishId) {
        const dish = dishesFile.find(d => d.id==dishId);
        if (dish) {
          state.orderItems.push(dish);
        }
      },
      deleteItem(state, index) {
        state.orderItems.splice(index, 1);
      },
      setOrder(state, {orderItems, status}) {
        state.orderItems = orderItems.splice(0);
        state.status = status;
      }
    },
    // enable strict mode (adds overhead!)
    // for dev mode and --debug builds only
    strict: process.env.DEBUGGING
  })

  return Store
})
