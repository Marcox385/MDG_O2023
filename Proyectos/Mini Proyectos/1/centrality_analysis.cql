// Mini Proyecto 1 - Equipo 3
// Análisis de centralidad
// ICD745653 - López Arnaud, Luis Francisco
// IS727272 - Cordero Hernández, Marco Ricardo

// 1. ¿Qué personaje tiene el mayor número de interacciones con otras personas? [DEGREE]
// Creación de proyecto en GDS
CALL gds.graph.project(
    'got3_DEG',                        
    'Person',                          
    {                                   
        COMPANION: {
            orientation: 'UNDIRECTED',
            properties: 'Weight'
        }
    }
);

// 2. ¿Qué personaje tiene el mayor número de personas que se relacionan con el mismo? [IN_DEGREE]


// 3. ¿Qué personaje tiene el *menor* número de relaciones con otras personas? [OUT_DEGREE]


// 4. Top 5 de personajes con más interacciones [DEGREE]


// 5. La línea de relación entre el personaje con la mayor cantidad de relaciones hacía otras personas [OUT] y el personaje con menos relaciones [DEG]


// 6. ¿Qué personaje tiene más influencia/popularidad en esta temporada? [PR]


// 7. ¿Cuáles son los 5 personajes menos influyentes/populares? [PR]


// 8. ¿Qué personajes resultan más influyentes en el grafo al aplicar un damping factor de 0.6 y 30 iteraciones? [PR]
---

// 9. ¿Qué personajes se conectan entre varios grupos de personas? [BT]


// 10. ¿Qué personaje no tendría una eficacia óptima para hacer pactos entre otros grupos de personas? [BT]


// 11. ¿Qué personaje podría mandar mensajes de mejor manera? [CL]


// 12. ¿Cuál es la línea de relación entre el personaje con menor posibilidad de comunicar mensajes y el Señor de los Huesos? [CL]


// 13. Tomando en cuenta su habilidad de relacionar grupos [BT] y comunicar mensajes [CL] ¿Cuáles son los 5 personajes más relevantes?


// 14. Tomando en cuenta su influencia [PR] y sus relaciones [DEG] ¿Cuáles son los 5 personajes más relevantes?


// 15. Tomando en cuenta todas las estadísticas anteriores ¿Cuáles son los 5 personajes más relevantes?

