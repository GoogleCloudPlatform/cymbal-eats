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

      <div class="q-pa-md q-gutter-md">

        <q-markup-table>
          <thead>
            <tr>
              <th class="text-left">Name</th>
              <th class="text-left">Tagline</th>
              <th>Price</th>
              <th class="text-left">Inventory</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="dish in dishes"
              :key="dish.id"
            >
              <td>{{ dish.itemName }}</td>
              <td>{{ dish.tagLine }}</td>
              <td class="text-center">${{ dish.itemPrice.toFixed(2) }}</td>
              <td>
                {{ dish.inventory || '?' }}
                <q-btn
                  dense
                  round
                  flat
                  color="primary"
                  icon="edit"
                  @click="editInventory(dish.id, dish.itemName, dish.inventory)"
                />
              </td>
            </tr>
          </tbody>
        </q-markup-table>

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { onMounted, computed } from 'vue';
  import { useStore } from 'vuex';
  import { useQuasar } from 'quasar';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const $q = useQuasar();
  const dishes = computed(() => store.state.menuItems);

  onMounted(async () => {
    $q.loading.show();
    await store.dispatch('loadMenu');
    $q.loading.hide();
  });

  function editInventory(dishId, dishName, dishInventory) {
    $q.dialog({
      title: dishName,
      message: 'How much to add to the inventory count?',
      prompt: {
        model: '',
        type: 'number',
        filled: true,
        dense: true
      },
      cancel: true
    }).onOk(inventoryCount => {
      store.dispatch('updateInventoryCount', {
        dishId: dishId,
        inventoryCount: parseInt(inventoryCount)
      });
    })
  }

</script>
