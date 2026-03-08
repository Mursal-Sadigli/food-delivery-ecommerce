import React, { useEffect, useState } from "react";
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { getFoods, createFood, updateFood, deleteFood } from "@/services/api";
import { Loader2, Plus, Pencil, Trash2, RefreshCw } from "lucide-react";

export default function FoodsPage() {
  const [foods, setFoods] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingFood, setEditingFood] = useState<any>(null);
  const [formData, setFormData] = useState({
    name: "",
    price: "",
    category: "",
    description: "",
    image: ""
  });

  const fetchFoods = async () => {
    try {
      setLoading(true);
      const data = await getFoods();
      setFoods(data);
    } catch (error) {
      console.error("Yeməklər yüklənərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFoods();
  }, []);

  const handleOpenDialog = (food: any = null) => {
    if (food) {
      setEditingFood(food);
      setFormData({
        name: food.name,
        price: food.price.toString(),
        category: food.category || "",
        description: food.description || "",
        image: food.image || ""
      });
    } else {
      setEditingFood(null);
      setFormData({
        name: "",
        price: "",
        category: "",
        description: "",
        image: ""
      });
    }
    setIsDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const dataToSend = {
        ...formData,
        price: parseFloat(formData.price)
      };

      if (editingFood) {
        await updateFood(editingFood._id, dataToSend);
      } else {
        await createFood(dataToSend);
      }
      
      setIsDialogOpen(false);
      fetchFoods();
    } catch (error) {
      alert("Xəta baş verdi. Zəhmət olmasa yenidən yoxlayın.");
    }
  };

  const handleDelete = async (id: string) => {
    if (window.confirm("Bu məhsulu silmək istədiyinizə əminsiniz?")) {
      try {
        await deleteFood(id);
        fetchFoods();
      } catch (error) {
        alert("Silinmə zamanı xəta baş verdi.");
      }
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Məhsullar</h2>
          <p className="text-muted-foreground">Menyudakı bütün yeməkləri idarə edin.</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={fetchFoods}>
             <RefreshCw className="mr-2 h-4 w-4" />
             Yenilə
          </Button>
          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" onClick={() => handleOpenDialog()}>
                <Plus className="mr-2 h-4 w-4" />
                Yeni Yemək
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
              <form onSubmit={handleSubmit}>
                <DialogHeader>
                  <DialogTitle>{editingFood ? "Yeməyi Redaktə Et" : "Yeni Yemək Əlavə Et"}</DialogTitle>
                  <DialogDescription>
                    Məhsul məlumatlarını aşağıdakı xanalara daxil edin.
                  </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="name" className="text-right">Ad</Label>
                    <Input id="name" value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} className="col-span-3" required />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="price" className="text-right">Qiymət</Label>
                    <Input id="price" type="number" step="0.01" value={formData.price} onChange={(e) => setFormData({...formData, price: e.target.value})} className="col-span-3" required />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="category" className="text-right">Kateqoriya</Label>
                    <Input id="category" value={formData.category} onChange={(e) => setFormData({...formData, category: e.target.value})} className="col-span-3" required />
                  </div>
                  <div className="grid grid-cols-4 items-center gap-4">
                    <Label htmlFor="description" className="text-right">Təsvir</Label>
                    <Input id="description" value={formData.description} onChange={(e) => setFormData({...formData, description: e.target.value})} className="col-span-3" />
                  </div>
                </div>
                <DialogFooter>
                  <Button type="submit">{editingFood ? "Yadda Saxla" : "Əlavə Et"}</Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Yeməklər Siyahısı</CardTitle>
          <CardDescription>Məhsulları silə və ya məlumatlarını yeniləyə bilərsiniz.</CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center p-8">
              <Loader2 className="h-8 w-8 animate-spin" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ad</TableHead>
                  <TableHead>Kateqoriya</TableHead>
                  <TableHead>Qiymət</TableHead>
                  <TableHead className="text-right">Əməliyyatlar</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {foods.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="text-center py-6 text-muted-foreground">
                      Hələ heç bir məhsul yoxdur.
                    </TableCell>
                  </TableRow>
                ) : (
                  foods.map((food) => (
                    <TableRow key={food._id}>
                      <TableCell className="font-medium">{food.name}</TableCell>
                      <TableCell>{food.category}</TableCell>
                      <TableCell className="font-semibold">${food.price?.toFixed(2)}</TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" onClick={() => handleOpenDialog(food)}>
                            <Pencil className="h-4 w-4 text-blue-500" />
                          </Button>
                          <Button variant="ghost" size="icon" onClick={() => handleDelete(food._id)}>
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
