import { store } from 'quasar/wrappers'
import { createStore } from 'vuex'
import dishesFile from '../assets/dishes.json';

export default store(function () {
  const Store = createStore({
    state: {
      dishes: []
    },
    getters: {
      orderTotal: state => {
        let retVal = 0;
        for (const dish of state.dishes) {
          retVal += parseFloat(dish.price);
        }
        return retVal;
      }
    },
    mutations: {
      addDish(state, dishId) {
        const dish = dishesFile.find(d => d.id==dishId);
        if (dish) {
          state.dishes.push(dish);
        }
      }
    },
    // enable strict mode (adds overhead!)
    // for dev mode and --debug builds only
    strict: process.env.DEBUGGING
  })

  return Store
})
