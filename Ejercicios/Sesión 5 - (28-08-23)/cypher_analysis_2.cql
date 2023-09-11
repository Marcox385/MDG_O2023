// Top 5 OUT_DEGREE Person
MATCH (p:Person)-[r]->(m:Movie)
RETURN p.name, COUNT(r) as OUT_DEGREE
ORDER BY OUT_DEGREE
LIMIT 5

// Consulta para ver nodos alcanzables a n saltos dado un nodo de entrada

