<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <Toolbar/>
    </q-header>

    <q-page-container>

      <div class="q-gutter-md q-pa-md">
        <q-markup-table>
          <thead>
            <tr>
              <th class="text-left">Order number</th>
              <th class="text-left">Order amount</th>
              <th class="text-left">Reward points</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in store.state.orders" :key="order.id">
              <td>
                {{ order.orderNumber }}
              </td>
              <td>
                {{ makeDollarAmount(order.totalAmount) }}
              </td>
              <td>
                {{ order.rewardPoints }}
              </td>
            </tr>
          </tbody>
        </q-markup-table>
      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { computed, onMounted } from 'vue';
  import { useStore } from 'vuex';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();

  onMounted(async () => {
    store.dispatch('loadOrders');
  })

  function makeDollarAmount(amount) {
    if (amount) return '$' + amount.toFixed(2);
  }

</script>
