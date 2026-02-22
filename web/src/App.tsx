import React, { useState, useEffect, useMemo } from 'react';
import { ShoppingCart, Search, X, Package, Trash2, ChevronRight, Store, ShieldAlert } from 'lucide-react';

interface Item {
  name: string;
  label: string;
  price: number;
  stock: number;
  index: number;
  image?: string;
  requiresLicense?: string;
}

interface CartItem extends Item {
  quantity: number;
  shopIndex: number;
}

interface ShopData {
  name: string;
  items: Item[];
  shopIndex: number;
}

const App: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [shopData, setShopData] = useState<ShopData | null>(null);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [brandInfo, setBrandInfo] = useState({ brandName: 'DjonStNix Shops', currencyPrefix: '$' });

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === 'openShop') {
        setShopData(event.data.shopData);
        setBrandInfo(event.data.config);
        setVisible(true);
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  // Close on Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && visible) {
        closeModal();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [visible]);

  const closeModal = () => {
    setVisible(false);
    setCart([]);
    setSearchQuery('');
    fetch(`https://DjonStNix-Shops/close`, { method: 'POST', body: JSON.stringify({}) });
  };

  const filteredItems = useMemo(() => {
    if (!shopData) return [];
    return shopData.items.filter((item: Item) => 
      item.label.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.name.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [shopData, searchQuery]);

  const addToCart = (item: Item) => {
    if (!shopData) return;
    setCart((prev: CartItem[]) => {
      const existing = prev.find((i: CartItem) => i.name === item.name);
      if (existing) {
        if (existing.quantity >= item.stock) return prev;
        return prev.map((i: CartItem) => i.name === item.name ? { ...i, quantity: i.quantity + 1 } : i);
      }
      return [...prev, { ...item, quantity: 1, shopIndex: shopData.shopIndex }];
    });
  };

  const removeFromCart = (itemName: string) => {
    setCart((prev: CartItem[]) => prev.filter((i: CartItem) => i.name !== itemName));
  };

  const updateQuantity = (itemName: string, delta: number) => {
    setCart((prev: CartItem[]) => prev.map((i: CartItem) => {
      if (i.name === itemName) {
        const newQty = Math.max(1, Math.min(i.stock, i.quantity + delta));
        return { ...i, quantity: newQty };
      }
      return i;
    }));
  };

  const cartTotal = useMemo(() => cart.reduce((sum: number, item: CartItem) => sum + (item.price * item.quantity), 0), [cart]);

  const handleCheckout = () => {
    if (cart.length === 0) return;
    fetch(`https://DjonStNix-Shops/checkout`, { 
      method: 'POST', 
      body: JSON.stringify({ cart }) 
    });
    closeModal();
  };

  if (!visible || !shopData) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center p-8 font-sans animate-in fade-in duration-300 pointer-events-none">
      <div className="w-full max-w-6xl h-[85vh] glass rounded-[2.5rem] overflow-hidden flex shadow-2xl relative border border-white/10 pointer-events-auto">
        
        {/* Main Content Area */}
        <div className="flex-1 flex flex-col p-10 h-full overflow-hidden">
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-premium-gold rounded-2xl shadow-lg shadow-premium-gold/20">
                <Store className="text-black w-6 h-6" />
              </div>
              <div>
                <h1 className="text-2xl font-bold tracking-tight text-white">{shopData.name}</h1>
                <p className="text-premium-muted text-sm font-medium tracking-wide uppercase">{brandInfo.brandName} • {filteredItems.length} Products</p>
              </div>
            </div>
            
            <div className="relative group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-premium-muted w-5 h-5 group-focus-within:text-premium-gold transition-colors" />
              <input 
                type="text" 
                placeholder="Search products..." 
                className="bg-premium-bg/50 border border-white/5 rounded-2xl pl-12 pr-6 py-3.5 w-80 text-sm focus:outline-none focus:ring-1 focus:ring-premium-gold/50 transition-all placeholder:text-premium-muted font-medium"
                value={searchQuery}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearchQuery(e.target.value)}
              />
            </div>
          </div>

          {/* Weapons License Warning Banner */}
          {filteredItems.some((item: Item) => item.requiresLicense) && (
            <div className="flex items-center gap-3 mb-4 px-4 py-3 rounded-xl bg-amber-500/10 border border-amber-500/20">
              <ShieldAlert className="w-5 h-5 text-amber-400 shrink-0" />
              <p className="text-amber-300/90 text-xs font-semibold tracking-wide">
                ⚠ WEAPONS LICENSE REQUIRED — Some items in this store require a valid weapons license to purchase.
              </p>
            </div>
          )}

          {/* Grid */}
          <div className="flex-1 overflow-y-auto pr-4 -mr-4 custom-scrollbar grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5 auto-rows-max">
            {filteredItems.map((item: Item) => (
              <div key={item.name} className="glass-card rounded-[2rem] p-6 flex flex-col group relative overflow-hidden">
                <div className="aspect-square rounded-[1.5rem] bg-white/5 mb-5 relative flex items-center justify-center overflow-hidden border border-white/5 group">
                   {item.image ? (
                    <img 
                      src={item.image} 
                      className="w-full h-full object-contain p-4 group-hover:scale-110 transition-transform duration-500" 
                      onError={(e: React.SyntheticEvent<HTMLImageElement, Event>) => {
                        (e.target as HTMLImageElement).src = ''; // Clear source to show fallback
                        (e.target as HTMLImageElement).style.display = 'none';
                      }}
                    />
                   ) : (
                    <Package className="w-12 h-12 text-white/10 group-hover:scale-110 transition-transform duration-500" />
                   )}
                   
                   {!item.image && <Package className="w-12 h-12 text-white/10 absolute z-0" />}

                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end p-4">
                    <button 
                      onClick={() => addToCart(item)}
                      disabled={item.stock <= 0}
                      className="w-full bg-white text-black py-2.5 rounded-xl font-bold text-sm shadow-xl active:scale-95 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {item.stock > 0 ? 'Add to Cart' : 'Out of Stock'}
                    </button>
                  </div>
                </div>
                
                <div className="flex flex-col flex-1">
                  <div className="flex justify-between items-start mb-1">
                    <h3 className="font-bold text-lg text-white/90 truncate mr-2">{item.label}</h3>
                    <span className="text-premium-gold font-bold">{brandInfo.currencyPrefix}{item.price.toLocaleString()}</span>
                  </div>
                  <p className="text-premium-muted text-xs font-semibold mb-4">Stock: <span className={item.stock > 0 ? 'text-green-400/80' : 'text-red-400/80'}>{item.stock} Units</span></p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Sidebar Cart */}
        <div className="w-[400px] border-l border-white/5 bg-white/5 flex flex-col p-10">
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-3">
              <ShoppingCart className="w-6 h-6 text-premium-gold" />
              <h2 className="text-2xl font-bold">Your Cart</h2>
            </div>
            <button onClick={closeModal} className="p-2.5 hover:bg-white/5 rounded-xl transition-colors">
              <X className="w-5 h-5 text-premium-muted" />
            </button>
          </div>

          <div className="flex-1 overflow-y-auto pr-2 custom-scrollbar space-y-4">
            {cart.length === 0 ? (
              <div className="h-full flex flex-col items-center justify-center text-center p-8">
                <div className="w-16 h-16 bg-white/5 rounded-full flex items-center justify-center mb-4">
                  <ShoppingCart className="w-8 h-8 text-white/20" />
                </div>
                <h3 className="text-lg font-bold text-white/40">Cart is Empty</h3>
                <p className="text-sm text-white/20">Add some items to get started</p>
              </div>
            ) : (
              cart.map((item) => (
                <div key={item.name} className="flex gap-4 p-4 rounded-2xl bg-white/5 border border-white/5 hover:border-premium-gold/20 transition-all items-center">
                  <div className="w-16 h-16 rounded-xl bg-white/5 flex items-center justify-center border border-white/5 shrink-0 overflow-hidden">
                    {item.image ? (
                        <img src={item.image} className="w-10 h-10 object-contain" />
                    ) : (
                        <Package className="w-6 h-6 text-white/10" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start">
                      <h4 className="font-bold text-sm truncate pr-2">{item.label}</h4>
                      <button onClick={() => removeFromCart(item.name)} className="text-white/20 hover:text-red-400 transition-colors p-1">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                    <div className="flex items-center justify-between mt-2">
                       <div className="flex items-center gap-3 bg-white/10 px-3 py-1.5 rounded-lg border border-white/5">
                        <button onClick={() => updateQuantity(item.name, -1)} className="text-premium-gold/80 hover:text-premium-accent transition-colors">
                          <span className="font-bold text-lg">-</span>
                        </button>
                        <span className="text-sm font-bold w-4 text-center">{item.quantity}</span>
                        <button onClick={() => updateQuantity(item.name, 1)} className="text-premium-gold/80 hover:text-premium-accent transition-colors">
                          <span className="font-bold text-lg">+</span>
                        </button>
                      </div>
                      <span className="text-premium-gold font-bold text-sm">{brandInfo.currencyPrefix}{(item.price * item.quantity).toLocaleString()}</span>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Footer - Checkout */}
          <div className="mt-8 pt-8 border-t border-white/5 space-y-6">
            <div className="space-y-3">
              <div className="flex justify-between text-sm font-medium">
                <span className="text-premium-muted">Subtotal</span>
                <span>{brandInfo.currencyPrefix}{cartTotal.toLocaleString()}</span>
              </div>
              <div className="flex justify-between items-end border-t border-white/5 pt-4">
                <span className="text-premium-muted font-bold">Total Due</span>
                <span className="text-3xl font-black text-premium-gold">{brandInfo.currencyPrefix}{cartTotal.toLocaleString()}</span>
              </div>
            </div>

            <button 
              onClick={handleCheckout}
              disabled={cart.length === 0}
              className="w-full bg-premium-gold text-black py-4 rounded-[1.25rem] font-black text-lg shadow-2xl shadow-premium-gold/20 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-50 disabled:grayscale disabled:cursor-not-allowed flex items-center justify-center gap-3"
            >
              Confirm Purchase
              <ChevronRight className="w-5 h-5" />
            </button>
            
            {/* Animated DjonStNix Logo */}
            <div className="flex justify-center mt-2">
              <svg
                width="200"
                height="65"
                viewBox="0 0 240 80"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                className="filter drop-shadow-[0_0_6px_rgba(197,160,89,0.4)] opacity-80"
              >
                <path
                  d="M10 10H230V70H10V10Z"
                  stroke="#c5a059"
                  strokeWidth="1"
                  strokeDasharray="700"
                  strokeDashoffset="700"
                  className="opacity-20"
                  style={{ animation: 'draw 2s ease-in-out forwards' }}
                />
                <path d="M5 15V5H15" stroke="#c5a059" strokeWidth="2" className="animate-pulse" />
                <path d="M225 5H235V15" stroke="#c5a059" strokeWidth="2" className="animate-pulse" />
                <path d="M235 65V75H225" stroke="#c5a059" strokeWidth="2" className="animate-pulse" />
                <path d="M15 75H5V65" stroke="#c5a059" strokeWidth="2" className="animate-pulse" />
                <text x="20" y="20" fill="#c5a059" fontSize="6" fontFamily="monospace" className="opacity-10 animate-pulse">10110</text>
                <text x="200" y="70" fill="#c5a059" fontSize="6" fontFamily="monospace" className="opacity-10 animate-pulse">01001</text>
                <text
                  x="50%"
                  y="38"
                  dominantBaseline="middle"
                  textAnchor="middle"
                  fill="white"
                  fontSize="26"
                  fontWeight="900"
                  letterSpacing="2"
                  fontFamily="'Inter', sans-serif"
                >
                  Djon<tspan fill="#c5a059" className="animate-pulse">St</tspan>Nix
                </text>
                <text x="50%" y="58" textAnchor="middle" fill="#c5a059" fontSize="7" fontFamily="monospace" className="opacity-50">
                  PREMIUM SHOPS
                </text>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;
