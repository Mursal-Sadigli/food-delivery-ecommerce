import { useEffect, useState, useCallback } from "react";
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
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { getUsers } from "@/services/api";
import { Loader2, Plus } from "lucide-react";
import { AddRestaurantModal } from "./AddRestaurantModal";

export default function RestaurantsPage() {
  const [restaurants, setRestaurants] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchRestaurants = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getUsers();
      // Sadecə seller və ya restoran olanları filtrli (role: seller olanları restoran kimi qəbul edirik)
      const filters = data.filter((u: any) => u.role === 'seller' || u.role === 'admin');
      setRestaurants(filters);
    } catch (error) {
      console.error("Restoranları gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchRestaurants();
  }, [fetchRestaurants]);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Restaurants</h2>
          <p className="text-muted-foreground">Sistemdəki bütün partnyor restoranlar və satıcılar.</p>
        </div>
        <Button onClick={() => setIsModalOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Restoran Əlavə Et
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Restoranlar</CardTitle>
          <CardDescription>Restoranları aktiv/deaktiv edin və detallarına baxın.</CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex h-40 items-center justify-center">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ad</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Rol</TableHead>
                  <TableHead>Şəhər / Rayon</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Əməliyyat</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {restaurants.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-10 text-muted-foreground">
                      Heç bir restoran tapılmadı.
                    </TableCell>
                  </TableRow>
                ) : (
                  restaurants.map((rest) => (
                    <TableRow key={rest._id}>
                      <TableCell className="font-medium">{rest.name}</TableCell>
                      <TableCell>{rest.email}</TableCell>
                      <TableCell className="capitalize">{rest.role}</TableCell>
                      <TableCell>{rest.city || '-'} / {rest.district || '-'}</TableCell>
                      <TableCell>
                        <Badge variant="default">Aktiv</Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <Button variant="outline" size="sm">Edit</Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <AddRestaurantModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        onSuccess={fetchRestaurants}
      />
    </div>
  );
}
