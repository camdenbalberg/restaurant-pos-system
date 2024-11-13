import api from '@/api';

export const fetchInventoryItems = async () => {
    try{
        const response = await api.get('/inventory_items');
        return response.data;
    } catch (error) {
        console.error('Error fetching menu items:', error);
        throw error;
    }
};