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
          v-model="slide"
          height="400px"
        >
          <q-carousel-slide
            v-for="slide in slides"
            :name="slide.name"
            :key="slide.name"
            img-src="/images/cottage-cheese-with-peas.jpg"
          >
            <div class="absolute-bottom custom-caption">
              <div class="text-h2">
                {{ slide.title }}
              </div>
              <div class="text-subtitle1">
                {{ slide.subtitle }}
              </div>
              <q-btn
                color="primary"
                label="Order"
              />
            </div>
          </q-carousel-slide>
        </q-carousel>
      </div>

    </q-page-container>
  </q-layout>
</template>

<script>

import { defineComponent, ref } from 'vue'

export default defineComponent({
  name: 'MainLayout',

  components: {
  },

  setup () {

    return {
      slide: ref('first'),
      slides: ref([
        {name: 'first', title: 'Spicy', subtitle: 'Cottage cheese with peas'},
        {name: 'second', title: 'Spicy 2', subtitle: 'Cottage cheese with peas 2'},
      ])
    }
  }
})
</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
