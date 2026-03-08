import axios from 'axios';

// Backend serverinizin ünvanı
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request Interceptor: Tokeni avtomatik əlavə et
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response Interceptor: 401 xətasını (Unauthorized) idarə et
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      console.warn("Token etibarsızdır. Yenidən giriş tələb olunur.");
      // Gələcəkdə auth context vasitəsilə çıxış əməliyyatını bura əlavə edəcəyik
    }
    return Promise.reject(error);
  }
);

// --- Admin Endpoint Funksiyaları ---

export const getAnalytics = async () => {
  const { data } = await api.get('/admin/analytics');
  return data;
};

export const getOrders = async () => {
  const { data } = await api.get('/admin/orders');
  return data;
};

export const updateOrderStatus = async (id: string, status: string) => {
  const { data } = await api.put(`/admin/orders/${id}`, { status });
  return data;
};

export const getFoods = async () => {
  const { data } = await api.get('/admin/foods');
  return data;
};

export const createFood = async (foodData: any) => {
  const { data } = await api.post('/admin/foods', foodData);
  return data;
};

export const updateFood = async (id: string, foodData: any) => {
  const { data } = await api.put(`/admin/foods/${id}`, foodData);
  return data;
};

export const deleteFood = async (id: string) => {
  const { data } = await api.delete(`/admin/foods/${id}`);
  return data;
};

export const getUsers = async () => {
  const { data } = await api.get('/admin/users');
  return data;
};

export const updateUserRole = async (id: string, role: string) => {
  const { data } = await api.put(`/admin/users/${id}`, { role });
  return data;
};

export const getCouriers = async () => {
  const { data } = await api.get('/admin/couriers');
  return data;
};

// --- Reviews ---
export const getReviews = async () => {
  const { data } = await api.get('/admin/reviews');
  return data;
};

export const deleteReview = async (id: string) => {
  const { data } = await api.delete(`/admin/reviews/${id}`);
  return data;
};

// --- Promotions ---
export const getPromotions = async () => {
  const { data } = await api.get('/admin/promotions');
  return data;
};

export const createPromotion = async (promotionData: any) => {
  const { data } = await api.post('/admin/promotions', promotionData);
  return data;
};

export const deletePromotion = async (id: string) => {
  const { data } = await api.delete(`/admin/promotions/${id}`);
  return data;
};

// --- Settings ---
export const getSettings = async () => {
  const { data } = await api.get('/admin/settings');
  return data;
};

export const updateSettings = async (settingsData: any) => {
  const { data } = await api.put('/admin/settings', settingsData);
  return data;
};

// --- Payments ---
export const getPayments = async () => {
  const { data } = await api.get('/admin/payments');
  return data;
};

// --- Audit Logs ---
export const getAuditLogs = async () => {
  const { data } = await api.get('/admin/audit-logs');
  return data;
};

// --- Order Actions ---
export const cancelOrder = async (id: string) => {
  const { data } = await api.put(`/admin/orders/${id}/cancel`);
  return data;
};

export const refundOrder = async (id: string) => {
  const { data } = await api.put(`/admin/orders/${id}/refund`);
  return data;
};

export const globalSearch = async (query: string) => {
  const { data } = await api.get(`/admin/search?query=${query}`);
  return data;
};

export const getAdvancedAnalytics = async () => {
  const { data } = await api.get('/admin/analytics-advanced');
  return data;
};

export default api;
