import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Cell, LabelList } from 'recharts';

interface FunnelData {
  _id: string;
  count: number;
}

interface OrderFunnelProps {
  data: FunnelData[];
}

const COLORS = ['#8884d8', '#82ca9d', '#ffc658', '#ff8042', '#0088FE', '#00C49F', '#FFBB28'];

export function OrderFunnel({ data }: OrderFunnelProps) {
  // Sort data by a logical order funnel if possible
  const orderStages = ['Hazırlanır', 'Bişirilir', 'Kuryerə verildi', 'Qapınızdadır', 'Çatdırıldı'];
  const sortedData = [...data].sort((a, b) => {
    return orderStages.indexOf(a._id) - orderStages.indexOf(b._id);
  });

  return (
    <div className="h-[300px] w-full mt-4">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          layout="vertical"
          data={sortedData}
          margin={{ top: 5, right: 30, left: 40, bottom: 5 }}
        >
          <XAxis type="number" hide />
          <YAxis 
            dataKey="_id" 
            type="category" 
            tick={{ fontSize: 12 }} 
            width={100}
          />
          <Tooltip 
            cursor={{ fill: 'transparent' }}
            contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
          />
          <Bar dataKey="count" radius={[0, 4, 4, 0]} barSize={30}>
            {sortedData.map((_entry, index) => (
              <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
            ))}
            <LabelList dataKey="count" position="right" style={{ fontSize: '12px', fontWeight: 'bold' }} />
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
