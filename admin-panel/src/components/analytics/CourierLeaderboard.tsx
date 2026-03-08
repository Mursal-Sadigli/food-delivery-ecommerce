import { Badge } from "@/components/ui/badge";
import { Star, TrendingUp, Bike } from "lucide-react";

interface CourierData {
  _id: string;
  name: string;
  orderCount: number;
  avgRating: number;
  totalRevenue: number;
}

interface CourierLeaderboardProps {
  data: CourierData[];
}

export function CourierLeaderboard({ data }: CourierLeaderboardProps) {
  return (
    <div className="space-y-4 mt-4">
      {data.map((courier, index) => (
        <div key={courier._id} className="flex items-center justify-between p-3 rounded-xl border bg-card hover:shadow-md transition-all group">
          <div className="flex items-center gap-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary font-bold border relative">
              {index + 1}
              {index === 0 && <div className="absolute -top-1 -right-1 h-3 w-3 bg-yellow-400 rounded-full border-2 border-background animate-bounce" />}
            </div>
            <div>
              <p className="text-sm font-bold group-hover:text-primary transition-colors">{courier.name}</p>
              <div className="flex items-center gap-3 mt-1">
                <span className="flex items-center text-[10px] text-muted-foreground gap-1">
                  <Star className="h-3 w-3 text-yellow-500 fill-yellow-500" /> {courier.avgRating.toFixed(1)}
                </span>
                <span className="flex items-center text-[10px] text-muted-foreground gap-1">
                  <Bike className="h-3 w-3" /> {courier.orderCount} sifariş
                </span>
              </div>
            </div>
          </div>
          <div className="text-right">
            <p className="text-xs font-bold text-primary">{courier.totalRevenue.toFixed(2)} AZN</p>
            <Badge variant="outline" className="text-[9px] mt-1 h-4 bg-green-500/5 text-green-600 border-green-500/20">
              <TrendingUp className="h-2 w-2 mr-1" /> Best Speed
            </Badge>
          </div>
        </div>
      ))}
    </div>
  );
}
