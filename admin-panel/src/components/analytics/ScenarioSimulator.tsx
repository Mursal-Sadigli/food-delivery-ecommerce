import { useState, useEffect } from 'react';
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

export function ScenarioSimulator() {
  const [deliveryFee, setDeliveryFee] = useState(2);
  const [promoDiscount, setPromoDiscount] = useState(10);
  const [simData, setSimData] = useState<any[]>([]);

  useEffect(() => {
    // Generate simulated data based on parameters
    const baseOrders = 100;
    const feeImpact = (2 - deliveryFee) * 10; 
    const discountImpact = (promoDiscount - 10) * 2;
    const predictedOrders = Math.max(10, baseOrders + feeImpact + discountImpact);
    
    const newData = Array.from({ length: 7 }, (_, i) => ({
      name: `Day ${i + 1}`,
      orders: Math.round(predictedOrders * (0.8 + Math.random() * 0.4)),
      revenue: Math.round(predictedOrders * 25 * (1 - promoDiscount/100) + predictedOrders * deliveryFee)
    }));
    setSimData(newData);
  }, [deliveryFee, promoDiscount]);

  return (
    <div className="space-y-6 mt-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-3">
          <Label className="text-xs">Sifariş Haqqı (₼)</Label>
          <Input 
            type="number" 
            value={deliveryFee} 
            onChange={(e) => setDeliveryFee(Number(e.target.value))}
            className="h-8"
          />
        </div>
        <div className="space-y-3">
          <Label className="text-xs">Global Endirim (%)</Label>
          <Input 
            type="number" 
            value={promoDiscount} 
            onChange={(e) => setPromoDiscount(Number(e.target.value))}
            className="h-8"
          />
        </div>
      </div>

      <div className="p-4 rounded-xl bg-primary/5 border border-primary/10">
        <p className="text-[10px] text-muted-foreground uppercase font-bold tracking-widest text-center mb-4">
          Həftəlik Təsir Proqnozu
        </p>
        <div className="h-[150px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={simData}>
              <XAxis dataKey="name" hide />
              <YAxis hide />
              <Tooltip 
                contentStyle={{ borderRadius: '12px', fontSize: '10px' }}
                itemStyle={{ padding: '0' }}
              />
              <Line type="monotone" dataKey="revenue" stroke="hsl(var(--primary))" strokeWidth={2} dot={false} />
              <Line type="monotone" dataKey="orders" stroke="#82ca9d" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
        <div className="flex justify-between mt-2 text-[10px] font-bold">
          <span className="text-primary">Gəlir Təsiri</span>
          <span className="text-[#82ca9d]">Sifariş Həcmi</span>
        </div>
      </div>
    </div>
  );
}
