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

        <q-list
          bordered
          separator
        >
          <q-item
            v-for="(order, i) in orders"
            :key="order.orderNumber"
            clickable
            v-ripple
            :active="activeOrderIndex==i"
            @click="activeOrderIndex=i"
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
          <h5 class="text-h5">
            Order {{ activeOrder.orderNumber }}
          </h5>
          <OrderView
            :items="activeOrder.orderItems"
            :allowdelete="false"
          />
          <q-btn
            v-if="orderCanBeCanceled(activeOrder.status)"
            color="red"
            label="Cancel &amp; refund"
            @click="cancelOrder(activeOrder.orderNumber)"
          />
          <q-btn
            v-if="activeOrder.status=='New'"
            color="primary"
            label="Start preparing"
            @click="updateOrderStatus(activeOrder.orderNumber, 'Being prepared')"
          />
          <q-btn
            v-if="activeOrder.status=='Being prepared'"
            color="primary"
            label="Ready for pickup"
            @click="updateOrderStatus(activeOrder.orderNumber, 'Ready for pickup')"
          />
          <q-btn
            v-if="activeOrder.status=='Ready for pickup'"
            color="primary"
            label="Picked up"
            @click="updateOrderStatus(activeOrder.orderNumber, 'Picked up')"
          />
        </q-card>

      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref, onMounted, computed } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter, useRoute } from 'vue-router';
  import { useTimeAgo } from '@vueuse/core';
  import { query, orderBy, doc, deleteDoc, collection, onSnapshot, updateDoc } from 'firebase/firestore';
  import OrderView from '../components/OrderView.vue';
  import * as Firestore from '../utils/Firestore.js';
  import * as Server from '../utils/Server.js';
  import Toolbar from '../components/Toolbar.vue';

  const store = useStore();
  const router = useRouter();
  const route = useRoute();

  const orders = ref([]);
  const activeOrderIndex = ref(-1);

  const activeOrder = computed(() => {
    if (activeOrderIndex.value > -1 && activeOrderIndex.value < orders.value.length) {
      return orders.value[activeOrderIndex.value];
    }
    else {
      return {};
    }
  })

  onMounted(async () => {
    const db = await Firestore.getDb();
    const q = query(collection(db, 'orders'), orderBy('placedAt', 'desc'));
    onSnapshot(q, (querySnapshot) => {
      orders.value = [];
      querySnapshot.forEach((doc) => {
        const order = doc.data();
        order.age = useTimeAgo(order.placedAt.seconds * 1000);
        orders.value.push(order);
      });
    });
  })

  async function cancelOrder(orderNumber) {
    if (confirm(`Are you sure you want to cancel order ${orderNumber}?`)) {
      try {
        await Server.updateOrderStatus(orderNumber, 'Canceled');
      }
      catch (ex) {
        alert(ex);
      }
    }
  }

  function orderCanBeCanceled(orderStatus) {
    const allowedStatuses = ['New', 'Being prepared'];
    return allowedStatuses.includes(orderStatus);
  }

  async function updateOrderStatus(orderNumber, newStatus) {
    try {
      await Server.updateOrderStatus(orderNumber, newStatus);
    }
    catch (ex) {
      alert(ex);
    }
  }

</script>

<style lang="sass">
  .active-order
    color: white
    background: #F2C037
</style>
