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

      <div class="q-pa-md">

        <div>
          <q-list
            bordered
            separator
          >
            <q-item
              v-for="(item, i) in store.state.orderItems"
              :key="item.title"
            >
              <q-item-section side>
                <q-btn
                  flat
                  dense
                  round
                  icon="close"
                  @click="deleteItem(i)"
                />
              </q-item-section>
              <q-item-section>
                {{ item.subtitle }}
              </q-item-section>
              <q-item-section side>
                <div class="text-grey-8">
                  ${{ item.price }}
                </div>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section side>
                <q-btn flat dense round />
              </q-item-section>
              <q-item-section>
                <b>Total</b>
              </q-item-section>
              <q-item-section side>
                <b>
                  ${{ store.getters.orderTotal }}
                </b>
              </q-item-section>
            </q-item>
          </q-list>
        </div>

        <div style="margin-top:20px; display:flex; justify-content:space-between">
          <q-btn
            label="Keep Shopping"
            @click="goBackToShopping"
          />
          <q-btn
            color="primary"
            label="Place Order"
            @click="placeOrder"
          />
        </div>
        
      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter } from 'vue-router';
  import dishesFile from '../assets/dishes.json';

  const store = useStore();
  const router = useRouter();

  const dish = ref(1);
  const dishes = ref(dishesFile);

  function deleteItem(itemIndex) {
    store.commit('deleteItem', itemIndex);
  }

  function goBackToShopping() {
    router.push('/');
  }

  function placeOrder() {
    router.push('/place-order');
  }

</script>

<style lang="sass" scoped>
  .custom-caption
    text-align: center
    padding: 12px
    color: white
    background-color: rgba(0, 0, 0, .3)
</style>
