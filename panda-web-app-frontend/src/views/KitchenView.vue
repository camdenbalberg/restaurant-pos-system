<!-- src/views/AboutView.vue -->
<template>
  <body>
    <div id="weather">Loading weather...</div>
  

    <div>
      <Transactions />
      <router-link to="/">Go to Home</router-link>
    </div>
  </body>
</template>


<script>
  //weather script, API connection presently nonfunctional
  const apiKey = '6fb6a81a74d923c021c776074b270bc9'; // Replace with your OpenWeather API key
  const city = 'College Station'; // Change to your preferred city
  const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

  fetch(url)
      .then(response => {
          if (!response.ok) {
              throw new Error('Network response was not ok ' + response.statusText);
          }
          return response.json();
      })
      .then(data => {
          const temperature = data.main.temp;
          const weatherDescription = data.weather[0].description;
          document.getElementById('weather').innerText = 
              `Temperature: ${temperature}°C\nCondition: ${weatherDescription}`;
      })
      .catch(error => {
          document.getElementById('weather').innerText = 
              'Failed to load weather data: ' + error;
      });
  //end weather script
  
  import Transactions from '../components/KitchenComponents.vue';
  export default { 
    name: 'HomeView',
    components: {
    Transactions,
    },
  };
</script>

<style>
  body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
  }

  h1 {
      text-align: center;
      color: #333;
  }

  #weather {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 10px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
        }
</style>