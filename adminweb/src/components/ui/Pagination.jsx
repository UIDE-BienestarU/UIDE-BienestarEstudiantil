export default function Pagination({ current, total }) {
  return (
    <div className="flex justify-end gap-2 mt-4">
      {Array.from({ length: total }).map((_, i) => (
        <button
          key={i}
          className={`px-3 py-1 rounded ${
            current === i + 1
              ? "bg-[#96004B] text-white"
              : "bg-gray-200"
          }`}
        >
          {i + 1}
        </button>
      ))}
    </div>
  );
}
