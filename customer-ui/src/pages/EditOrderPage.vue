<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
        />

        <q-toolbar-title>
          Cymbal Eats
        </q-toolbar-title>

      </q-toolbar>
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
        <div>
          <q-btn
            class="float-right"
            label="Keep Shopping"
            @click="goBackToShopping"
          />
          <br><br><br>
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
  import * as Server from '../utils/Server.js';
  import statesFile from '../assets/us-states.json';

  const store = useStore();
  const router = useRouter();

  const orderItems = computed(() => store.state.orderItems);
  const name = ref('Angela Jensen');
  const address = ref('1845 Denise St');
  const city = ref('Mountain View');
  const state = ref('CA');
  const zip = ref('94043');
  const states = ref(statesFile);

  function goBackToShopping() {
    router.push('/');
  }

  function deleteItem(itemIndex) {
    console.log(`deleteItem(${itemIndex}) called`);
    store.commit('deleteItem', itemIndex);
  }

  async function placeOrder() {
    try {
      const orderNumber = await Server.placeOrder(
        name.value, address.value, city.value, state.value, zip.value,
        store.state.orderItems
      )
      router.push('/order-status/' + orderNumber);
    }
    catch(ex) {
      console.error(ex);
      alert(ex.toString());
    }
  }

</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
