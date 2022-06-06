<template>
  <q-toolbar>
    <q-toolbar-title>
      <img src="/images/Cymbal_Apps_Horizontal.png" height="45" style="margin-top:7px"/>
    </q-toolbar-title>
    <q-btn
      flat
      dense
      round
      icon="menu"
      aria-label="Menu"
    >
      <q-menu>
      <q-list style="min-width: 100px">
        <q-item clickable v-close-popup @click="goHome()">
        <q-item-section avatar>
          <q-icon name="home" />
        </q-item-section>
        <q-item-section>
          Home
        </q-item-section>
        </q-item>
      </q-list>
      </q-menu>
    </q-btn>
  </q-toolbar>
</template>

<script setup>

  import { useRouter } from 'vue-router';

  const router = useRouter();

  function goHome() {
    router.push('/');
  }

</script>
