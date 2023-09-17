// IS727272 - Cordero Hernández, Marco Ricardo
// Complementario para análisis de la sesión anterior

// Top 5 OUT_DEGREE Person
MATCH (p:Person)-[r]->(m:Movie)
RETURN p.name, COUNT(r) as OUT_DEGREE
ORDER BY OUT_DEGREE
LIMIT 5

// Consulta para ver nodos alcanzables a n saltos dado un nodo de entrada
//      Buscar en las siguientes sesiones para ver el resultado
