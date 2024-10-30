<template>
    <div class="popup">
      <p>{{ message }}</p>
      <button @click="$emit('close')">Close</button>
    </div>
  </template>
  
  <script>
  export default {
    name: 'Popup',
    props: {
      message: {
        type: String,
        required: true,
      },
    },
  };
  </script>
  
  <style>
  .popup {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: white;
    padding: 20px;
    border: 1px solid black;
  }
  </style>