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

        <div style="margin-top:20px; display:flex; justify-content:space-between">
          <q-btn
            label="Keep Shopping"
            @click="goBackToShopping"
          />
          <q-btn
            color="primary"
            label="Place Order"
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
  import dishesFile from '../assets/dishes.json';

  const store = useStore();
  const router = useRouter();

  const orderItems = computed(() => store.state.orderItems);

  function goBackToShopping() {
    router.push('/');
  }

  function deleteItem(itemIndex) {
    console.log(`deleteItem(${itemIndex}) called`);
    store.commit('deleteItem', itemIndex);
  }

  function placeOrder() {
    router.push('/place-order');
  }

</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
