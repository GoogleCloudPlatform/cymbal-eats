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
        <q-carousel
          arrows
          animated
          infinite
          transition-prev="slide-right"
          transition-next="slide-left"
          :autoplay="true"
          v-model="dish"
          height="400px"
        >
          <q-carousel-slide
            v-for="dish in dishes"
            :name="dish.id"
            :key="dish.id"
            :img-src="dish.image"
          >
            <div class="absolute-bottom custom-caption">
              <div class="text-h2">
                {{ dish.title }}
              </div>
              <div class="text-subtitle1">
                {{ dish.subtitle }}
              </div>
              <q-btn
                color="primary"
                :label="'Order $' + dish.price"
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

  const store = useStore();
  const router = useRouter();
  const dish = ref(1);
  const dishes = computed(() => store.state.menuItems);

  // TODO: Add admin UI for adding new menu items.
  //       Create the new item in the menu database, with status=draft.
  //       Upload image to GCS, with name being the menu item id.
  //       On the server, when an image is uploaded, check that it's not adult or violent.
  //       Generate thumbnail.
  //       Generate new entry in menu service.
  // TODO: Order service should check inventory svc, and deduct from inventory.
  // TODO: Add front-page that is not connected to the database, for demo. Put a welcome page under /.
  // TODO: Add +/- buttons to set quantity of each order line in the order.
  // TODO: If you order the same dish twice, make it one single order line with qty of 2.
  // TODO: Send quantity to the order service.
  // TODO: Deploy the consumer web front-end to the cloud.
  // TODO: Deploy the admin web front-end to the cloud.
  // TODO: Update order status through the Order service, not directly in Firestore.

  onMounted(async () => {
    await store.dispatch('loadMenu');
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
