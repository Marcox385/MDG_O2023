// Mini Proyecto 3 - Equipo 1
// Análisis básico
// IS727272 - Cordero Hernández, Marco Ricardo

// 1. Esquema del grafo
CALL db.schema.visualization;

// 2. Grafo entero
// Hecho en Gephi

// 3. ¿Cuáles nodos hay?
CALL db.labels() YIELD label RETURN COLLECT(label) AS NODOS;

// 4. ¿Cuántos nodos hay?
MATCH (n) RETURN LABELS(n) AS tipoNodo, COUNT(DISTINCT n) AS totalNodos
UNION
MATCH (n) RETURN 'Total' AS tipoNodo, COUNT(DISTINCT n) AS totalNodos;

// 5. ¿Cuáles atributos tienen los nodos?
CALL db.schema.nodeTypeProperties()
YIELD nodeType AS Nodo, propertyName AS Propiedad, propertyTypes AS Tipo;

// 6. ¿Cuáles son las relaciones?
MATCH ()-[r]->() RETURN DISTINCT TYPE(r) AS RELACIONES;

// 7. ¿Cuántas son las relaciones?
MATCH ()-[r]->() RETURN TYPE(r) as tipoRelacion, COUNT(r) as totalRelaciones
UNION
MATCH ()-[r]->() RETURN "Total" as tipoRelacion, COUNT(r) as totalRelaciones;

// 8. ¿Cuáles atributos tienen las relaciones?
CALL db.schema.relTypeProperties()
YIELD relType AS Relacion, propertyName AS Propiedad, propertyTypes AS Tipo;

// 9. Diámetro del grafo (dirigido)
// Hecho en Gephi (el grafo es demasiado grande para ser analizado con Neo4j)

// 10. Densidad del grafo
// Hecho en Gephi

// 11.  ¿El grafo es homogéneo o heterogéneo?
MATCH (n)
WITH COLLECT(DISTINCT LABELS(n)) AS NodeTypes
RETURN NodeTypes, COUNT(NodeTypes) AS TOTAL;

MATCH ()-[r]->()
WITH COLLECT(DISTINCT TYPE(r)) AS RelantionshipTypes
RETURN RelantionshipTypes, COUNT(RelantionshipTypes) AS TOTAL;
// Sí es homogéneo, ya que todos los nodos y relaciones tienen las mismas propiedades
