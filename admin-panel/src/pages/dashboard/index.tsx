import { useEffect, useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Activity,
  DollarSign,
  Users,
  Utensils,
  Loader2,
  TrendingUp,
  PieChart as PieChartIcon,
  ShoppingBag,
  Bell
} from "lucide-react";
import {
  Area,
  AreaChart,
  ResponsiveContainer,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  PieChart,
  Pie,
  Cell,
  Legend
} from "recharts";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { getAnalytics, getAuditLogs } from "@/services/api";
import { useSocket } from "@/contexts/SocketContext";
import { formatDistanceToNow } from "date-fns";
import { az } from "date-fns/locale";

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d'];

export default function Dashboard() {
  const [data, setData] = useState<any>(null);
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const { socket } = useSocket();

  const fetchDashboardData = async () => {
    try {
      const [analytics, auditLogs] = await Promise.all([
        getAnalytics(),
        getAuditLogs()
      ]);
      setData(analytics);
      setLogs(auditLogs.slice(0, 5)); // Son 5 loq
    } catch (error) {
      console.error("Dashboard məlumatları çəkilərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  useEffect(() => {
    if (socket) {
      socket.on("new_order", () => {
        // Yeni sifariş gəldikdə analitikanı yenilə
        fetchDashboardData();
      });
      
      socket.on("order_updated", () => {
        fetchDashboardData();
      });
    }
    return () => {
      if (socket) {
        socket.off("new_order");
        socket.off("order_updated");
      }
    };
  }, [socket]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[400px]">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  const summary = data?.summary || { totalOrders: 0, totalProducts: 0, totalUsers: 0, totalRevenue: 0 };
  const salesTrend = data?.salesTrend || [];
  const categoryStats = data?.categoryStats?.map((c: any) => ({ name: c._id || "Digər", value: c.count })) || [];

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-3xl font-bold tracking-tight">Dashboard</h2>
        <p className="text-muted-foreground text-sm">Xoş gəlmisiniz! Platformanın cari vəziyyəti barədə qısa icmal.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {[
          { title: "Ümumi Gəlir", value: `$${summary.totalRevenue.toFixed(2)}`, icon: DollarSign, trend: "+12.5%", color: "text-green-600" },
          { title: "İstifadəçilər", value: summary.totalUsers, icon: Users, trend: "+3", color: "text-blue-600" },
          { title: "Məhsullar", value: summary.totalProducts, icon: Utensils, trend: "Aktiv", color: "text-orange-600" },
          { title: "Sifarişlər", value: summary.totalOrders, icon: ShoppingBag, trend: "Son 24 saat", color: "text-purple-600" },
        ].map((stat, i) => (
          <Card key={i} className="overflow-hidden">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-xs font-bold uppercase text-muted-foreground">{stat.title}</CardTitle>
              <stat.icon className={`h-4 w-4 ${stat.color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stat.value}</div>
              <p className="text-[10px] text-muted-foreground mt-1 flex items-center gap-1">
                <TrendingUp className="h-3 w-3 text-green-500" />
                {stat.trend} keçən aya nisbətən
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="lg:col-span-4 h-fit">
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle className="text-lg">Satış Trendi</CardTitle>
              <CardDescription>Son 7 günün gəlir qrafiki</CardDescription>
            </div>
            <TrendingUp className="h-5 w-5 text-muted-foreground opacity-50" />
          </CardHeader>
          <CardContent className="pt-4">
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={salesTrend}>
                  <defs>
                    <linearGradient id="colorSales" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
                  <XAxis 
                    dataKey="_id" 
                    stroke="#888888" 
                    fontSize={10} 
                    tickLine={false} 
                    axisLine={false}
                    tickFormatter={(val) => val.split("-").slice(1).join("/")}
                  />
                  <YAxis 
                    stroke="#888888" 
                    fontSize={10} 
                    tickLine={false} 
                    axisLine={false}
                    tickFormatter={(value) => `$${value}`}
                  />
                  <Tooltip 
                    contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="totalSales" 
                    stroke="hsl(var(--primary))" 
                    fillOpacity={1} 
                    fill="url(#colorSales)" 
                    strokeWidth={2}
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card className="lg:col-span-3">
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle className="text-lg">Kateqoriyalar</CardTitle>
              <CardDescription>Məhsul paylanması</CardDescription>
            </div>
            <PieChartIcon className="h-5 w-5 text-muted-foreground opacity-50" />
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryStats}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {categoryStats.map((_: any, index: number) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend verticalAlign="bottom" height={36} wrapperStyle={{fontSize: '10px'}} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="lg:col-span-4">
          <CardHeader>
            <CardTitle className="text-lg">Populyar Məhsullar</CardTitle>
            <CardDescription>Ən çox satılan 5 məhsul.</CardDescription>
          </CardHeader>
          <CardContent>
             <Table>
                <TableHeader>
                  <TableRow className="hover:bg-transparent">
                    <TableHead className="w-[200px]">Məhsul</TableHead>
                    <TableHead>Kateqoriya</TableHead>
                    <TableHead className="text-right">Satış</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data?.topProducts?.map((p: any) => (
                    <TableRow key={p._id}>
                      <TableCell className="font-medium text-sm">{p.name}</TableCell>
                      <TableCell className="text-xs text-muted-foreground uppercase">{p._id || "Digər"}</TableCell>
                      <TableCell className="text-right font-bold text-sm text-primary">{p.totalQty} ədəd</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
          </CardContent>
        </Card>

        <Card className="lg:col-span-3">
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
               <CardTitle className="text-lg">Sistem Aktivliyi</CardTitle>
               <CardDescription>Son admin hadisələri.</CardDescription>
            </div>
            <Bell className="h-4 w-4 text-muted-foreground animate-pulse" />
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {logs.length === 0 ? (
                <p className="text-xs text-muted-foreground italic text-center py-4">Hələlik aktivlik yoxdur.</p>
              ) : (
                logs.map((log: any, i: number) => (
                  <div key={i} className="flex items-start gap-3">
                    <div className="h-8 w-8 rounded bg-muted flex items-center justify-center shrink-0">
                       <Activity className="h-4 w-4 text-primary" />
                    </div>
                    <div className="flex-1 space-y-0.5 min-w-0">
                      <p className="text-[11px] font-bold leading-none truncate uppercase tracking-tighter">{log.action}</p>
                      <p className="text-[10px] text-muted-foreground leading-tight italic">{log.details}</p>
                      <p className="text-[9px] text-muted-foreground/60">
                         {formatDistanceToNow(new Date(log.createdAt), { addSuffix: true, locale: az })}
                      </p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
