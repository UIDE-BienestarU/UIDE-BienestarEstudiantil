export default function Input({ label, type = "text", ...props }) {
  return (
    <div className="flex flex-col gap-1">
      {label && (
        <label className="text-sm font-medium text-[#53565A]">
          {label}
        </label>
      )}
      <input
        type={type}
        className="border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#96004B]"
        {...props}
      />
    </div>
  );
}
