<!-- src/views/AboutView.vue -->
<template>
  <div>
    <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">
    <p>
      12Team12 is committed to making a simple yet effective management system for Panda Express.  Focused is placed on accessibility and human centered design to ensure that as many customers and employees are able to easily use the system.
      <br>
      The system can be accessed here: <a href=" https://frontend-12-team-12-39b757c25b17.herokuapp.com/">https://frontend-12-team-12-39b757c25b17.herokuapp.com/</a>
      <br>
      The project is being developed using Vuejs and Ruby on Rails.
    </p>
  </div>
</template>

<script>
export default {
  name: 'AboutView',
};
</script>

<style scoped>
  :root {
    --accentColor: #dc8a78;
    --accentColorIntense: #db5132;
    --accentColorWeak: #edbeb4;
    --surfaceColor: #ccd0da;
    --backgroundColor: #eff1f5;
    --borderColor: #dce0e8;
    --textColor: #4c4f69;
    --subTextColor: #5c5f77;
    --transparent: #00000000;
  }

  img {
    scale: 0.75;
    /* Center the image */
    margin: auto;
    width: 50%;
  }

  p {
    font-size: 30px;
    margin-left: 200px;
    margin-right: 200px;
  }

  br {
   display: block;
   margin: 50px 0;
  }

  a:link {
    color: blue;
    text-decoration: underline;
  }

  /* visited link */
  a:visited {
    color: blue;
    text-decoration: underline;
  }

  /* mouse over link */
  a:hover {
    color: var(--accentColorIntense);
    text-decoration: underline;
  }

  /* selected link */
  a:active {
    color: var(--accentColorIntense);
    text-decoration: underline;
}
</style>