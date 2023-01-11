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

      <div class="q-pa-md q-gutter-md">

        <q-input filled v-model="tagLine" label="Tagline" />
        <q-input filled v-model="itemName" label="Item name" />
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

  import { ref } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter } from 'vue-router';
  import * as Server from '../utils/Server.js';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const router = useRouter();

  const tagLine = ref('');
  const itemName = ref('');
  const itemPrice = ref('');
  const spiceLevel = ref('');

  async function createMenuItem() {
    const newMenuItem = await Server.createMenuItem(
      tagLine.value, itemName.value, itemPrice.value, spiceLevel.value
    );
    store.commit('setMenuItemId', newMenuItem.id);
    router.push('/add-menu-item2')
  }

</script>
