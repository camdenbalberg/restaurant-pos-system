<!-- src/App.vue -->
<template>
  <div id="app">
    <div class="scaffold">
      <RouterLink to="/">
        <button class="scaffold-item" id="home-button">Home</button>
      </RouterLink>
      
      <img class="scaffold-item" src="./assets/smalllogo.png" id="scaffold-logo" alt="12Team12 Scaffold Logo" @click="goHome">
      <div class="scaffold-item">
        <div id="clock">
          <div v-show="time">{{ time }}</div>
          <!-- TODO: Add uptime here -->
        </div>

        <div id="weather">
          Loading weather...
        </div>
      </div>
    </div>

    <router-view />
  </div>
</template>



<script>
  export default {
    name: 'App',
    components: {
    },

    data() {
      return {
        time: "",
      };
    },

    mounted() {
      setInterval(() => {
        this.time = this.getTime();
      }, 1 * 1000);
    
      this.getWeather();  // get weather
      // update weather every 24 hours
      setInterval(() => {
        console.log("Updating weather");
        this.getWeather();
      }, 24 * 60 * 60 * 1000);  // 24 hours in a day, 60 minutes in an hour, 60 seconds in a minute, 1000 ms in a second
    },

    methods: {
      async getWeather() {
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
      },

      getTime() {
        return new Date().toLocaleTimeString();
      },

      goHome() {
        return this.$router.push('/');
      },
    }
  }
</script>

<style scoped>
  #clock {
    margin-right: 30px;
  }
</style>

