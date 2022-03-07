<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="restaurant"
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
            :active="activeOrder==order"
            @click="activeOrder=order"
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

        <hr>

        <q-card
          v-if="activeOrder.orderItems"
          class="q-pa-lg q-gutter-md"
        >
          <OrderView
            :items="activeOrder.orderItems"
            :allowdelete="false"
          />
          <q-btn
            color="red"
            label="Cancel &amp; refund"
            @click="cancel(activeOrder.orderNumber)"
          />
          <q-btn
            v-if="activeOrder.status=='New'"
            color="primary"
            label="Start preparing"
            @click="startPreparing(activeOrder.orderNumber)"
          />
          <q-btn
            v-if="activeOrder.status=='Being prepared'"
            color="primary"
            label="Ready for pickup"
            @click="readyForPickup(activeOrder.orderNumber)"
          />
          <q-btn
            v-if="activeOrder.status=='Ready for pickup'"
            color="primary"
            label="Picked up"
            @click="pickedUp(activeOrder.orderNumber)"
          />
        </q-card>

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
  import { getFirestore, query, orderBy, doc, deleteDoc, collection, onSnapshot, updateDoc } from 'firebase/firestore';
  import OrderView from '../components/OrderView.vue';

  // TODO: Show live inventory, based on the Inventory service.
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
  const activeOrder = ref({});

  const q = query(collection(db, 'orders'), orderBy('placedAt', 'desc'));
  onSnapshot(q, (querySnapshot) => {
    orders.value = [];
    querySnapshot.forEach((doc) => {
      const order = doc.data();
      order.age = useTimeAgo(order.placedAt.seconds * 1000);
      orders.value.push(order);
    });
  });

  async function cancel(orderNumber) {
    if (confirm(`Are you sure you want to delete order ${orderNumber}?`)) {
      const orderDoc = doc(db, 'orders', orderNumber.toString());
      await deleteDoc(orderDoc);
    }
  }

  async function startPreparing(orderNumber) {
    const orderDoc = doc(db, 'orders', orderNumber.toString());
    await updateDoc(orderDoc, { status: 'Being prepared' });
  }

  async function readyForPickup(orderNumber) {
    const orderDoc = doc(db, 'orders', orderNumber.toString());
    await updateDoc(orderDoc, { status: 'Ready for pickup' });
  }

  async function pickedUp(orderNumber) {
    const orderDoc = doc(db, 'orders', orderNumber.toString());
    await updateDoc(orderDoc, { status: 'Out for delivery' });
  }

</script>

<style lang="sass">
  .active-order
    color: white
    background: #F2C037
</style>
