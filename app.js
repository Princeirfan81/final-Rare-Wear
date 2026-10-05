const DEFAULT_PRODUCTS=[
{name:'Classic T-Shirt',category:'T-Shirts',price:399,image:'assets/tshirt.png',description:'Premium custom printed T-shirt.'},
{name:'White Mug',category:'Mugs',price:199,image:'assets/white-mug.png',description:'Personalized photo/name mug.'},
{name:'Black Mug',category:'Mugs',price:249,image:'assets/black-mug.png',description:'Premium black custom mug.'},
{name:'Magic Mug',category:'Mugs',price:299,image:'assets/magic-mug.png',description:'Heat-reveal magic mug.'},
{name:'Blue Mug',category:'Mugs',price:229,image:'assets/blue-mug.png',description:'Blue handle personalized mug.'},
{name:'Black Handle Mug',category:'Mugs',price:229,image:'assets/black-handle-mug.png',description:'White mug with black handle.'},
{name:'Heart Handle Mug',category:'Mugs',price:249,image:'assets/heart-handle-mug.png',description:'Cute heart-handle gift mug.'},
{name:'White Heart Mug',category:'Mugs',price:249,image:'assets/white-heart-mug.png',description:'White heart-handle mug.'},
{name:'Water Bottle',category:'Bottles',price:349,image:'assets/water-bottle.png',description:'Custom printed water bottle.'},
{name:'Marble Tile',category:'Tiles',price:299,image:'assets/marble-tile.png',description:'Personalized marble-look tile.'},
{name:'Photo Tile',category:'Tiles',price:399,image:'assets/photo-tile.png',description:'Custom photo tile gift.'},
{name:'Caps',category:'Caps',price:299,image:'assets/caps.png',description:'Custom printed cap.'},
{name:'Plates',category:'Plates',price:399,image:'assets/plates.png',description:'Personalized decorative plate.'}
];
const cfg={phone:'6362619930',instagram:'_rare__wear_official'};
let products=JSON.parse(localStorage.getItem('rw_products')||'null')||DEFAULT_PRODUCTS; let cart=JSON.parse(localStorage.getItem('rw_cart')||'[]'); let category='All';
const $=s=>document.querySelector(s); const money=n=>'₹'+Number(n||0).toLocaleString('en-IN');
function save(){localStorage.setItem('rw_products',JSON.stringify(products));localStorage.setItem('rw_cart',JSON.stringify(cart));}
function renderFilters(){const cats=['All',...new Set(products.map(p=>p.category))];$('#filters').innerHTML=cats.map(c=>`<button class="filter ${c===category?'active':''}" data-cat="${c}">${c}</button>`).join('');document.querySelectorAll('.filter').forEach(b=>b.onclick=()=>{category=b.dataset.cat;renderFilters();renderProducts()})}
function renderProducts(){const list=category==='All'?products:products.filter(p=>p.category===category);$('#products').innerHTML=list.map((p,i)=>`<article class="card"><div class="card-img"><img src="${p.image}" alt="${p.name}" loading="lazy"></div><div class="card-body"><span class="cat">${p.category}</span><h3>${p.name}</h3><div class="price">${money(p.price)}</div><button class="btn gold" onclick="addToCart(${products.indexOf(p)})">Add to cart</button></div></article>`).join('')||'<div class="empty">No products yet.</div>';$('#customProduct').innerHTML='<option>Custom / Other</option>'+products.map(p=>`<option>${p.name}</option>`).join('')}
window.addToCart=i=>{const p=products[i];const found=cart.find(x=>x.name===p.name);found?found.qty++:cart.push({...p,qty:1});save();renderCart();openCart()};
function renderCart(){let count=cart.reduce((s,x)=>s+x.qty,0),total=cart.reduce((s,x)=>s+x.qty*x.price,0);$('#cartCount').textContent=count;$('#cartTotal').textContent=money(total);$('#cartItems').innerHTML=cart.length?cart.map((x,i)=>`<div class="cart-item"><img src="${x.image}"><div><b>${x.name}</b><small>${money(x.price)} each</small><div class="qty"><button onclick="changeQty(${i},-1)">−</button><span>${x.qty}</span><button onclick="changeQty(${i},1)">+</button></div></div><b>${money(x.qty*x.price)}</b></div>`).join(''):'<div class="empty">Your cart is empty.</div>'}
window.changeQty=(i,d)=>{cart[i].qty+=d;if(cart[i].qty<=0)cart.splice(i,1);save();renderCart()};
function openCart(){$('#cart').classList.add('open');$('#overlay').classList.add('show')}function closeCart(){$('#cart').classList.remove('open');$('#overlay').classList.remove('show')}
$('#cartOpen').onclick=openCart;$('#cartClose').onclick=closeCart;$('#overlay').onclick=closeCart;
$('#checkout').onclick=()=>{if(!cart.length)return alert('Your cart is empty.');const lines=cart.map(x=>`${x.name} x${x.qty} = ${money(x.qty*x.price)}`).join('%0A');const total=cart.reduce((s,x)=>s+x.qty*x.price,0);location.href=`https://wa.me/${cfg.phone}?text=Hello%20Rare%20Wear,%20I%20want%20to%20order:%0A${lines}%0A%0ATotal:%20${money(total)}%0A%0AName:%0AAddress:`};
$('#customForm').onsubmit=e=>{e.preventDefault();const f=new FormData(e.target);const msg=`Hello Rare Wear! Custom enquiry.%0AName: ${f.get('name')}%0AWhatsApp: ${f.get('phone')}%0AProduct: ${f.get('product')}%0AIdea: ${f.get('message')}`;location.href=`https://wa.me/${cfg.phone}?text=${encodeURIComponent(msg)}`};
$('#waLink').href=`https://wa.me/${cfg.phone}`;$('#year').textContent=new Date().getFullYear();renderFilters();renderProducts();renderCart();
