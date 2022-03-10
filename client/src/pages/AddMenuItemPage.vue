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

      <div class="q-pa-md q-gutter-md">

        <q-input filled v-model="tagLine" label="tagLine" />
        <q-input filled v-model="itemName" label="itemName" />
        <q-input filled v-model="itemImageURL" label="itemImageURL" />
        <q-input filled v-model="itemPrice" label="itemPrice" />
        <q-input filled v-model="spiceLevel" label="spiceLevel" />
        <q-btn
          label="Create menu item"
          @click="createMenuItem"
        />

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref, onMounted, computed } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter } from 'vue-router';
  import * as Server from '../utils/Server.js';

  const tagLine = ref('');
  const itemName = ref('');
  const itemImageURL = ref('');
  const itemPrice = ref('');
  const spiceLevel = ref('');
  
  async function createMenuItem() {
    await Server.createMenuItem(
      tagLine.value, itemName.value, itemImageURL.value, itemPrice.value,
      spiceLevel.value
    )
  }

</script>
