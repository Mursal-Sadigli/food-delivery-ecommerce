import { Routes, Route } from "react-router-dom";
import { MainLayout } from "./components/layout/MainLayout";
import Dashboard from "./pages/dashboard";

function App() {
  return (
    <Routes>
      <Route path="/" element={<MainLayout />}>
        <Route index element={<Dashboard />} />
        {/* Digər səhifələr buraya gələcək */}
        <Route path="orders" element={<div>Orders Page</div>} />
        <Route path="restaurants" element={<div>Restaurants Page</div>} />
        <Route path="foods" element={<div>Foods Page</div>} />
        <Route path="users" element={<div>Users Page</div>} />
        <Route path="couriers" element={<div>Couriers Page</div>} />
        <Route path="analytics" element={<div>Analytics Page</div>} />
      </Route>
    </Routes>
  );
}

export default App;
