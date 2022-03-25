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
          Menu items
        </q-toolbar-title>

      </q-toolbar>
    </q-header>

    <q-page-container>

      <div class="q-pa-md q-gutter-md">

        <q-markup-table>
          <thead>
            <tr>
              <th class="text-left">Tagline</th>
              <th class="text-left">Name</th>
              <th>Price</th>
              <th class="text-left">Inventory</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="dish in dishes"
              :key="dish.id"
            >
              <td>{{ dish.tagLine }}</td>
              <td>{{ dish.itemName }}</td>
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

  const store = useStore();
  const $q = useQuasar();
  const dishes = computed(() => store.state.menuItems);

  onMounted(async () => {
    $q.loading.show();
    await store.dispatch('loadMenu');
    console.log(dishes.value)
    $q.loading.hide();
  });

  function editInventory(dishId, dishName, dishInventory) {
    $q.dialog({
      title: dishName,
      message: 'What is the new inventory count?',
      prompt: {
        model: dishInventory,
        type: 'number',
        filled: true,
        dense: true
      },
      cancel: true,
      persistent: true
    }).onOk(data => {
      console.log('>>>> OK, send ', data, ' to inventory service')
    })
  }

</script>
