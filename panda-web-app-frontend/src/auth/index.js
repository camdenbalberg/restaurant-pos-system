import api from "@/api";

export async function authStatus() {
  try {
    const response = await api.get('/sessions/authStatus');
    return response.data.authenticated;
  } catch (err) {
    console.error("Error checking authentication of user: ", err);
    return false;
  }
}
