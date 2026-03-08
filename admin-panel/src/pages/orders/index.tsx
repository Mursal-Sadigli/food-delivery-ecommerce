import { useEffect, useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from "@/components/ui/select";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { getOrders, updateOrderStatus, cancelOrder, refundOrder } from "@/services/api";
import { useSocket } from "@/contexts/SocketContext";
import { 
  Loader2, 
  RefreshCw, 
  MoreVertical, 
  Eye, 
  XCircle, 
  RotateCcw, 
  Download,
  User,
  Store,
  Truck,
  Search
} from "lucide-react";
import { format } from "date-fns";
import { az } from "date-fns/locale";

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);
  const [isViewOpen, setIsViewOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [activeTab, setActiveTab] = useState("all");
  const { socket } = useSocket();

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const data = await getOrders();
      setOrders(data);
    } catch (error) {
      console.error("Sifarişləri gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();

    if (socket) {
      socket.on("new_order", (newOrder) => {
        setOrders((prev) => [newOrder, ...prev]);
        // Yeni sifariş gəldikdə səsli bildiriş və ya toast əlavə edilə bilər
        console.log("🆕 Yeni sifariş daxil oldu:", newOrder._id);
      });

      socket.on("order_updated", (updatedOrder) => {
        setOrders((prev) => 
          prev.map((o) => (o._id === updatedOrder._id ? { ...o, ...updatedOrder } : o))
        );
        console.log("🔄 Sifariş yeniləndi:", updatedOrder._id);
      });
    }

    return () => {
      if (socket) {
        socket.off("new_order");
        socket.off("order_updated");
      }
    };
  }, [socket]);

  const handleStatusChange = async (orderId: string, newStatus: string) => {
    setUpdatingId(orderId);
    try {
      await updateOrderStatus(orderId, newStatus);
      setOrders(orders.map(order =>
        order._id === orderId ? { ...order, status: newStatus } : order
      ));
    } catch (error) {
      alert("Status yenilənərkən xəta baş verdi");
    } finally {
      setUpdatingId(null);
    }
  };

  const handleCancel = async (id: string) => {
    if (!confirm("Bu sifarişi ləğv etmək istədiyinizə əminsiniz?")) return;
    try {
      await cancelOrder(id);
      fetchOrders();
    } catch (error) {
      alert("Ləğv edilərkən xəta baş verdi");
    }
  };

  const handleRefund = async (id: string) => {
    if (!confirm("Ödənişi geri qaytarmaq istədiyinizə əminsiniz?")) return;
    try {
      await refundOrder(id);
      fetchOrders();
    } catch (error) {
      alert("Geri qaytarılarkən xəta baş verdi");
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Hazırlanır': return 'bg-blue-500/10 text-blue-600 border-blue-500/20';
      case 'Bişirilir': return 'bg-orange-500/10 text-orange-600 border-orange-500/20';
      case 'Kuryerə verildi': return 'bg-purple-500/10 text-purple-600 border-purple-500/20';
      case 'Qapınızdadır': return 'bg-indigo-500/10 text-indigo-600 border-indigo-500/20';
      case 'Çatdırıldı': return 'bg-green-500/10 text-green-600 border-green-500/20';
      case 'Ləğv edildi': return 'bg-red-500/10 text-red-600 border-red-500/20';
      case 'Geri qaytarıldı': return 'bg-gray-500/10 text-gray-600 border-gray-500/20';
      default: return 'bg-slate-500/10 text-slate-500 border-slate-500/20';
    }
  };

  const filteredOrders = orders.filter(order => {
    const matchesSearch = 
      order._id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.user?.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.orderItems?.[0]?.product?.user?.name?.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesTab = activeTab === "all" || order.status === activeTab;
    
    return matchesSearch && matchesTab;
  });

  const exportCSV = () => {
    const headers = ["ID", "Customer", "Restaurant", "Amount", "Status", "Date"];
    const rows = filteredOrders.map(o => [
      o._id,
      o.user?.name || "Guest",
      o.orderItems?.[0]?.product?.user?.name || "Unknown",
      o.totalPrice,
      o.status,
      o.createdAt
    ]);
    
    let csvContent = "data:text/csv;charset=utf-8," 
      + headers.join(",") + "\n"
      + rows.map(e => e.join(",")).join("\n");
      
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `orders_${format(new Date(), 'yyyy-MM-dd')}.csv`);
    document.body.appendChild(link);
    link.click();
  };

  if (loading) {
    return (
      <div className="flex h-[400px] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  const tabs = [
    { id: "all", label: "Hamısı" },
    { id: "Hazırlanır", label: "Hazırlanır" },
    { id: "Kuryerə verildi", label: "Kuryerdə" },
    { id: "Çatdırıldı", label: "Çatdırıldı" },
    { id: "Ləğv edildi", label: "Ləğv edilmiş" },
  ];

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Sifarişlər</h2>
          <p className="text-muted-foreground">Sistemdəki bütün sifarişlərin idarə edilməsi.</p>
        </div>
        <div className="flex gap-2">
           <Button variant="outline" size="sm" onClick={fetchOrders}>
             <RefreshCw className="mr-2 h-4 w-4" />
             Yenilə
           </Button>
           <Button size="sm" variant="secondary" onClick={exportCSV}>
             <Download className="mr-2 h-4 w-4" />
             Eksport (CSV)
           </Button>
        </div>
      </div>

      <div className="flex flex-col md:flex-row gap-4 items-center justify-between bg-card p-4 rounded-lg border shadow-sm">
         <div className="flex gap-1 bg-muted p-1 rounded-md w-full md:w-auto overflow-x-auto no-scrollbar">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-3 py-1.5 text-xs font-medium rounded transition-all whitespace-nowrap ${
                  activeTab === tab.id 
                    ? "bg-background text-foreground shadow-sm" 
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                {tab.label}
              </button>
            ))}
         </div>
         <div className="relative w-full md:w-64">
            <Search className="absolute left-2.5 top-2.5 h-3.5 w-3.5 text-muted-foreground" />
            <Input
              placeholder="Sifariş və ya müştəri axtar..."
              className="pl-9 h-9 text-xs"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
         </div>
      </div>

      <Card>
        <CardHeader className="pb-2">
          <div className="flex items-center justify-between">
            <CardTitle>Sifariş Siyahısı</CardTitle>
            <Badge variant="outline" className="font-mono text-[10px]">
              {filteredOrders.length} nəticə
            </Badge>
          </div>
          <CardDescription>Siyahı hazırda {activeTab === "all" ? "hamısını" : activeTab} göstərir.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow className="hover:bg-transparent">
                <TableHead className="w-[100px]">ID</TableHead>
                <TableHead>Müştəri</TableHead>
                <TableHead>Restoran</TableHead>
                <TableHead>Məbləğ</TableHead>
                <TableHead>Kuryer</TableHead>
                <TableHead>Tarix</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Əməliyyat</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredOrders.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="h-24 text-center">
                    Axtarışa uyğun sifariş tapılmadı.
                  </TableCell>
                </TableRow>
              ) : (
                filteredOrders.map((order) => (
                  <TableRow key={order._id}>
                    <TableCell className="font-mono text-[10px] text-muted-foreground">
                      #{order._id.slice(-6).toUpperCase()}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <div className="h-7 w-7 rounded-full bg-primary/10 flex items-center justify-center">
                          <User className="h-3.5 w-3.5 text-primary" />
                        </div>
                        <div className="flex flex-col">
                          <span className="text-xs font-bold">{order.user?.name || 'Qonaq'}</span>
                          <span className="text-[10px] text-muted-foreground">{order.user?.email || '-'}</span>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                       <div className="flex items-center gap-1.5 text-xs">
                          <Store className="h-3 w-3 text-muted-foreground" />
                          <span>{order.orderItems?.[0]?.product?.user?.name || "Naməlum"}</span>
                       </div>
                    </TableCell>
                    <TableCell className="font-bold text-xs">
                      ${order.totalPrice?.toFixed(2)}
                    </TableCell>
                    <TableCell>
                       {order.courier ? (
                         <div className="flex items-center gap-1.5 text-xs text-green-600">
                            <Truck className="h-3 w-3" />
                            <span>{order.courier.name}</span>
                         </div>
                       ) : (
                         <span className="text-[10px] text-muted-foreground italic">Təyin edilməyib</span>
                       )}
                    </TableCell>
                    <TableCell className="text-[10px] text-muted-foreground">
                      {format(new Date(order.createdAt), "d MMM, HH:mm", { locale: az })}
                    </TableCell>
                    <TableCell>
                       <Select
                          defaultValue={order.status}
                          onValueChange={(value) => handleStatusChange(order._id, value)}
                          disabled={updatingId === order._id}
                        >
                          <SelectTrigger className={`w-[130px] h-7 text-[10px] font-bold uppercase ${getStatusColor(order.status)}`}>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="Hazırlanır">Hazırlanır</SelectItem>
                            <SelectItem value="Bişirilir">Bişirilir</SelectItem>
                            <SelectItem value="Kuryerə verildi">Kuryerə</SelectItem>
                            <SelectItem value="Qapınızdadır">Qapınızda</SelectItem>
                            <SelectItem value="Çatdırıldı">Çatdırıldı</SelectItem>
                          </SelectContent>
                        </Select>
                    </TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon" className="h-8 w-8">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Seçimlər</DropdownMenuLabel>
                          <DropdownMenuItem onClick={() => { setSelectedOrder(order); setIsViewOpen(true); }}>
                            <Eye className="mr-2 h-4 w-4" /> Baxış
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem 
                            className="text-destructive focus:text-destructive"
                            onClick={() => handleCancel(order._id)}
                            disabled={order.status === 'Ləğv edildi'}
                          >
                            <XCircle className="mr-2 h-4 w-4" /> Ləğv Et
                          </DropdownMenuItem>
                          <DropdownMenuItem 
                            onClick={() => handleRefund(order._id)}
                            disabled={order.status === 'Geri qaytarıldı'}
                          >
                            <RotateCcw className="mr-2 h-4 w-4" /> Geri Qaytar
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* View Dialog */}
      <Dialog open={isViewOpen} onOpenChange={setIsViewOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Sifariş Detalları</DialogTitle>
            <DialogDescription>
              ID: #{selectedOrder?._id.toUpperCase()}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
             <div className="grid grid-cols-2 gap-4 border-b pb-4">
                <div>
                  <p className="text-[10px] uppercase text-muted-foreground font-bold">Müştəri</p>
                  <p className="text-sm font-medium">{selectedOrder?.user?.name}</p>
                </div>
                <div>
                  <p className="text-[10px] uppercase text-muted-foreground font-bold">Telefon</p>
                  <p className="text-sm font-medium">{selectedOrder?.shippingAddress?.phone || "Qeyd yoxdur"}</p>
                </div>
             </div>
             
             <div>
                <p className="text-[10px] uppercase text-muted-foreground font-bold mb-2">Məhsullar</p>
                <div className="space-y-2">
                   {selectedOrder?.orderItems.map((item: any, i: number) => (
                     <div key={i} className="flex justify-between items-center text-sm p-2 bg-muted/50 rounded">
                        <span>{item.qty}x {item.name}</span>
                        <span className="font-bold">${(item.price * item.qty).toFixed(2)}</span>
                     </div>
                   ))}
                </div>
             </div>

             <div className="flex justify-between items-center pt-2 border-t">
                <span className="text-sm font-bold">Cəmi Məbləğ</span>
                <span className="text-lg font-bold text-primary">${selectedOrder?.totalPrice?.toFixed(2)}</span>
             </div>
             
             <div className="bg-yellow-500/5 p-3 rounded-lg border border-yellow-500/10">
                <p className="text-[10px] uppercase text-yellow-600 font-bold">Ünvan</p>
                <p className="text-xs">{selectedOrder?.shippingAddress?.address}, {selectedOrder?.shippingAddress?.city}</p>
             </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
