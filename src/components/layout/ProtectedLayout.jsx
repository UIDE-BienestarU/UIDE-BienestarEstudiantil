import Navbar from "./TopBar";
import Footer from "./Footer";

export default function ProtectedLayout({ children }) {
  return (
    <div className="app-layout">
      <Navbar />
      <main className="main-content">{children}</main>
      <Footer />
    </div>
  );
}
