<script setup>
import { RouterView } from 'vue-router'
import AppHeader from "./components/AppHeader.vue";
import GlobalNotification from "./components/GlobalNotification.vue";
import AppFooter from "./components/AppFooter.vue";
</script>

<template>
  <div class="body">
    <div class="main">

      <app-header />
      <global-notification></global-notification>
      <RouterView />
    </div>


  </div>
  <app-footer></app-footer>
</template>

<style scoped> .body {
   height: 100%;
 }

 #wrap {
   min-height: 100%;
 }

 .main {
   padding-bottom: 100px;
   /*Высота футера*/
 }

 footer {
   margin-bottom: 10%;
   height: 100px;
   /*Высота футера*/
 }
</style>