import api from './api';

/**
 * Register a new user
 * @param {Object} data - Registration data
 * @param {string} data.email - User email
 * @param {string} data.name - User name
 * @param {string} data.password - User password
 * @param {string} data.confirmPassword - Password confirmation
 * @returns {Promise} API response
 */
export const register = async (data) => {
  const response = await api.post('/auth/register', data);
  return response.data;
};

/**
 * Login user
 * @param {Object} data - Login data
 * @param {string} data.email - User email
 * @param {string} data.password - User password
 * @returns {Promise} API response
 */
export const login = async (data) => {
  const response = await api.post('/auth/login', data);
  
  // Store tokens
  if (response.data.data?.token) {
    localStorage.setItem('token', response.data.data.token);
    localStorage.setItem('refreshToken', response.data.data.refreshToken);
  }
  
  return response.data;
};

/**
 * Logout user
 * @returns {Promise} API response
 */
export const logout = async () => {
  const response = await api.post('/auth/logout');
  
  // Clear tokens
  localStorage.removeItem('token');
  localStorage.removeItem('refreshToken');
  
  return response.data;
};

/**
 * Get current user profile
 * @returns {Promise} API response
 */
export const getMe = async () => {
  const response = await api.get('/auth/me');
  return response.data;
};

/**
 * Check if user is authenticated
 * @returns {boolean}
 */
export const isAuthenticated = () => {
  return !!localStorage.getItem('token');
};

/**
 * Get stored auth token
 * @returns {string|null}
 */
export const getToken = () => {
  return localStorage.getItem('token');
};

