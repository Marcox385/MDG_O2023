// IS727272 - Cordero Hernández, Marco Ricardo
// Recomendaciones utilizando una BDG

// 0. Importar datos
// Inicializar tutorial de creación de datos de Northwind
:play northwind-graph
// El resto de los pasos hasta el punto (1) pueden ser omitido, solo es necesario seguir los pasos

// Primeros importes (extraído para propósitos demostrativos)
// Tabla | Nodo producto
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/products.csv" AS row
CREATE (n:Product)
SET n = row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), n.discontinued = (row.discontinued <> "0");

// Tabla | Nodo categoría
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/categories.csv" AS row
CREATE (n:Category)
SET n = row;

// Tabla | Nodo proveedor
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/suppliers.csv" AS row
CREATE (n:Supplier)
SET n = row;

// Primeros índices con sintaxis antigua (no hay nombre para los índices)
CREATE INDEX FOR (p:Product) ON (p.productID);
CREATE INDEX FOR (p:Product) ON (p.productName);
CREATE INDEX FOR (c:Category) ON (c.categoryID);
CREATE INDEX FOR (s:Supplier) ON (s.supplierID);

// Primeras relaciones (extraídas para propósitos demostrativos)
// Relación producto -[parte_de]-> categoría
MATCH (p:Product),(c:Category)
WHERE p.categoryID = c.categoryID
CREATE (p)-[:PART_OF]->(c);

// Relación proveedor -[provee]-> producto
MATCH (p:Product),(s:Supplier)
WHERE p.supplierID = s.supplierID
CREATE (s)-[:SUPPLIES]->(p);

// Entidad débil producto -(producto, orden)- orden (importes previos omitidos)
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity);

// 0.1 Consultas de prueba
// Categorías de una compañía
MATCH (s:Supplier)-->(:Product)-->(c:Category)
RETURN s.companyName as Company, collect(distinct c.categoryName) as Categories;

// Cantidad de productos por cliente
MATCH (cust:Customer)-[:PURCHASED]->(:Order)-[o:ORDERS]->(p:Product),
  (p)-[:PART_OF]->(c:Category {categoryName:"Produce"})
RETURN DISTINCT cust.contactName as CustomerName, SUM(o.quantity) AS TotalProductsPurchased;

// 1. Recomendaciones
// 1.1 Basada en coincidencia de compra
MATCH (p:Product)<-[:ORDERS]-(o:Order)-[:ORDERS]->(op:Product)
WHERE p.productName = 'Chai'
AND p <> op
RETURN p.productName as originalProduct,
       op.productName as recommendedProduct,
       COUNT(o.orderID) as numOrders
ORDER BY numOrders DESC
LIMIT 5;

// 1.2 Basada en coincidencia de compra y misma categoría
MATCH (cat1:Category)<-[:PART_OF]-(p:Product)<-[:ORDERS]-(o:Order)-[:ORDERS]->(op:Product)-[:PART_OF]->(cat2:Category)
WHERE p.productName = 'Tofu'
AND p <> op
AND cat1.categoryID = cat2.categoryID
RETURN p.productName as originalProduct,
       op.productName as recommendedProduct,
       cat1.categoryName as category,
       COUNT(o.orderID) as numOrders
ORDER BY numOrders DESC
LIMIT 5;

// Alternativa
MATCH (cat1:Category)<-[:PART_OF]-(p:Product {productName: 'Tofu'})<-[:ORDERS]-(o:Order)-[:ORDERS]->(op:Product)-[:PART_OF]->(cat2:Category)
WHERE op <> p AND (op)-[:PART_OF]->(cat1)
RETURN p.productName as originalProduct,
       op.productName as recommendedProduct,
       cat1.categoryName as category,
       COUNT(o.orderID) as numOrders
ORDER BY numOrders DESC
LIMIT 5;

// 1.3 Basada en coincidencia de compra y mismo proveedor
MATCH (prov1:Supplier)-[:SUPPLIES]->(p:Product {productName: 'Chai'})<-[:ORDERS]-(o:Order)-[:ORDERS]->(op:Product)<-[:SUPPLIES]->(prov2:Supplier)
WHERE op <> p AND (op)<-[:SUPPLIES]->(prov1)
RETURN p.productName as originalProduct,
       op.productName as recommendedProduct,
       prov1.companyName as supplier,
       COUNT(o.orderID) as numOrders
ORDER BY numOrders DESC
LIMIT 5;

// 1.4 Producto y proveedor (personalización agregada al anterior)
MATCH (prov1:Supplier {companyName: 'Exotic Liquids'})-[:SUPPLIES]->(p:Product {productName: 'Chai'})<-[:ORDERS]-(o:Order)-[:ORDERS]->(op:Product)<-[:SUPPLIES]->(prov2:Supplier)
WHERE op <> p AND (op)<-[:SUPPLIES]->(prov1)
RETURN p.productName as originalProduct,
       op.productName as recommendedProduct,
       prov1.companyName as supplier,
       COUNT(o.orderID) as numOrders
ORDER BY numOrders DESC
LIMIT 5;

// Producto más vendido
MATCH (p:Product)<-[o:ORDERS]-(:Order)
RETURN p.productName AS product, SUM(o.quantity) AS totalOrdered
ORDER BY totalOrdered DESC
LIMIT 5;
// Resultado: Camembert Pierrot <- Aplicar las recomendaciones vistas sobre este resultado
