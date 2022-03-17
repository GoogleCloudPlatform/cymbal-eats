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

        <div class="row items-center">
          <div class="col-4">
            Order number
          </div>
          <div class="col-4">
            <q-input
              filled
              v-model="orderNumber"
              :readonly="true"
            />
          </div>
        </div>

        <div class="row items-center">
          <div class="col-4">
            Order status
          </div>
          <div class="col-4">
            <q-input
              filled
              v-model="status"
              :readonly="true"
            />
          </div>
        </div>
          
        <br>
        <br>
        
        <OrderView
          :items="orderItems"
          :allowdelete="false"
        />

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
  import OrderView from '../components/OrderView.vue';

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
  const orderItems = ref([]);
  const status = ref('');

  onSnapshot(doc(db, 'orders', orderNumber.value), (doc) => {
    const order = doc.data();
    orderItems.value = order.orderItems;
    status.value = order.status;
  });


</script>
