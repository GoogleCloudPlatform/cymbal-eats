<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <Toolbar/>
    </q-header>

    <q-page-container>

      <div class="q-pa-xl q-gutter-md">

        Welcome! From here you can:
        <ul>
          <li>
            <router-link to="kitchen">
              View and update pending orders
            </router-link>
          </li>
          <li>
            <router-link to="view-menu">
              Manage menu
            </router-link>
          </li>
        </ul>

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import Toolbar from '../components/Toolbar.vue';

</script>
