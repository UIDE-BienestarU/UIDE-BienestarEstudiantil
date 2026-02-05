export default function Card({ title, children, className = "" }) {
  return (
    <div className={`bg-white rounded-lg shadow p-4 ${className}`}>
      {title && (
        <h3 className="text-lg font-semibold text-[#003366] mb-3">
          {title}
        </h3>
      )}
      {children}
    </div>
  );
}
