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
import { getUsers, updateUserRole } from "@/services/api";
import { Loader2, RefreshCw, UserCheck, ShieldAlert } from "lucide-react";

export default function UsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const data = await getUsers();
      setUsers(data);
    } catch (error) {
      console.error("İstifadəçilər yüklənərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleRoleChange = async (userId: string, newRole: string) => {
    setUpdatingId(userId);
    try {
      await updateUserRole(userId, newRole);
      setUsers(users.map(user => 
        user._id === userId ? { ...user, role: newRole } : user
      ));
    } catch (error) {
      alert("Rol yenilənərkən xəta baş verdi.");
    } finally {
      setUpdatingId(null);
    }
  };

  const getRoleColor = (role: string) => {
    switch (role?.toLowerCase()) {
      case 'admin': return 'bg-purple-500/10 text-purple-500 border-purple-500/20';
      case 'seller': return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
      case 'courier': return 'bg-orange-500/10 text-orange-500 border-orange-500/20';
      default: return 'bg-slate-500/10 text-slate-500 border-slate-500/20';
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">İstifadəçilər</h2>
          <p className="text-muted-foreground">Sistemdəki bütün istifadəçi hesabları və rolları.</p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchUsers}>
          <RefreshCw className="mr-2 h-4 w-4" />
          Yenilə
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>İstifadəçi Siyahısı</CardTitle>
          <CardDescription>Buradan istifadəçilərin rollarını dəyişə və ya fəaliyyətlərinə baxa bilərsiniz.</CardDescription>
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
                  <TableHead>Ad & Soyad</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Rol</TableHead>
                  <TableHead>Qeydiyyat Tarixi</TableHead>
                  <TableHead className="text-right">Əməliyyat</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {users.map((user) => (
                  <TableRow key={user._id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                         <div className="h-8 w-8 rounded-full bg-muted flex items-center justify-center">
                            {user.role === 'admin' ? <ShieldAlert className="h-4 w-4 text-purple-500" /> : <UserCheck className="h-4 w-4 text-slate-500" />}
                         </div>
                         <span className="font-medium">{user.name}</span>
                      </div>
                    </TableCell>
                    <TableCell>{user.email}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {updatingId === user._id ? (
                          <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                        ) : (
                          <Select
                            defaultValue={user.role}
                            onValueChange={(value) => handleRoleChange(user._id, value)}
                            disabled={user.email === 'admin@smartmarket.com'} // Esas admin-i deyismek olmaz
                          >
                            <SelectTrigger className={`w-[120px] h-8 text-[11px] font-bold uppercase ${getRoleColor(user.role)}`}>
                              <SelectValue placeholder="Rol" />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="user">İstifadəçi</SelectItem>
                              <SelectItem value="admin">Admin</SelectItem>
                              <SelectItem value="courier">Kuryer</SelectItem>
                              <SelectItem value="seller">Satıcı</SelectItem>
                            </SelectContent>
                          </Select>
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="text-muted-foreground text-xs">
                       {new Date(user.createdAt).toLocaleDateString()}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button variant="ghost" size="sm">Detallar</Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
