export default function Table({ headers, children }) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full border-collapse">
        <thead>
          <tr className="bg-[#003366] text-white">
            {headers.map((h, i) => (
              <th key={i} className="px-4 py-2 text-left text-sm">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>{children}</tbody>
      </table>
    </div>
  );
}
