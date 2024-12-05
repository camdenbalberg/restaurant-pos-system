<template>
  <div class="employees-section">
    <div class="header-section">
      <h2>Employee Management</h2>
      <button 
        @click="showAddForm = true" 
        class="add-button"
      >
        Add New Employee
      </button>
    </div>

    <!-- Employee Table -->
    <div class="table-container">
      <table class="employee-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Role</th>
            <th>Status</th>
            <th>Hire Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="employee in employees" :key="employee.employee_id">
            <td>{{ employee.first_name }} {{ employee.last_name }}</td>
            <td>{{ employee.email }}</td>
            <td>{{ formatPhoneNumber(employee.phone_number) }}</td>
            <td>
              <span :class="['role-badge', employee.is_manager ? 'manager' : 'employee']">
                {{ employee.is_manager ? 'Manager' : 'Employee' }}
              </span>
            </td>
            <td>
              <span :class="['status-badge', employee.is_working ? 'active' : 'inactive']">
                {{ employee.is_working ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>{{ formatDate(employee.hiring_date) }}</td>
            <td class="actions">
              <button 
                @click="editEmployee(employee)"
                class="action-button edit"
              >
                Edit
              </button>
              <button 
                @click="confirmDelete(employee)"
                class="action-button delete"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal" v-if="showAddForm || editingEmployee">
      <div class="modal-content">
        <h3>{{ editingEmployee ? 'Edit Employee' : 'Add New Employee' }}</h3>
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label>First Name:</label>
            <input 
              v-model="formData.first_name" 
              required
              type="text"
            >
          </div>
          <div class="form-group">
            <label>Last Name:</label>
            <input 
              v-model="formData.last_name" 
              required
              type="text"
            >
          </div>
          <div class="form-group">
            <label>Email:</label>
            <input 
              v-model="formData.email" 
              required
              type="email"
            >
          </div>
          <div class="form-group">
            <label>Phone Number:</label>
            <input 
              v-model="formData.phone_number" 
              required
              type="tel"
              pattern="[0-9]{10}"
              placeholder="1234567890"
            >
          </div>
          <div class="form-group">
            <label>Password:</label>
            <input 
              v-model="formData.password" 
              required
              type="password"
              :placeholder="editingEmployee ? '(unchanged)' : 'Enter password'"
            >
          </div>
          <div class="form-group">
            <label>Hire Date:</label>
            <input 
              v-model="formData.hiring_date" 
              required
              type="date"
            >
          </div>
          <div class="form-group checkbox">
            <label>
              <input 
                v-model="formData.is_manager" 
                type="checkbox"
              >
              Is Manager
            </label>
          </div>
          <div class="form-group checkbox">
            <label>
              <input 
                v-model="formData.is_working" 
                type="checkbox"
              >
              Is Currently Working
            </label>
          </div>
          <div class="form-actions">
            <button 
              type="button" 
              @click="closeForm" 
              class="cancel-button"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="submit-button"
            >
              {{ editingEmployee ? 'Update' : 'Add' }} Employee
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal" v-if="showDeleteConfirm">
      <div class="modal-content">
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete {{ deleteEmployee?.first_name }} {{ deleteEmployee?.last_name }}?</p>
        <div class="form-actions">
          <button 
            @click="showDeleteConfirm = false" 
            class="cancel-button"
          >
            Cancel
          </button>
          <button 
            @click="handleDelete" 
            class="delete-button"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/api';

/**
 * @component EmployeesSection
 * @description A component that provides functionality for managing employee data,
 * including adding new employees, editing existing employees, and handling employee status changes.
 */
export default {
  name: 'EmployeesSection',
  
  /**
   * Initial component data
   * @returns {Object} Component data
   */
  data() {
    return {
      /** @type {Array} List of all employees fetched from the API */
      employees: [],
      
      /** @type {Boolean} Controls visibility of the add employee form */
      showAddForm: false,
      
      /** @type {Object|null} Currently edited employee object */
      editingEmployee: null,
      
      /** @type {Boolean} Controls visibility of delete confirmation modal */
      showDeleteConfirm: false,
      
      /** @type {Object|null} Employee object to be deleted */
      deleteEmployee: null,
      
      /** @type {Object} Form data for adding/editing employees */
      formData: {
        first_name: '',
        last_name: '',
        email: '',
        phone_number: '',
        password: '',
        hiring_date: '',
        is_manager: false,
        is_working: true
      }
    }
  },

  methods: {
    /**
     * Fetches the list of employees from the backend API
     * @async
     * @returns {Promise<void>}
     */
    async fetchEmployees() {
      try {
        const response = await api.get('/employees');
        this.employees = response.data;
      } catch (error) {
        console.error('Error fetching employees:', error);
      }
    },

    /**
     * Formats a phone number string into a standardized format (XXX) XXX-XXXX
     * @param {string} phone - Raw phone number input
     * @returns {string} Formatted phone number
     */
    formatPhoneNumber(phone) {
      const cleaned = phone.replace(/\D/g, '');
      return `(${cleaned.slice(0,3)}) ${cleaned.slice(3,6)}-${cleaned.slice(6)}`;
    },

    /**
     * Converts a date string into a localized date format
     * @param {string} date - Date string to format
     * @returns {string} Formatted date
     */
    formatDate(date) {
      return new Date(date).toLocaleDateString();
    },

    /**
     * Prepares the form for editing an existing employee
     * @param {Object} employee - Employee object to edit
     */
    editEmployee(employee) {
      this.editingEmployee = employee;
      this.formData = { ...employee };
      // Convert date format for input
      this.formData.hiring_date = this.formData.hiring_date.split('T')[0];
    },

    /**
     * Initiates the deletion process for an employee
     * @param {Object} employee - Employee to delete
     */
    confirmDelete(employee) {
      this.deleteEmployee = employee;
      this.showDeleteConfirm = true;
    },

    /**
     * Processes the actual deletion of an employee from the system
     * @async
     * @returns {Promise<void>}
     */
    async handleDelete() {
      try {
        await api.delete(`/employees/delete_employee/${this.deleteEmployee.employee_id}`);
        this.employees = this.employees.filter(
          emp => emp.employee_id !== this.deleteEmployee.employee_id
        );
        this.showDeleteConfirm = false;
        this.deleteEmployee = null;
      } catch (error) {
        console.error('Error deleting employee:', error);
      }
    },

    /**
     * Handles form submission for both adding new employees and updating existing ones
     * @async
     * @returns {Promise<void>}
     */
    async handleSubmit() {
      try {
        if (this.editingEmployee) {
          // Update existing employee
          const response = await api.put(
            `/employees/edit_employee/${this.editingEmployee.employee_id}`,
            this.formData
          );
          const index = this.employees.findIndex(
            emp => emp.employee_id === this.editingEmployee.employee_id
          );
          this.employees[index] = { ...this.formData, employee_id: this.editingEmployee.employee_id };
        } else {
          // Add new employee
          const response = await api.post('/employees/add_employee', this.formData);
          this.employees.push(response.data);
        }
        this.closeForm();
      } catch (error) {
        console.error('Error saving employee:', error);
      }
    },

    /**
     * Closes the form and resets all form data to initial values
     */
    closeForm() {
      this.showAddForm = false;
      this.editingEmployee = null;
      this.formData = {
        first_name: '',
        last_name: '',
        email: '',
        phone_number: '',
        password: '',
        hiring_date: '',
        is_manager: false,
        is_working: true
      };
    }
  },

  /**
   * Lifecycle hook - Called when component is created
   * Fetches initial employee data
   */
  created() {
    this.fetchEmployees();
  }
}
</script>

<style scoped>
.employees-section {
  padding: 2rem;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.add-button {
  background-color: #4CAF50;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

.table-container {
  overflow-x: auto;
}

.employee-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}

.employee-table th,
.employee-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.employee-table th {
  background-color: #f8f9fa;
  font-weight: 600;
}

.role-badge,
.status-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.875rem;
}

.role-badge.manager {
  background-color: #e3f2fd;
  color: #1976d2;
}

.role-badge.employee {
  background-color: #f5f5f5;
  color: #616161;
}

.status-badge.active {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.status-badge.inactive {
  background-color: #ffebee;
  color: #c62828;
}

.actions {
  display: flex;
  gap: 0.5rem;
}

.action-button {
  padding: 0.25rem 0.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
}

.action-button.edit {
  background-color: #2196F3;
  color: white;
}

.action-button.delete {
  background-color: #f44336;
  color: white;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  padding: 2rem;
  border-radius: 8px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.form-group input:not([type="checkbox"]) {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group.checkbox {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-group.checkbox label {
  margin-bottom: 0;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}

.submit-button,
.cancel-button,
.delete-button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

.submit-button {
  background-color: #4CAF50;
  color: white;
}

.cancel-button {
  background-color: #9e9e9e;
  color: white;
}

.delete-button {
  background-color: #f44336;
  color: white;
}

button:hover {
  opacity: 0.9;
}
</style>