export default {
  // @vuese
  // Flash the scaffolding to alert the user something has changed.
  // Call this function when something significant has happened, like an API request finishing or items added to cart.
  flashScaffolding: function () {
    // https://stackoverflow.com/questions/35045119/how-can-i-share-a-method-between-components-in-vue-js
    var opacity = 0;
    var scaffold = document.getElementsByClassName("scaffold")[0];
    var intervalId = setInterval(function () {
      if (opacity >= 1) {
        clearInterval(intervalId);
      }
      scaffold.style.background = "rgba(204, 208, 218, " + opacity + ")";
      opacity += 0.01;
    }, 5) 
  }
}