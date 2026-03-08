import { Link, useLocation } from "react-router-dom";
import { 
  LayoutDashboard, 
  ShoppingCart, 
  Store, 
  Pizza, 
  Users, 
  Bike, 
  Activity,
  LogOut,
  MessageSquare,
  Ticket,
  Settings,
  CreditCard,
  ChevronLeft,
  ChevronRight,
  ShieldCheck
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";

const navItems = [
  { group: "Main", items: [
    { title: "Dashboard", href: "/", icon: LayoutDashboard },
    { title: "Sifarişlər", href: "/orders", icon: ShoppingCart },
    { title: "Restoranlar", href: "/restaurants", icon: Store },
    { title: "Məhsullar", href: "/foods", icon: Pizza },
  ]},
  { group: "Management", items: [
    { title: "İstifadəçilər", href: "/users", icon: Users },
    { title: "Kuryerlər", href: "/couriers", icon: Bike },
    { title: "Rəylər", href: "/reviews", icon: MessageSquare },
  ]},
  { group: "Marketing & Finance", items: [
    { title: "Promosiyalar", href: "/promotions", icon: Ticket },
    { title: "Ödənişlər", href: "/payments", icon: CreditCard },
  ]},
  { group: "System", items: [
    { title: "Analitika", href: "/analytics", icon: Activity },
    { title: "Audit Loqları", href: "/audit-logs", icon: ShieldCheck },
    { title: "Tənzimləmələr", href: "/settings", icon: Settings },
  ]}
];

interface SidebarProps {
  isCollapsed: boolean;
  setIsCollapsed: (value: boolean) => void;
}

export function Sidebar({ isCollapsed, setIsCollapsed }: SidebarProps) {
  const location = useLocation();
  const { user, logout } = useAuth();

  return (
    <aside className={cn(
      "fixed inset-y-0 left-0 z-20 border-r bg-background hidden sm:flex flex-col transition-all duration-300 shadow-sm",
      isCollapsed ? "w-20" : "w-64"
    )}>
      <div className="relative flex h-16 items-center px-6 border-b">
        {!isCollapsed && (
          <h1 className="text-xl font-bold tracking-tight text-primary truncate">SmartMarket</h1>
        )}
        <Button 
          variant="ghost" 
          size="icon" 
          className="absolute -right-3 top-20 h-6 w-6 rounded-full border bg-background shadow-md z-30"
          onClick={() => setIsCollapsed(!isCollapsed)}
        >
          {isCollapsed ? <ChevronRight className="h-3 w-3" /> : <ChevronLeft className="h-3 w-3" />}
        </Button>
      </div>

      <nav className="flex-1 flex flex-col gap-4 p-4 overflow-y-auto no-scrollbar">
        {navItems.map((group) => (
          <div key={group.group} className="flex flex-col gap-1">
            {!isCollapsed && (
              <h2 className="px-3 text-[10px] font-bold uppercase tracking-wider text-muted-foreground/60 mb-1">
                {group.group}
              </h2>
            )}
            {group.items.map((item) => {
              const isActive = location.pathname === item.href;
              return (
                <Link
                  key={item.title}
                  to={item.href}
                  className={cn(
                    "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-all hover:bg-muted/50",
                    isActive ? "bg-primary/10 text-primary shadow-sm" : "text-muted-foreground",
                    isCollapsed && "justify-center px-0"
                  )}
                  title={isCollapsed ? item.title : ""}
                >
                  <item.icon className={cn("h-4 w-4", isActive ? "animate-pulse" : "")} />
                  {!isCollapsed && <span>{item.title}</span>}
                </Link>
              );
            })}
          </div>
        ))}
      </nav>

      <div className="p-4 border-t space-y-4">
        {!isCollapsed && (
          <div className="flex items-center gap-3 px-2">
            <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold border shrink-0">
              {user?.name?.charAt(0) || 'A'}
            </div>
            <div className="flex flex-col truncate">
              <span className="text-xs font-semibold truncate">{user?.name}</span>
              <span className="text-[10px] text-muted-foreground truncate">{user?.email}</span>
            </div>
          </div>
        )}
        <Button 
          variant="ghost" 
          className={cn(
            "w-full justify-start gap-3 text-destructive hover:text-destructive hover:bg-destructive/10",
            isCollapsed && "justify-center"
          )}
          onClick={logout}
          title={isCollapsed ? "Logout" : ""}
        >
          <LogOut className="h-4 w-4" />
          {!isCollapsed && <span>Çıxış</span>}
        </Button>
      </div>
    </aside>
  );
}
