// Mini Proyecto 2 - Equipo 3
// Análisis básico
// IS727272 - Cordero Hernández, Marco Ricardo

// 0. Creación de índices
// 0.1 Índice para títulos de películas
CREATE INDEX index_movie_title FOR (m:Movie) ON (m.title);

// 1. Análisis básico
// 1.1 Esquema del grafo
CALL db.schema.visualization;

// 1.2 Grafo entero
// Hecho en Gephi

// 1.3 ¿Cuáles nodos hay?
CALL db.labels() YIELD label RETURN COLLECT(label) AS NODOS;

// 1.4 ¿Cuántos nodos hay?
MATCH (n) RETURN LABELS(n) AS tipoNodo, COUNT(DISTINCT n) AS totalNodos
UNION
MATCH (n) RETURN 'Total' AS tipoNodo, COUNT(DISTINCT n) AS totalNodos;

// 1.5 ¿Cuáles atributos tienen los nodos?
CALL db.schema.nodeTypeProperties()
YIELD nodeType AS Nodo, propertyName AS Propiedad, propertyTypes AS Tipo;

// 1.6 ¿Cuáles son las relaciones?
MATCH ()-[r]->() RETURN DISTINCT TYPE(r) AS RELACIONES;

// 1.7 ¿Cuántas son las relaciones?
MATCH ()-[r]->() RETURN TYPE(r) as tipoRelacion, COUNT(r) as totalRelaciones
UNION
MATCH ()-[r]->() RETURN "Total" as tipoRelacion, COUNT(r) as totalRelaciones;

// 1.8 ¿Cuáles atributos tienen las relaciones?
CALL db.schema.relTypeProperties()
YIELD relType AS Relacion, propertyName AS Propiedad, propertyTypes AS Tipo;

// 1.9 Diámetro del grafo (dirigidoo)
// Hecho en Gephi (el grafo es demasiado grande para ser analizado con Neo4j)

// 1.10 Densidad del grafo
// Hecho en Gephi

// 1.11  ¿El grafo es homogéneo o heterogéneo?
MATCH (n)
WITH COLLECT(DISTINCT LABELS(n)) AS NodeTypes
RETURN NodeTypes, COUNT(NodeTypes) AS TOTAL;

MATCH ()-[r]->()
WITH COLLECT(DISTINCT TYPE(r)) AS RelantionshipTypes
RETURN RelantionshipTypes, COUNT(RelantionshipTypes) AS TOTAL;
// Sí es homogéneo, ya que todos los nodos y relaciones tienen las mismas propiedades
