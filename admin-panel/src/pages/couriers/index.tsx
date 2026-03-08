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
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { getCouriers } from "@/services/api";
import { Loader2, Bike, RefreshCw } from "lucide-react";

export default function CouriersPage() {
  const [couriers, setCouriers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchCouriers = async () => {
    try {
      setLoading(true);
      const data = await getCouriers();
      setCouriers(data);
    } catch (error) {
      console.error("Kuryerlər yüklənərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCouriers();
  }, []);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Kuryerlər</h2>
          <p className="text-muted-foreground">Sistemdə qeydiyyatda olan kuryerlərin siyahısı.</p>
        </div>
        <div className="flex gap-2">
           <Button variant="outline" size="sm" onClick={fetchCouriers}>
              <RefreshCw className="mr-2 h-4 w-4" />
              Yenilə
           </Button>
           <Button size="sm">Kuryer Əlavə Et</Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Kuryer Siyahısı</CardTitle>
          <CardDescription>Kuryerlərin fəaliyyətini və statuslarını buradan izləyə bilərsiniz.</CardDescription>
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
                  <TableHead>Kuryer Adı</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Ümumi Çatdırılma</TableHead>
                  <TableHead className="text-right">Əməliyyat</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {couriers.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} className="text-center py-6 text-muted-foreground">
                      Heç bir kuryer tapılmadı.
                    </TableCell>
                  </TableRow>
                ) : (
                  couriers.map((courier) => (
                    <TableRow key={courier._id}>
                      <TableCell>
                        <div className="flex items-center gap-2">
                           <div className="h-8 w-8 rounded-full bg-orange-500/10 flex items-center justify-center">
                              <Bike className="h-4 w-4 text-orange-500" />
                           </div>
                           <span className="font-medium">{courier.name}</span>
                        </div>
                      </TableCell>
                      <TableCell>{courier.email}</TableCell>
                      <TableCell>
                        <Badge variant={courier.isOnline ? 'default' : 'secondary'}>
                          {courier.isOnline ? 'Online' : 'Offline'}
                        </Badge>
                      </TableCell>
                      <TableCell className="font-medium text-center">
                        {courier.deliveryCount || 0}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button variant="ghost" size="sm">Detallar</Button>
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
