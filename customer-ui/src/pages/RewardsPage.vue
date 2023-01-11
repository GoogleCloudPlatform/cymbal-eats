<!--
 Copyright 2023 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

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
