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
          Add menu item
        </q-toolbar-title>

      </q-toolbar>
    </q-header>

    <q-page-container>

      <div class="q-pa-md q-gutter-md">

        <q-input filled v-model="tagLine" label="Tagline" />
        <q-input filled v-model="itemName" label="Item name" />
        <q-file filled v-model="itemImage" label="Item image" />
        <q-input filled v-model="itemPrice" label="Item price" />
        <q-input filled v-model="spiceLevel" label="Spice level" />
        <q-btn
          label="Create menu item"
          color="primary"
          @click="createMenuItem"
        />

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref, watch } from 'vue';
  import * as Server from '../utils/Server.js';

  const tagLine = ref('');
  const itemName = ref('');
  const itemImage = ref();
  const itemPrice = ref('');
  const spiceLevel = ref('');

  // TODO: Send the item properties and the file to a new endpoint on the server.
  //       That serverside code will add the record in the menu service and it
  //       will upload the file to GCS. It's too hard/insecure to upload to
  //       GCS directly from the client.
  
  watch(() => itemImage.value, (newValue) => {
    const reader = new FileReader();
    reader.onload = async function(e) {
      console.log(e.target.result)
    }
    reader.readAsDataURL(newValue);
  })
  
  async function createMenuItem() {
    await Server.createMenuItem(
      tagLine.value, itemName.value, itemPrice.value,
      spiceLevel.value
    )
  }

</script>
