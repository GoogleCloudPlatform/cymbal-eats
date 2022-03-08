<template>
  <q-list
    v-if="items"
    bordered
    separator
  >
    <q-item
      v-for="(item, i) in props.items"
      :key="item.title"
    >
      <q-item-section side>
        <q-btn
          v-if="props.allowdelete"
          flat
          dense
          round
          icon="close"
          @click="emit('delete-item', i)"
        />
      </q-item-section>
      <q-item-section>
        {{ item.subtitle }}
      </q-item-section>
      <q-item-section side v-if="item.inventory<5">
        <q-badge color="orange" label="about to run out" />
      </q-item-section>
      <q-space/>
      <q-item-section side>
        <div class="text-grey-8">
          ${{ item.price }}
        </div>
      </q-item-section>
    </q-item>
    <q-item>
      <q-item-section side>
        <q-btn
          v-if="props.allowdelete"
          flat
          dense
          round
        />
      </q-item-section>
      <q-item-section>
        <b>Total</b>
      </q-item-section>
      <q-item-section side>
        <b>
          ${{ orderTotal }}
        </b>
      </q-item-section>
    </q-item>
  </q-list>
</template>

<script setup>

  import { computed } from 'vue';

const orderTotal = computed(() => {
    let retVal = 0;
    for (const item of props.items) {
      retVal += parseFloat(item.price);
    }
    return retVal.toFixed(2);
  });

  const props = defineProps(['items', 'allowdelete']);
  const emit = defineEmits(['delete-item']);

</script>
