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

      <div class="q-pa-md row">
        <div class="col-3 q-pa-md" v-for="dish in dishes" :key="dish.id">
          <q-card class="my-card">
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
              <div class="text-subtitle2">
                Spice level:
                <span v-html="getSpiceLevel(dish.spiceLevel)"/>
              </div>
            </q-card-section>
            <q-card-section>
              <div class="text-subtitle2">
                <q-btn
                  color="primary"
                  :label="'Order $' + dish.itemPrice.toFixed(2)"
                  @click="addDishToOrder(dish.id)"
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
  import { useRouter } from 'vue-router';
  import { useQuasar } from 'quasar';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const router = useRouter();
  const $q = useQuasar();
  const dish = ref(1);
  const dishes = computed(() => store.state.menuItems);

  onMounted(async () => {
    $q.loading.show();
    await store.dispatch('loadMenu');
    $q.loading.hide();
  });

  function addDishToOrder(dishId) {
    store.commit('addDishToOrder', dishId);
    router.push('edit-order');
  }

  function getSpiceLevel(spiceLevel) {
    if (!spiceLevel) return '-';
    let retVal = '<span style="color:red">';
    for (let i=0; i<spiceLevel; i++) {
      retVal += '<i class="fas fa-pepper-hot"></i>';
    }
    retVal += '</span>';
    return retVal;
  }

</script>
