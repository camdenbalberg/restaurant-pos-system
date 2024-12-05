/**
 * @fileoverview Axios API module for backend communication.
 * Extends Axios with additional methods for locking and unlocking the screen.
 */

import axios from 'axios';
import store from '../store/';

/**
 * Axios instance configured for API requests to the backend.
 */
const api = axios.create({
  baseURL: "http://localhost/api/v1",
  withCredentials: true,
});

/**
 * Sends a request to lock the screen with a payload.
 * @async
 * @function
 * @param {Object} payload - Data to send with the lock screen request.
 * @returns {Promise<Object>} Resolves with the response data from the server.
 * @throws {Error} Throws an error with server response if the request fails.
 */
api.lockScreen = async (payload) => {
  try {
    const response = await api.post('/lock_screen', payload);
    return response.data;
  } catch (error) {
    console.error("Error locking screen:", error);
    throw error.response?.data || error;
  }
};

/**
 * Sends a request to unlock the screen with a payload.
 * @async
 * @function
 * @param {Object} payload - Data to send with the unlock screen request.
 * @returns {Promise<Object>} Resolves with the response data from the server.
 * @throws {Error} Throws an error with server response if the request fails.
 */
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
