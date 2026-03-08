import { useEffect, useState } from 'react';
import { 
  Card, 
  CardContent, 
  CardDescription, 
  CardHeader, 
  CardTitle 
} from "@/components/ui/card";
import { 
  BarChart3, 
  Map as MapIcon, 
  Users, 
  Zap, 
  History,
  RefreshCcw,
  Loader2,
  TrendingUp,
  Target
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { getAdvancedAnalytics } from "@/services/api";
import { OrderFunnel } from "@/components/analytics/OrderFunnel";
import { CourierLeaderboard } from "@/components/analytics/CourierLeaderboard";
import { RevenueFlow } from "@/components/analytics/RevenueFlow";
import { LiveMap } from "@/components/analytics/LiveMap";
import { AlertTimeline } from "@/components/analytics/AlertTimeline";
import { CohortAnalytics } from "@/components/analytics/CohortAnalytics";
import { ScenarioSimulator } from "@/components/analytics/ScenarioSimulator";

export default function AnalyticsPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      setLoading(true);
      const res = await getAdvancedAnalytics();
      setData(res);
    } catch (err) {
      console.error("Analitika yüklənərkən xəta:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    // Real-time update simulation or use socket here if needed
    const interval = setInterval(fetchData, 30000); // 30s update
    return () => clearInterval(interval);
  }, []);

  if (loading && !data) {
    return (
      <div className="flex h-[80vh] w-full items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6 p-6 animate-in fade-in duration-500">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Qabaqcıl Analitika</h1>
          <p className="text-muted-foreground mt-1">Sistemin real-time vəziyyəti və biznes proqnozları.</p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchData} disabled={loading}>
          <RefreshCcw className={loading ? "mr-2 h-4 w-4 animate-spin" : "mr-2 h-4 w-4"} />
          Yenilə
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* 1. Order Funnel */}
        <Card className="shadow-sm border-primary/10 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <Zap className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Sifariş Funnel-i</CardTitle>
            </div>
            <CardDescription className="text-[10px]">Mərhələlər üzrə sifariş paylanması</CardDescription>
          </CardHeader>
          <CardContent className="h-[300px]">
            <OrderFunnel data={data?.funnel || []} />
          </CardContent>
        </Card>

        {/* 2. Revenue Flow */}
        <Card className="shadow-sm border-primary/10 lg:col-span-2 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <BarChart3 className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Gəlir və Sifariş Axını</CardTitle>
            </div>
            <CardDescription className="text-[10px]">Son 24 saatın real-time trendləri</CardDescription>
          </CardHeader>
          <CardContent className="h-[300px]">
            <RevenueFlow data={data?.revenueFlow || []} />
          </CardContent>
        </Card>

        {/* 3. Live Map */}
        <Card className="shadow-sm border-primary/10 lg:col-span-2 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <MapIcon className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Smart Multi-Zone Xəritə</CardTitle>
            </div>
            <CardDescription className="text-[10px]">Canlı kuryer və sifariş xəritəsi</CardDescription>
          </CardHeader>
          <CardContent>
            <LiveMap data={data?.mapData || { orders: [], couriers: [], restaurants: [] }} />
          </CardContent>
        </Card>

        {/* 4. Scenario Simulator */}
        <Card className="shadow-sm border-primary/10 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <Target className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Biznes Simulyatoru</CardTitle>
            </div>
            <CardDescription className="text-[10px]">What-if senarilərini test edin</CardDescription>
          </CardHeader>
          <CardContent>
            <ScenarioSimulator />
          </CardContent>
        </Card>

        {/* 5. Courier Leaderboard */}
        <Card className="shadow-sm border-primary/10 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Kuryer Leaderboard</CardTitle>
            </div>
            <CardDescription className="text-[10px]">Ən yaxşı performans göstərən kuryerlər</CardDescription>
          </CardHeader>
          <CardContent>
            <CourierLeaderboard data={data?.courierLeaderboard || []} />
          </CardContent>
        </Card>

        {/* 6. Cohort Analytics */}
        <Card className="shadow-sm border-primary/10 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <Users className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Cohort Analitika</CardTitle>
            </div>
            <CardDescription className="text-[10px]">İstifadəçi retention və seqmentasiya</CardDescription>
          </CardHeader>
          <CardContent className="h-[300px] flex items-center justify-center">
            <CohortAnalytics data={data?.cohortData || { total: 0, active: 0, returning: 0 }} />
          </CardContent>
        </Card>

        {/* 7. Alert Timeline */}
        <Card className="shadow-sm border-primary/10 overflow-hidden">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <History className="h-4 w-4 text-primary" />
              <CardTitle className="text-base">Canlı Sistem Timeline-ı</CardTitle>
            </div>
            <CardDescription className="text-[10px]">Kritik alertlər və hadisələr</CardDescription>
          </CardHeader>
          <CardContent className="max-h-[300px] overflow-y-auto no-scrollbar">
            <AlertTimeline data={data?.alerts || []} />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
