import React, { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { getAuditLogs } from "@/services/api";
import { Loader2, ShieldAlert, User, Terminal, Globe } from "lucide-react";
import { format } from "date-fns";
import { az } from "date-fns/locale";

export default function AuditLogsPage() {
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchLogs = async () => {
    try {
      setLoading(true);
      const data = await getAuditLogs();
      setLogs(data);
    } catch (error) {
      console.error("Loqları gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
  }, []);

  const getActionColor = (action: string) => {
    if (action.includes("DELETE")) return "text-red-600 font-bold";
    if (action.includes("UPDATE") || action.includes("CHANGE")) return "text-blue-600 font-bold";
    if (action.includes("CREATE")) return "text-green-600 font-bold";
    return "text-muted-foreground";
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
        <h2 className="text-3xl font-bold tracking-tight">Audit Loqları</h2>
        <p className="text-muted-foreground">Admin panelində həyata keçirilən bütün kritik fəaliyyətlər.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <ShieldAlert className="h-5 w-5 text-primary" />
            Fəaliyyət Tarixçəsi
          </CardTitle>
          <CardDescription>Sistem təhlükəsizliyi üçün bütün admin əməliyyatları qeyd olunur.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow className="hover:bg-transparent">
                <TableHead>Admin</TableHead>
                <TableHead>Əməliyyat</TableHead>
                <TableHead>Hədəf</TableHead>
                <TableHead>Detallar</TableHead>
                <TableHead>IP / Cihaz</TableHead>
                <TableHead className="text-right">Tarix</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {logs.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-10 text-muted-foreground">
                    Heç bir loq tapılmadı.
                  </TableCell>
                </TableRow>
              ) : (
                logs.map((log) => (
                  <TableRow key={log._id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <User className="h-4 w-4 text-muted-foreground" />
                        <div className="flex flex-col">
                          <span className="text-xs font-bold">{log.admin?.name || "Sistem"}</span>
                          <span className="text-[10px] text-muted-foreground">{log.admin?.email}</span>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className={`text-[10px] uppercase tracking-tighter ${getActionColor(log.action)}`}>
                        {log.action}
                      </span>
                    </TableCell>
                    <TableCell className="text-xs">
                       <span className="bg-muted px-1.5 py-0.5 rounded text-[10px] font-mono">
                          {log.targetType}
                       </span>
                    </TableCell>
                    <TableCell className="text-xs italic max-w-[200px] truncate" title={log.details}>
                       {log.details}
                    </TableCell>
                    <TableCell>
                       <div className="flex flex-col gap-1">
                          <span className="text-[10px] flex items-center gap-1">
                             <Globe className="h-3 w-3" /> {log.ipAddress || "::1"}
                          </span>
                          <span className="text-[9px] text-muted-foreground max-w-[150px] truncate" title={log.userAgent}>
                             <Terminal className="h-2 w-2 inline mr-1" /> {log.userAgent?.split(" ").slice(0, 3).join(" ")}...
                          </span>
                       </div>
                    </TableCell>
                    <TableCell className="text-right text-[10px] text-muted-foreground">
                       {format(new Date(log.createdAt), "d MMM, HH:mm:ss", { locale: az })}
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
