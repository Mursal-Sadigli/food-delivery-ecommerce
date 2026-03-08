import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';

interface CohortData {
  total: number;
  active: number;
  returning: number;
}

interface CohortAnalyticsProps {
  data: CohortData;
}

const COLORS = ['#8884d8', '#82ca9d', '#ffc658'];

export function CohortAnalytics({ data }: CohortAnalyticsProps) {
  const chartData = [
    { name: 'Active Users', value: data.active },
    { name: 'Returning Users', value: data.returning },
    { name: 'New Users', value: data.total - data.returning }
  ];

  return (
    <div className="h-[250px] w-full mt-4">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={chartData}
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={80}
            paddingAngle={5}
            dataKey="value"
            animationDuration={1500}
          >
            {chartData.map((_entry, index) => (
              <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} stroke="none" />
            ))}
          </Pie>
          <Tooltip 
            contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
          />
          <Legend iconType="circle" wrapperStyle={{ fontSize: '10px' }} />
        </PieChart>
      </ResponsiveContainer>
      <div className="flex justify-between mt-4 px-4 h-full">
        <div className="text-center">
          <p className="text-[10px] text-muted-foreground">Total Users</p>
          <p className="text-sm font-bold">{data.total}</p>
        </div>
        <div className="text-center">
          <p className="text-[10px] text-muted-foreground">Retention Rate</p>
          <p className="text-sm font-bold text-green-500">
            {((data.returning / data.total) * 100).toFixed(1)}%
          </p>
        </div>
      </div>
    </div>
  );
}
