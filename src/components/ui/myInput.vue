<template>
    <div>
        <input :value="modelValue" @input="updateInput" class="input" type="text">
    </div>
</template>

<script>
export default {
    name: "my_input",

    props: {
        modelValue: [String, Number],
    },

    methods: {
        updateInput(event) {
            this.$emit('update:modelValue', event.target.value)
        }
    }
}
</script>

<style scoped>
.input {
    border: 2px solid solid rgb(53, 91, 91);
    padding: 10px 15px;
    margin-top: 10px;
    margin-right: 15px;

}
</style>