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
          Kitchen
        </q-toolbar-title>

      </q-toolbar>
    </q-header>

    <q-page-container>

      <div class="q-gutter-md q-pa-md">

        <q-list
          bordered
          separator
        >
          <q-item
            v-for="order in orders"
            :key="order.orderNumber"
            clickable
            v-ripple
            :active="activeOrder==order.orderNumber"
            @click="activeOrder=order.orderNumber"
            active-class="active-order"
          >
            <q-item-section>
              {{ order.orderNumber }}
            </q-item-section>
            <q-item-section>
              {{ order.age }}
            </q-item-section>
            <q-item-section>
              {{ order.status }}
            </q-item-section>
          </q-item>
        </q-list>


      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter, useRoute } from 'vue-router';
  import { useTimeAgo } from '@vueuse/core';
  import { initializeApp } from 'firebase/app';
  import { getAnalytics } from "firebase/analytics";
  import { getFirestore, query, orderBy, collection, onSnapshot } from 'firebase/firestore';

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

  const orders = ref([]);
  const activeOrder = ref(0);

  const q = query(collection(db, 'orders'), orderBy('placedAt'));
  onSnapshot(q, (querySnapshot) => {
    orders.value = [];
    querySnapshot.forEach((doc) => {
      const order = doc.data();
      order.age = useTimeAgo(order.placedAt.seconds * 1000);
      orders.value.push(order);
    });
  });


</script>

<style lang="sass">
  .active-order
    color: white
    background: #F2C037
</style>
