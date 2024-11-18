defmodule DistributedSATSolver do
  def main() do
    # Nombre del archivo CNF a resolver
    "uf20-02.cnf"
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
    # Obtener nodos conectados
    nodes = Node.list()

    # Comenzar el proceso distribuido de DPLL
    solutions = distributed_dpll(clausulas, [], nodes)

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

  # Implementación distribuida del algoritmo DPLL
  defp distributed_dpll(clauses, assignment, nodes) do
    cond do
      Enum.all?(clauses, &clause_satisfied?(&1, assignment)) ->
        [assignment]

      Enum.any?(clauses, &(&1 == [])) ->
        []

      true ->
        variable = select_variable(clauses, assignment)

        # Dividir el trabajo entre nodos
        task_true = spawn_task(nodes, clauses, variable, [variable | assignment])
        task_false = spawn_task(nodes, clauses, -variable, [-variable | assignment])

        # Esperar a los resultados de las tareas en nodos remotos
        Task.await(task_true, :infinity) ++ Task.await(task_false, :infinity)
    end
  end

  # Función para crear y enviar una tarea a un nodo remoto
  defp spawn_task(nodes, clauses, variable, assignment) do
    node = Enum.random(nodes) # Seleccionar un nodo aleatorio
    Task.async({node, __MODULE__}, :distributed_dpll, [simplify(clauses, variable), assignment, nodes])
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

DistributedSATSolver.main()
