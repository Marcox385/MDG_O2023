/// Víctor Ortega
/// Script para importar un archivo CSV a una BD de NEO4J

//Paso 0
//Baja los archivos CSV
FB_Nodos_Toy.csv        (12)
FB_Relaciones_Toy.csv   (10)

//Paso 1
// Crea la base de datos
FB - FB_toy : mineriag

//Paso 2
// Antes de iniciar la BD copiar los archivos CSV a la carpeta import
...

//Paso 3
// Pega los archivos CSV en la carpeta import
...

//Paso 4 
// Inicia la BD y abre el browser
...

//Paso 5
// Código cypher para cargar los nodos
LOAD CSV WITH HEADERS FROM "file:///FB_Nodos_Toy.csv" AS row
CREATE (n:Page)
SET n=row

//Paso 6
// Crear un índice para los nodos
CREATE INDEX index_Page FOR (n:Page) ON (n.id)

//Paso 6.1
//Crea un índice de búsqueda útil en bloom   page_type
CREATE INDEX index_Page_Type FOR (n:Page) ON (n.page_type)

//Paso 7
// Cargar las relaciones del archivo CSV
LOAD CSV FROM "file:///FB_Relaciones_Toy.csv" AS row
MATCH (n:Page), (m:Page)
WHERE n.id=row[0] and m.id=row[1]
MERGE (n)-[:LINK]->(m) 