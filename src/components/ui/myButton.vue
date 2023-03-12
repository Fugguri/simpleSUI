
<template>
    <button class="btn">
        <slot></slot>
    </button>
</template>
<script>
export default {
    name: "my_btn",
}
</script>

<style scoped>
body {
    align-items: center;
}

.btn {
    overflow: visible;
    /* margin: 3px; */
    padding: 3px;
    width: 70px;
    height: 30px;
    /* border: 1px solid #876500; */
    border-radius: 10px;
    /* color: rgb(0, 0, 0); */
    background-color: #89816b;
    background: #89816b;

}
</style>