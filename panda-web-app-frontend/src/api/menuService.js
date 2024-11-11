import api from '@/api';  // Assuming you're using axios for making requests

export const fetchMenuItems = async () => {
  try {
    const response = await api.get('/menu_items');
    return response.data;  // Return the response data, which is the list of menu items
  } catch (error) {
    console.error('Error fetching menu items:', error);
    throw error;  // Throw the error to be handled by the calling function
  }
};
