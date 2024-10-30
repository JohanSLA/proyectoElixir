defmodule SATSolver do
  @clauses [
    [4, -18, 19], [3, 18, -5], [-5, -8, -15], [-20, 7, -16], [10, -13, -7],
    [-12, -9, 17], [17, 19, 5], [-16, 9, 15], [11, -5, -14], [18, -10, 13],
    [-3, 11, 12], [-6, -17, -8], [-18, 14, 1], [-19, -15, 10], [12, 18, -19],
    [-8, 4, 7], [-8, -9, 4], [7, 17, -15], [12, -7, -14], [-10, -11, 8],
    [2, -15, -11], [9, 6, 1], [-11, 20, -17], [9, -15, 13], [12, -7, -17],
    [-18, -2, 20], [20, 12, 4], [19, 11, 14], [-16, 18, -4], [-1, -17, -19],
    [-13, 15, 10], [-12, -14, -13], [12, -14, -7], [-7, 16, 10], [6, 10, 7],
    [20, 14, -16], [-19, 17, 11], [-7, 1, -20], [-5, 12, 15], [-4, -9, -13],
    [12, -11, -7], [-5, 19, -8], [1, 16, 17], [20, -14, -15], [13, -4, 10],
    [14, 7, 10], [-5, 9, 20], [10, 1, -19], [-16, -15, -1], [16, 3, -11],
    [-15, -10, 4], [4, -15, -3], [-10, -16, 11], [-8, 12, -5], [14, -6, 12],
    [1, 6, 11], [-13, -5, -1], [-7, -2, 12], [1, -20, 19], [-2, -13, -8],
    [15, 18, 4], [-11, 14, 9], [-6, -15, -2], [5, -12, -15], [-6, 17, 5],
    [-13, 5, -19], [20, -1, 14], [9, -17, 15], [-5, 19, -18], [-12, 8, -10],
    [-18, 14, -4], [15, -9, 13], [9, -5, -1], [10, -19, -14], [20, 9, 4],
    [-9, -2, 19], [-5, 13, -17], [2, -10, -18], [-18, 3, 11], [7, -9, 17],
    [-15, -6, -3], [-2, 3, -13], [12, 3, -2], [-2, -3, 17], [20, -15, -16],
    [-5, -17, -19], [-20, -18, 11], [-9, 1, -5], [-19, 9, 17], [12, -2, 17],
    [4, -16, -5]
  ]

  # Resolver la CNF utilizando DPLL y mostrar si es satisfactible y sus soluciones en 0 y 1
  def solve do
    solutions = dpll(@clauses, [])

    if solutions == [] do
      IO.puts("Insatisfactible")
    else
      IO.puts("Satisfactible")

      solutions
      |> Enum.with_index()
      |> Enum.each(fn {sol, idx} ->
        binary_solution = format_as_binary(sol)
        IO.puts("Solución #{idx + 1}: #{inspect(binary_solution)}")
      end)
    end
  end

  # Implementación del algoritmo DPLL
  defp dpll(clauses, assignment) do
    cond do
      # Si todas las cláusulas están satisfechas, devolver la asignación
      Enum.all?(clauses, &clause_satisfied?(&1, assignment)) ->
        [assignment]

      # Si alguna cláusula está vacía (insatisfactible), no hay solución
      Enum.any?(clauses, &(&1 == [])) ->
        []

      true ->
        # Seleccionar la primera variable no asignada
        variable = select_variable(clauses, assignment)

        # Intentar asignar true o false a la variable y hacer recursión
        dpll(simplify(clauses, variable), [variable | assignment]) ++
        dpll(simplify(clauses, -variable), [-variable | assignment])
    end
  end

  # Simplificar las cláusulas al asignar una variable
  defp simplify(clauses, variable) do
    Enum.reduce(clauses, [], fn clause, acc ->
      cond do
        variable in clause -> acc  # Clausula satisfecha
        -variable in clause -> [List.delete(clause, -variable) | acc]  # Remover la negación
        true -> [clause | acc]  # Añadir la cláusula sin cambios
      end
    end)
  end

  # Verificar si una cláusula está satisfecha
  defp clause_satisfied?(clause, assignment) do
    Enum.any?(clause, &(&1 in assignment))
  end

  # Seleccionar la próxima variable a asignar (heurística básica)
  defp select_variable(clauses, assignment) do
    clauses
    |> Enum.flat_map(& &1)
    |> Enum.uniq()
    |> Enum.find(&(&1 not in assignment and -&1 not in assignment))
  end

  # Convertir la asignación a formato binario (0 y 1)
  defp format_as_binary(solution) do
    for i <- 1..20 do
      if i in solution, do: 1, else: 0
    end
  end
end

SATSolver.solve()
