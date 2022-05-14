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
