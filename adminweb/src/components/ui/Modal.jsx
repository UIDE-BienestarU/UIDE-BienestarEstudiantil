export default function Modal({ open, title, children, onClose }) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-md p-5">
        <div className="flex justify-between items-center mb-3">
          <h3 className="font-semibold text-lg">{title}</h3>
          <button onClick={onClose} className="text-gray-500 text-xl">
            ×
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}
