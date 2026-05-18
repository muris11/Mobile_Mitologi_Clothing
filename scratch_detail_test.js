const url = 'https://adminmitologiclothing.center.biz.id/api/v1/products/jatayu-legend-oversized-tee';
fetch(url)
  .then(res => res.json())
  .then(parsed => {
    console.log("Success fetching product detail:", !!parsed.data);
    if (parsed.data) {
      console.log("Product detail keys:", Object.keys(parsed.data));
      console.log("Product detail sample (first 1000 chars):", JSON.stringify(parsed.data, null, 2).substring(0, 1000));
    }
  })
  .catch(err => console.error("Error:", err));
