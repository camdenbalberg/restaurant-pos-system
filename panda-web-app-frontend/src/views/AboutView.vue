<!-- src/views/AboutView.vue -->
<template>
  <div>
    <img src="../assets/biglogo.png" id="big-logo" alt="12Team12 Main Logo">

    <!-- Show team pictures -->
    <h1><strong>MEET THE TEAM</strong></h1>

    <div class="team-grid">
      <img class="member-card" src="../assets/about/connor.jpg" alt="Connor, scrum master">
      <img class="member-card" src="../assets/about/leonardo.jpg" alt="Leonardo, refactoring god">
      <img class="member-card" src="../assets/about/eduardo.jpg" alt="Eduardo, customer concierge">
      <img class="member-card" src="../assets/about/nathan.jpg" alt="Nathan, design dynamo">
      <img class="member-card" src="../assets/about/steven.jpg" alt="Steven, clutch king">
      <img class="member-card" src="../assets/about/camden.jpg" alt="Camden, employee enforcer">
    </div>

    <div class="team-picture-wrapper">
      <img class="team-picture" src="../assets/about/all.jpg" alt="Team picture">
    </div>
    


    <!-- Show general about text for the project -->
    <h1><strong>ABOUT</strong></h1>

    <p>
      12Team12 is committed to making a simple yet effective management system for Panda Express.  Focused is placed on accessibility and human centered design to ensure that as many customers and employees are able to easily use the system.
      <br>
      The system can be accessed here: <a href=" https://frontend-12-team-12-39b757c25b17.herokuapp.com/">https://frontend-12-team-12-39b757c25b17.herokuapp.com/</a>
      <br>
      The project is being developed using Vuejs and Ruby on Rails.
    </p>
    
    <!-- Show watermark -->
    <div class="small-logo-wrapper">
      <img src="../assets/smalllogo.png" id="small-logo" alt="12Team12 Small Logo">
      <div id="small-logo-text">12Team12 Systems</div>
    </div>
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

  #big-logo {
    scale: 0.75;
    /* Center the image */
    margin: auto;
    width: 50%;
  }

  #small-logo {
    width: 8%;
    margin-bottom: 20px;
    opacity: 30%;
  }

  #small-logo-text {
    font-size: 30px;
    opacity: 80%;
  }

  .small-logo-wrapper {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    
    margin-top: 15rem;
    margin-bottom: 10rem;
  }

  p {
    font-size: 30px;
    text-align: left;
    margin-left: 8%;
    margin-right: 8%;
  }

  br {
   display: block;
   margin: 20px 0;
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

  h1 {
    font-size: 70px;
    text-align: left;
    margin-left: 8%;
  }

  .team-grid {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: center;
  }

  .member-card {
    margin: 1.5%;
    width: 38rem;
  }

  .team-picture-wrapper {
    display: flex;
    justify-content: center;
    margin-top: 40px;
    margin-bottom: 70px;
  }

  .team-picture {
    width: 60%;
  }
</style>