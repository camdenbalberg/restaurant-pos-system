export default {
  // https://stackoverflow.com/questions/35045119/how-can-i-share-a-method-between-components-in-vue-js
  flashScaffolding: function () {
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