import { Routes, Route, Navigate } from "react-router-dom";
import { MainLayout } from "./components/layout/MainLayout";
import Dashboard from "./pages/dashboard";
import OrdersPage from "./pages/orders";
import RestaurantsPage from "./pages/restaurants";
import FoodsPage from "./pages/foods";
import UsersPage from "./pages/users";
import CouriersPage from "./pages/couriers";
import LoginPage from "./pages/login";
import ReviewsPage from "./pages/reviews";
import PromotionsPage from "./pages/promotions";
import SettingsPage from "./pages/settings";
import PaymentsPage from "./pages/payments";
import AuditLogsPage from "./pages/audit-logs";
import { AuthProvider } from "./contexts/AuthContext";
import { ProtectedRoute } from "./components/auth/ProtectedRoute";
import { ThemeProvider } from "./components/theme-provider";
import { SocketProvider } from "./contexts/SocketContext";

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route 
        path="/" 
        element={
          <ProtectedRoute>
            <MainLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="orders" element={<OrdersPage />} />
        <Route path="restaurants" element={<RestaurantsPage />} />
        <Route path="foods" element={<FoodsPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="couriers" element={<CouriersPage />} />
        <Route path="reviews" element={<ReviewsPage />} />
        <Route path="promotions" element={<PromotionsPage />} />
        <Route path="settings" element={<SettingsPage />} />
        <Route path="payments" element={<PaymentsPage />} />
        <Route path="audit-logs" element={<AuditLogsPage />} />
        <Route path="analytics" element={<div>Analytics Page is coming soon.</div>} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

function App() {
  return (
    <ThemeProvider defaultTheme="light" storageKey="admin-theme">
      <SocketProvider>
        <AuthProvider>
          <AppRoutes />
        </AuthProvider>
      </SocketProvider>
    </ThemeProvider>
  );
}

export default App;
