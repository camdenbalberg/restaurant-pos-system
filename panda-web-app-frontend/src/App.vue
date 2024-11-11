<!-- src/App.vue -->
<template>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Dongle&display=swap" rel="stylesheet">

  <div id="app">
    <div class="scaffold">
      <RouterLink to="/">
        <button class="scaffold-item" id="home-button">Home</button>
      </RouterLink>
      
      <img class="scaffold-item" src="./assets/smalllogo.png" id="scaffold-logo" alt="12Team12 Scaffold Logo" @click="goHome">
      <div class="scaffold-item">
        <div id="time">
          <div v-show="time" id="clock">{{ time }}</div>
          <div id="uptime">running {{ uptime }}</div>
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
        startTime: new Date(),
        uptime: "00:00:00",
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
        if (diffHours == 0) {
          diffHours = "00";
        }
        if (diffMinutes == 0) {
          diffMinutes = "00";
        }
        return diffHours + ":" + diffMinutes + ":" + diffSeconds;
      },

      goHome() {
        return this.$router.push('/');
      },
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
  }

  .scaffold {
    width: 100%;
    height: 70px;
    position: sticky;
    top: 0;

    background: var(--surfaceColor);
    backdrop-filter: blur(1000px);

    display: flex;
    justify-content: space-between;
    align-items: center;

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

  #home-button {
    background: rgba(--accentColorWeak);
  }

  #scaffold-logo {
    height: 90%;
  }

  #time {
    margin-right: 40px;
    text-align: left;
    font-family: "Dongle", arial;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: 0px;
  }

  #clock {
    font-size: 40px;
    margin: -15px;
    padding: 0px;
  }

  #uptime {
    color: var(--accentColorIntense);
    font-size: 30px;
    margin: -15px;
    padding: 0px;
  }
</style>

