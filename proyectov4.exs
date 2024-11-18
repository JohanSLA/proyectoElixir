defmodule SATSolver do
  def main() do
    "uf20-01.cnf"
    |>leer_cnf() #LLama al metodo para leer archivos cnf
    |> solve()
  end

  defp leer_cnf(nombre_archivo) do
    File.read!(nombre_archivo)
    |> String.split("\n") # Divide el contenido en líneas
    |> Enum.filter(&filtrar_lineas_validas/1) # Filtra solo las líneas que contienen cláusulas
    |> Enum.map(&extraer_clausula/1) # Convierte cada línea de cláusula en una lista de enteros
  end

  defp filtrar_lineas_validas(linea) do
    # Ignora líneas de comentarios, encabezado y cualquier línea de porcentaje o vacía
    not (String.starts_with?(linea, "c") or
         String.starts_with?(linea, "p") or
         linea == "%" or
         linea == "" or
         linea == "0")
  end

  defp extraer_clausula(linea) do
    # Convierte cada número de la línea en un entero y elimina el 0 al final de la cláusula
    linea
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reject(&(&1 == 0)) # Remover el 0 que marca el fin de la cláusula
  end

  #--------------------------------------------------------------------------------------------------------

  # Resolver la CNF utilizando DPLL y mostrar si es satisfactible y sus soluciones en 0 y 1
  def solve(clausulas) do

    solutions = dpll(clausulas, [])

    if solutions == [] do
      IO.puts("Insatisfactible")
    else
      IO.puts("Satisfactible")

      solutions
      |> Enum.with_index()
      |> Enum.each(fn {sol, idx} ->
        binary_solution = format_as_binary(sol)
        IO.puts("#{inspect(binary_solution)}")
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

SATSolver.main()
