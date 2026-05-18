const url = 'https://adminmitologiclothing.center.biz.id/api/v1/products';
fetch(url)
  .then(res => res.json())
  .then(parsed => {
    console.log("Success fetching products:", !!parsed.data);
    if (parsed.data && parsed.data.products) {
      console.log("Products length:", parsed.data.products.length);
      if (parsed.data.products.length > 0) {
        console.log("First product sample:", JSON.stringify(parsed.data.products[0], null, 2));
      }
    }
  })
  .catch(err => console.error("Error:", err));
