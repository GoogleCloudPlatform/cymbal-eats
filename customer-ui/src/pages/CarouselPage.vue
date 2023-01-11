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

      <div class="q-pa-md">
        <q-carousel
          arrows
          animated
          infinite
          transition-prev="slide-right"
          transition-next="slide-left"
          v-model="dish"
          height="400px"
        >
          <q-carousel-slide
            v-for="dish in dishes"
            :name="dish.id"
            :key="dish.id"
            :img-src="dish.itemImageURL"
          >
            <div class="absolute-bottom custom-caption">
              <div class="text-h2">
                {{ dish.tagLine }}
              </div>
              <div class="text-subtitle1">
                {{ dish.itemName }}
              </div>
              <q-btn
                color="primary"
                :label="'Order $' + dish.itemPrice.toFixed(2)"
                @click="addDishToOrder(dish.id)"
              />
              <div>
                Inventory: {{ dish.inventory }}
              </div>
            </div>
          </q-carousel-slide>
        </q-carousel>
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
    // Open the first dish in the carousel.
    dish.value = dishes.value[0].id;
    $q.loading.hide();
  });

  function addDishToOrder(dishId) {
    store.commit('addDishToOrder', dishId);
    router.push('edit-order');
  }

</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
