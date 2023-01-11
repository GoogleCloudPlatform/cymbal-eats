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

        <form
          method="POST"
          action="/upload-picture"
          enctype="multipart/form-data"
        >
          <input class="file-input" type="file" name="picture">
          <br><br>
          <input type="hidden" name="menuItemId" :value="store.state.menuItemId"/>
          <q-btn
            type="submit"
            color="primary"
            no-caps
            label="Submit"
          />
        </form>

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { onMounted, computed } from 'vue';
  import { useRouter } from 'vue-router';
  import { useStore } from 'vuex';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const router = useRouter();

  onMounted(() => {
    if (!store.state.menuItemId) {
      store.commit('setMenuItemId', 4);
    }
  })


</script>
