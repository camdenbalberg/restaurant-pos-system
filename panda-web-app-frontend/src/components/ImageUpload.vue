<template>
    <div class="image-upload-container">
      <!-- File input to choose an image -->
      <label for="file-upload" class="file-label">Choose an image:</label>
      <input 
        type="file" 
        id="file-upload" 
        @change="handleFileChange" 
        accept="image/*" 
        class="file-input"
      />
    </div>
  </template>
  
  <script>
  export default {
    // Expect menuId to be passed as a prop from the parent component
    props: {
      menuId: {
        type: Number,
        required: true
      }
    },
    methods: {
      handleFileChange(event) {
        const file = event.target.files[0]; // Get the selected file
  
        // If there's a file selected, emit an event with menuId and file
        if (file) {
          this.$emit('imageUploaded', { menuId: this.menuId, file });
        } else {
          console.error('No file selected');
        }
      }
    }
  };
  </script>
  
  <style scoped>
  .image-upload-container {
    margin-top: 20px;
    padding: 10px;
    background-color: #f7f7f7;
    border-radius: 5px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }
  
  .file-label {
    font-size: 1rem;
    margin-right: 10px;
    cursor: pointer;
    color: #333;
  }
  
  .file-input {
    display: none;
  }
  
  .file-input + .file-label {
    padding: 8px 16px;
    background-color: #4CAF50;
    color: white;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
  }
  
  .file-input + .file-label:hover {
    background-color: #45a049;
  }
  </style>
  