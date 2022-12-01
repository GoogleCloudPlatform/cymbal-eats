<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <Toolbar/>
    </q-header>

    <q-page-container>

      <div class="q-pa-md">

        <div>
          <OrderView
            :items="orderItems"
            :allowdelete="true"
            v-on:delete-item="deleteItem"
          />
        </div>

        <div class="q-pt-xl q-gutter-md">
          <h4>
            Delivery address
          </h4>

          <q-input
            filled
            v-model="name"
            label="Name"
          />

          <q-input
            filled
            v-model="email"
            label="Email"
          />

          <q-input
            filled
            v-model="address"
            label="Address"
          />

          <q-input
            filled
            v-model="city"
            label="City"
          />

          <div style="display:flex; justify-content:space-between">
            <q-select
              style="width:45%"
              filled
              v-model="state"
              :options="states"
              label="State"
            />
            <q-input
              filled
              v-model="zip"
              label="Zip"
            />
          </div>
        </div>

        <br><br>
        <div class="q-gutter-sm">
          <q-btn
            class="float-right"
            label="Keep Shopping"
            @click="goBackToShopping"
          />
          <q-btn
            v-if="!store.getters.userIsLoggedIn"
            class="float-right"
            label="Log in for reward points"
            @click="logIn"
          />
          <img
            class="float-right"
            style="cursor: pointer;"
            src="/images/order-with-g-pay.png"
            @click="placeOrder"
          />
        </div>
        
      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref, computed } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter } from 'vue-router';
  import OrderView from '../components/OrderView.vue';
  import statesFile from '../assets/us-states.json';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const router = useRouter();

  const orderItems = computed(() => store.state.orderItems);
  const name = ref('Angela Jensen');
  const email = ref('ajensen9090+eats@gmail.com')
  const address = ref('1845 Denise St');
  const city = ref('Mountain View');
  const state = ref('CA');
  const zip = ref('94043');
  const states = ref(statesFile);

  // TODO: Create a new page that lists the user's orders.
  //       Link to it from the hamburger menu.

  function goBackToShopping() {
    router.push('/');
  }

  function deleteItem(itemIndex) {
    store.commit('deleteItem', itemIndex);
  }

  async function placeOrder() {
    try {
      const orderNumber = await store.dispatch('placeOrder', {
        name: name.value,
        email: email.value,
        address: address.value,
        city: city.value,
        state: state.value,
        zip: zip.value
      })
      if (!orderNumber) throw 'No order number returned from server';
      // TODO: Clear the cart after an order has been placed.
      router.push('/order-status/' + orderNumber);
    }
    catch(ex) {
      console.error(ex);
      alert(ex.toString());
    }
  }

  function logIn() {
    store.dispatch('logIn');
  }


</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
