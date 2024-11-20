<!-- import { Translator } from 'vue-google-translate'; -->

<!-- src/App.vue -->
<template>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Dongle&display=swap" rel="stylesheet">

  <div id="app">
    <!-- <Translator /> -->
    <div class="scaffold-overlay">
      <div class="scaffold">
        <RouterLink to="/">
          <button class="scaffold-item" id="home-button">Home</button>
        </RouterLink>        
        <img class="scaffold-item" src="./assets/smalllogo.png" id="scaffold-logo" alt="12Team12 Scaffold Logo" @click="goHome">
        <div class="right-side">
          <div class="scaffold-item" id="time" @click="timeClicked">
            <div v-show="time" id="clock">{{ time }}</div>
            <div id="uptime" v-show="timeConfig">running {{ uptime }}</div>
          </div>

          <div class="scaffold-item" id="weather" @click="weatherClicked">
            Loading weather...
          </div>
        </div>
      </div>
    </div>

    <router-view />
  </div>
</template>



<script>
  import shared from './shared'

  export default {
    name: 'App',
    components: {
      // Translator
    },

    data() {
      return {
        time: "",
        startTime: new Date(),
        uptime: "00:00:00",
        timeConfig: 0,
        weatherC: 9999,
        weatherConfig: 0,  // 0F, 1C, 2K
        weatherDescription: "",
      };
    },

    mounted() {
      setInterval(() => {
        this.time = this.getTime();
        this.uptime = this.getUptime();
      }, 1 * 1000);
    
      this.getWeather();  // get weather
      // update weather every 24 hours
      setInterval(() => {
        console.log("Updating weather");
        this.getWeather();
      }, 24 * 60 * 60 * 1000);  // 24 hours in a day, 60 minutes in an hour, 60 seconds in a minute, 1000 ms in a second
    },

    created() {
      this.flashScaffolding = shared.flashScaffolding
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
                this.weatherC = data.main.temp;
                this.weatherDescription = data.weather[0].description;
                document.getElementById('weather').innerText = 
                    `Temperature: ${this.weatherC}°C\nCondition: ${this.weatherDescription}`;
                this.flashScaffolding();
            })
            .catch(error => {
                document.getElementById('weather').innerText = 
                    'Failed to load weather data: ' + error;
            });
        //end weather script
      },

      getTime() {
        var date = new Date().toDateString();
        var time = new Date().toLocaleTimeString('en-US', { hour12: false });
        return date + " -> " + time;
      },

      getUptime() {
        var currentTime = new Date();
        var diffTime = Math.abs(currentTime - this.startTime);
        var diffHours = Math.floor(diffTime / (60 * 60 * 1000)); 
        var diffMinutes = Math.floor(diffTime / (60 * 1000)) % 60; 
        var diffSeconds = Math.floor(diffTime / (1000)) % 60; 

        // Ensure number is always 2 digits
        if (diffHours < 10) {
          diffHours = "0" + diffHours;
        }
        if (diffMinutes < 10) {
          diffMinutes = "0" + diffMinutes;
        }
        if (diffSeconds < 10) {
          diffSeconds = "0" + diffSeconds;
        }

        return diffHours + ":" + diffMinutes + ":" + diffSeconds;
      },

      goHome() {
        return this.$router.push('/');
      },

      weatherClicked() {
        switch (this.weatherConfig) {
          case 0:
            // Switch to F
            var weatherF = (this.weatherC * 1.8 + 32).toFixed(2);
            document.getElementById('weather').innerText = 
              `Temperature: ${weatherF}°F\nCondition: ${this.weatherDescription}`;
            break;
          case 1:
            // Switch to K
            var weatherK = (this.weatherC + 273.15).toFixed(2);
            document.getElementById('weather').innerText = 
              `Temperature: ${weatherK}°K\nCondition: ${this.weatherDescription}`;
            break;
          case 2:
            // Switch to C
            this.weatherConfigCelcius = true;
            document.getElementById('weather').innerText = 
              `Temperature: ${this.weatherC}°C\nCondition: ${this.weatherDescription}`;
            break;
          default:
            console.log("You should not see this");
        }
        this.weatherConfig = (this.weatherConfig + 1) % 3
      },

      timeClicked() {
        this.timeConfig = (this.timeConfig + 1) % 2
      }
    }
  }
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

  .scaffold-overlay {
    width: 100%;
    height: 70px;
    position: sticky;
    top: 0;
    background: var(--accentColorIntense);
  }

  .scaffold {
    width: 100%;
    height: 100%;
    background: var(--surfaceColor);
    backdrop-filter: blur(1000px);

    display: flex;
    justify-content: space-between;
    align-items: center;

    font-family: "Dongle", arial;
    font-size: 30px;
    line-height: 22px;
  }

  .scaffold-item {
    display: flex;
    align-items: center;
    height: 70px;
    padding-left: 50px;
    padding-right: 50px;
    /* background: rgba(--accentColorWeak); */

    color: var(--textColor);
    text-decoration: none;
  }

  .right-side {
    height: 70px;
    display: flex;
    align-items: center;
  }

  #home-button {
    background-color: var(--transparent);
    scale: 1;
  }

  #home-button:hover {
    background-color: var(--accentColorWeak);
    scale: 1;
  }

  #home-button:active {
    scale: 1;
    background-color: var(--accentColor);
  }

  #scaffold-logo {
    height: 90%;
  }

  #time {
    margin-right: 40px;
    text-align: left;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
  }

  #clock {
    font-size: 40px;
    padding: 0px;
  }

  #uptime {
    color: var(--accentColorIntense);
    font-size: 30px;
    padding: 0px;
  }

  /* Weather */

  #weather {
    /* background-color: var(--surfaceColor); */
    scale: 1;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 5px;
    transition: scale 0.5s ease;
    transition: background-color 0.25s ease;
  }

  #weather:hover {
    background-color: var(--accentColorWeak);
    scale: 1;
  }

  #weather:active {
    scale: 1;
    background-color: var(--accentColor);
  }

  #time {
    border-radius: 5px;
    transition: scale 0.5s ease;
    transition: background-color 0.25s ease;
  }

  #time:hover {
    background-color: var(--accentColorWeak);
  }

  #time:active {
    background-color: var(--accentColor);
  }
</style>

