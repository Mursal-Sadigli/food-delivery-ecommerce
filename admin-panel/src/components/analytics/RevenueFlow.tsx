import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';

interface RevenueData {
  _id: string;
  revenue: number;
  orders: number;
}

interface RevenueFlowProps {
  data: RevenueData[];
}

export function RevenueFlow({ data }: RevenueFlowProps) {
  return (
    <div className="h-[300px] w-full mt-4">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={data} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
          <defs>
            <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.3}/>
              <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0}/>
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="hsl(var(--muted-foreground))" opacity={0.1} />
          <XAxis 
            dataKey="_id" 
            hide
          />
          <YAxis 
            tick={{ fontSize: 10 }} 
            tickFormatter={(value) => `${value}₼`}
            width={40}
          />
          <Tooltip 
            contentStyle={{ borderRadius: '12px', border: '1px solid hsl(var(--border))', backgroundColor: 'hsl(var(--card))' }}
          />
          <Area 
            type="monotone" 
            dataKey="revenue" 
            stroke="hsl(var(--primary))" 
            fillOpacity={1} 
            fill="url(#colorRevenue)" 
            strokeWidth={3}
            animationDuration={1500}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
