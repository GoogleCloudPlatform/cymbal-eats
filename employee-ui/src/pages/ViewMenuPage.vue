<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <Toolbar/>
    </q-header>

    <q-page-container>

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
            </q-card-section>
            <q-card-section>
              <div class="text-subtitle2">
                <q-btn
                  color="primary"
                  label="Adjust inventory"
                />
              </div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-3 q-pa-md">
          <q-card style="height: 100%">
            <q-card-section style="padding-top: 40%">
              <div class="text-subtitle2" style="text-align: center">
                <q-btn
                  color="primary"
                  label="Create a new menu item"
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
