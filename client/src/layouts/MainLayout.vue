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
                @click="placeOrder(dish.id)"
              />
            </div>
          </q-carousel-slide>
        </q-carousel>
      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref } from 'vue';
  import dishesFile from '../assets/dishes.json';

  const dish = ref(1);
  const dishes = ref(dishesFile);

  function placeOrder(dishId) {
    console.log(`placeOrder(${dishId})`)
  }

</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
