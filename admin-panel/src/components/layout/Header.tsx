import { useState, useEffect, useRef } from "react";
import { 
  Bell, 
  Search, 
  User, 
  LogOut, 
  Settings as SettingsIcon,
  ShoppingCart,
  Store,
  Pizza,
  Loader2,
  X
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useAuth } from "@/contexts/AuthContext";
import { ThemeToggle } from "./ThemeToggle";
import { globalSearch } from "@/services/api";
import { useNavigate } from "react-router-dom";

export function Header() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const delayDebounceFn = setTimeout(async () => {
      if (query.length >= 2) {
        setLoading(true);
        try {
          const data = await globalSearch(query);
          setResults(data);
          setIsOpen(true);
        } catch (error) {
          console.error("Search error:", error);
        } finally {
          setLoading(false);
        }
      } else {
        setResults(null);
        setIsOpen(false);
      }
    }, 300);

    return () => clearTimeout(delayDebounceFn);
  }, [query]);

  // Click outside close
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSelect = (type: string, _id: string) => {
    setIsOpen(false);
    setQuery("");
    if (type === 'order') navigate('/orders');
    if (type === 'restaurant') navigate('/restaurants');
    if (type === 'food') navigate('/foods');
  };

  return (
    <header className="sticky top-0 z-10 flex h-16 items-center gap-4 border-b bg-background px-6 backdrop-blur-sm bg-background/80">
      <div className="flex flex-1 items-center gap-4 relative" ref={searchRef}>
        <div className="relative w-full max-w-sm hidden md:block">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            type="search"
            placeholder="Sifariş, müştəri və ya məhsul axtar..."
            className="pl-9 bg-muted/50 border-none focus-visible:ring-1 focus-visible:ring-primary/20"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => query.length >= 2 && setIsOpen(true)}
          />
          {loading && (
            <Loader2 className="absolute right-2.5 top-2.5 h-4 w-4 animate-spin text-muted-foreground" />
          )}
          {query && !loading && (
            <X 
              className="absolute right-2.5 top-2.5 h-4 w-4 cursor-pointer text-muted-foreground hover:text-foreground" 
              onClick={() => setQuery("")}
            />
          )}
        </div>

        {/* Global Search Results Dropdown */}
        {isOpen && results && (
          <div className="absolute top-12 left-0 w-full max-w-sm bg-card border rounded-lg shadow-xl z-50 p-2 overflow-hidden animate-in fade-in zoom-in duration-200">
             <div className="max-h-[400px] overflow-y-auto no-scrollbar">
                {results.orders.length > 0 && (
                  <div className="mb-3">
                    <p className="px-2 py-1 text-[10px] font-bold uppercase text-muted-foreground">Sifarişlər</p>
                    {results.orders.map((o: any) => (
                      <div 
                        key={o._id} 
                        className="flex items-center gap-2 p-2 hover:bg-muted rounded cursor-pointer transition-colors"
                        onClick={() => handleSelect('order', o._id)}
                      >
                         <ShoppingCart className="h-3.5 w-3.5 text-blue-500" />
                         <div className="flex flex-col">
                            <span className="text-xs font-medium">#{o._id.slice(-6).toUpperCase()}</span>
                            <span className="text-[10px] text-muted-foreground">{o.user?.name}</span>
                         </div>
                         <span className="ml-auto text-[8px] h-4 border px-1 rounded-full">{o.status}</span>
                      </div>
                    ))}
                  </div>
                )}

                {results.restaurants.length > 0 && (
                  <div className="mb-3">
                    <p className="px-2 py-1 text-[10px] font-bold uppercase text-muted-foreground">Restoranlar</p>
                    {results.restaurants.map((r: any) => (
                      <div 
                        key={r._id} 
                        className="flex items-center gap-2 p-2 hover:bg-muted rounded cursor-pointer transition-colors"
                        onClick={() => handleSelect('restaurant', r._id)}
                      >
                         <Store className="h-3.5 w-3.5 text-green-500" />
                         <span className="text-xs font-medium">{r.name}</span>
                      </div>
                    ))}
                  </div>
                )}

                {results.foods.length > 0 && (
                  <div className="mb-3">
                    <p className="px-2 py-1 text-[10px] font-bold uppercase text-muted-foreground">Məhsullar</p>
                    {results.foods.map((f: any) => (
                      <div 
                        key={f._id} 
                        className="flex items-center gap-2 p-2 hover:bg-muted rounded cursor-pointer transition-colors"
                        onClick={() => handleSelect('food', f._id)}
                      >
                         <Pizza className="h-3.5 w-3.5 text-orange-500" />
                         <div className="flex flex-col">
                            <span className="text-xs font-medium">{f.name}</span>
                            <span className="text-[10px] text-muted-foreground">{f.category}</span>
                         </div>
                      </div>
                    ))}
                  </div>
                )}

                {results.orders.length === 0 && results.restaurants.length === 0 && results.foods.length === 0 && (
                  <div className="p-4 text-center text-xs text-muted-foreground italic">
                    Nəticə tapılmadı.
                  </div>
                )}
             </div>
          </div>
        )}
      </div>
      
      <div className="flex items-center gap-3">
        <ThemeToggle />
        <Button variant="ghost" size="icon" className="relative">
          <Bell className="h-5 w-5 text-muted-foreground" />
          <span className="absolute top-2 right-2 flex h-2 w-2 rounded-full bg-primary ring-2 ring-background" />
        </Button>
        
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="rounded-full bg-muted/50 border h-9 w-9">
              <User className="h-5 w-5 text-muted-foreground" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel className="flex flex-col">
              <span className="text-sm font-bold">{user?.name}</span>
              <span className="text-[10px] text-muted-foreground font-normal">{user?.email}</span>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem className="cursor-pointer" onClick={() => navigate('/settings')}>
              <User className="mr-2 h-4 w-4" />
              <span>Profil</span>
            </DropdownMenuItem>
            <DropdownMenuItem className="cursor-pointer" onClick={() => navigate('/settings')}>
              <SettingsIcon className="mr-2 h-4 w-4" />
              <span>Tənzimləmələr</span>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem 
              className="cursor-pointer text-destructive focus:text-destructive focus:bg-destructive/10"
              onClick={logout}
            >
              <LogOut className="mr-2 h-4 w-4" />
              <span>Çıxış</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}

