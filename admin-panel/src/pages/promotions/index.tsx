import { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { 
  Dialog, 
  DialogContent, 
  DialogDescription, 
  DialogFooter, 
  DialogHeader, 
  DialogTitle, 
  DialogTrigger 
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { getPromotions, createPromotion, deletePromotion } from "@/services/api";
import { Loader2, Plus, Trash2, Ticket, Percent, DollarSign, Calendar } from "lucide-react";
import { format } from "date-fns";
import { az } from "date-fns/locale";

export default function PromotionsPage() {
  const [promotions, setPromotions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [newPromo, setNewPromo] = useState({
    code: "",
    discountAmount: 0,
    discountType: "fixed",
    expiryDate: ""
  });
  const [creating, setCreating] = useState(false);

  const fetchPromotions = async () => {
    try {
      setLoading(true);
      const data = await getPromotions();
      setPromotions(data);
    } catch (error) {
      console.error("Promosiyaları gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPromotions();
  }, []);

  const handleCreate = async () => {
    setCreating(true);
    try {
      await createPromotion(newPromo);
      setIsDialogOpen(false);
      setNewPromo({ code: "", discountAmount: 0, discountType: "fixed", expiryDate: "" });
      fetchPromotions();
    } catch (error) {
      alert("Promo kod yaradılarkən xəta baş verdi.");
    } finally {
      setCreating(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Bu promo kodu silmək istədiyinizə əminsiniz?")) return;
    try {
      await deletePromotion(id);
      setPromotions(promotions.filter(p => p._id !== id));
    } catch (error) {
      alert("Silinərkən xəta baş verdi.");
    }
  };

  if (loading) {
    return (
      <div className="flex h-[400px] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Promosiyalar</h2>
          <p className="text-muted-foreground">Endirim kuponları və kampaniya kodları.</p>
        </div>
        
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Yeni Promo Kod
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Yeni Promo Kod Yarat</DialogTitle>
              <DialogDescription>Endirim məbləği və son istifadə tarixini qeyd edin.</DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid gap-2">
                <Label htmlFor="code">Kupon Kodu</Label>
                <Input 
                  id="code" 
                  placeholder="Məs: YAY2024" 
                  value={newPromo.code}
                  onChange={(e) => setNewPromo({...newPromo, code: e.target.value})}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="type">Növ</Label>
                  <Select 
                    value={newPromo.discountType} 
                    onValueChange={(val) => setNewPromo({...newPromo, discountType: val})}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Seçin" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="fixed">Sabit Məbləğ ($)</SelectItem>
                      <SelectItem value="percent">Faiz (%)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="amount">Məbləğ / Faiz</Label>
                  <Input 
                    id="amount" 
                    type="number" 
                    placeholder="20" 
                    value={newPromo.discountAmount}
                    onChange={(e) => setNewPromo({...newPromo, discountAmount: parseFloat(e.target.value)})}
                  />
                </div>
              </div>
              <div className="grid gap-2">
                <Label htmlFor="expiry">Son İstifadə Tarixi</Label>
                <Input 
                  id="expiry" 
                  type="date" 
                  value={newPromo.expiryDate}
                  onChange={(e) => setNewPromo({...newPromo, expiryDate: e.target.value})}
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsDialogOpen(false)}>Ləğv Et</Button>
              <Button onClick={handleCreate} disabled={creating}>
                {creating && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Yarat
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Aktiv Kuponlar ({promotions.length})</CardTitle>
          <CardDescription>Sistemdəki bütün endirim kodları.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Kod</TableHead>
                <TableHead>Növ</TableHead>
                <TableHead>Endirim</TableHead>
                <TableHead>Son Tarix</TableHead>
                <TableHead className="text-right">Əməliyyat</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {promotions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-10 text-muted-foreground">
                    Heç bir promo kod tapılmadı.
                  </TableCell>
                </TableRow>
              ) : (
                promotions.map((promo) => (
                  <TableRow key={promo._id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Ticket className="h-4 w-4 text-primary" />
                        <span className="font-bold font-mono">{promo.code}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                       <Badge variant="outline" className="flex w-fit items-center gap-1">
                          {promo.discountType === "percent" ? <Percent className="h-3 w-3" /> : <DollarSign className="h-3 w-3" />}
                          {promo.discountType === "percent" ? "Faiz" : "Sabit"}
                       </Badge>
                    </TableCell>
                    <TableCell className="font-bold">
                       {promo.discountAmount}{promo.discountType === "percent" ? "%" : "$"}
                    </TableCell>
                    <TableCell className="text-sm">
                       <span className="flex items-center gap-1">
                          <Calendar className="h-3 w-3 text-muted-foreground" />
                          {format(new Date(promo.expiryDate), "d MMM yyyy", { locale: az })}
                       </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <Button 
                        variant="ghost" 
                        size="icon" 
                        className="text-destructive hover:text-destructive hover:bg-destructive/10"
                        onClick={() => handleDelete(promo._id)}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
