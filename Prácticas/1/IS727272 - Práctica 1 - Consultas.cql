// IS727272 - Cordero Hernández, Marco Ricardo
// Práctica 1 - Analizando la información contenida en una base de datos basada en grafos

// 4.1. Una imagen del esquema general del grafo.
CALL db.schema.visualization;

// 4.2. Una imagen del grafo completo.
MATCH (n)-[r]->(m) RETURN n, r, m;
// Alternativa: MATCH p = ()-->() RETURN p

// 4.3. ¿Cuáles son los tipos de nodos y sus atributos?
CALL db.labels() YIELD label RETURN label AS NODOS; // Cuáles nodos
MATCH (n) RETURN COUNT(n) as totalNodos; // Cuántos nodos
// Atributos y tipos
CALL db.schema.nodeTypeProperties()
YIELD nodeType AS Nodo, propertyName AS Propiedad, propertyTypes AS Tipo;

// 4.4. ¿Cuáles son los tipos de relaciones y sus atributos?
// Cuáles relaciones y tipos
CALL db.schema.relTypeProperties()
YIELD relType AS Relacion, propertyName AS Propiedad, propertyTypes AS Tipo;
MATCH ()-[r]->() RETURN COUNT(r) AS totalRelaciones; // Cuántas relaciones

// 4.5. Una consulta en cypher que me indique cuantos nodos hay de cada tipo.
MATCH (n) RETURN DISTINCT LABELS(n) AS Nodo, COUNT(n) AS Total;

// 4.6. ¿Cómo demuestras que es correcto el resultado de la consulta anterior?
MATCH (n) RETURN n;

// 4.7. Una o varias consultas en cypher que me indique cuantas relaciones hay de cada tipo.
MATCH ()-[r]->() RETURN TYPE(r) as Relacion, COUNT(r) AS Total;

// 4.8. ¿Cómo demuestras que es correcto el resultado de la consulta anterior?
MATCH p=()-[r]->() RETURN p;

// 4.9. ¿Cuál es el diámetro del grafo?
// Dirigido
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]->(end)) AS path
WITH length(path) AS distance
WHERE distance IS NOT NULL
RETURN distance DiametroDirigido
ORDER BY distance DESC 
LIMIT 1;
// No dirigido
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]-(end)) AS path
WITH length(path) AS distance
WHERE distance IS NOT NULL
RETURN distance AS DiametroNoDirigido
ORDER BY distance DESC 
LIMIT 1;

// 4.10. Explica con tus palabras para que te sirve conocer el diámetro del grafo.
// N/A

// 4.11. Un listado de los médicos, el número de pacientes que ha atendido, como lista el
// nombre de los pacientes y como lista el apellido de los pacientes. El resultado debe estar
// ordenado en forma descendente con base en el número de pacientes que ha atendido que
// ha atendido cada médico.
MATCH (m:medico)-[r:ATIENDE_A]->(p:paciente)
RETURN m.nombre + ' ' + m.apellido AS NombreMedico, COUNT(p) AS TotalAtendidos,
COLLECT(p.nombre) AS NombrePaciente, COLLECT(p.apellido) AS ApellidoPaciente;

// 4.12. Una consulta que reciba el nombre del médico y muestre una tabla con, el médico,
// el número de pacientes que ha atendido, la lista de pacientes y el número de
// enfermedades. Utiliza al médico que más pacientes ha atendido como valor del parámetro
// para probar tu consulta.
// Médico con mayor atendidos
MATCH (m:medico)-[:ATIENDE_A]->(p:paciente)
RETURN m.nombre AS Nombre, m.apellido AS Apellido, COUNT(p) AS Atendidos
ORDER BY Atendidos DESC
LIMIT 1;
// Consulta parametrizada
MATCH (m:medico)-[a:ATIENDE_A]->(p:paciente)-[pd:PADECE]->(e:enfermedad)
WITH m, p, pd, e, p.nombre + ' ' + p.apellido AS nombrePaciente
WHERE toUpper(m.nombre) = toUpper(:nombre)
AND m.apellido = toUpper(:apellido)
RETURN m.nombre + ' ' + m.apellido AS NombreMedico, COUNT(DISTINCT p) AS TotalAtendidos,
COLLECT(DISTINCT nombrePaciente) AS Pacientes, COUNT(DISTINCT e) AS TotalEnfermedades;

