defmodule ParallelSATSolver do
  def main() do
    "uf20-01.cnf"
    |> leer_cnf()
    |> solve()
  end

  defp leer_cnf(nombre_archivo) do
    File.read!(nombre_archivo)
    |> String.split("\n")
    |> Enum.filter(&filtrar_lineas_validas/1)
    |> Enum.map(&extraer_clausula/1)
  end

  defp filtrar_lineas_validas(linea) do
    not (String.starts_with?(linea, "c") or
         String.starts_with?(linea, "p") or
         linea == "%" or
         linea == "" or
         linea == "0")
  end

  defp extraer_clausula(linea) do
    linea
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reject(&(&1 == 0))
  end

  def solve(clausulas) do
    solutions = parallel_dpll(clausulas, [])

    if solutions == [] do
      IO.puts("Insatisfactible")
    else
      IO.puts("Satisfactible")

      solutions
      |> Enum.each(fn sol ->
        binary_solution = format_as_binary(sol)
        IO.puts("#{inspect(binary_solution)}")
      end)
    end
  end

  # Implementación paralela del algoritmo DPLL
  defp parallel_dpll(clauses, assignment) do
    cond do
      Enum.all?(clauses, &clause_satisfied?(&1, assignment)) ->
        [assignment]

      Enum.any?(clauses, &(&1 == [])) ->
        []

      true ->
        variable = select_variable(clauses, assignment)

        # Crear tareas concurrentes para ambas asignaciones
        task_true = Task.async(fn ->
          parallel_dpll(simplify(clauses, variable), [variable | assignment])
        end)

        task_false = Task.async(fn ->
          parallel_dpll(simplify(clauses, -variable), [-variable | assignment])
        end)

        # Esperar a que ambas tareas terminen y combinar sus resultados
        Task.await(task_true, :infinity) ++ Task.await(task_false, :infinity)
    end
  end

  defp simplify(clauses, variable) do
    Enum.reduce(clauses, [], fn clause, acc ->
      cond do
        variable in clause -> acc
        -variable in clause -> [List.delete(clause, -variable) | acc]
        true -> [clause | acc]
      end
    end)
  end

  defp clause_satisfied?(clause, assignment) do
    Enum.any?(clause, &(&1 in assignment))
  end

  defp select_variable(clauses, assignment) do
    clauses
    |> Enum.flat_map(& &1)
    |> Enum.uniq()
    |> Enum.find(&(&1 not in assignment and -&1 not in assignment))
  end

  defp format_as_binary(solution) do
    for i <- 1..20 do
      if i in solution, do: 1, else: 0
    end
  end
end

ParallelSATSolver.main()
