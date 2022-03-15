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

        <!-- TODO: Make the URL below an environment variable. -->
        <form method="POST" action="https://picture-upload-service-luu7kai33a-uc.a.run.app" enctype="multipart/form-data">
          <div class="field">
            <div id="file-js-example" class="file is-boxed has-name">
              <label class="file-label">
                <input class="file-input" type="file" name="picture">
                <span class="file-cta">
                  <span class="file-icon">
                    <i class="fas fa-upload"></i>
                  </span>
                  <span class="file-label">
                    Choose a file...
                  </span>
                </span>
                <span class="file-name">
                </span>
              </label>
            </div>
          </div>
          <input type="hidden" name="menuItemId" :value="store.state.menuItemId"/>
          <div class="field">
            <div class="control is-centered">
              <button class="button is-link">Submit</button>
            </div>
          </div>
        </form>

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref, watch, onMounted } from 'vue';
  import { useStore } from 'vuex';
  import * as Server from '../utils/Server.js';

  const store = useStore();

  onMounted(() => {
    // For debugging only. Remove for production.
    console.log('store.state.menuItemId', store.state.menuItemId)
    if (!store.state.menuItemId) {
      store.commit('setMenuItemId', 4);
    }
  })


</script>
