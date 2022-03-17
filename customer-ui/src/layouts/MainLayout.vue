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
                :label="'Order $' + dish.price.toFixed(2)"
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
