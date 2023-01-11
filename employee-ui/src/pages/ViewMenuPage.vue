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

      <div class="q-pa-md row flex-center">
        <div class="col-auto">
          <q-checkbox
            size="lg"
            v-model="displayOnlyReadyItems"
          >
            <span style="font-size:150%">
              Display only Ready items
            </span>
          </q-checkbox>
        </div>
        <div class="col q-ml-lg">
          <q-btn
            size="lg"
            color="primary"
            label="Create a new menu item"
            @click="goToCreateMenuItemPage"
          />
        </div>
      </div>
      <div class="q-pa-md row">
        <div class="col-3 q-pa-md" v-for="dish in dishes" :key="dish.id">
          <q-card>
            <div
              class="q-carousel__slide"
              style="height:200px"
              :style="'background-image: url('+dish.itemImageURL+');'"
            />
            <q-card-section>
              <div class="text-h6">
                {{ dish.itemName }}              
              </div>
              <div class="text-subtitle2">
                {{ dish.tagLine }}              
              </div>
              <div class="q-mt-lg">
                Status: {{ dish.status }}
              </div>
              <div>
                Price: ${{ dish.itemPrice.toFixed(2) }}
              </div>
              <div>
                Spice level: {{ dish.spiceLevel }}
              </div>
              <div>
                Inventory: {{ dish.inventory }}
              </div>
            </q-card-section>
            <q-card-section>
              <div class="text-subtitle2">
                <q-btn
                  color="primary"
                  label="Adjust inventory"
                  @click="editInventory(dish.id, dish.name, dish.inventory)"
                />
              </div>
            </q-card-section>
          </q-card>
        </div>
      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref, onMounted, computed } from 'vue';
  import { useStore } from 'vuex';
  import { useQuasar } from 'quasar';
  import { useRouter } from 'vue-router';
  import Toolbar from '../components/Toolbar.vue';

  const router = useRouter();
  const store = useStore();
  const $q = useQuasar();
  const dishes = computed(() =>
    store.state.menuItems
    .filter(item => item.status=='Ready' || !displayOnlyReadyItems.value)
  );

  const displayOnlyReadyItems = ref(true);

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

  function goToCreateMenuItemPage() {
    router.push('/add-menu-item');
  }

</script>
