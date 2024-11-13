// /frontend/src/api/index.js
import axios from 'axios';

const api = axios.create({
  baseURL: "https://backend-12-team-12-699b369e6ba9.herokuapp.com/api/v1"
});

console.log("Base URL:", api.defaults.baseURL); // Check the base URL
export default api;
