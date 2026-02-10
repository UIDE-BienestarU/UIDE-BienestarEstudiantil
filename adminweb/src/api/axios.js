// src/api/axios.js
import axios from "axios";

const baseURL =
  process.env.REACT_APP_API_URL || "https://api-prod.uidehub.tech/api";

const api = axios.create({
  baseURL,
  headers: { "Content-Type": "application/json" },
});

// 👉 instancia “pelada” para refresh (sin interceptores) para evitar loops
const raw = axios.create({
  baseURL,
  headers: { "Content-Type": "application/json" },
});

// ===== Helpers tokens =====
const getAccessToken = () => localStorage.getItem("token") || "";
const setAccessToken = (t) => localStorage.setItem("token", t);
const getRefreshToken = () => localStorage.getItem("refreshToken") || "";
const clearAuthStorage = () => {
  localStorage.removeItem("token");
  localStorage.removeItem("refreshToken");
  localStorage.removeItem("user");
};

// ===== Request interceptor: agrega Bearer =====
api.interceptors.request.use(
  (config) => {
    const token = getAccessToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  },
  (error) => Promise.reject(error)
);

// ===== Refresh queue (evita múltiples refresh simultáneos) =====
let isRefreshing = false;
let queue = [];

function resolveQueue(error, newToken = null) {
  queue.forEach((p) => {
    if (error) p.reject(error);
    else p.resolve(newToken);
  });
  queue = [];
}

// ===== Response interceptor: refresh & retry =====
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const status = error?.response?.status;
    const code = error?.response?.data?.code; // tu backend usa "INVALID_TOKEN"
    const original = error.config;

    // Sin respuesta = red/CORS
    if (!error.response) return Promise.reject(error);

    // Si es refresh endpoint y falló, logout directo
    const isRefreshCall = original?.url?.includes("/auth/refresh");
    if (isRefreshCall) {
      clearAuthStorage();
      window.location.href = "/login";
      return Promise.reject(error);
    }

    // ✅ condición para intentar refresh
    const shouldTryRefresh =
      (status === 401 || status === 403) &&
      (code === "INVALID_TOKEN" || code === "TOKEN_EXPIRED" || !code) && // por si backend no manda code
      !original._retry;

    if (!shouldTryRefresh) return Promise.reject(error);

    original._retry = true;

    // Si ya estamos refrescando, encola
    if (isRefreshing) {
      return new Promise((resolve, reject) => {
        queue.push({ resolve, reject });
      }).then((newToken) => {
        original.headers.Authorization = `Bearer ${newToken}`;
        return api(original);
      });
    }

    isRefreshing = true;

    try {
      const refreshToken = getRefreshToken();
      if (!refreshToken) throw new Error("No refreshToken en storage");

      // 🔥 OJO: tu backend (según tu login) devuelve en response.data.data
      const refreshRes = await raw.post("/auth/refresh", { refreshToken });

      // Ajuste según tu estructura:
      // Login: response.data.data = { user, accessToken, refreshToken }
      // Refresh: lo más probable es lo mismo o { accessToken, refreshToken }
      const payload = refreshRes.data?.data || refreshRes.data;

      const newAccess = payload?.accessToken || payload?.token;
      const newRefresh = payload?.refreshToken;

      if (!newAccess) throw new Error("Refresh no devolvió accessToken/token");

      setAccessToken(newAccess);
      if (newRefresh) localStorage.setItem("refreshToken", newRefresh);

      resolveQueue(null, newAccess);

      // Reintenta request original con token nuevo
      original.headers.Authorization = `Bearer ${newAccess}`;
      return api(original);
    } catch (refreshErr) {
      resolveQueue(refreshErr, null);
      clearAuthStorage();
      window.location.href = "/login";
      return Promise.reject(refreshErr);
    } finally {
      isRefreshing = false;
    }
  }
);

export default api;