// 4.13. Realiza una frase de búsqueda en Bloom que reciba el nombre del médico como
// parámetro y te regrese, el grafo que incluya la relación con los pacientes, los pacientes, la
// relación con las enfermedades y las enfermedades. Prueba con un médico de tu elección
// como parámetro; Muestra el grafo resultante como par ordenado.
MATCH (m:medico)-[a:ATIENDE_A]->(p:paciente)-[pd:PADECE]->(e:enfermedad)
WHERE toUpper(m.nombre) = toUpper($NOMBRE)
AND m.apellido = toUpper($APELLIDO)
RETURN m, a, p, pd, e;
// Medico elegido: Bienvenido Garrido Rubio

// 4.14. Una consulta que muestre el IN_DEGREE de los nodos tipo medicina. El resultado
// debe estar ordenado de forma descendente por IN_DEGREE.
MATCH ()-[r:]->(:medicina)
RETURN COUNT(r) AS IN_DEGREE;

// 4.15. Realiza una frase de búsqueda en Bloom que reciba el nombre de una medicina
// como parámetro y regrese el grafo con el nombre de la medicina, la relación con la
// enfermedad, el nombre de las enfermedades, la relación con la farmacéutica y el nombre
// de la farmacéutica que la produce. Prueba con una medicina de tu elección como
// parámetro; Muestra el grafo resultante como una matriz.
MATCH r=(e:enfermedad)-[c:CURADA_POR]->(m:medicina)-[fb:FABRICADA_POR]->(f:farmaceutica)
WHERE m.nombre = $MEDICINA
RETURN r;
// Medicina elegida: Almax

// 4.16. Realiza una frase de búsqueda en Bloom que reciba el nombre de una medicina y
// muestre el grafo, sin importar la dirección, que conecta el nodo inicio, las relaciones y los
// nodos destino a 3 saltos. Prueba con almax como entrada y muestra el grafo resultante.
MATCH (m:medicina)
MATCH r=(m)-[*1..3]-(n)
WHERE m.nombre = $MEDICINA
RETURN r;

// 4.17. Realiza una consulta que muestre cuantos patrones (:Medicina) –[:INCOMPATIBLE]->(:Medicina) se
// presentan en la base de datos. ¿Cómo compruebas que tu resultado es correcto?
MATCH (:medicina)-[i:INCOMPATIBLE_CON]->(:medicina)
RETURN COUNT(i) AS Total;
// Comprobación
MATCH (m1:medicina)-[r]->(m2:medicina)
RETURN m1, r, m2;

// 4.18. Una consulta que muestre el top 3 de nodos con mayor DEGREE.
MATCH (n)-[r]-()
RETURN LABELS(n) AS Tipo, n.nombre AS nombre, n.apellido AS apellido, COUNT(r) AS DEGREE
ORDER BY DEGREE DESC
LIMIT 3;

// 4.19. Crea los nodos y relaciones necesarias para que tú seas un paciente, te atienda el
// médico con menor OUT_DEGREE a causa de la enfermedad con mayor IN_DEGREE
// Creación del nuevo nodo
CALL {
    MATCH (m:medico)-[r]->()
    RETURN m.nombre AS Nombre, m.apellido AS Apellido, COUNT(r) AS OUT_DEGREE
    ORDER BY OUT_DEGREE
    LIMIT 1
}
WITH Nombre AS NombreMedico, Apellido as ApellidoMedico
CALL {
    MATCH ()-[r]->(e:enfermedad)
    RETURN e.nombre AS Nombre, COUNT(r) AS IN_DEGREE
    ORDER BY IN_DEGREE DESC
    LIMIT 1
}
WITH Nombre AS NombreEnfermedad, NombreMedico, ApellidoMedico
MATCH (m:medico {nombre: NombreMedico, apellido: ApellidoMedico}), (e:enfermedad {nombre: NombreEnfermedad})
MERGE (p:paciente {nombre: 'Marco', apellido: 'CORDERO HERNÁNDEZ'})
MERGE (m)-[:ATIENDE_A {hora: toString(time())}]->(p)-[:PADECE]->(e);

// 4.20. Muestra la ruta más corta entre un paciente y la medicina de tu elección.
MATCH (p:paciente), (m:medicina)
WHERE p.apellido = 'CORDERO HERNÁNDEZ'
AND m.nombre = 'inmunoglobulina antitoxina'
RETURN shortestPath((p)-[*]->(m));
