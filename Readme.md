Explicación del Código:

- main: Es la función de inicio. Define una fórmula de prueba en CNF y luego llama a la función satisfiable? para verificar si existe una combinación que satisfaga todas las cláusulas.

- satisfiable?: Esta función es el núcleo del resolver. Extrae las variables, genera todas las combinaciones posibles de valores (asignaciones), y luego evalúa si alguna de estas combinaciones hace que toda la fórmula sea verdadera.

- extract_variables: Toma cada cláusula y extrae los nombres de las variables, sin repetir, para saber qué variables evaluar.

- generate_assignments: Crea todas las combinaciones posibles de true/false para las variables, transformándolas en un mapa que relaciona cada variable con un valor.

- all_boolean_combinations: Genera las combinaciones de true/false de una longitud específica, que luego se usan para todas las variables.

- evaluate_formula: Evalúa toda la fórmula para una asignación dada y devuelve true si todas las cláusulas son verdaderas.

- evaluate_clause: Verifica si una cláusula es verdadera, evaluando si al menos un literal en la cláusula es verdadero.

- evaluate_literal: Verifica el valor de un literal específico (variable o su negación) usando la asignación dada.