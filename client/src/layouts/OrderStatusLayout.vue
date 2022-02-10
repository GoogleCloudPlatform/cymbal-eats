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

      <div class="q-gutter-md q-pa-md">

        <br>
        <br>
        {{ orderNumber }}
        <br>
        <br>
        {{ store.state.status }}

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter, useRoute } from 'vue-router';
  import { initializeApp } from 'firebase/app';
  import { getAnalytics } from "firebase/analytics";
  import { getFirestore, doc, onSnapshot } from 'firebase/firestore';
  import * as Server from '../utils/Server.js';

  const store = useStore();
  const router = useRouter();
  const route = useRoute();

  const firebaseConfig = {
    apiKey: "AIzaSyCUyX0Gr2PagBPr9Mu1FovoFIF2UbjiHdA",
    authDomain: "cymbal-eats.firebaseapp.com",
    projectId: "cymbal-eats",
    storageBucket: "cymbal-eats.appspot.com",
    messagingSenderId: "713244360550",
    appId: "1:713244360550:web:527af1da8b5a83f26c92a7",
    measurementId: "G-WBKZRJC2DP"
  };
  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
  const db = getFirestore();

  const orderNumber = ref(route.params.orderNumber);

  onSnapshot(doc(db, 'orders', orderNumber.value), (doc) => {
    const order = doc.data();
    store.commit('setOrder', {orderItems: order.orderItems, status: order.status});
  });


</script>
