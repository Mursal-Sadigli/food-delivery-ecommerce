import { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { getPayments } from "@/services/api";
import { Loader2, CreditCard, User, Calendar, CheckCircle2 } from "lucide-react";
import { format } from "date-fns";
import { az } from "date-fns/locale";

export default function PaymentsPage() {
  const [payments, setPayments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchPayments = async () => {
    try {
      setLoading(true);
      const data = await getPayments();
      setPayments(data);
    } catch (error) {
      console.error("Ödənişləri gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPayments();
  }, []);

  const totalRevenue = payments.reduce((sum, p) => sum + p.totalPrice, 0);

  if (loading) {
    return (
      <div className="flex h-[400px] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Ümumi Gəlir</CardTitle>
          </CardHeader>
          <CardContent>
             <div className="text-2xl font-bold text-primary">${totalRevenue.toFixed(2)}</div>
             <p className="text-[10px] text-muted-foreground mt-1">Bütün uğurlu ödənişlərin cəmi</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Ödəniş Sayı</CardTitle>
          </CardHeader>
          <CardContent>
             <div className="text-2xl font-bold">{payments.length}</div>
             <p className="text-[10px] text-muted-foreground mt-1">Tranzaksiyaların ümumi sayı</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Orta Çek</CardTitle>
          </CardHeader>
          <CardContent>
             <div className="text-2xl font-bold">
               ${payments.length > 0 ? (totalRevenue / payments.length).toFixed(2) : "0.00"}
             </div>
             <p className="text-[10px] text-muted-foreground mt-1">Hər ödənişə düşən orta məbləğ</p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Ödəniş Tarixçəsi</CardTitle>
          <CardDescription>Sistemdəki bütün uğurlu tranzaksiyaların siyahısı.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Tranzaksiya ID</TableHead>
                <TableHead>Müştəri</TableHead>
                <TableHead>Məbləğ</TableHead>
                <TableHead>Metod</TableHead>
                <TableHead>Tarix</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {payments.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-10 text-muted-foreground">
                    Heç bir ödəniş tapılmadı.
                  </TableCell>
                </TableRow>
              ) : (
                payments.map((payment) => (
                  <TableRow key={payment._id}>
                    <TableCell className="font-mono text-xs text-muted-foreground">
                      #{payment._id.slice(-8).toUpperCase()}
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-col">
                        <span className="font-medium text-sm flex items-center gap-1">
                          <User className="h-3 w-3" /> {payment.user?.name || "Naməlum"}
                        </span>
                        <span className="text-[10px] text-muted-foreground">{payment.user?.email}</span>
                      </div>
                    </TableCell>
                    <TableCell className="font-bold">
                       ${payment.totalPrice.toFixed(2)}
                    </TableCell>
                    <TableCell>
                       <div className="flex items-center gap-2">
                          <CreditCard className="h-4 w-4 text-muted-foreground" />
                          <span className="text-sm capitalize">{payment.paymentMethod || "Kart"}</span>
                       </div>
                    </TableCell>
                    <TableCell className="text-xs">
                       <span className="flex items-center gap-1 text-muted-foreground">
                          <Calendar className="h-3 w-3" />
                          {payment.paidAt ? format(new Date(payment.paidAt), "d MMM yyyy, HH:mm", { locale: az }) : "Qeyd olunmayıb"}
                       </span>
                    </TableCell>
                    <TableCell>
                       <Badge variant="outline" className="bg-green-500/10 text-green-600 border-green-500/20 flex w-fit items-center gap-1">
                          <CheckCircle2 className="h-3 w-3" />
                          Uğurlu
                       </Badge>
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
