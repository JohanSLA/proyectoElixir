# Creamos un módulo para el resolver SAT secuencial
defmodule SATSolverSequential do

    # La función principal, que es el punto de inicio del programa
    def main do
      # Definimos una fórmula de prueba en CNF (Conjunctive Normal Form)
      # Cada lista interna representa una cláusula
      formula = [
        [{:x1, true}, {:x2, false}, {:x3, true}],
        [{:x1, true}, {:x2, false}],
        [{:x2, true}, {:x3, true}]
      ]

      #Formula insatisfactible como prueba
      #formula = [
       # [{:x1, true}],
       # [{:x1, false}]
     # ]


      # Usamos la función 'satisfiable?' para verificar si la fórmula tiene solución
      result = satisfiable?(formula)

      # Mostramos el resultado
      case result do
        {:satisfiable, solution} ->
          IO.puts("La fórmula es satisfacible con la solución: #{inspect(solution)}")

        {:unsatisfiable, _} ->
          IO.puts("La fórmula es insatisfacible")
      end
    end

    # Esta función verifica si hay una asignación que haga verdadera la fórmula
    def satisfiable?(formula) do
      formula
      |> extract_variables()          # Extrae todas las variables de la fórmula
      |> generate_assignments()       # Genera todas las combinaciones de valores posibles (true, false) para cada variable
      |> Enum.find(&evaluate_formula(formula, &1)) # Busca una combinación que haga verdadera la fórmula
      |> case do
        nil -> {:unsatisfiable, []}         # Si no encuentra una combinación que funcione, devuelve insatisfacible
        solution -> {:satisfiable, solution} # Si encuentra una combinación, devuelve satisfacible con la solución
      end
    end

    # Extrae todas las variables de la fórmula para saber cuáles necesitamos evaluar
    defp extract_variables(formula) do
      formula
      |> Enum.flat_map(& &1)                # Aplana todas las cláusulas en una sola lista
      |> Enum.map(&variable_name/1)         # Convierte cada literal en el nombre de su variable
      |> Enum.uniq()                        # Remueve duplicados
    end

    # Genera todas las combinaciones posibles de true y false para las variables
    defp generate_assignments(variables) do
      combinations =
        for values <- all_boolean_combinations(length(variables)), do: Enum.zip(variables, values)
      Enum.map(combinations, &Map.new/1)    # Convierte cada combinación en un mapa de asignación
    end

    # Genera todas las combinaciones posibles de true/false de longitud n
    defp all_boolean_combinations(0), do: [[]]
    defp all_boolean_combinations(n) do
      for tail <- all_boolean_combinations(n - 1), head <- [true, false], do: [head | tail]
    end

    # Evalúa si toda la fórmula es verdadera para una asignación dada
    defp evaluate_formula(formula, assignments) do
      formula
      |> Enum.all?(&evaluate_clause(&1, assignments)) # Verifica que todas las cláusulas sean verdaderas
    end

    # Evalúa si una cláusula específica es verdadera para una asignación
    defp evaluate_clause(clause, assignments) do
      clause
      |> Enum.any?(&evaluate_literal(&1, assignments)) # Verifica si al menos un literal es verdadero
    end

    # Evalúa si un literal específico es verdadero
    defp evaluate_literal({variable, true}, assignments) do
      Map.get(assignments, variable)          # Devuelve el valor si el literal no está negado
    end
    defp evaluate_literal({variable, false}, assignments) do
      not Map.get(assignments, variable)      # Devuelve el valor negado si el literal está negado
    end

    # Obtiene el nombre de una variable de un literal
    defp variable_name({variable, _}), do: variable
  end

  # Llamamos a la función principal para ejecutar el programa
  SATSolverSequential.main()
