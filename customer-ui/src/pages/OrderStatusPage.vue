<template>
  <q-layout view="hhh lpr fff">
    <q-header elevated>
      <Toolbar/>
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

  import { ref, onMounted } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter, useRoute } from 'vue-router';
  import { doc, onSnapshot } from 'firebase/firestore';
  import * as Firebase from '../utils/Firebase.js';
  import OrderView from '../components/OrderView.vue';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const router = useRouter();
  const route = useRoute();

  const orderNumber = ref(route.params.orderNumber);
  const orderItems = ref([]);
  const status = ref('');

  onMounted(async () => {
    const db = await Firebase.getDb();
    onSnapshot(doc(db, 'orders', orderNumber.value), (doc) => {
      const order = doc.data();
      orderItems.value = order.orderItems;
      status.value = order.status;
    });
  })

</script>
