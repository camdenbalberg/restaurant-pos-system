<!-- src/App.vue -->
<template>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <!-- Font and icons -->
  <link href="https://fonts.googleapis.com/css2?family=Dongle&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon_names=arrow_back,home,location_city,translate" />
  <!-- Modal style -->
  <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"><link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

  <div id="app">
    <div class="scaffold-overlay">
      <div class="scaffold">

        <button class="scaffold-item" id="home-button" @click="goHome">
          <div class="scaffold-button-pair">
            <span class="material-symbols-outlined">home</span>
            Home
          </div>
        </button>

        <button class="scaffold-item" id="back-button" @click="goBack">
          <div class="scaffold-button-pair">
            <span class="material-symbols-outlined">arrow_back</span>
            Back
          </div>
        </button>

        <button type="button" onclick="document.getElementById('translate-modal').style.display='block'" class="scaffold-item">
          <div class="scaffold-button-pair">
            <span class="material-symbols-outlined">translate</span>
            Translate
          </div>
        </button>

        
        <img class="scaffold-item" src="./assets/smalllogo.png" id="scaffold-logo" alt="12Team12 Scaffold Logo" @click="goHome">
        <div class="right-side">
          <div class="scaffold-item" id="time" @click="timeClicked">
            <div v-show="time" id="clock">{{ time }}</div>
            <div id="uptime" v-show="timeConfig">running {{ uptime }}</div>
          </div>

          <button class="scaffold-item" id ="changeCity" @click="changeCityClicked">
            <div class="scaffold-button-pair">
              <span class="material-symbols-outlined">location_city</span>
              Change city
            </div>
          </button>

          <div class="scaffold-item" id="weather" @click="weatherClicked">
            Loading weather...
          </div>
        </div>
      </div>
    </div>

    <div id="translate-modal" class="w3-modal">
      <div class="w3-modal-content w3-animate-top">
        <div class="w3-container">
          <span onclick="document.getElementById('translate-modal').style.display='none'"
          class="w3-button w3-display-topright">&times;</span>
          <h1>Translate Page</h1>
          <div id="google_translate_element"></div>
          <button id="translate-close-button" onclick="document.getElementById('translate-modal').style.display='none'">Close</button>
        </div>
      </div>
    </div>

    <router-view></router-view>

  </div>
</template>



<script>
  import shared from './shared'

  export default {
    name: 'App',
    components: {
    },

    data() {
      return {
        time: "",
        startTime: new Date(),
        uptime: "00:00",
        timeConfig: 0,
        weatherC: 9999,
        weatherConfig: 0,  // 0F, 1C, 2K
        weatherDescription: "",
        currentCity: 'College Station',
      };
    },

    mounted() {
      setInterval(() => {
        this.time = this.getTime();
        this.uptime = this.getUptime();
      }, 60 * 1000); 

      setInterval(() => {
        console.log("Updating weather");
        this.getWeather();
      }, 60 * 60 * 1000);  // Fetch weather updates every hour

      // Initialize time and weather immediately to avoid delay
      this.time = this.getTime();
      this.uptime = this.getUptime();
      this.getWeather();
    },

    created() {
      this.flashScaffolding = shared.flashScaffolding
    },

  methods: {
    setup() {
      const store = useStore();

      onMounted(() => {
        store.dispatch('checkAuth'); // Check auth on app load
      });
    },
      async getWeather() {
        // weather script
        const apiKey = '6fb6a81a74d923c021c776074b270bc9'; // Replace with your OpenWeather API key
        const city = this.currentCity; // Change to your preferred city
        const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok ' + response.statusText);
                }

                this.googleTranslateElementInit();  // Call translate
                return response.json();
            })
            .then(data => {
                this.weatherC = data.main.temp;
                this.weatherDescription = data.weather[0].description;
                document.getElementById('weather').innerText =
                    `Temperature: ${this.weatherC}°C\nCondition: ${this.weatherDescription}`;
                this.flashScaffolding();

                this.googleTranslateElementInit();  // Call translate
            })
            .catch(error => {
                // document.getElementById('weather').innerText =
                //     'Failed to load weather data: ' + error;
                alert("Error loading city. Resetting to default city.");
                this.currentCity = 'College Station';
                this.googleTranslateElementInit();  // Call translate
                this.getWeather();
            });
        //end weather script
      },

      getTime() {
        const options = {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false, // Use 24-hour format
        };
        const time = new Date().toLocaleTimeString('en-US', options); // Returns HH:MM
        const date = new Date().toDateString();
        return `${date} -> ${time}`;
      },

      getUptime() {
        var currentTime = new Date();
        var diffTime = Math.abs(currentTime - this.startTime);
        var diffHours = Math.floor(diffTime / (60 * 60 * 1000));
        var diffMinutes = Math.floor(diffTime / (60 * 1000)) % 60;
    
        // Ensure number is always 2 digits
        if (diffHours < 10) {
          diffHours = "0" + diffHours;
        }
        if (diffMinutes < 10) {
          diffMinutes = "0" + diffMinutes;
        }

        return diffHours + ":" + diffMinutes;
      },

      goHome() {
        if (this.$route.name == "/home") {
          this.$backStack.push("/");
        } else {
          this.$backStack.push(this.$route.name);
        }
        
        return this.$router.push('/');
      },

      changeCityClicked() {
        const city = prompt("Enter a city name for weather updates:", this.currentCity);
        if(city) {
          this.currentCity = city;
          this.getWeather();
          console.log("Changed city to ", this.currentCity);
        }
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
        this.timeConfig = (this.timeConfig + 1) % 2;
      },

      googleTranslateElementInit() {
        window.google.translate.TranslateElement(
          { pageLanguage: "en" },
          "google_translate_element"
        );
      },

      goBack() {
        return this.$router.push(this.$backStack.pop());
      },

      showModal() {
        this.$bvModal.show(translate-modal);
      },

      hideModal() {
        this.$bvModal.hide(translate-modal);
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
    --transparent: #00000000;
  }

  /* ----------------------
  Scaffolding
  ---------------------- */

  .scaffold-overlay {
    width: 100%;
    height: 70px;
    z-index: 998;
    position: sticky;
    top: 0;
    background: var(--accentColorIntense);
  }

  .scaffold {
    z-index: 999;
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
    z-index: 1000;
    display: flex;
    align-items: center;
    height: 70px;
    padding-left: 50px;
    padding-right: 50px;
    /* background: rgba(--accentColorWeak); */

    color: var(--textColor);
    text-decoration: none;
  }

  .scaffold-button-pair {
    display: flex;
    align-items: center;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .right-side {
    height: 70px;
    display: flex;
    align-items: center;
  }

  /* ----------------------
  Home and Logo
  ---------------------- */

  #home-button {
    z-index: 1;
    background-color: var(--transparent);
    scale: 1;
  }

  #home-button:hover {
    z-index: 1;
    background-color: var(--accentColorWeak);
    scale: 1;
  }

  #home-button:active {
    z-index: 1;
    scale: 1;
    background-color: var(--accentColor);
  }

  #scaffold-logo {
    height: 90%;
  }

  /* ----------------------
  Time
  ---------------------- */

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

  /* ----------------------
  Weather
  ---------------------- */

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

  #changeCity:hover {
    background-color: var(--accentColorWeak);
    scale: 1;
  }

  /* ----------------------
  Time
  ---------------------- */

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

  /* ----------------------
  Translate
  ---------------------- */

  #translate-close-button {
    margin: 70px;
    font-size: 30px;
    padding-top: 25px;
    padding-bottom: 25px;
    padding-right: 50px;
    padding-left: 50px;
  }
</style>
