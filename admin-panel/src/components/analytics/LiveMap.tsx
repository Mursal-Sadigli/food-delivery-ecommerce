import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { Search, Navigation, Loader2 } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

// Fix for default Leaflet icons in Vite/React
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});

L.Marker.prototype.options.icon = DefaultIcon;

// Custom icons for different types
const restaurantIcon = L.divIcon({
  html: `<div class="bg-red-500 p-2 rounded-full border-2 border-white shadow-lg"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m8 3 4 18 4-18H8Z"/><path d="M12 21a9 9 0 0 0 0-18"/><path d="M8 3c0 4 4 5 4 5s4-1 4-5"/></svg></div>`,
  className: '',
  iconSize: [28, 28],
  iconAnchor: [14, 14]
});

const deliveryIcon = L.divIcon({
  html: `<div class="bg-green-500 p-2 rounded-lg border-2 border-white shadow-lg"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="18.5" cy="17.5" r="3.5"/><circle cx="5.5" cy="17.5" r="3.5"/><circle cx="15" cy="5" r="1"/><path d="M12 17.5V14l-3-3 4-3 2 3h2"/></svg></div>`,
  className: '',
  iconSize: [28, 28],
  iconAnchor: [14, 14]
});

const orderIcon = L.divIcon({
  html: `<div class="bg-blue-500 p-2 rounded-full border-2 border-white shadow-lg"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg></div>`,
  className: '',
  iconSize: [28, 28],
  iconAnchor: [14, 14]
});

interface MapData {
  orders: any[];
  couriers: any[];
  restaurants: any[];
}

interface LiveMapProps {
  data: MapData;
}

const BAKU_CENTER: [number, number] = [40.4093, 49.8671];

// Helper component to handle map movement
function MapControl({ position, zoom }: { position: [number, number], zoom: number }) {
  const map = useMap();
  useEffect(() => {
    map.setView(position, zoom);
  }, [position, zoom, map]);
  return null;
}

export function LiveMap({ data }: LiveMapProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [mapView, setMapView] = useState<{ center: [number, number], zoom: number }>({
    center: BAKU_CENTER,
    zoom: 13
  });
  const [isSearching, setIsSearching] = useState(false);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!searchQuery) return;

    setIsSearching(true);
    try {
      const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(searchQuery)}&limit=1`);
      const results = await response.json();

      if (results && results.length > 0) {
        const { lat, lon } = results[0];
        setMapView({
          center: [parseFloat(lat), parseFloat(lon)],
          zoom: 14
        });
      } else {
        alert("Məkan tapılmadı: " + searchQuery);
      }
    } catch (error) {
      console.error("Axtarış xətası:", error);
      alert("Axtarış zamanı xəta baş verdi.");
    } finally {
      setIsSearching(false);
    }
  };

  return (
    <div className="space-y-4 mt-4">
      {/* Search Bar */}
      <form onSubmit={handleSearch} className="flex gap-2">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input 
            placeholder="Şəhər, rayon və ya məkan daxil edin (məs: Bakı, Nərimanov)..." 
            className="pl-9 h-10 shadow-sm border-primary/10 transition-all focus:border-primary/30"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            disabled={isSearching}
          />
        </div>
        <Button type="submit" disabled={isSearching} className="shadow-sm min-w-[100px]">
          {isSearching ? <Loader2 className="h-4 w-4 animate-spin" /> : "Görüntülə"}
        </Button>
      </form>

      <div className="h-[400px] w-full rounded-xl overflow-hidden border relative shadow-md bg-muted/5">
        <MapContainer 
          center={BAKU_CENTER} 
          zoom={13} 
          style={{ height: '100%', width: '100%' }}
          zoomControl={false}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          
          <MapControl position={mapView.center} zoom={mapView.zoom} />

          {data.restaurants.map((res, i) => (
            <Marker 
              key={`res-${i}`} 
              position={BAKU_CENTER} 
              icon={restaurantIcon}
            >
              <Popup>
                <div className="p-1">
                  <p className="font-bold text-red-600 text-xs">RESTORAN</p>
                  <p className="font-semibold">{res.name || "Restoran"}</p>
                </div>
              </Popup>
            </Marker>
          ))}

          {data.orders.map((order, i) => {
            const pos: [number, number] = [
              BAKU_CENTER[0] + (Math.random() - 0.5) * 0.06,
              BAKU_CENTER[1] + (Math.random() - 0.5) * 0.06
            ];
            return (
              <Marker 
                key={`order-${i}`} 
                position={pos}
                icon={orderIcon}
              >
                <Popup>
                  <div className="p-1">
                    <p className="font-bold text-blue-600 text-xs">SİFARİŞ</p>
                    <p className="font-semibold text-sm">#{order._id?.slice(-5) || "Sifariş"}</p>
                    <p className="text-[10px] text-muted-foreground uppercase">{order.status}</p>
                  </div>
                </Popup>
              </Marker>
            );
          })}

          {data.couriers.map((courier, i) => {
            const pos: [number, number] = [
              BAKU_CENTER[0] + (Math.random() - 0.5) * 0.06,
              BAKU_CENTER[1] + (Math.random() - 0.5) * 0.06
            ];
            return (
              <Marker 
                key={`cour-${i}`} 
                position={pos}
                icon={deliveryIcon}
              >
                <Popup>
                  <div className="p-1">
                    <p className="font-bold text-green-600 text-xs">KURYER</p>
                    <p className="font-semibold">{courier.name || "Kuryer"}</p>
                    <p className="text-[10px] text-muted-foreground uppercase">{courier.status || "AKTİV"}</p>
                  </div>
                </Popup>
              </Marker>
            );
          })}
        </MapContainer>

        {/* Legend */}
        <div className="absolute top-4 right-4 bg-background/90 backdrop-blur-md border p-3 rounded-lg shadow-lg flex flex-col gap-2 text-[10px] font-bold z-[1000]">
          <div className="flex items-center gap-2"><div className="h-2.5 w-2.5 rounded-full bg-red-500 shadow-sm" /> Restoran</div>
          <div className="flex items-center gap-2"><div className="h-2.5 w-2.5 rounded-full bg-blue-500 shadow-sm" /> Sifariş</div>
          <div className="flex items-center gap-2"><div className="h-2.5 w-2.5 rounded-full bg-green-500 shadow-sm" /> Kuryer</div>
        </div>

        {/* Home Button */}
        <Button 
          variant="secondary" 
          size="icon" 
          className="absolute bottom-6 right-6 h-10 w-10 rounded-full shadow-lg border z-[1000] hover:scale-110 transition-transform"
          onClick={() => setMapView({ center: BAKU_CENTER, zoom: 13 })}
          title="Mərkəzə qayıt"
        >
          <Navigation className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}
