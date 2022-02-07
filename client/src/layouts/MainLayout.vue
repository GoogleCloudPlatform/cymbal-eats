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
          <q-carousel-slide name="first" img-src="https://cdn.quasar.dev/img/mountains.jpg">
            <div class="absolute-bottom custom-caption">
              <div class="text-h2">First stop</div>
              <div class="text-subtitle1">Mountains</div>
            </div>
          </q-carousel-slide>
          <q-carousel-slide name="second" img-src="https://cdn.quasar.dev/img/parallax1.jpg">
            <div class="absolute-bottom custom-caption">
              <div class="text-h2">Second stop</div>
              <div class="text-subtitle1">Famous City</div>
            </div>
          </q-carousel-slide>
          <q-carousel-slide name="third" img-src="https://cdn.quasar.dev/img/parallax2.jpg">
            <div class="absolute-bottom custom-caption">
              <div class="text-h2">Third stop</div>
              <div class="text-subtitle1">Famous Bridge</div>
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
      slide: ref('first')
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
