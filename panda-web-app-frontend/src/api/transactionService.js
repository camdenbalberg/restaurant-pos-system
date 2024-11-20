import axios from 'axios';
import api from '@/api';

export const fetchTransactions = async () => {
  try {
    console.log(import.meta.env.VITE_API_BACKEND_URL);
    // Get today's date in YYYY-MM-DD format (commented out for testing)
    // const today = new Date();
    // const formattedDate = today.toISOString().split('T')[0];

    // Temporary hardcoded value for testing
    const response = await api.get("/transactions/by_date/2024-10-19"); 
    const transactions = response.data;

    // Fetch sale items for each transaction
    await Promise.all(transactions.map(async (transaction) => {
      const saleItemsResponse = await api.get(`/sale_items/by_transaction_id/${transaction.transaction_id}`);
      transaction.sale_items = saleItemsResponse.data;
    }));

    return transactions;
  } catch (error) {
    console.error('Error fetching transactions:', error);
    throw error; // Rethrow error to be handled in the calling function
  }
};

export const fetchTransactionsForDate = async (date) => {
  try {
    // Log the backend URL for verification
    console.log(import.meta.env.VITE_API_BACKEND_URL);

    // Make a request to fetch transactions for the specified date
    const response = await api.get(`/transactions/by_date/${date}`);
    const transactions = response.data;

    // Fetch sale items for each transaction asynchronously
    await Promise.all(transactions.map(async (transaction) => {
      const saleItemsResponse = await api.get(`/sale_items/by_transaction_id/${transaction.transaction_id}`);
      transaction.sale_items = saleItemsResponse.data;
    }));

    return transactions;
  } catch (error) {
    console.error('Error fetching transactions:', error);
    throw error; // Rethrow the error for handling in the calling function
  }
};