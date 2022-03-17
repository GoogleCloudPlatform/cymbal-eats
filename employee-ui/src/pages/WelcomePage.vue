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
          Cymbal Eats Employee Portal
        </q-toolbar-title>

      </q-toolbar>
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
            View the menu items in the system
            <i>[Not yet implemented]</i>
          </li>
          <li>
            <router-link to="add-menu-item">
              Create new menu items in the system
            </router-link>
          </li>
        </ul>

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

</script>
