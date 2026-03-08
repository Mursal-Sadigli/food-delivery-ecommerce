import { useState, useEffect } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import { createRestaurant } from "@/services/api";
import { Loader2 } from "lucide-react";
import L from "leaflet";
import axios from "axios";

// Fix Leaflet marker icon issue
import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerShadow from "leaflet/dist/images/marker-shadow.png";

const DefaultIcon = L.icon({
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

L.Marker.prototype.options.icon = DefaultIcon;

interface AddRestaurantModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

// Component to change map view
function ChangeView({ center, zoom }: { center: L.LatLngExpression; zoom: number }) {
  const map = useMap();
  map.setView(center, zoom);
  return null;
}

export function AddRestaurantModal({ isOpen, onClose, onSuccess }: AddRestaurantModalProps) {
  const [loading, setLoading] = useState(false);
  const [searching, setSearching] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    address: "",
    city: "Bakı",
    district: "",
    lat: 40.4093,
    lng: 49.8671,
  });

  // Auto-geocode address when city, district or address changes
  useEffect(() => {
    if (!isOpen) return;
    
    const delayDebounceFn = setTimeout(async () => {
      const query = `${formData.address} ${formData.district} ${formData.city} Azerbaijan`.trim();
      if (query.length < 5) return;

      setSearching(true);
      try {
        const response = await axios.get(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1`
        );
        
        if (response.data && response.data.length > 0) {
          const { lat, lon } = response.data[0];
          setFormData(prev => ({ ...prev, lat: parseFloat(lat), lng: parseFloat(lon) }));
        }
      } catch (error) {
        console.error("Geocoding error:", error);
      } finally {
        setSearching(false);
      }
    }, 1000);

    return () => clearTimeout(delayDebounceFn);
  }, [formData.city, formData.district, formData.address, isOpen]);

  const LocationPicker = () => {
    useMapEvents({
      click(e) {
        setFormData({ ...formData, lat: e.latlng.lat, lng: e.latlng.lng });
      },
    });
    return (
      <Marker position={[formData.lat, formData.lng]} icon={DefaultIcon} />
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await createRestaurant(formData);
      onSuccess();
      onClose();
      // Reset form
      setFormData({
        name: "",
        email: "",
        password: "",
        address: "",
        city: "Bakı",
        district: "",
        lat: 40.4093,
        lng: 49.8671,
      });
    } catch (error: any) {
      console.error("Restoran yaradılarkən xəta:", error);
      alert(error.response?.data?.message || "Restoran yaradılarkən xəta baş verdi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[700px] h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Yeni Restoran Əlavə Et</DialogTitle>
          <DialogDescription>
            Restoranın məlumatlarını daxil edin və xəritədən ünvanını seçin.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 py-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Restoran Adı</Label>
              <Input
                id="name"
                required
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Məs: Pizza Mizza"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                placeholder="restoran@mail.com"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Parol (Seller girişi üçün)</Label>
              <Input
                id="password"
                type="password"
                required
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                placeholder="******"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="address">Ünvan</Label>
              <div className="relative">
                <Input
                    id="address"
                    required
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    placeholder="Məs: Nizami küç. 45"
                />
                {searching && <Loader2 className="absolute right-2 top-2.5 h-4 w-4 animate-spin text-muted-foreground" />}
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="city">Şəhər</Label>
              <Input
                id="city"
                required
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="district">Rayon / Qəsəbə</Label>
              <Input
                id="district"
                required
                value={formData.district}
                onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                placeholder="Məs: Yasamal"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label className="flex items-center gap-2">
              Mövqe Seçin 
              {searching && <span className="text-xs text-blue-500 animate-pulse">Axtarılır...</span>}
            </Label>
            <div className="h-[300px] w-full border rounded-md overflow-hidden z-0 bg-muted flex items-center justify-center">
              <MapContainer
                center={[formData.lat, formData.lng]}
                zoom={13}
                style={{ height: "100%", width: "100%" }}
              >
                <ChangeView center={[formData.lat, formData.lng]} zoom={15} />
                <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                <LocationPicker />
              </MapContainer>
            </div>
            <p className="text-xs text-muted-foreground flex justify-between">
                <span>Koordinatlar: {formData.lat.toFixed(6)}, {formData.lng.toFixed(6)}</span>
                <span className="text-blue-500 italic">Xəritədə klik edərək dəqiqləşdirə bilərsiniz</span>
            </p>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={onClose}>Ləğv Et</Button>
            <Button type="submit" disabled={loading}>
              {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Yadda Saxla
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
