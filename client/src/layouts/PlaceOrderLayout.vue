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

        <h3>
          Delivery address
        </h3>

        <q-input
          filled
          v-model="name"
          label="Name"
        />

        <q-input
          filled
          v-model="address"
          label="Address"
        />

        <q-input
          filled
          v-model="city"
          label="City"
        />

        <div style="display:flex; justify-content:space-between">
          <q-select
            style="width:45%"
            filled
            v-model="state"
            :options="states"
            label="State"
          />
          <q-input
            filled
            v-model="zip"
            label="Zip"
          />
        </div>

        <q-btn
          label="Keep Shopping"
          @click="goBackToShopping"
        />
        <br><br>
        <img src="/images/order-with-g-pay.png"/>
        
      </div>

    </q-page-container>
  </q-layout>
</template>

<script setup>

  import { ref } from 'vue';
  import { useStore } from 'vuex';
  import { useRouter } from 'vue-router';

  const store = useStore();
  const router = useRouter();

  const name = ref('Angela Jensen');
  const address = ref('1845 Denise St');
  const city = ref('Mountain View');
  const state = ref('CA');
  const zip = ref('94043');
  const states = ref([
    'AL',
    'AK',
    'AS',
    'AZ',
    'AR',
    'CA',
    'CO',
    'CT',
    'DE',
    'DC',
    'FL',
    'GA',
    'GU',
    'HI',
    'ID',
    'IL',
    'IN',
    'IA',
    'KS',
    'KY',
    'LA',
    'ME',
    'MD',
    'MA',
    'MI',
    'MN',
    'MS',
    'MO',
    'MT',
    'NE',
    'NV',
    'NH',
    'NJ',
    'NM',
    'NY',
    'NC',
    'ND',
    'MP',
    'OH',
    'OK',
    'OR',
    'PA',
    'PR',
    'RI',
    'SC',
    'SD',
    'TN',
    'TX',
    'UT',
    'VT',
    'VA',
    'VI',
    'WA',
    'WV',
    'WI',
    'WY'
  ])

  function goBackToShopping() {
    router.push('/');
  }

</script>
