import { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { getReviews, deleteReview } from "@/services/api";
import { Loader2, Trash2, Star, User, Pizza } from "lucide-react";
import { format } from "date-fns";
import { az } from "date-fns/locale";

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchReviews = async () => {
    try {
      setLoading(true);
      const data = await getReviews();
      setReviews(data);
    } catch (error) {
      console.error("Rəyləri gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReviews();
  }, []);

  const handleDelete = async (id: string) => {
    if (!confirm("Bu rəyi silmək istədiyinizə əminsiniz?")) return;
    try {
      await deleteReview(id);
      setReviews(reviews.filter(r => r._id !== id));
    } catch (error) {
      alert("Rəy silinərkən xəta baş verdi.");
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
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Rəylər</h2>
        <p className="text-muted-foreground">İstifadəçilərin məhsul və xidmətlər barədə rəyləri.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Bütün Rəylər ({reviews.length})</CardTitle>
          <CardDescription>Müştərilərin rəylərini izləyin və spam rəyləri uzaqlaşdırın.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>İstifadəçi</TableHead>
                <TableHead>Məhsul</TableHead>
                <TableHead>Reytinq</TableHead>
                <TableHead>Şərh</TableHead>
                <TableHead>Tarix</TableHead>
                <TableHead className="text-right">Əməliyyat</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {reviews.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-10 text-muted-foreground">
                    Heç bir rəy tapılmadı.
                  </TableCell>
                </TableRow>
              ) : (
                reviews.map((review) => (
                  <TableRow key={review._id}>
                    <TableCell>
                      <div className="flex flex-col">
                        <span className="font-medium text-sm flex items-center gap-1">
                          <User className="h-3 w-3" /> {review.user?.name || "Naməlum"}
                        </span>
                        <span className="text-[10px] text-muted-foreground">{review.user?.email}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm flex items-center gap-1">
                        <Pizza className="h-3 w-3" /> {review.product?.name || "Məhsul silinib"}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-0.5">
                        {[...Array(5)].map((_, i) => (
                          <Star 
                            key={i} 
                            className={`h-3 w-3 ${i < review.rating ? "fill-primary text-primary" : "text-muted"}`} 
                          />
                        ))}
                        <span className="ml-1 text-xs font-bold">{review.rating}</span>
                      </div>
                    </TableCell>
                    <TableCell className="max-w-[300px] truncate" title={review.comment}>
                      {review.comment}
                    </TableCell>
                    <TableCell className="text-xs">
                      {format(new Date(review.createdAt), "d MMM yyyy", { locale: az })}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button 
                        variant="ghost" 
                        size="icon" 
                        className="text-destructive hover:text-destructive hover:bg-destructive/10"
                        onClick={() => handleDelete(review._id)}
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
