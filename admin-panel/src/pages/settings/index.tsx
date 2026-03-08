import { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { getSettings, updateSettings } from "@/services/api";
import { Loader2, Save, Globe, CreditCard, ShieldCheck } from "lucide-react";

export default function SettingsPage() {
  const [settings, setSettings] = useState<any>({
    deliveryFee: 0,
    platformCommission: 0,
    tax: 0,
    minOrderAmount: 0,
    contactEmail: "",
    contactPhone: "",
    supportedCities: []
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [newCity, setNewCity] = useState("");

  const fetchSettings = async () => {
    try {
      setLoading(true);
      const data = await getSettings();
      setSettings(data);
    } catch (error) {
      console.error("Tənzimləmələri gətirərkən xəta:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    try {
      await updateSettings(settings);
      alert("Tənzimləmələr uğurla yadda saxlanıldı!");
    } catch (error) {
      alert("Yadda saxlayarkən xəta baş verdi.");
    } finally {
      setSaving(false);
    }
  };

  const handleAddCity = () => {
    if (newCity && !settings.supportedCities.includes(newCity)) {
      setSettings({
        ...settings,
        supportedCities: [...settings.supportedCities, newCity]
      });
      setNewCity("");
    }
  };

  const handleRemoveCity = (city: string) => {
    setSettings({
      ...settings,
      supportedCities: settings.supportedCities.filter((c: string) => c !== city)
    });
  };

  if (loading) {
    return (
      <div className="flex h-[400px] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6 max-w-4xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Tənzimləmələr</h2>
          <p className="text-muted-foreground">Platformanın qlobal parametrlərini idarə edin.</p>
        </div>
        <Button onClick={handleSave} disabled={saving}>
          {saving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
          Yadda Saxla
        </Button>
      </div>

      <Tabs defaultValue="general" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="general" className="flex items-center gap-2">
            <Globe className="h-4 w-4" /> Ümumi
          </TabsTrigger>
          <TabsTrigger value="finance" className="flex items-center gap-2">
            <CreditCard className="h-4 w-4" /> Maliyyə
          </TabsTrigger>
          <TabsTrigger value="security" className="flex items-center gap-2">
            <ShieldCheck className="h-4 w-4" /> Sistem
          </TabsTrigger>
        </TabsList>

        <TabsContent value="general">
          <Card>
            <CardHeader>
              <CardTitle>Ümumi Parametrlər</CardTitle>
              <CardDescription>Əlaqə məlumatları və xidmət zonaları.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="email">Dəstək E-poçtu</Label>
                  <Input 
                    id="email" 
                    value={settings.contactEmail} 
                    onChange={(e) => setSettings({...settings, contactEmail: e.target.value})}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Dəstək Telefonu</Label>
                  <Input 
                    id="phone" 
                    value={settings.contactPhone} 
                    onChange={(e) => setSettings({...settings, contactPhone: e.target.value})}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label>Xidmət Göstərilən Şəhərlər</Label>
                <div className="flex gap-2">
                  <Input 
                    value={newCity} 
                    onChange={(e) => setNewCity(e.target.value)}
                    placeholder="Şəhər adı..."
                  />
                  <Button variant="outline" onClick={handleAddCity}>Əlavə Et</Button>
                </div>
                <div className="flex flex-wrap gap-2 mt-2">
                  {settings.supportedCities.map((city: string) => (
                    <div key={city} className="flex items-center gap-2 bg-muted px-3 py-1 rounded-full text-sm">
                      {city}
                      <button onClick={() => handleRemoveCity(city)} className="text-muted-foreground hover:text-destructive">×</button>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="finance">
          <Card>
            <CardHeader>
              <CardTitle>Maliyyə Parametrləri</CardTitle>
              <CardDescription>Qiymət və faiz dərəcələri.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="deliveryFee">Çatdırılma Haqqı ($)</Label>
                  <Input 
                    id="deliveryFee" 
                    type="number" 
                    value={settings.deliveryFee} 
                    onChange={(e) => setSettings({...settings, deliveryFee: parseFloat(e.target.value)})}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="commission">Platforma Komissiyası (%)</Label>
                  <Input 
                    id="commission" 
                    type="number" 
                    value={settings.platformCommission} 
                    onChange={(e) => setSettings({...settings, platformCommission: parseFloat(e.target.value)})}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="tax">Vergi (%)</Label>
                  <Input 
                    id="tax" 
                    type="number" 
                    value={settings.tax} 
                    onChange={(e) => setSettings({...settings, tax: parseFloat(e.target.value)})}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="minAmount">Minimum Sifariş Məbləği ($)</Label>
                  <Input 
                    id="minAmount" 
                    type="number" 
                    value={settings.minOrderAmount} 
                    onChange={(e) => setSettings({...settings, minOrderAmount: parseFloat(e.target.value)})}
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="security">
          <Card>
            <CardHeader>
              <CardTitle>Sistem və Təhlükəsizlik</CardTitle>
              <CardDescription>Platformanın statusu və texniki ayarlar.</CardDescription>
            </CardHeader>
            <CardContent>
               <div className="flex items-center justify-between p-4 border rounded-lg bg-yellow-500/5 border-yellow-500/20">
                  <div className="space-y-0.5">
                    <Label className="text-yellow-600 font-bold">Texniki Xidmət Rejimi (Maintenance)</Label>
                    <p className="text-xs text-muted-foreground">Bu rejim aktiv olduqda sadecə adminlər sistemə daxil ola bilər.</p>
                  </div>
                  <Button 
                    variant={settings.isMaintenanceMode ? "destructive" : "outline"}
                    onClick={() => setSettings({...settings, isMaintenanceMode: !settings.isMaintenanceMode})}
                  >
                    {settings.isMaintenanceMode ? "Deaktiv Et" : "Aktiv Et"}
                  </Button>
               </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
