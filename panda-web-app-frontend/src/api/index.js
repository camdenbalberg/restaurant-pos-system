import axios from 'axios';
import store from '../store/';

const api = axios.create({
  baseURL: "http://localhost/api/v1",
  withCredentials: true,
});

api.lockScreen = async (payload) => {
  try {
    const response = await api.post('/lock_screen', payload);
    return response.data;
  } catch (error) {
    console.error("Error locking screen:", error);
    throw error.response?.data || error;
  }
};

api.unlockScreen = async (payload) => {
  try {
    const response = await api.post('/unlock_screen', payload);
    return response.data;
  } catch (error) {
    console.error("Error unlocking screen:", error);
    throw error.response?.data || error;
  }
};

export default api;