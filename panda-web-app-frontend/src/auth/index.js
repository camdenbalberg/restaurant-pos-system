import api from "@/api";

/**
 * Checks the user's authentication status by making a request to the backend.
 *
 * @async
 * @function authStatus
 * @returns {Promise<boolean>} Resolves to `true` if the user is authenticated, otherwise `false`.
 * @throws {Error} If an error occurs during the API request.
 */
export async function authStatus() {
  try {
    const response = await api.get('/sessions/authStatus');
    return response.data.authenticated;
  } catch (err) {
    console.error("Error checking authentication of user: ", err);
    return false;
  }
}
