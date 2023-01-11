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
  <q-toolbar>
    <q-toolbar-title>
      <img src="/images/Cymbal_Apps_Horizontal.png" height="45" style="margin-top:7px"/>
    </q-toolbar-title>

    <span v-if="store.state.userName">
      {{ store.state.userName }}
    </span>

    <q-avatar
      class="q-mx-lg"
      v-if="store.state.userPhotoUrl"
    >
      <img :src="store.state.userPhotoUrl">
    </q-avatar>

    <q-btn
      flat
      dense
      round
      icon="menu"
      aria-label="Menu"
    >
      <q-menu auto-close>
      <q-list style="min-width: 150px">
        <q-item clickable @click="goHome">
          <q-item-section avatar>
            <q-icon name="home" />
          </q-item-section>
          <q-item-section>
            Home
          </q-item-section>
        </q-item>
        <q-item
          v-if="!store.getters.userIsLoggedIn"
          clickable
          @click="logIn"
        >
          <q-item-section avatar>
            <q-icon name="fas fa-user" />
          </q-item-section>
          <q-item-section>
            Log in
          </q-item-section>
        </q-item>

        <q-item
          v-if="store.getters.userIsLoggedIn"
          clickable
          @click="goToRewardsPage"
        >
          <q-item-section avatar>
            <q-icon name="fas fa-list" />
          </q-item-section>
          <q-item-section>
            Rewards
          </q-item-section>
        </q-item>

        <q-item
          v-if="store.getters.userIsLoggedIn"
          clickable
          @click="logOut"
        >
          <q-item-section avatar>
            <q-icon name="fas fa-user-slash" />
          </q-item-section>
          <q-item-section>
            Log out
          </q-item-section>
        </q-item>
      </q-list>
      </q-menu>
    </q-btn>
  </q-toolbar>
</template>

<script setup>

  import { useRouter } from 'vue-router';
  import { useStore } from 'vuex';

  const router = useRouter();
  const store = useStore();

  function goHome() {
    router.push('/');
  }

  function goToRewardsPage() {
    router.push('/rewards');
  }

  function logIn() {
    store.dispatch('logIn');
  }

  function logOut() {
    store.dispatch('logOut');
  }

</script>
