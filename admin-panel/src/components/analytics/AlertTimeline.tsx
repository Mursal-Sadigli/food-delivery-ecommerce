import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";
import { AlertCircle, ArrowUpRight, Ban, CreditCard } from "lucide-react";

interface Alert {
  _id: string;
  admin: { name: string };
  action: string;
  details: string;
  createdAt: string;
}

interface AlertTimelineProps {
  data: Alert[];
}

const getActionIcon = (action: string) => {
  switch (action) {
    case 'REFUND_ORDER': return <CreditCard className="h-4 w-4 text-blue-500" />;
    case 'CANCEL_ORDER': return <Ban className="h-4 w-4 text-red-500" />;
    case 'USER_ROLE_CHANGE': return <ArrowUpRight className="h-4 w-4 text-green-500" />;
    default: return <AlertCircle className="h-4 w-4 text-primary" />;
  }
};

export function AlertTimeline({ data }: AlertTimelineProps) {
  return (
    <div className="space-y-6 mt-4 relative before:absolute before:left-[17px] before:top-2 before:bottom-2 before:w-0.5 before:bg-muted">
      {data.map((alert) => (
        <div key={alert._id} className="relative pl-10 group">
          <div className="absolute left-0 top-1.5 h-9 w-9 rounded-full bg-card border flex items-center justify-center z-10 group-hover:border-primary transition-colors shadow-sm">
            {getActionIcon(alert.action)}
          </div>
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-xs font-bold">{alert.admin?.name || 'Sistem'}</span>
              <Badge variant="secondary" className="text-[9px] uppercase tracking-tighter h-4">
                {alert.action.replace('_', ' ')}
              </Badge>
              <span className="text-[10px] text-muted-foreground ml-auto">
                {format(new Date(alert.createdAt), 'HH:mm')}
              </span>
            </div>
            <p className="text-xs text-muted-foreground line-clamp-1">{alert.details}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
