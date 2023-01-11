<!--
 Copyright 2023 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

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
