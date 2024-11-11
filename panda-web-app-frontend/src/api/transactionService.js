import axios from 'axios';

export const fetchTransactions = async () => {
  try {
    console.log(import.meta.env.VITE_API_BACKEND_URL);
    // Get today's date in YYYY-MM-DD format (commented out for testing)
    // const today = new Date();
    // const formattedDate = today.toISOString().split('T')[0];

    // Temporary hardcoded value for testing
    const response = await axios.get("/api/v1/transactions/by_date/2023-12-25"); 
    const transactions = response.data;

    // Fetch sale items for each transaction
    await Promise.all(transactions.map(async (transaction) => {
      const saleItemsResponse = await axios.get(`/api/v1/sale_items/by_transaction_id/${transaction.transaction_id}`);
      transaction.sale_items = saleItemsResponse.data;
    }));

    return transactions;
  } catch (error) {
    console.error('Error fetching transactions:', error);
    throw error; // Rethrow error to be handled in the calling function
  }
};
